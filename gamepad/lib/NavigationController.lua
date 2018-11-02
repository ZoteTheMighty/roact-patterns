local FocusHost = require(script.Parent.FocusHost)

local NavigationController = {}
NavigationController.__index = NavigationController

function NavigationController.create()
	return setmetatable({
		__currentFocus = nil,
		__focusHosts = {},
	}, NavigationController)
end

-- TODO: Consider giving refs a unique id?
function NavigationController:mountFocusHost(hostRef)
	assert(self.__focusHosts[hostRef] == nil, "Focus host already registered for " .. tostring(hostRef))
	assert(typeof(hostRef) == "table", "hostRef must be a ref, but was type " .. typeof(hostRef))

	-- TODO: Support selection tuple if possible
	local newFocusHost = FocusHost.new(hostRef)
	self.__focusHosts[hostRef] = newFocusHost

	return newFocusHost
end

function NavigationController:unmountFocusHost(hostRef)
	assert(self.__focusHosts[hostRef] ~= nil, "No focus host registered for " .. tostring(hostRef))

	-- TODO: What if this group is currently focused?

	self.__focusHosts[hostRef] = nil
end

function NavigationController:navigateTo(newFocusRef)
	if self.__focusHosts[newFocusRef] == nil then
		-- TODO: Is it safe to error here? Or is a warning actually okay?
		warn("No focus host registered for " .. tostring(newFocusRef))

		return
	end

	-- Remove focus from previous group
	if self.__currentFocus ~= nil then
		local oldFocusHost = self.__focusHosts[self.__currentFocus]

		oldFocusHost:removeFocus()
	end

	-- Setup focus for new selection
	self.__currentFocus = newFocusRef

	local newFocusHost = self.__focusHosts[newFocusRef]
	newFocusHost:giveFocus()
end

return NavigationController