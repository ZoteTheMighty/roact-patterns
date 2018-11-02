local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)

--[[
	Equivalent to JavaScript's Object.assign, useful for merging together tables
	without mutating them and without creating extra tables.
]]
local function assign(target, ...)
	for i = 1, select("#", ...) do
		local source = select(i, ...)

		for key, value in pairs(source) do
			if value == Roact.None then
				target[key] = nil
			else
				target[key] = value
			end
		end
	end

	return target
end

return assign