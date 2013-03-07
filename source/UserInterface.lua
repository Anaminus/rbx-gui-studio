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
		local GuiColor = InternalSettings.GuiColor
		local buttonSize = InternalSettings.GuiButtonSize
		local menuSize = buttonSize + 8

		local MenuFrame do
			local MenuButtons = {
				{
					Name = "InsertScreenGui";
					Icon = Widgets.Icon(nil,InternalSettings.IconMap.Menu,32,0,0);
					ToolTip = "Insert a new ScreenGui";
					KeyBinding = "shift+ctrl+i";
					Select = function()
						ScreenManager:InsertDialog()
					end;
				};
				{
					Name = "SelectScreenGui";
					Icon = Widgets.Icon(nil,InternalSettings.IconMap.Menu,32,0,1);
					ToolTip = "Set a ScreenGui to the canvas";
					KeyBinding = "shift+ctrl+s";
					Select = function()
						ScreenManager:SelectDialog()
					end;
				};
				{
					Name = "ExportScreen";
					Icon = Widgets.Icon(nil,InternalSettings.IconMap.Menu,32,0,6);
					KeyBinding = "shift+ctrl+e";
					ToolTip = "Export the current Screen.";
					Select = function()
						Exporter:ExportDialog()
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
					KeyBinding = "alt+l";
					Select = function(self)
						if Settings.LayoutMode('Scale') then
							Settings.LayoutMode = Enums.LayoutMode.Offset
						else
							Settings.LayoutMode = Enums.LayoutMode.Scale
						end
					end;
					Setup = function(self)
						Settings.Changed:connect(function(key,value)
							if key == 'LayoutMode' then
								if value('Scale') then
									Widgets.Icon(self.Button.MenuButtonIcon,InternalSettings.IconMap.Menu,32,0,2)
									ToolTipService:AddToolTip(self.Button,"Toggle Layout Mode (currently Scale)")
								else
									Widgets.Icon(self.Button.MenuButtonIcon,InternalSettings.IconMap.Menu,32,0,3)
									ToolTipService:AddToolTip(self.Button,"Toggle Layout Mode (currently Offset)")
								end
							end
						end)
					end;
				};
				'----------------';
				{
					Name = "ToggleGrid";
					Icon = Widgets.Icon(nil,InternalSettings.IconMap.Menu,32,0,4);
					ToolTip = "Toggle visibility of the grid";
					KeyBinding = "alt+g";
					Select = function(self)
						Grid:SetVisible(not Grid.Visible)
					end;
					Setup = function(self)
						Grid.VisibilitySet:connect(function(visible)
							if visible then
								self.Button.BorderColor3 = GuiColor.ButtonSelected
							else
								self.Button.BorderColor3 = GuiColor.ButtonBorder
							end
						end)
					end;
				};
				{
					Name = "ConfigGrid";
					Icon = Widgets.Icon(nil,InternalSettings.IconMap.Menu,32,1,1);
					KeyBinding = "shift+ctrl+g";
					ToolTip = "Configure the grid";
					Select = function()
						Grid:ConfigDialog()
					end;
				};
			--[[
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

			MenuFrame = Widgets.ButtonMenu(MenuButtons,Vector2.new(buttonSize,buttonSize),true)
		end

		local SnapperFrame do
			local SnapperButtons = {
				{
					Name = "ToggleSnapping";
					Icon = Widgets.Icon(nil,InternalSettings.IconMap.Snap,32,0,0);
					ToolTip = "Enable snapping";
					KeyBinding = "alt+s";
					Select = function()
						Settings.SnapEnabled = not Settings.SnapEnabled
					end;
					Setup = function(self)
						Settings.Changed:connect(function(key,value)
							if key == 'SnapEnabled' then
								self:SetActive(value)
							end
						end)
						self:SetActive(Settings.SnapEnabled)
					end;
				};
				{
					Name = "ToggleEdgeSnapping";
					Icon = Widgets.Icon(nil,InternalSettings.IconMap.Snap,32,1,0);
					ToolTip = "Snap to edge";
					Select = function()
						Settings.SnapToEdges = not Settings.SnapToEdges
					end;
					Setup = function(self)
						Settings.Changed:connect(function(key,value)
							if key == 'SnapToEdges' then
								self:SetActive(value)
							elseif key == 'SnapEnabled' then
								self:SetEnabled(value)
								Widgets.Icon(self.Button.MenuButtonIcon,InternalSettings.IconMap.Menu,32,1,value and 0 or 1)
							end
						end)
						self:SetActive(Settings.SnapToEdges)
						self:SetEnabled(Settings.SnapEnabled)
						Widgets.Icon(self.Button.MenuButtonIcon,InternalSettings.IconMap.Menu,32,1,Settings.SnapEnabled and 0 or 1)
					end;
				};
				{
					Name = "ToggleCenterSnapping";
					Icon = Widgets.Icon(nil,InternalSettings.IconMap.Snap,32,2,0);
					ToolTip = "snap to center";
					Select = function()
						Settings.SnapToCenter = not Settings.SnapToCenter
					end;
					Setup = function(self)
						Settings.Changed:connect(function(key,value)
							if key == 'SnapToCenter' then
								self:SetActive(value)
							elseif key == 'SnapEnabled' then
								self:SetEnabled(value)
								Widgets.Icon(self.Button.MenuButtonIcon,InternalSettings.IconMap.Menu,32,2,value and 0 or 1)
							end
						end)
						self:SetActive(Settings.SnapToCenter)
						self:SetEnabled(Settings.SnapEnabled)
						Widgets.Icon(self.Button.MenuButtonIcon,InternalSettings.IconMap.Menu,32,2,Settings.SnapEnabled and 0 or 1)
					end;
				};
				{
					Name = "ToggleParentSnapping";
					Icon = Widgets.Icon(nil,InternalSettings.IconMap.Snap,32,3,0);
					ToolTip = "Snap to parent";
					Select = function()
						Settings.SnapToParent = not Settings.SnapToParent
					end;
					Setup = function(self)
						Settings.Changed:connect(function(key,value)
							if key == 'SnapToParent' then
								self:SetActive(value)
							elseif key == 'SnapEnabled' then
								self:SetEnabled(value)
								Widgets.Icon(self.Button.MenuButtonIcon,InternalSettings.IconMap.Menu,32,3,value and 0 or 1)
							end
						end)
						self:SetActive(Settings.SnapToParent)
						self:SetEnabled(Settings.SnapEnabled)
						Widgets.Icon(self.Button.MenuButtonIcon,InternalSettings.IconMap.Menu,32,3,Settings.SnapEnabled and 0 or 1)
					end;
				};
				{
					Name = "TogglePaddingSnapping";
					Icon = Widgets.Icon(nil,InternalSettings.IconMap.Snap,32,4,0);
					ToolTip = "Snap to padding";
					Select = function()
						Settings.SnapToPadding = not Settings.SnapToPadding
					end;
					Setup = function(self)
						Settings.Changed:connect(function(key,value)
							if key == 'SnapToPadding' then
								self:SetActive(value)
							elseif key == 'SnapEnabled' then
								self:SetEnabled(value)
								Widgets.Icon(self.Button.MenuButtonIcon,InternalSettings.IconMap.Menu,32,4,value and 0 or 1)
							end
						end)
						self:SetActive(Settings.SnapToPadding)
						self:SetEnabled(Settings.SnapEnabled)
						Widgets.Icon(self.Button.MenuButtonIcon,InternalSettings.IconMap.Menu,32,4,Settings.SnapEnabled and 0 or 1)
					end;
				};
				{
					Name = "ToggleGridSnapping";
					Icon = Widgets.Icon(nil,InternalSettings.IconMap.Snap,32,5,0);
					ToolTip = "Snap to grid";
					Select = function()
						Settings.SnapToGrid = not Settings.SnapToGrid
					end;
					Setup = function(self)
						Settings.Changed:connect(function(key,value)
							if key == 'SnapToGrid' then
								self:SetActive(value)
							elseif key == 'SnapEnabled' then
								self:SetEnabled(value)
								Widgets.Icon(self.Button.MenuButtonIcon,InternalSettings.IconMap.Menu,32,5,value and 0 or 1)
							end
						end)
						self:SetActive(Settings.SnapToGrid)
						self:SetEnabled(Settings.SnapEnabled)
						Widgets.Icon(self.Button.MenuButtonIcon,InternalSettings.IconMap.Menu,32,5,Settings.SnapEnabled and 0 or 1)
					end;
				};
			}

			SnapperFrame = Widgets.ButtonMenu(SnapperButtons,Vector2.new(buttonSize,buttonSize))
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
					Size = UDim2.new(1, -menuSize*2, 1, -menuSize*2);
					BorderSizePixel = 0;
					Name = "Background";
					Position = UDim2.new(0, menuSize, 0, menuSize*2);
					BackgroundColor3 = Color3.new(0.5, 0.5, 0.5);
				};
				Create(Canvas.CanvasFrame){
					Size = UDim2.new(1, -menuSize*2, 1, -menuSize*2);
					Name = "Canvas";
					Position = UDim2.new(0, menuSize, 0, menuSize*2);
					BackgroundTransparency = 1;
				};
				Create(MenuFrame){
					Name = "MainMenu ButtonMenu";
					Size = UDim2.new(1,0,0,menuSize);
				};
				Create(SnapperFrame){
					Name = "SnapperMenu ButtonMenu";
					Position = UDim2.new(1,-menuSize,0,menuSize*2);
					Size = UDim2.new(0,menuSize,1,0);
				};
				Create(ToolbarFrame){
					Name = "Toolbar ButtonMenu";
					Position = UDim2.new(0, 0, 0, menuSize*2);
					Size = UDim2.new(0, menuSize, 1, -menuSize*2);
				};
				Create(ToolManager.ToolOptionsFrame){
					Name = "ToolOptions";
					Position = UDim2.new(0, 0, 0, menuSize);
					Size = UDim2.new(1, 0, 0, menuSize);
					BackgroundColor3 = GuiColor.Background;
					BorderColor3 = GuiColor.Border;
				};
				Create'Frame'{
					Name = "BottomPanel";
					Position = UDim2.new(0, 0, 1, -1);
					Size = UDim2.new(1, 0, 0, 60);
					BackgroundColor3 = GuiColor.Background;
					BorderColor3 = GuiColor.Border;
					Create(Status.StatusFrame){
						Position = UDim2.new(0,60,0,4);
						Size = UDim2.new(0.5,-60,1,-8);
					};
				};
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
