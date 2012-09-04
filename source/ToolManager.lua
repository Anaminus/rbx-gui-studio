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
		CurrentTool = nil;
	}

	local eventToolSelected = CreateSignal(ToolManager,'ToolSelected')
	local eventToolDeselected = CreateSignal(ToolManager,'ToolDeselected')

	function ToolManager:AddTool(tool)
		--[[ tool:
				Name		the tool's name
				Icon		the icon to display on the tool button
				ToolTip		the text to display when the button is hovered over
				Shortcut	a shortcut key that selects the tool
				Select		called when the tool is selected
				Deselect	called when the tool is deselected

				Button		the button associated with the tool
				Index		the index of the tool in the manager
		]]
		if not self.Status('Stopped') then
			error("ToolManager:AddTool: service must be stopped",2)
		end
		local index = #self.ToolList+1
		self.ToolList[index] = tool
		tool.Index = index
		if index == 1 then
			self.CurrentTool = tool
			eventToolSelected:Fire(tool,false)
		end
	end

	function ToolManager:SelectTool(tool)
		if tool and tool ~= self.CurrentTool then
			local started = self.Status('Started')
			if started then
				self.CurrentTool:Deselect()
			end
			eventToolDeselected:Fire(self.CurrentTool,started)

			self.CurrentTool = tool
			if started then
				tool:Select()
			end
			eventToolSelected:Fire(tool,started)
		end
	end

	AddServiceStatus{ToolManager;
		Start = function(self)
			if self.CurrentTool then
				self.CurrentTool:Select()
			else
				error("ToolManager must have at least 1 tool",2)
			end
		end;
		Stop = function(self)
			self.CurrentTool:Deselect()
		end;
	}
end
