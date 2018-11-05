local FocusHost = require(script.Parent.FocusHost)

local NavigationController = {}
NavigationController.__index = NavigationController

function NavigationController.create()
	return setmetatable({
		__currentFocus = nil,
		__focusHosts = {},
	}, NavigationController)
end

function NavigationController:mountFocusHost(hostRef)
	assert(self.__focusHosts[hostRef] == nil, "Focus host already registered for " .. tostring(hostRef))
	assert(typeof(hostRef) == "table", "hostRef must be a ref")

	-- TODO: Support selection tuple if possible
	local newFocusHost = FocusHost.new(hostRef)
	self.__focusHosts[hostRef] = newFocusHost

	return newFocusHost
end

function NavigationController:unmountFocusHost(hostRef)
	assert(self.__focusHosts[hostRef] ~= nil, "No focus host registered for " .. tostring(hostRef))

	if self.__currentFocus == hostRef then
		-- TODO: Is there a more graceful way to handle unmounting the thing with focus?
		-- It may be correct behavior after all
		warn("Unmounting currently-focused group")
		FocusHost.removeFocus(self.__focusHosts[self.__currentFocus])
	end

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

		FocusHost.removeFocus(oldFocusHost)
	end

	-- Setup focus for new selection
	self.__currentFocus = newFocusRef

	local newFocusHost = self.__focusHosts[newFocusRef]
	FocusHost.giveFocus(newFocusHost)
end

return NavigationController