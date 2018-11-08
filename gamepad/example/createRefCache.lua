local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)

-- This is a handy trick to allow us to reference refs before we've actually
-- rendered anything, and without duplicating rendering logic!
local function createRefCache()
	local refCache = {}

	setmetatable(refCache, {
		__index = function(_, key)
			local newRef = Roact.createRef()
			refCache[key] = newRef

			return newRef
		end,
	})

	return refCache
end

return createRefCache