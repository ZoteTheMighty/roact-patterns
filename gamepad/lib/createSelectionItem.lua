local GuiService = game:GetService("GuiService")

local SelectionItem = {}
SelectionItem.__index = SelectionItem

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
		__defaultSelection = defaultSelection
	}, SelectionItem)
end

return createSelectionItem