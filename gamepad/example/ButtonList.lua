local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)
local Gamepad = require(Modules.Gamepad)

local SelectableButton = require(script.Parent.SelectableButton)

local ButtonList = Roact.Component:extend("ButtonList")

function ButtonList:init()
	local persist = self.props.persist

	self.group = Gamepad.createSelectionGroup(persist)
	self.group:setDefault(self.group.childRefs[1])
end

function ButtonList:render()
	local buttons = self.props.buttons
	local selectionUp = self.props.selectionUp
	local selectionDown = self.props.selectionDown

	local children = {}

	children.Layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Horizontal,
	})

	for index, button in ipairs(buttons) do
		-- 1-based indexing makes math gross
		local previousSibling = ((index - 2) % #buttons) + 1
		local nextSibling = (index % #buttons) + 1

		children[index] = Roact.createElement(SelectableButton, {
			selectionId = index,
			style = {
				Text = button.text,
				LayoutOrder = index,
				-- If either of these are nil, SelectableButton will make them loop back
				NextSelectionUp = selectionUp,
				NextSelectionDown = selectionDown,

				-- Inverted from expectations, to help us confirm that its not just default selection logic
				NextSelectionLeft = self.group.childRefs[previousSibling],
				NextSelectionRight = self.group.childRefs[nextSibling],

				[Roact.Ref] = self.group.childRefs[index],
			},
			selectedStyle = {
				BackgroundColor3 = Color3.new(1, 0, 0),
			},
		})
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,

		[Roact.Ref] = self.props[Roact.Ref],
		[Roact.Event.SelectionGained] = self.group:getGroupSelectedCallback()
	}, children)
end

function ButtonList:willUnmount()
	self.group:destruct()
end

return ButtonList