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
	local selectionChildren = self.props.selectionChildren

	local default = self.props.default
	local persist = self.props.persist
	local navRules = self.props.navRules

	self.focusHost = Gamepad.createFocusHost(host, selectionChildren)

	self.focusHost:setDefault(default)
	self.focusHost:setPersist(persist)

	for button, handler in pairs(navRules) do
		self.focusHost:setNavRule(tostring(button), handler, button)
	end

	self.nav:mountFocusHost(self.focusHost)
end

function FocusGroup:willUnmount()
	self.nav:unmountFocusHost(self.focusHost)
end

return FocusGroup