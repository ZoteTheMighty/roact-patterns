local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)

local Menu = require(script.Menu)

local e = Roact.createElement

local function App(props)
	return e("ScreenGui", nil, {
		Menu = e(Menu),
	})
end

Roact.setGlobalConfig({
	["elementTracing"] = true
})

Roact.mount(Roact.createElement(App), Players.LocalPlayer:WaitForChild("PlayerGui"), "Gamepad")