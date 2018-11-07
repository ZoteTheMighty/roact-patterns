local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)
local Gamepad = require(Modules.Gamepad)

local SelectableButton = require(script.Parent.SelectableButton)

local e = Roact.createElement

local ViewPager = Roact.Component:extend("")

function ViewPager:init()
	self.navRef = self.props[Roact.Ref] or Roact.createRef()
	self.pageRef = Roact.createRef()

	self.navController = self._context["Navigation"]

	self:setState({
		currentIndex = 1,
	})

	local pages = self.props.pages
	self.tabLeftNavRule = function()
		local target = (self.state.currentIndex - 1 < 1) and #pages or self.state.currentIndex - 1
		self:setState({
			currentIndex = target
		})
		self.navController:navigateTo(self.pageRef)
	end

	self.tabRightNavRule = function()
		local target = (self.state.currentIndex + 1 > #pages) and 1 or self.state.currentIndex + 1
		self:setState({
			currentIndex = target
		})
		self.navController:navigateTo(self.pageRef)
	end
end

function ViewPager:render()
	local pages = self.props.pages
	local renderPage = self.props.renderPage

	local currentIndex = self.state.currentIndex

	local navChildren = {
		["$FocusGroup"] = e(Gamepad.FocusGroup, {
			host = self.navRef,
			configureFocus = function(focusHost)
				focusHost:setNavRule("tabLeft", self.tabLeftNavRule, Enum.KeyCode.ButtonL1)
				focusHost:setNavRule("tabRight", self.tabRightNavRule, Enum.KeyCode.ButtonR1)
			end,
		}),
		["$Layout"] = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	local pageChildren = {
		-- ["$FocusGroup"] = e(Gamepad.FocusGroup, {
		-- 	host = self.pageRef,
		-- 	configureFocus = function(focusHost)
		-- 		focusHost:setNavRule("tabLeft", self.tabLeftNavRule, Enum.KeyCode.ButtonL1)
		-- 		focusHost:setNavRule("tabRight", self.tabRightNavRule, Enum.KeyCode.ButtonR1)
		-- 	end,
		-- })
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
				[Roact.Event.Activated] = function()
					self.navController:navigateTo(self.pageRef)
				end
			},
		})

		if index == currentIndex then
			pageChildren.CurrentPage = renderPage(page, self.pageRef)
		end
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
		}, pageChildren)
	})
end

return ViewPager