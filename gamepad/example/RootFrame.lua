local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)

local assign = require(script.Parent.assign)

local RootFrame = Roact.Component:extend("RootFrame")

function RootFrame:init()
	self.isRooted = false
end

function RootFrame:render()
	local rooted = self.props.rooted
	local unrooted = self.props.unrooted

	local frameProps = {
		[Roact.Event.AncestryChanged] = function(object)
			if object:IsDescendantOf(game) then
				if not self.isRooted then
					self.isRooted = true
					rooted()
				end
			else
				if self.isRooted then
					self.isRooted = false
					unrooted()
				end
			end
		end,
	}

	return Roact.createElement("Frame", assign(frameProps, self.props, {
		rooted = Roact.None,
		unrooted = Roact.None,
	}))
end

return RootFrame