local GuiService = game:GetService("GuiService")

local SelectionItem = {}
SelectionItem.__index = SelectionItem

-- TODO:
-- * implement persistent selection state
-- * find way to support bumper/alternate nav
-- * paradigm for hierarchical selection

function SelectionItem:getOnSelected()
	return function()
		print("Select default:", tostring(self.__defaultSelection))
		if typeof(self.__defaultSelection) == "table" then
			GuiService.SelectedObject = self.__defaultSelection.current
		elseif self.__defaultSelection ~= nil then
			GuiService.SelectedObject = self.__defaultSelection
		end
	end
end

local function createSelectionItem(defaultSelection)
	return setmetatable({
		__defaultSelection = defaultSelection,
	}, SelectionItem)
end

return createSelectionItem