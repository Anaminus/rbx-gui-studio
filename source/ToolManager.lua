--[[ToolManager
Manages the selection of tools.
Tools are just tables containing data about the tool; these are the values that are passed around.
They contain the following fields:
	Name        The tool's name.
	Icon        The icon to display on the tool button.
	ToolTip     The text to display when the button is hovered over.
	Shortcut    A shortcut key that selects the tool (unused).
	Select      A function called when the tool is selected.
	Deselect    A function called when the tool is deselected.
These fields are added later:
	Button      the GUI button associated with the tool.
	Index       the index of the tool in the manager's tool list.

If the manager is not started, tools can still be selected, but they wont do anything until the manager starts.


API:
	ToolManager.ToolList                A list of tools added to the manager.
	ToolManager.CurrentTool             The currently selected tool.
	ToolManager.ToolbarFrame            A GUI containing buttons for each tool (must be initialized).
	ServiceStatus.Status                Whether the service is started or not.

	ToolManager:AddTool(data)           Adds a new tool. This must be done before the manager is started.
	!ToolManager:InitializeTools()      Indicates that all tools have been added, and create the toolbar.
	ToolManager:SelectTool(tool)        Selects a tool. The previous tool is deselected.
	ToolManager:Start()                 Starts the manager.
	ToolManager:Stop()                  Stops the manager.

	ToolManager.ToolSelected(tool)      Fired after a tool is selected.
	ToolManager.ToolDeselected(tool)    Fired after a tool is deselected.
]]
local ToolManager do
	ToolManager = {
		ToolList = {};
		CurrentTool = nil;
	}

	local eventToolSelected = CreateSignal(ToolManager,'ToolSelected')
	local eventToolDeselected = CreateSignal(ToolManager,'ToolDeselected')

	function ToolManager:AddTool(tool)
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

	function ToolManager:InitializeToolbar()
		if not self.ToolbarFrame then
			local buttonSize = InternalSettings.GuiButtonSize
			self.ToolbarFrame = Widgets.ButtonMenu(self.ToolList,Vector2.new(buttonSize,buttonSize),false,function(tool)
				self:SelectTool(tool)
			end)
			self.ToolSelected:connect(function(tool)
				if tool.Button then
					tool.Button.BorderColor3 = Color3.new(1,0,0)
				end
			end)
			self.ToolDeselected:connect(function(tool)
				if tool.Button then
					tool.Button.BorderColor3 = Color3.new(0.588235, 0.588235, 0.588235)
				end
			end)
			if self.CurrentTool.Button then
				self.CurrentTool.Button.BorderColor3 = Color3.new(1,0,0)
			end
		end
		return self.ToolbarFrame
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
