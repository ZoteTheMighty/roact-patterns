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

	local selectionRule = self.props.selectionRule
	local contextActions = self.props.contextActions

	self.focusHost = Gamepad.createFocusHost(host, selectionChildren)

	self.focusHost:setSelectionRule(selectionRule)
	for button, handler in pairs(contextActions) do
		self.focusHost:setContextAction(tostring(button), handler, button)
	end

	self.nav:mountFocusHost(self.focusHost)
end

function FocusGroup:willUnmount()
	self.nav:unmountFocusHost(self.focusHost)
end

return FocusGroup