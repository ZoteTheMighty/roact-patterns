local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")

local FocusHost = {}
FocusHost.__index = FocusHost
FocusHost.__tostring = function(self)
	local navRulesString = "{ "
	for id, _ in pairs(self.navRules) do
		navRulesString = navRulesString .. tostring(id) .. ", "
	end
	navRulesString = navRulesString .. " }"

	return ("FocusHost(host: %s, default: %s, navRules: %s)"):format(
		self.id,
		tostring(self.host),
		tostring(self.default),
		navRulesString
	)
end

function FocusHost.new(id, host)
	return setmetatable({
		id = id,
		host = host,

		defaultSelection = nil,
		navRules = {},
	}, FocusHost)
end

function FocusHost:setDefault(default)
	self.defaultSelection = default
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
	GuiService:RemoveSelectionGroup(self.id, self.host.current)

	for _, navRule in pairs(self.navRules) do
		navRule.unbind()
	end

	print("Unfocusing", tostring(self))
end

function FocusHost:giveFocus()
	GuiService:AddSelectionParent(self.id, self.host.current)
	GuiService.SelectedObject = self.defaultSelection.current

	for _, navRule in pairs(self.navRules) do
		navRule.bind()
	end

	print("Focusing", tostring(self))
end

return FocusHost