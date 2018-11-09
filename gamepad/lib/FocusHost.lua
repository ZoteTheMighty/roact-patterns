local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local ContextActionService = game:GetService("ContextActionService")

local Symbol = require(script.Parent.Symbol)

--[[
	Features to implement:
	* support multiple sets of nav rules
		* there are a number of ways to go about this. Maybe add method to inherit
			parent nav rules?
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

--[[
	THIS IS BAD AND SHOULD PROBABLY BE DITCHED
]]
local function findDefaultSelection(host)
	if host.current ~= nil then
		for _, object in ipairs(host.current:GetChildren()) do
			if object:IsA("GuiObject") and object.Selectable then
				return object
			end
		end
	end
end

local function unwrapRefList(refList)
	local result = {}

	for _, ref in pairs(refList) do
		result[#result + 1] = ref.current
	end

	return unpack(result)
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

	return ("FocusHost(\n\tid: %s,\n\thost: %s,\n\tlastSelected: %s,\n\tnavRules: %s\n)"):format(
		internalData.id,
		tostring(internalData.host),
		tostring(internalData.lastSelected),
		navRulesString
	)
end

--[[
	Sets a selection rule that is used to determine what item to select
	when the FocusHost gains focus. This is expected to be a function with
	the following signature:

		function selectionRule(lastSelected: Instance) -> Instance
]]
function FocusHostPrototype:setSelectionRule(selectionRule)
	self[InternalData].selectionRule = selectionRule

	return self
end

--[[
	More ergonomic wrapper around context action service. Actions are
	bound and unbound as the focusHost gains and loses focus.
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

function FocusHost.create(host, selectionChildren)
	assert(typeof(host) == "table", "Bad arg #1: host must be a Roact ref")
	assert(selectionChildren == nil or typeof(selectionChildren) == "table",
		"Bad arg #2: optional arg selectionChildren must be a table of refs")

	return setmetatable({
		[InternalData] = {
			id = HttpService:GenerateGUID(false),
			host = host,
			selectionChildren = selectionChildren,

			selectionRule = nil,
			lastSelected = nil,
			navRules = {},
		}
	}, FocusHostPrototype)
end

function FocusHost.removeFocus(focusHost)
	local internalData = focusHost[InternalData]

	if internalData.selectionRule ~= nil then
		internalData.lastSelected = GuiService.SelectedObject
	end

	GuiService:RemoveSelectionGroup(internalData.id, internalData.host.current)

	for _, navRule in pairs(internalData.navRules) do
		navRule.unbind()
	end
end

function FocusHost.giveFocus(focusHost)
	local internalData = focusHost[InternalData]

	if internalData.selectionChildren == nil then
		GuiService:AddSelectionParent(internalData.id, internalData.host.current)
	else
		GuiService:AddSelectionTuple(internalData.id, unwrapRefList(internalData.selectionChildren))
	end

	local persistedSelection = nil
	if internalData.selectionRule ~= nil then
		persistedSelection = internalData.selectionRule(internalData.lastSelected)
	end

	if isPersistedSelectionValid(persistedSelection) then
		GuiService.SelectedObject = persistedSelection
	else
		local default = findDefaultSelection(internalData.host)
		if default ~= nil then
			GuiService.SelectedObject = default
		else
			warn(("No default selection exists for host %s, and none could be found"):format(internalData.host))
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