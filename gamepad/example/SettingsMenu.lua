local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)
local Gamepad = require(Modules.Gamepad)

local VerticalButtonList = require(script.Parent.VerticalButtonList)
local SettingsPageGameplay = require(script.Parent.SettingsPageGameplay)
local SettingsPageDisplay = require(script.Parent.SettingsPageDisplay)
local SettingsPageAudio = require(script.Parent.SettingsPageAudio)
local Rooter = require(script.Parent.Rooter)

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
	self.group = Gamepad.createSelectionGroup(false)
	self.group:setDefault(self.group.childRefs.categoryList)

	self.state = {
		selectedIndex = 1,
	}
end

function SettingsMenu:render()
	local pageComponent = settingsCategories[self.state.selectedIndex].page

	return e("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
	}, {
		Rooter = e(Rooter, {
			rooted = self.group:getGroupSelectedCallback(),
		}),
		NavigationFrame = e("Frame", {
			Size = UDim2.new(0, 200, 1, 0),
			BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
		}, {
			NavButtons = e(VerticalButtonList, {
				buttons = settingsCategories,
				persist = true,

				selectionRight = self.group.childRefs.page,

				[Roact.Ref] = self.group.childRefs.categoryList,
				onButtonSelected = function(index)
					self:setState{
						selectedIndex = index,
					}
				end,
				-- onButtonActivated = function(index)
				-- 	self.group:selectChild(self.group.childRefs.page)
				-- end
			}),
		}),
		PageContainer = e("Frame", {
			Size = UDim2.new(1, -200, 1, 0),
			Position = UDim2.new(0, 200, 0, 0),
			BackgroundTransparency = 1,
		}, {
			Page = pageComponent ~= nil and e(pageComponent, {
				navigation = self.group.childRefs.categoryList,

				[Roact.Ref] = self.group.childRefs.page,
			}),
		})
	})
end

function SettingsMenu:willUnmount()
	self.group:destruct()
end

return SettingsMenu