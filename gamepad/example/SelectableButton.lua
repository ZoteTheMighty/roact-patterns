local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)

local assign = require(script.Parent.assign)

local SelectableButton = Roact.Component:extend("SelectableButton")

function SelectableButton:init()
	self.state = {
		selected = false,
	}
end

function SelectableButton:render()
	local style = self.props.style
	local selectedStyle = self.props.selectedStyle

	local fullProps = {
		Size = UDim2.new(0, 200, 1, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.SourceSans,
		TextSize = 30,

		[Roact.Event.SelectionGained] = function()
			self:setState({
				selected = true,
			})
		end,

		[Roact.Event.SelectionLost] = function()
			self:setState({
				selected = false,
			})
		end,
	}

	if self.state.selected and selectedStyle ~= nil then
		assign(fullProps, style, selectedStyle)
	else
		assign(fullProps, style)
	end

	return Roact.createElement("TextButton", fullProps)
end

return SelectableButton