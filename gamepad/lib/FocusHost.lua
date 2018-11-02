local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local ContextActionService = game:GetService("ContextActionService")

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

local function isPersistedSelectionValid(instance)
	if typeof(instance) ~= "Instance" then
		return false
	end

	return instance:IsDescendantOf(game)
end

local FocusHost = {}
FocusHost.__index = FocusHost
FocusHost.__tostring = function(self)
	local navRulesString = "{ "
	for navRuleId, _ in pairs(self.navRules) do
		navRulesString = navRulesString .. tostring(navRuleId) .. ", "
	end
	navRulesString = navRulesString .. " }"

	local onFocus = self.persists and self.persistedSelection or self.defaultSelection

	return ("FocusHost(\n\tid: %s,\n\thost: %s,\n\tonFocus: %s,\n\tnavRules: %s\n)"):format(
		self.id,
		tostring(self.host),
		tostring(onFocus),
		navRulesString
	)
end

function FocusHost.new(host)
	return setmetatable({
		id = HttpService:GenerateGUID(false),
		host = host,

		persist = false,
		defaultSelection = nil,
		persistedSelection = nil,
		navRules = {},
	}, FocusHost)
end

-- TODO: Support builder pattern interface with these?
function FocusHost:setDefault(default)
	self.defaultSelection = default
end

function FocusHost:setPersist(persist)
	self.persist = persist
end

--[[
	More ergonomic wrapper around context action service.

	Actions are bound and unbound as the focusHost gains and loses focus
]]
function FocusHost:setNavRule(id, callback, ...)
	if callback == nil then
		-- clear the rule
		self.navRules[id] = nil

		return
	end

	local buttons = {...}

	local function bind()
		ContextActionService:BindAction(id, callback, false, unpack(buttons))
	end

	local function unbind()
		ContextActionService:UnbindAction(id)
	end

	self.navRules[id] = {
		bind = bind,
		unbind = unbind,
	}
end

function FocusHost:removeFocus()
	-- Persistence has no choice but to operate on actual Instances,
	-- since we don't really have a way to roll it back into a ref
	if self.persist then
		self.persistedSelection = GuiService.SelectedObject
	end

	GuiService:RemoveSelectionGroup(self.id, self.host.current)

	for _, navRule in pairs(self.navRules) do
		navRule.unbind()
	end
end

function FocusHost:giveFocus()
	GuiService:AddSelectionParent(self.id, self.host.current)
	if self.persist and isPersistedSelectionValid(self.persistedSelection) then
		GuiService.SelectedObject = self.persistedSelection
	else
		GuiService.SelectedObject = self.defaultSelection.current
	end


	for _, navRule in pairs(self.navRules) do
		navRule.bind()
	end
end

return FocusHost