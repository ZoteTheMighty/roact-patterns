local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)
local Gamepad = require(Modules.Gamepad)

local SelectableButton = require(script.Parent.SelectableButton)
local FocusGroup = require(script.Parent.FocusGroup)

local assign = require(script.Parent.assign)
local createRefCache = require(script.Parent.createRefCache)

local e = Roact.createElement

local ViewPager = Roact.Component:extend("")

function ViewPager:init()
	local pages = self.props.pages

	self.navRef = self.props[Roact.Ref] or Roact.createRef()
	self.pageRef = Roact.createRef()

	self.navController = self._context[Gamepad]
	self.navSelectionTuple = createRefCache()

	self.selectionRule = function(lastSelected)
		return self.navSelectionTuple[self.state.currentIndex].current
	end
	self.navRules = {
		[Enum.KeyCode.ButtonL1] = function(action, inputState)
			if inputState == Enum.UserInputState.Begin then
				local target = (self.state.currentIndex - 1 < 1) and #pages or self.state.currentIndex - 1
				self:setState({
					currentIndex = target
				})
				self.navController:navigateTo(self.pageRef)
			end
		end,
		[Enum.KeyCode.ButtonR1] = function(action, inputState)
			if inputState == Enum.UserInputState.Begin then
				local target = (self.state.currentIndex + 1 > #pages) and 1 or self.state.currentIndex + 1
				self:setState({
					currentIndex = target
				})
				self.navController:navigateTo(self.pageRef)
			end
		end,
	}

	self:setState({
		currentIndex = 1,
	})
end

function ViewPager:render()
	local pages = self.props.pages
	local renderPage = self.props.renderPage

	local currentIndex = self.state.currentIndex

	local navChildren = {
		["$FocusGroup"] = e(FocusGroup, {
			host = self.navRef,
			navRules = self.navRules,
			selectionChildren = self.navSelectionTuple,
			selectionRule = self.selectionRule,
		}),
		["$Layout"] = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	for index, page in ipairs(pages) do
		local backgroundColor = currentIndex == index and Color3.new(1, 0, 0) or Color3.new(0, 0, 0)
		navChildren[index] = e(SelectableButton, {
			onSelectionGained = function()
				self:setState({
					currentIndex = index,
				})
			end,
			style = {
				Text = page, -- TODO: need more than just string, probably
				LayoutOrder = index,
				BackgroundColor3 = backgroundColor,

				[Roact.Ref] = self.navSelectionTuple[index],
				[Roact.Event.Activated] = function()
					self.navController:navigateTo(self.pageRef)
				end
			},
		})
	end

	return e("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		NavigationFrame = e("Frame", {
			Size = UDim2.new(1, 0, 100, 0),
			BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),

			[Roact.Ref] = self.navRef,
		}, navChildren),
		PageContainer = e("Frame", {
			Size = UDim2.new(1, 0, 1, -100),
			Position = UDim2.new(0, 0, 0, 100),
			BackgroundTransparency = 1,
		}, {
			[tostring(pages[currentIndex])] = renderPage(pages[currentIndex], {
				[Roact.Ref] = self.pageRef,

				navRules = assign({
					-- Back button navigation rule
					[Enum.KeyCode.ButtonB] = function()
						self.navController:navigateTo(self.navRef)
					end,
				}, self.navRules),
			}),
		})
	})
end

return ViewPager