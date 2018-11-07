local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)
local Gamepad = require(Modules.Gamepad)

local RootFrame = require(script.Parent.RootFrame)
local ViewPager = require(script.Parent.ViewPager)

local e = Roact.createElement

local SettingsMenu = Roact.Component:extend("SettingsMenu")

function SettingsMenu:init()
	self.navigationController = Gamepad.createNavigationController()
	self._context["Navigation"] = self.navigationController

	self.navRef = Roact.createRef()
end

function SettingsMenu:render()

	return e(RootFrame, {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),

		rooted = function()
			self.navigationController:navigateTo(self.navRef)
		end,
	}, {
		ViewPager = e(ViewPager, {
			[Roact.Ref] = self.navRef,
		})
	})
end

return SettingsMenu