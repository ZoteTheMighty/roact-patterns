local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)
local VerticalButtonList = require(script.Parent.VerticalButtonList)

local e = Roact.createElement

local options = {
	{
		text = "Resolution"
	},
	{
		text = "Quality"
	},
	{
		text = "Anti-Aliasing"
	},
	{
		text = "Depth of Field"
	},
	{
		text = "Motion Blur"
	},
}

local function SettingsPageGameplay(props)
	return e("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0.1, 0.2, 0.1),
	}, {
		Buttons = e(VerticalButtonList, {
			buttons = options,
			persist = true,

			[Roact.Ref] = props[Roact.Ref]
		})
	})
end

return SettingsPageGameplay