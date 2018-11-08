local FocusHost = require(script.Parent.FocusHost)

local NavigationController = {}
NavigationController.__index = NavigationController

function NavigationController.create()
	return setmetatable({
		__currentFocus = nil,
		__focusHosts = {},
	}, NavigationController)
end

function NavigationController:mountFocusHost(focusHost)
	local hostRef = FocusHost.getHostRef(focusHost)

	assert(self.__focusHosts[hostRef] == nil, "Focus host already registered for " .. tostring(hostRef))
	assert(typeof(hostRef) == "table", "hostRef must be a ref but was " .. typeof(hostRef))

	self.__focusHosts[hostRef] = focusHost
end

function NavigationController:unmountFocusHost(focusHost)
	local hostRef = FocusHost.getHostRef(focusHost)

	assert(self.__focusHosts[hostRef] ~= nil, "No focus host registered for " .. tostring(hostRef))

	if self.__currentFocus == hostRef then
		-- TODO: Should we provide a hook so that focusHosts can navigate somewhere else
		-- if they get unmounted while focused?
		warn("Unmounting currently-focused group")
		FocusHost.removeFocus(self.__focusHosts[self.__currentFocus])
	end

	self.__focusHosts[hostRef] = nil
end

function NavigationController:navigateTo(newFocusRef)
	if self.__focusHosts[newFocusRef] == nil then
		warn("No focus host mounted for " .. tostring(newFocusRef))

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