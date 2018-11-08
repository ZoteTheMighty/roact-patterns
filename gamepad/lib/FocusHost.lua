local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local ContextActionService = game:GetService("ContextActionService")

local Symbol = require(script.Parent.Symbol)

--[[
	Features to implement:
	* support multiple sets of nav rules
		* in other words, allow a parent to have special navigation rules active
			even when child group has focus
		* there are a number of ways to go about this. Maybe add method to inherit
			parent nav rules?
	* Support selection tuple in addition to selection parent
	* Focus redirection, or allow FocusHosts with other FocusHosts as children

	Misc TODO:
	* Reconsider the naming of various pieces of this component
]]

-- Used to access a set of fields that are internal to FocusHost
local InternalData = Symbol.named("InternalData")

--[[
	Selection persistence is in terms of actual Instances,
	because there's not really a way to find an associated
	ref object for an instance when saving persisted selection
]]
local function isPersistedSelectionValid(instance)
	if typeof(instance) ~= "Instance" then
		return false
	end

	return instance:IsDescendantOf(game)
end

local function findDefaultSelection(host)
	if host.current ~= nil then
		for _, object in ipairs(host.current:GetChildren()) do
			if object:IsA("GuiObject") then
				return object
			end
		end
	end
end

local FocusHostPrototype = {}
FocusHostPrototype.__index = FocusHostPrototype
FocusHostPrototype.__tostring = function(self)
	local internalData = self[InternalData]

	local navRulesString = "{ "
	for navRuleId, _ in pairs(internalData.navRules) do
		navRulesString = navRulesString .. tostring(navRuleId) .. ", "
	end
	navRulesString = navRulesString .. " }"

	local onFocus = internalData.persists and internalData.persistedSelection or internalData.defaultSelection

	return ("FocusHost(\n\tid: %s,\n\thost: %s,\n\tonFocus: %s,\n\tnavRules: %s\n)"):format(
		internalData.id,
		tostring(internalData.host),
		tostring(onFocus),
		navRulesString
	)
end

function FocusHostPrototype:setDefault(default)
	self[InternalData].defaultSelection = default

	return self
end

function FocusHostPrototype:setPersist(persist)
	self[InternalData].persist = persist

	return self
end

--[[
	More ergonomic wrapper around context action service.

	Actions are bound and unbound as the focusHost gains and loses focus
]]
function FocusHostPrototype:setNavRule(id, callback, ...)
	local navRuleId = ("%s.%s"):format(self[InternalData].id, id)

	if callback == nil then
		-- clear the rule
		self[InternalData].navRules[navRuleId] = nil

		return self
	end

	local buttons = {...}

	local function bind()
		-- TODO: We may need to abstract this so that RobloxScripts can use 'BindCoreAction'
		ContextActionService:BindAction(navRuleId, callback, false, unpack(buttons))
	end

	local function unbind()
		ContextActionService:UnbindAction(navRuleId)
	end

	self[InternalData].navRules[navRuleId] = {
		bind = bind,
		unbind = unbind,
	}

	return self
end

local FocusHost = {}

-- TODO: Should we let this be created by the user and passed to the navigation controller?
function FocusHost.create(host)
	assert(typeof(host) == "table", "Bad arg #1: host must be a Roact ref")

	return setmetatable({
		[InternalData] = {
			id = HttpService:GenerateGUID(false),
			host = host,

			defaultSelection = nil,
			persist = false,
			persistedSelection = nil,
			navRules = {},
		}
	}, FocusHostPrototype)
end

function FocusHost.removeFocus(focusHost)
	local internalData = focusHost[InternalData]

	if internalData.persist then
		internalData.persistedSelection = GuiService.SelectedObject
	end

	GuiService:RemoveSelectionGroup(internalData.id, internalData.host.current)

	for _, navRule in pairs(internalData.navRules) do
		navRule.unbind()
	end
end

function FocusHost.giveFocus(focusHost)
	local internalData = focusHost[InternalData]

	GuiService:AddSelectionParent(internalData.id, internalData.host.current)

	if internalData.persist and isPersistedSelectionValid(internalData.persistedSelection) then
		GuiService.SelectedObject = internalData.persistedSelection
	elseif internalData.defaultSelection ~= nil then
		GuiService.SelectedObject = internalData.defaultSelection.current
	else
		local default = findDefaultSelection(internalData.host)
		if default ~= nil then
			warn("Using sub-optimal default selection logic")
			GuiService.SelectedObject = default
		else
			warn("No default selection exists, and none could be found")
		end
	end

	for _, navRule in pairs(internalData.navRules) do
		navRule.bind()
	end
end

function FocusHost.getHostRef(focusHost)
	return focusHost[InternalData].host
end

return FocusHost