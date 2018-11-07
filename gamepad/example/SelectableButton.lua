local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)

local assign = require(script.Parent.assign)

local SelectableButton = Roact.Component:extend("SelectableButton")

function SelectableButton:init()
	-- This is kind of a gross workaround for a simple problem: With
	-- object-style refs, sharing a ref with your parent is not as easy as it
	-- was with function refs. Maybe Roact should provide an API for this?
	self.ref = self.props.style[Roact.Ref] or Roact.createRef()

	self.state = {
		selected = false,
	}
end

function SelectableButton:render()
	local style = self.props.style
	local selectedStyle = self.props.selectedStyle
	local onSelectionGained = self.props.onSelectionGained
	local onSelectionLost = self.props.onSelectionLost

	local fullProps = {
		Size = UDim2.new(0, 200, 0, 100),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.SourceSans,
		TextSize = 30,

		[Roact.Ref] = self.ref,

		--[[
			We'll overwrite nil defaults with ourselves, so that automatic
			gui navigation won't kick in unexpectedly
		]]
		-- NextSelectionLeft = self.ref,
		-- NextSelectionRight = self.ref,
		-- NextSelectionUp = self.ref,
		-- NextSelectionDown = self.ref,

		[Roact.Event.SelectionGained] = function()
			if onSelectionGained ~= nil then
				onSelectionGained()
			end
			self:setState({
				selected = true,
			})
		end,

		[Roact.Event.SelectionLost] = function()
			if onSelectionLost ~= nil then
				onSelectionGained()
			end
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