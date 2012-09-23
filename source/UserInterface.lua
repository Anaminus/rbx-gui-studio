--[[UserInterface
The plugin's user interface.

API:
    UserInterface.Screen          The ScreenGui of the UI. Must be initialized.
	ServiceStatus.Status          Whether the service is started or not

	UserInterface:Initialize()    Creates the UI Screen, allowing this service to be started and stopped.
	UserInterface:Start()         Displays the UI. Must be initialized before calling.
	UserInterface:Stop()          Stops displaying the UI. Must be initialized before calling.
]]

local UserInterface do
	UserInterface = {}

	function UserInterface:Initialize()
		local MenuButtons = {
			{
				Name = "InsertScreenGui";
				Icon = Preload"http://www.roblox.com/asset/?id=92518177";
				ToolTip = "Insert a new ScreenGui";
				Select = function()
					ScreenManager:InsertDialog()
				end;
			};
			{
				Name = "SelectScreenGui";
				Icon = Preload"http://www.roblox.com/asset/?id=92033564";
				ToolTip = "Set a ScreenGui to the canvas";
				Select = function()
					ScreenManager:SelectDialog()
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
		--]]
			'----------------';
			{
				Name = "ScaleMode";
				Icon = "";
				ToolTip = "Scale Mode";
				Select = function(self)
					Settings.LayoutMode = Enums.LayoutMode.Scale
				end;
			};
			{
				Name = "OffsetMode";
				Icon = "";
				ToolTip = "Offset Mode";
				Select = function(self)
					Settings.LayoutMode = Enums.LayoutMode.Offset
				end;
			};
		--[[
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
		do
			local scaleButton = MenuButtons[4].Button
			local offsetButton = MenuButtons[5].Button
			local function layoutChanged(key,value)
				if key == 'LayoutMode' then
					if value('Offset') then
						scaleButton.BorderColor3 = Color3.new(0.588235, 0.588235, 0.588235)
						offsetButton.BorderColor3 = Color3.new(1,0,0)
					else
						scaleButton.BorderColor3 = Color3.new(1,0,0)
						offsetButton.BorderColor3 = Color3.new(0.588235, 0.588235, 0.588235)
					end
				end
			end
			Settings.Changed:connect(layoutChanged)
			layoutChanged('LayoutMode',Settings.LayoutMode)
		end

		local ToolbarFrame = ToolManager:InitializeTools()

		self.Screen = Create'ScreenGui'{
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

		ToolTipService.Parent = self.Screen
	end

	AddServiceStatus{UserInterface;
		Start = function(self)
			if self.Screen then
				self.Screen.Parent = Game:GetService("CoreGui")
			else
				error("UserInterface:Start: UI has not been initialized",2)
			end
		end;
		Stop = function(self)
			if self.Screen then
				self.Screen.Parent = nil
			else
				error("UserInterface:Stop: UI has not been initialized",2)
			end
		end;
	}
end
