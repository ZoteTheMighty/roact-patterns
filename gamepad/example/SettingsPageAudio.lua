local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)
local VerticalButtonList = require(script.Parent.VerticalButtonList)

local e = Roact.createElement

local options = {
	{
		text = "Volume"
	},
	{
		text = "Subtitles"
	},
}

local function SettingsPageGameplay(props)
	return e("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0.1, 0.2, 0.1),
	}, {
		Buttons = e(VerticalButtonList, {
			-- TODO: Allow focus redirection so we can avoid this prop drilling
			focusGroupId = props.focusGroupId,
			buttons = options,

			-- FIXME: drilling :/
			onBack = props.onBack,

			[Roact.Ref] = props[Roact.Ref]
		})
	})
end

return SettingsPageGameplay