local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)
local Gamepad = require(Modules.Gamepad)

local ButtonList = require(script.ButtonList)
local Rooter = require(script.Rooter)

local e = Roact.createElement

local topButtons = {
	{
		text = "Spooky",
	},
	{
		text = "Scary",
	},
	{
		text = "Skeletons",
	},
}

local bottomButtons = {
	{
		text = "Hey",
	},
	{
		text = "Boo",
	},
}

local TabNavigation = Roact.Component:extend("TabNavigation")

function TabNavigation:init()
	self.group = Gamepad.createSelectionGroup(false)
	self.group:setDefault(self.group.childRefs.top)
end

function TabNavigation:render()
	return e("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
	}, {
		Rooter = e(Rooter, {
			rooted = self.group:getGroupSelectedCallback(),
		}),
		NavigationFrame = e("Frame", {
			Size = UDim2.new(1, 0, 0, 60),
			BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
		}, {
			NavButtons = e(ButtonList, {
				buttons = topButtons,
				persist = true,

				[Roact.Ref] = self.group.childRefs.top,
				selectionDown = self.group.childRefs.bottom,
			}),
		}),
		BodyFrame = e("Frame", {
			Size = UDim2.new(1, 0, 1, -60),
			Position = UDim2.new(0, 0, 0, 60),
			BackgroundColor3 = Color3.new(0.3, 0.3, 0.3),
		}, {
			BodyButtons = e(ButtonList, {
				buttons = bottomButtons,
				persist = false,

				[Roact.Ref] = self.group.childRefs.bottom,
				selectionUp = self.group.childRefs.top,
			}),
		})
	})
end

function TabNavigation:willUnmount()
	self.group:destruct()
end

local function App(props)
	return e("ScreenGui", nil, {
		Nav = e(TabNavigation),
	})
end

Roact.mount(Roact.createElement(App), Players.LocalPlayer:WaitForChild("PlayerGui"), "Gamepad")