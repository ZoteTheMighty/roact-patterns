local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local ContextActionService = game:GetService("ContextActionService")

local Symbol = require(script.Parent.Symbol)

--[[
	Features to implement:
	* support multi-focus for nav rules
		* in other words, allow a parent to have special navigation rules active
			even when child group has focus
	* support focus redirection to avoid prop drilling

	Interface TODOs:
	* hide private members
	* hide give/remove focus from users (probably as static functions)
]]

-- Used to access a set of fields that are internal to FocusHost
local InternalData = Symbol.named("InternalData")

local function isPersistedSelectionValid(instance)
	if typeof(instance) ~= "Instance" then
		return false
	end

	return instance:IsDescendantOf(game)
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

-- TODO: Support builder pattern interface with these?
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
	-- TODO: Should we even support this?
	if callback == nil then
		-- clear the rule
		self[InternalData].navRules[id] = nil

		return
	end

	local buttons = {...}

	local function bind()
		ContextActionService:BindAction(id, callback, false, unpack(buttons))
	end

	local function unbind()
		ContextActionService:UnbindAction(id)
	end

	self[InternalData].navRules[id] = {
		bind = bind,
		unbind = unbind,
	}

	return self
end

local FocusHost = {}

function FocusHost.new(host)
	return setmetatable({
		[InternalData] = {
			id = HttpService:GenerateGUID(false),
			host = host,

			persist = false,
			defaultSelection = nil,
			persistedSelection = nil,
			navRules = {},
		}
	}, FocusHostPrototype)
end

function FocusHost.removeFocus(focusHost)
	local internalData = focusHost[InternalData]

	-- Persistence has no choice but to operate on actual Instances,
	-- since we don't really have a way to roll it back into a ref
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
	else
		GuiService.SelectedObject = internalData.defaultSelection.current
	end


	for _, navRule in pairs(internalData.navRules) do
		navRule.bind()
	end
end

return FocusHost