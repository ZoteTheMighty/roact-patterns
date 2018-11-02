local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)

local FocusGroup = Roact.Component:extend("FocusGroup")

function FocusGroup:render()
	return nil
end

function FocusGroup:didMount()
	local id = self.props.id
	local host = self.props.host
	local onRegister = self.props.onRegister

	-- FIXME: SCARY CONTEXT
	local nav = self._context["Navigation"]

	local focusHost = nav:registerFocusHost(id, host)

	onRegister(focusHost)
end

function FocusGroup:willUnmount()
	local id = self.props.id

	-- FIXME: SCARY CONTEXT
	local nav = self._context["Navigation"]

	nav:deregisterFocusHost(id)
end

return FocusGroup