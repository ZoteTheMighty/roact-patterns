local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)
local Gamepad = require(Modules.Gamepad)

local SelectableButton = require(script.Parent.SelectableButton)

-- This is a handy trick to allow us to reference refs before we've actually
-- rendered anything, and without duplicating rendering logic!
local function createRefCache()
	local refCache = {}

	setmetatable(refCache, {
		__index = function(_, key)
			local newRef = Roact.createRef()
			refCache[key] = newRef

			return newRef
		end,
	})

	return refCache
end

local function noop()
end

local ButtonList = Roact.Component:extend("ButtonList")

function ButtonList:init()
	self.childRefs = createRefCache()
end

function ButtonList:render()
	local buttons = self.props.buttons
	local selectionLeft = self.props.selectionLeft
	local selectionRight = self.props.selectionRight

	local onButtonActivated = self.props.onButtonActivated or noop
	local onButtonSelected = self.props.onButtonSelected or noop
	local onBack = self.props.onBack

	local children = {}

	children.Layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	})

	children.FocusGroup = Roact.createElement(Gamepad.FocusGroup, {
		host = self.props[Roact.Ref],
		configureFocus = function(focusHost)
			focusHost:setDefault(self.childRefs[1])
				:setPersist(true)
				:setNavRule("back", onBack, Enum.KeyCode.ButtonB)
		end
	})

	for index, button in ipairs(buttons) do
		-- 1-based indexing makes math gross
		local previousSibling = ((index - 2) % #buttons) + 1
		local nextSibling = (index % #buttons) + 1

		local buttonId = ("%s_%s"):format(index, button.text)

		children[buttonId] = Roact.createElement(SelectableButton, {
			selectionId = index,
			onSelectionGained = function()
				onButtonSelected(index)
			end,
			style = {
				Text = button.text,
				LayoutOrder = index,
				-- If either of these are nil, SelectableButton will make them loop back
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

		[Roact.Ref] = self.props[Roact.Ref],
	}, children)
end

return ButtonList