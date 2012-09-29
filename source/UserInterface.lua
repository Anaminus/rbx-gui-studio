--[[UserInterface
The plugin's user interface.

API:
    UserInterface.Screen          The ScreenGui of the UI. Must be initialized.
    UserInterface.Initialized     Whether the UI as been initialized.
	ServiceStatus.Status          Whether the service is started or not

	UserInterface:Initialize()    Creates the UI Screen, allowing this service to be started and stopped.
	UserInterface:Start()         Displays the UI. Must be initialized before calling.
	UserInterface:Stop()          Stops displaying the UI. Must be initialized before calling.
]]

do
	UserInterface = {}

	function UserInterface:Initialize()
		local MenuButtons = {
			{
				Name = "InsertScreenGui";
				Icon = Widgets.Icon(nil,InternalSettings.IconMap.Menu,32,0,0);
				ToolTip = "Insert a new ScreenGui";
				KeyBinding = "e";
				Select = function()
					ScreenManager:InsertDialog()
				end;
			};
			{
				Name = "SelectScreenGui";
				Icon = Widgets.Icon(nil,InternalSettings.IconMap.Menu,32,0,1);
				ToolTip = "Set a ScreenGui to the canvas";
				KeyBinding = "r";
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
				Name = "LayoutMode";
				Icon = Widgets.Icon(nil,InternalSettings.IconMap.Menu,32,0,2);
				ToolTip = "Toggle Layout Mode (currently Scale)";
				KeyBinding = "t";
				Select = function(self)
					if Settings.LayoutMode('Scale') then
						Settings.LayoutMode = Enums.LayoutMode.Offset
						Widgets.Icon(self.Button.MenuButtonIcon,InternalSettings.IconMap.Menu,32,0,3)
						ToolTipService:AddToolTip(self.Button,"Toggle Layout Mode (currently Offset)")
					else
						Settings.LayoutMode = Enums.LayoutMode.Scale
						Widgets.Icon(self.Button.MenuButtonIcon,InternalSettings.IconMap.Menu,32,0,2)
						ToolTipService:AddToolTip(self.Button,"Toggle Layout Mode (currently Scale)")
					end
				end;
			};
			{
				Name = "ToggleGrid";
				Icon = Widgets.Icon(nil,InternalSettings.IconMap.Menu,32,0,4);
				ToolTip = "Toggle visibility of the grid";
				KeyBinding = "y";
				Select = function(self)
					Grid:SetVisible(not Grid.Visible)
					if Grid.Visible then
						self.Button.BorderColor3 = Color3.new(1,0,0)
					else
						self.Button.BorderColor3 = Color3.new(0.588235, 0.588235, 0.588235)
					end
				end;
			};
		--[[
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
		for i,button in pairs(MenuButtons) do
			if button.KeyBinding then
				KeyBinding:Add(button.KeyBinding,function() button:Select() end)
			end
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
		IllegalScreen[self.Screen] = true

		self.Initialized = true
	end

	AddServiceStatus{UserInterface;
		Start = function(self)
			if self.Initialized then
				self.Screen.Parent = Game:GetService("CoreGui")
			else
				error("UserInterface:Start: UI has not been initialized",2)
			end
		end;
		Stop = function(self)
			if self.Initialized then
				self.Screen.Parent = nil
			else
				error("UserInterface:Stop: UI has not been initialized",2)
			end
		end;
	}
end
