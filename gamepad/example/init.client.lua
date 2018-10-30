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
	self.topRef = Roact.createRef()
	self.bottomRef = Roact.createRef()

	self.group = Gamepad.createSelectionItem(self.topRef)
end

function TabNavigation:render()
	return e("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
	}, {
		Rooter = e(Rooter, {
			rooted = function()
				self.group:selectDefault()
			end,
		}),
		NavigationFrame = e("Frame", {
			Size = UDim2.new(1, 0, 0, 60),
			BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
		}, {
			NavButtons = e(ButtonList, {
				buttons = topButtons,

				[Roact.Ref] = self.topRef,
				selectionDown = self.bottomRef,
			}),
		}),
		BodyFrame = e("Frame", {
			Size = UDim2.new(1, 0, 1, -60),
			Position = UDim2.new(0, 0, 0, 60),
			BackgroundColor3 = Color3.new(0.3, 0.3, 0.3),
		}, {
			BodyButtons = e(ButtonList, {
				buttons = bottomButtons,

				[Roact.Ref] = self.bottomRef,
				selectionUp = self.topRef,
			}),
		})
	})
end

local function App(props)
	return e("ScreenGui", nil, {
		Nav = e(TabNavigation),
	})
end

Roact.mount(Roact.createElement(App), Players.LocalPlayer:WaitForChild("PlayerGui"), "Gamepad")