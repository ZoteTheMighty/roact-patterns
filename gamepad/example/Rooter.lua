local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)

local Rooter = Roact.Component:extend("Rooter")

function Rooter:init()
	self.isRooted = false
end

function Rooter:render()
	return Roact.createElement("Folder", {
		[Roact.Event.AncestryChanged] = function(object)
			if object:IsDescendantOf(game) then
				if not self.isRooted then
					self.isRooted = true
					self.props.rooted()
				end
			else
				if self.isRooted then
					self.isRooted = false
					self.props.unrooted()
				end
			end
		end,
	})
end

return Rooter