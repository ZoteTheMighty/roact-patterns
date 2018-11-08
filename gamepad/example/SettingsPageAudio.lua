local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)

local FocusGroup = require(script.Parent.FocusGroup)
local SelectableButton = require(script.Parent.SelectableButton)

local e = Roact.createElement

local SettingsPageAudio = Roact.Component:extend("SettingsPageAudio")

function SettingsPageAudio:init()
	self.volumeRef = Roact.createRef()
end

function SettingsPageAudio:render()
	local forwardRef = self.props[Roact.Ref]
	local navRules = self.props.navRules

	return e("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0.1, 0.2, 0.1),

		[Roact.Ref] = forwardRef,
	}, {
		FocusGroup = e(FocusGroup, {
			host = forwardRef,
			default = self.volumeRef,
			persist = true,

			navRules = navRules,
		}),
		VolumeOption = e(SelectableButton, {
			style = {
				Size = UDim2.new(0, 300, 0, 100),
				Position = UDim2.new(0.5, -150, 0, 0),
				Text = "Volume",

				[Roact.Ref] = self.volumeRef,
				[Roact.Event.Activated] = function()
					print("Changing volume settings!")
				end,
			}
		}),
		SubtitlesOption = e(SelectableButton, {
			style = {
				Size = UDim2.new(0, 300, 0, 100),
				Position = UDim2.new(0.5, -150, 0, 100),
				Text = "Subtitles",

				[Roact.Event.Activated] = function()
					print("Toggling subtitles!")
				end,
			}
		})
	})
end

return SettingsPageAudio