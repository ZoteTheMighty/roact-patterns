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
	local configureFocus = self.props.configureFocus

	local nav = self._context["Navigation"]

	local focusHost = nav:mountFocusHost(id, host)

	configureFocus(focusHost)
end

function FocusGroup:willUnmount()
	local id = self.props.id

	local nav = self._context["Navigation"]

	nav:unmountFocusHost(id)
end

return FocusGroup