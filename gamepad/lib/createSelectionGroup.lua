local GuiService = game:GetService("GuiService")
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

local function DEBUG_printChildren(children)
	for name, child in pairs(children) do
		print(tostring(name), "-", tostring(child))
	end
end

local SelectionGroup = {}
SelectionGroup.__index = SelectionGroup

-- TODO:
-- * find way to support bumper/alternate nav
-- * paradigm for hierarchical selection?

function SelectionGroup:__connectToGuiService()
	-- Connecting to GuiService.SelectedObject lets us persist selections
	local rbxScriptSignal = GuiService:GetPropertyChangedSignal("SelectedObject")

	self.__guiServiceConnection = rbxScriptSignal:Connect(function()
		local selection = GuiService.SelectedObject

		for id, ref in pairs(self.childRefs) do
			if ref.current == selection then
				self.__lastSelected = id
			end
		end
	end)
end

function SelectionGroup:selectChild(refOrId)
	local childRef = refOrId

	if typeof(refOrId) ~= "table" then
		childRef = self.childRefs[refOrId]
	end

	if childRef ~= nil then
		GuiService.SelectedObject = childRef.current
	end
end

function SelectionGroup:setDefault(defaultSelection)
	--[[
		What if we did something like this instead?

		function SelectionGroup:configure(config)

		config.default -- ref; default selection
		config.enter -- function; runs when calling group:enter()
		config.exit -- function; mapped to back button when group:enter() is called

		too simple? maybe instead it uses some concept of rules or contexts?
		I feel like this is how context action service came to be...
	]]

	assert(
		typeof(defaultSelection) == nil or
		typeof(defaultSelection) == "table",
	"Bad arg #1: must be a table of refs")

	self.__defaultSelection = defaultSelection
end

function SelectionGroup:getGroupSelectedCallback()
	return function()
		if self.__persistSelection and self.__lastSelected ~= nil then
			self:selectChild(self.__lastSelected)
		else
			DEBUG_printChildren(self.childRefs)
			self:selectChild(self.__defaultSelection)
		end
	end
end

-- Any way we can avoid having to call this?
function SelectionGroup:destruct()
	if self.__guiServiceConnection ~= nil then
		self.__guiServiceConnection:Disconnect()
		self.__guiServiceConnection = nil
	end
end

local function createSelectionGroup(persistSelection)
	local self = setmetatable({
		childRefs = createRefCache(),

		__persistSelection = persistSelection,

		-- Uninitialized for now
		__defaultSelection = nil,
		__lastSelected = nil,
		__guiServiceConnection = nil,
	}, SelectionGroup)

	self:__connectToGuiService()

	return self
end

return createSelectionGroup