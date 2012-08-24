local Screen

local function InitializeGUI()
	Screen = Create'ScreenGui'{
		Name = "GuiStudio";
		Create'Frame'{
			Size = UDim2.new(1, 0, 1, -60);
			Name = "StudioFrame";
			Position = UDim2.new(0, 0, 0, -1);
			BackgroundTransparency = 1;
			Create'Frame'{
				Size = UDim2.new(1, -40, 1, -40);
				BorderColor3 = Color3.new(0, 0, 0);
				Name = "Background";
				Position = UDim2.new(0, 40, 0, 40);
				BackgroundColor3 = Color3.new(0.501961, 0.501961, 0.501961);
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
				Size = UDim2.new(1, -40, 1, -40);
				Name = "Canvas";
				Position = UDim2.new(0, 40, 0, 40);
				BackgroundTransparency = 1;
			};
			Create'Frame'{
				Size = UDim2.new(0, 112, 0, 40);
				BorderColor3 = Color3.new(0, 0, 0);
				Name = "Menu";
				BackgroundColor3 = Color3.new(0.698039, 0.698039, 0.698039);
				Create'ImageButton'{
					Size = UDim2.new(0, 32, 0, 32);
					BackgroundTransparency = 0.6;
					Name = "ExportButton";
					Position = UDim2.new(0, 4, 0, 4);
					BackgroundColor3 = Color3.new(0.698039, 0.698039, 0.698039);
				};
				Create'ImageButton'{
					Size = UDim2.new(0, 32, 0, 32);
					BackgroundTransparency = 0.6;
					Name = "ImportButton";
					Position = UDim2.new(0, 40, 0, 4);
					BackgroundColor3 = Color3.new(0.698039, 0.698039, 0.698039);
				};
				Create'ImageButton'{
					Size = UDim2.new(0, 32, 0, 32);
					BackgroundTransparency = 0.6;
					Name = "PreviewButton";
					Position = UDim2.new(0, 76, 0, 4);
					BackgroundColor3 = Color3.new(0.698039, 0.698039, 0.698039);
				};
			};
			Create'Frame'{
				Size = UDim2.new(0, 40, 1, -40);
				BorderColor3 = Color3.new(0, 0, 0);
				Name = "Tools";
				Position = UDim2.new(0, 0, 0, 40);
				BackgroundColor3 = Color3.new(0.698039, 0.698039, 0.698039);
				Create'ImageButton'{
					Size = UDim2.new(0, 32, 0, 32);
					BackgroundTransparency = 0.6;
					Name = "SelectionTool";
					Position = UDim2.new(0, 4, 0, 4);
					BackgroundColor3 = Color3.new(0.698039, 0.698039, 0.698039);
				};
				Create'ImageButton'{
					Size = UDim2.new(0, 32, 0, 32);
					BackgroundTransparency = 0.6;
					Name = "ObjectTool";
					Position = UDim2.new(0, 4, 0, 40);
					BackgroundColor3 = Color3.new(0.698039, 0.698039, 0.698039);
				};
			};
			Create'Frame'{
				Size = UDim2.new(1, -112, 0, 40);
				BorderColor3 = Color3.new(0, 0, 0);
				Name = "DynamicToolbar";
				Position = UDim2.new(0, 112, 0, 0);
				BackgroundColor3 = Color3.new(0.698039, 0.698039, 0.698039);
			};
		};
		Create'Frame'{
			Size = UDim2.new(1, 0, 0, -60);
			BorderColor3 = Color3.new(0, 0, 0);
			Name = "BottomPanel";
			Position = UDim2.new(0, 0, 1, -1);
			BackgroundColor3 = Color3.new(0.698039, 0.698039, 0.698039);
		};
	}
	local StudioFrame    = Screen.StudioFrame
	local Background     = StudioFrame.Background
	local ScaleGrid      = Background.ScaleGrid
	local OffsetGrid     = Background.OffsetGrid
	local Canvas         = StudioFrame.Canvas
	local Menu           = StudioFrame.Menu
	local ExportButton   = Menu.ExportButton
	local ImportButton   = Menu.ImportButton
	local PreviewButton  = Menu.PreviewButton
	local Tools          = StudioFrame.Tools
	local SelectionTool  = Tools.SelectionTool
	local ObjectTool     = Tools.ObjectTool
	local DynamicToolbar = StudioFrame.DynamicToolbar
	-- TEMP: select first tool
	ToolManager:SelectTool(1)
end

local function ActivateGUI()
	Screen.Parent = Game:GetService("CoreGui")
end

local function DeactivateGUI()
	Screen.Parent = nil
end
