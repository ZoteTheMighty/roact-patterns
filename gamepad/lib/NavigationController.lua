local GuiService = game:GetService("GuiService")

-- local Type = {
-- 	Ref = newproxy(false),
-- 	FocusOwner = newproxy(false),
-- }

-- function Type.of(object)
-- 	if object[Type.FocusOwner] then
-- 		return Type.FocusOwner
-- 	else
-- 		return Type.Ref
-- 	end
-- end

local function printFocus(prefix, id, focusGroup)
	if focusGroup == nil then
		print(("%s %s"):format(prefix, id))
	else
		print(("%s %s - host: %s - default: %s"):format(
			prefix, id, tostring(focusGroup.hostRef), tostring(focusGroup.defaultSelectionRef)
		))
	end
end

local function removeFocusFromRef(id, focusGroup)
	-- TODO: Allow persisted instead of default
	GuiService:RemoveSelectionGroup(id, focusGroup.hostRef.current)
end

local function focusSelectedRef(id, focusGroup)
	GuiService:AddSelectionParent(id, focusGroup.hostRef.current)
	GuiService.SelectedObject = focusGroup.defaultSelectionRef.current
end

local NavigationController = {}
NavigationController.__index = NavigationController

function NavigationController.create()
	return setmetatable({
		__currentFocusId = nil,
		__focusGroups = {},
	}, NavigationController)
end

-- TODO: Consider giving refs a unique id?
function NavigationController:registerFocusGroup(id, hostRef, defaultSelectionRef)
	assert(self.__focusGroups[id] == nil, "Focus listener already registered for " .. tostring(id))

	-- TODO: Support selection tuple
	self.__focusGroups[id] = {
		hostRef = hostRef,
		defaultSelectionRef = defaultSelectionRef,
	}

	printFocus("registered group", id, self.__focusGroups[id])
end

function NavigationController:deregisterFocusGroup(id)
	assert(self.__focusGroups[id] ~= nil, "No focus listener registered for " .. tostring(id))

	-- TODO: What if this group is currently focused?
	printFocus("deregistering group", id, self.__focusGroups[id])

	self.__focusGroups[id] = nil
end

function NavigationController:navigateTo(newFocusId)
	-- Remove focus from previous group
	if self.__currentFocusId ~= nil then
		local oldFocusId = self.__currentFocusId
		local oldFocus = self.__focusGroups[oldFocusId]

		removeFocusFromRef(self.__currentFocusId, oldFocus)
	end

	-- Setup focus for new selection
	self.__currentFocusId = newFocusId

	local newFocus = self.__focusGroups[newFocusId]
	printFocus("navigate to", newFocusId, newFocus)
	focusSelectedRef(newFocusId, newFocus)
end

return NavigationController