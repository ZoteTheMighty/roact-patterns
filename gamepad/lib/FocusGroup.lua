local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)

local FocusGroup = Roact.Component:extend("FocusGroup")

function FocusGroup:render()
	return nil
end

function FocusGroup:didMount()
	local host = self.props.host
	local configureFocus = self.props.configureFocus

	local nav = self._context["Navigation"]
	local focusHost = nav:mountFocusHost(host)

	if configureFocus ~= nil then
		configureFocus(focusHost)
	end
end

function FocusGroup:willUnmount()
	local host = self.props.host

	local nav = self._context["Navigation"]

	nav:unmountFocusHost(host)
end

return FocusGroup