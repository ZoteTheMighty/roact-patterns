local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)

local SelectableButton = require(script.Parent.SelectableButton)
local FocusGroup = require(script.Parent.FocusGroup)

local createRefCache = require(script.Parent.createRefCache)

local function noop()
end

local ButtonList = Roact.Component:extend("ButtonList")

function ButtonList:init()
	self.ref = self.props[Roact.Ref] or Roact.createRef()

	self.childRefs = createRefCache()
end

function ButtonList:render()
	local buttons = self.props.buttons
	local selectionLeft = self.props.selectionLeft
	local selectionRight = self.props.selectionRight

	local additionalNavRules = self.props.additionalNavRules

	local onButtonActivated = self.props.onButtonActivated or noop
	local onButtonSelected = self.props.onButtonSelected or noop

	local children = {
		["$Layout"] = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
		["$FocusGroup"] = Roact.createElement(FocusGroup, {
			host = self.ref,
			default = self.childRefs[1],
			persist = true,
			navRules = additionalNavRules,
		}),
	}

	for index, button in ipairs(buttons) do
		-- 1-based indexing makes math gross
		local previousSibling = ((index - 2) % #buttons) + 1
		local nextSibling = (index % #buttons) + 1

		local buttonId = ("%s_%s"):format(index, button.text)

		children[buttonId] = Roact.createElement(SelectableButton, {
			onSelectionGained = function()
				onButtonSelected(index)
			end,
			style = {
				Text = button.text,
				LayoutOrder = index,

				NextSelectionLeft = selectionLeft,
				NextSelectionRight = selectionRight,

				NextSelectionUp = self.childRefs[previousSibling],
				NextSelectionDown = self.childRefs[nextSibling],

				[Roact.Ref] = self.childRefs[index],
				[Roact.Event.Activated] = function()
					onButtonActivated(index)
				end,
			},
			selectedStyle = {
				BackgroundColor3 = Color3.new(1, 0, 0),
			},
		})
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,

		[Roact.Ref] = self.ref,
	}, children)
end

return ButtonList