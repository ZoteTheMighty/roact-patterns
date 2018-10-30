local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local function getId(id)
	if id == nil then
		id = HttpService:GenerateGUID(false)
	end

	return id
end

local function DEBUG_printChildren(children)
	for child, name in pairs(children) do
		print(tostring(name), "-", tostring(child))
	end
end

local SelectionGroup = {}
SelectionGroup.__index = SelectionGroup

-- TODO:
-- * find way to support bumper/alternate nav
-- * paradigm for hierarchical selection?

function SelectionGroup:__selectChild(refOrId)
	local childRef = refOrId

	if typeof(refOrId) ~= "table" then
		childRef = self.__children[refOrId]
	end

	GuiService.SelectedObject = childRef.current
end

function SelectionGroup:__connectToGuiService()
	-- Connecting to GuiService.SelectedObject lets us persist selections
	local rbxScriptSignal = GuiService:GetPropertyChangedSignal("SelectedObject")

	self.__guiServiceConnection = rbxScriptSignal:Connect(function()
		local selection = GuiService.SelectedObject

		for id, ref in pairs(self.__children) do
			if ref.current == selection then
				self.__lastSelected = id
			end
		end
	end)
end

function SelectionGroup:updateChildren(childRefs, default)
	assert(typeof(childRefs) == "table", "Bad arg #1: must be a table of refs")

	-- Children are a mapping of ref object -> key
	self.__children = childRefs
	DEBUG_printChildren(self.__children)
end

function SelectionGroup:getGroupSelectionCallback()
	return function()
		if self.__lastSelected ~= nil then
			self:__selectChild(self.__lastSelected)
		else
			self:__selectChild(self.__defaultSelection)
		end
	end
end

function SelectionGroup:destruct()
	-- Clean up change listener
	if self.__guiServiceConnection ~= nil then
		self.__guiServiceConnection:Disconnect()
		self.__guiServiceConnection = nil
	end
end

local function createSelectionGroup(defaultSelection, defaultId)
	local self = setmetatable({
		__defaultSelection = defaultSelection,
		-- Children are a mapping of ref object -> key
		__children = {
			[defaultSelection] = getId(defaultId),
		},
	}, SelectionGroup)

	self:__connectToGuiService()

	return self
end

return createSelectionGroup