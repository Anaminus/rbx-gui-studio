local function InitializeGUI()
	local MenuButtons = {
		{
			Name = "InsertScreenGui";
			Icon = "http://www.roblox.com/asset/?id=92518177";
			ToolTip = "Insert a new ScreenGui";
			Select = function()
				ScreenHandler:InsertDialog()
			end;
		};
		{
			Name = "SelectScreenGui";
			Icon = "http://www.roblox.com/asset/?id=92033564";
			ToolTip = "Set a ScreenGui to the canvas";
			Select = function()
				ScreenHandler:SelectDialog()
			end;
		};
--[[
		'----------------';
		{
			Name = "Import";
			Icon = "";
			ToolTip = "Import a GUI";
			Select = function()

			end;
		};
		{
			Name = "Export";
			Icon = "";
			ToolTip = "Export the current screen";
			Select = function()

			end;
		};
		{
			Name = "Preview";
			Icon = "";
			ToolTip = "Preview the current screen";
			Select = function()

			end;
		};
		'----------------';
		{
			Name = "ScaleMode";
			Icon = "";
			ToolTip = "Scale Mode";
			Select = function()

			end;
		};
		{
			Name = "OffsetMode";
			Icon = "";
			ToolTip = "Offset Mode";
			Select = function()

			end;
		};
		'----------------';
		{
			Name = "ToggleGrid";
			Icon = "";
			ToolTip = "Toggle the grid";
			Select = function()

			end;
		};
		{
			Name = "ConfigGrid";
			Icon = "";
			ToolTip = "Configure the grid";
			Select = function()

			end;
		};
		'----------------';
		{
			Name = "ToggleBackground";
			Icon = "";
			ToolTip = "Toggle the visiblity of the canvas background";
			Select = function()

			end;
		};
		{
			Name = "SetBackgoundColor";
			Icon = "";
			ToolTip = "Set the color of the canvas background";
			Select = function()

			end;
		};
--]]
	}

	local buttonSize = InternalSettings.GuiButtonSize
	local menuSize = buttonSize + 8

	local MenuFrame = Widgets.ButtonMenu(MenuButtons,Vector2.new(buttonSize,buttonSize),true)

	local ToolbarFrame = ToolManager:InitializeTools()

	Screen = Create'ScreenGui'{
		Name = "GuiStudio";
		Create'Frame'{
			Size = UDim2.new(1, 0, 1, -60);
			Name = "StudioFrame";
			Position = UDim2.new(0, 0, 0, -1);
			BackgroundTransparency = 1;
			Create'Frame'{
				Size = UDim2.new(1, -menuSize, 1, -menuSize*2);
				BorderSizePixel = 0;
				Name = "Background";
				Position = UDim2.new(0, menuSize, 0, menuSize*2);
				BackgroundColor3 = Color3.new(0.5, 0.5, 0.5);
				Create'Frame'{
					Size = UDim2.new(1, 0, 1, 0);
					Name = "ScaleGrid";
					BackgroundTransparency = 1;
				};
				Create'Frame'{
					Size = UDim2.new(1, 0, 1, 0);
					Name = "OffsetGrid";
					BackgroundTransparency = 1;
				};
			};
			Create(Canvas.CanvasFrame){
				Size = UDim2.new(1, -menuSize, 1, -menuSize*2);
				Name = "Canvas";
				Position = UDim2.new(0, menuSize, 0, menuSize*2);
				BackgroundTransparency = 1;
			};
			Create(MenuFrame){
				Name = "MainMenu ButtonMenu";
				Size = UDim2.new(1,0,0,menuSize);
			};
			Create(ToolbarFrame){
				Name = "Toolbar ButtonMenu";
				Position = UDim2.new(0, 0, 0, menuSize*2);
				Size = UDim2.new(0, menuSize, 1, -menuSize);
			};
			Create(ToolManager.ToolOptionsFrame){
				Name = "ToolOptions";
				Position = UDim2.new(0, 0, 0, menuSize);
				Size = UDim2.new(1, 0, 0, menuSize);
				BackgroundColor3 = Color3.new(0.917647, 0.917647, 0.917647);
				BorderColor3 = Color3.new(0.588235, 0.588235, 0.588235);
			};
		};
		Create'Frame'{
			Name = "BottomPanel";
			Position = UDim2.new(0, 0, 1, -1);
			Size = UDim2.new(1, 0, 0, -60);
			BackgroundColor3 = Color3.new(0.917647, 0.917647, 0.917647);
			BorderColor3 = Color3.new(0.588235, 0.588235, 0.588235);
		};
	}

	ToolTipService.Parent = Screen
end

local function ActivateGUI()
	Screen.Parent = Game:GetService("CoreGui")
end

local function DeactivateGUI()
	Screen.Parent = nil
end
