local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)
local Gamepad = require(Modules.Gamepad)

local SettingsPageAudio = require(script.Parent.SettingsPageAudio)
local SettingsPageDisplay = require(script.Parent.SettingsPageDisplay)
local SettingsPageGameplay = require(script.Parent.SettingsPageGameplay)

local SelectableButton = require(script.Parent.SelectableButton)

local e = Roact.createElement

local SAMPLE_PAGE_DATA = {
	{
		title = "Audio",
		render = function(index, visible)
			return visible and e(SettingsPageAudio)
		end,
	},
	{
		title = "Video",
		render = function(index, visible)
			return visible and e(SettingsPageDisplay)
		end,
	},
	{
		title = "Gameplay",
		render = function(index, visible)
			return visible and e(SettingsPageGameplay)
		end,
	},
}

local ViewPager = Roact.Component:extend("")

function ViewPager:init()
	self.navRef = self.props[Roact.Ref] or Roact.createRef()
	self.pageRef = Roact.createRef()

	self.navController = self._context["Navigation"]

	self:setState({
		currentIndex = 1,
	})

	local pages = self.props.pages or SAMPLE_PAGE_DATA
	self.tabLeftNavRule = function()
		local target = (self.state.currentIndex - 1 < 1) and #pages or self.state.currentIndex - 1
		self:setState({
			currentIndex = target
		})
	end

	self.tabRightNavRule = function()
		local target = (self.state.currentIndex + 1 > #pages) and 1 or self.state.currentIndex + 1
		self:setState({
			currentIndex = target
		})
	end
end

function ViewPager:render()
	local pages = self.props.pages or SAMPLE_PAGE_DATA

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
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	local pageChildren = {
		["$FocusGroup"] = e(Gamepad.FocusGroup, {
			host = self.pageRef,
			configureFocus = function(focusHost)
				print("Configure page")
			end,
		})
	}

	for index, page in ipairs(pages) do
		navChildren[index] = e(SelectableButton, {
			onSelectionGained = function()
				self:setState({
					currentIndex = index,
				})
			end,
			style = {
				Text = page.title,
				LayoutOrder = index,
				[Roact.Event.Activated] = function()
					self.navController:navigateTo(self.pageRef)
				end
			},
			selectedStyle = {
				BackgroundColor3 = Color3.new(1, 0, 0),
			},
		})

		pageChildren[index] = page.render(index, index == currentIndex, self.pageRef)
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
			Size = UDim2.new(1, -200, 1, 0),
			Position = UDim2.new(0, 200, 0, 0),
			BackgroundTransparency = 1,

			[Roact.Ref] = self.pageRef,
		}, pageChildren)
	})
end

return ViewPager