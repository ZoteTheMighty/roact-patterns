local FocusHost = require(script.Parent.FocusHost)

local NavigationController = {}
NavigationController.__index = NavigationController

function NavigationController.create()
	return setmetatable({
		__currentFocusId = nil,
		__focusGroups = {},
	}, NavigationController)
end

-- TODO: Consider giving refs a unique id?
function NavigationController:registerFocusHost(id, hostRef)
	assert(self.__focusGroups[id] == nil, "Focus host already registered for " .. tostring(id))
	assert(typeof(hostRef) == "table", "hostRef must be a valid ref")

	-- TODO: Support selection tuple
	local newFocusHost = FocusHost.new(id, hostRef)
	self.__focusGroups[id] = newFocusHost

	print("registering ", tostring(newFocusHost))

	return newFocusHost
end

function NavigationController:deregisterFocusHost(id)
	-- TODO: Remove host by identity as well as id
	assert(self.__focusGroups[id] ~= nil, "No focus host registered for " .. tostring(id))

	-- TODO: What if this group is currently focused?
	print("deregistering ", tostring(self.__focusGroups[id]))

	self.__focusGroups[id] = nil
end

function NavigationController:navigateTo(newFocusId)
	-- Remove focus from previous group
	if self.__currentFocusId ~= nil then
		local oldFocusId = self.__currentFocusId
		local oldFocusHost = self.__focusGroups[oldFocusId]

		oldFocusHost:removeFocus()
	end

	-- Setup focus for new selection
	self.__currentFocusId = newFocusId

	local newFocusHost = self.__focusGroups[newFocusId]
	newFocusHost:giveFocus()
end

return NavigationController