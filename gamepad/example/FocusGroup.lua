local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)
local Gamepad = require(Modules.Gamepad)

local FocusGroup = Roact.Component:extend("FocusGroup")

function FocusGroup:init()
	self.nav = self._context[Gamepad]
end

function FocusGroup:render()
	return nil
end

function FocusGroup:didMount()
	local host = self.props.host
	local default = self.props.default
	local persist = self.props.persist

	local navRules = self.props.navRules

	local focusHost = self.nav:mountFocusHost(host)

	focusHost:setDefault(default)
	focusHost:setPersist(persist)

	for button, handler in pairs(navRules) do
		focusHost:setNavRule(tostring(button), handler, button)
	end
end

function FocusGroup:willUnmount()
	local host = self.props.host

	self.nav:unmountFocusHost(host)
end

return FocusGroup