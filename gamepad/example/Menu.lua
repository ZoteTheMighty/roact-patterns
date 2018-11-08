local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)
local Gamepad = require(Modules.Gamepad)

local RootFrame = require(script.Parent.RootFrame)
local ViewPager = require(script.Parent.ViewPager)
local SettingsPageAudio = require(script.Parent.SettingsPageAudio)
local SettingsPageDisplay = require(script.Parent.SettingsPageDisplay)
local SettingsPageGameplay = require(script.Parent.SettingsPageGameplay)

local e = Roact.createElement

local SettingsMenu = Roact.Component:extend("SettingsMenu")

function SettingsMenu:init()
	self.navigationController = Gamepad.createNavigationController()
	self._context[Gamepad] = self.navigationController

	self.navRef = Roact.createRef()
end

--[[
	WHAT I LIKE about this modified approach:
		Focus Group is more like a real component
		Nav rules are specified more intuitively, easier to pass along

	WHAT I HATE about this modified approach:
		Selection ownership is still hard to define; that hasn't been fixed at all
		Forwarding refs remains awkward and opaque
		ViewPager relies on pages being focus groups (which maybe makes sense?) but has
			no way to enforce it
		Auto-default logic is scary and flaky and should die
]]

function SettingsMenu:render()

	return e(RootFrame, {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),

		rooted = function()
			self.navigationController:navigateTo(self.navRef)
		end,
	}, {
		ViewPager = e(ViewPager, {
			pages = {
				"Audio",
				"Display",
				"Gameplay",
			},
			renderPage = function(id, props)
				if id == "Audio" then
					return e(SettingsPageAudio, props)
				elseif id == "Display" then
					return e(SettingsPageDisplay, props)
				elseif id == "Gameplay" then
					return e(SettingsPageGameplay, props)
				end

				error("Unknown page id")
			end,

			[Roact.Ref] = self.navRef,
		})
	})
end

return SettingsMenu