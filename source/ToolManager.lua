--[[
manages tools
API:
	ToolManager.ToolList               A list of tool data
	ToolManager.CurrentTool            The tool currently selected

	ToolManager:AddTool(data)          Adds a new tool
	ToolManager:SelectTool(index)      Selects a tool

	ToolManager.ToolSelected(index)    Fired after a tool is selected
	ToolManager.ToolDeselected(index)  Fired after a tool is deselected
]]
local ToolManager do
	ToolManager = {
		ToolList = {};
		CurrentTool = 1;
	}

	local eventToolSelected = CreateSignal(ToolManager,'ToolSelected')
	local eventToolDeselected = CreateSignal(ToolManager,'ToolDeselected')

	function ToolManager:AddTool(data)
		--[[ data:
				Name = string
				Icon = Content
				ToolTip = string
				Shortcut = string
				Select = function
				Deselect = function
		]]
		self.ToolList[#self.ToolList+1] = data
	end

	function ToolManager:SelectTool(index)
		local ToolList = self.ToolList
		index = math.floor(index)
		if index > 0 and index <= #ToolList then
			ToolList[self.CurrentTool]:Deselect()
			eventToolDeselected:Fire(self.CurrentTool)

			self.CurrentTool = index
			ToolList[index]:Select()
			eventToolSelected:Fire(index)
		else
			error("ToolManager:SelectTool: invalid tool index ["..index.."]",2)
		end
	end

	AddServiceStatus{ToolManager;
		Start = function(self)
			self.ToolList[self.CurrentTool]:Select()
			eventToolSelected:Fire(self.CurrentTool)
		end;
		Stop = function(self)
			self.ToolList[self.CurrentTool]:Deselect()
		end;
	}
end
