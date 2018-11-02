local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)
local Gamepad = require(Modules.Gamepad)

local VerticalButtonList = require(script.Parent.VerticalButtonList)
local SettingsPageGameplay = require(script.Parent.SettingsPageGameplay)
local SettingsPageDisplay = require(script.Parent.SettingsPageDisplay)
local SettingsPageAudio = require(script.Parent.SettingsPageAudio)
local RootFrame = require(script.Parent.RootFrame)

local e = Roact.createElement

local settingsCategories = {
	{
		text = "Gameplay",
		page = SettingsPageGameplay,
	},
	{
		text = "Display",
		page = SettingsPageDisplay,
	},
	{
		text = "Audio",
		page = SettingsPageAudio,
	},
}

local SettingsMenu = Roact.Component:extend("SettingsMenu")

function SettingsMenu:init()
	self.navigationController = Gamepad.createNavigationController()
	self._context["Navigation"] = self.navigationController

	self.categoriesRef = Roact.createRef()
	self.pageRef = Roact.createRef()

	self.state = {
		selectedIndex = 1,
	}
end

function SettingsMenu:render()
	local pageName = settingsCategories[self.state.selectedIndex].text
	local pageComponent = settingsCategories[self.state.selectedIndex].page

	return e(RootFrame, {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),

		rooted = function()
			self.navigationController:navigateTo("Categories")
		end,
	}, {
		NavigationFrame = e("Frame", {
			Size = UDim2.new(0, 200, 1, 0),
			BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
		}, {
			NavButtons = e(VerticalButtonList, {
				focusGroupId = "Categories",

				buttons = settingsCategories,

				[Roact.Ref] = self.categoriesRef,
				onButtonSelected = function(index)
					self:setState{
						selectedIndex = index,
					}
				end,
				onButtonActivated = function(index)
					self.navigationController:navigateTo("Page")
				end
			}),
		}),
		PageContainer = e("Frame", {
			Size = UDim2.new(1, -200, 1, 0),
			Position = UDim2.new(0, 200, 0, 0),
			BackgroundTransparency = 1,
		}, {
			[pageName] = pageComponent ~= nil and e(pageComponent, {
				focusGroupId = "Page",
				onBack = function()
					self.navigationController:navigateTo("Categories")
				end,

				[Roact.Ref] = self.pageRef,
			}),
		})
	})
end

return SettingsMenu