local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)

local FocusGroup = Roact.Component:extend("FocusGroup")

function FocusGroup:render()
	return nil
end

function FocusGroup:didMount()
	local id = self.props.id
	local focusRef = self.props.focusRef
	local defaultSelection = self.props.defaultSelection

	-- FIXME: SCARY CONTEXT
	local nav = self._context["Navigation"]

	nav:registerFocusGroup(id, focusRef, defaultSelection)
end

function FocusGroup:willUnmount()
	local id = self.props.id

	-- FIXME: SCARY CONTEXT
	local nav = self._context["Navigation"]

	nav:deregisterFocusGroup(id)
end

return FocusGroup