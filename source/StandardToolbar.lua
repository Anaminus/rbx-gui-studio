--[[StandardToolbar

API:

Fields:

StandardToolbar.Frame
	The GUI object that this class represents.
	Nil if the toolbar is not initialized.

ServiceStatus.Status
	Whether the service is started or not.

Methods:

StandardToolbar:Initialize()

StandardToolbar:Start()
StandardToolbar:Stop()

]]

do
	StandardToolbar = {}

	local SelectedObjects = Selection.SelectedObjects
	local Maid = CreateMaid()

	function StandardToolbar:Initialize()
		local GuiColor = InternalSettings.GuiColor
		local ComponentFrame = Create'Frame'{
			Size = UDim2.new(0, 530, 1, 0);
			BorderColor3 = GuiColor.Border;
			Name = "Components";
			BackgroundColor3 = GuiColor.Background;
			Visible = false;
			Create'Frame'{
				Size = UDim2.new(0.5, 0, 1, 0);
				Name = "Position Group";
				BackgroundTransparency = 1;
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size10;
					Text = "X";
					Size = UDim2.new(0, 12, 1, -8);
					TextColor3 = GuiColor.Text;
					Name = "X Label";
					Position = UDim2.new(0, 4, 0, 4);
					BackgroundTransparency = 1;
				};
				Create'TextBox'{
					FontSize = Enum.FontSize.Size9;
					Text = "";
					Size = UDim2.new(0.5, -40, 1, -16);
					TextColor3 = GuiColor.Text;
					BorderColor3 = GuiColor.FieldBorder;
					Name = "XComponent";
					Position = UDim2.new(0, 20, 0, 8);
					BackgroundColor3 = GuiColor.Field;
				};
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size10;
					Text = "Y";
					Size = UDim2.new(0, 12, 1, -8);
					TextColor3 = GuiColor.Text;
					Name = "Y Label";
					Position = UDim2.new(0.5, -16, 0, 4);
					BackgroundTransparency = 1;
				};
				Create'TextBox'{
					FontSize = Enum.FontSize.Size9;
					Text = "";
					Size = UDim2.new(0.5, -40, 1, -16);
					TextColor3 = GuiColor.Text;
					BorderColor3 = GuiColor.FieldBorder;
					Name = "YComponent";
					Position = UDim2.new(0.5, 0, 0, 8);
					BackgroundColor3 = GuiColor.Field;
				};
				Create'TextButton'{
					FontSize = Enum.FontSize.Size18;
					BackgroundColor3 = GuiColor.Button;
					Name = "SetToZero Button";
					Text = "0";
					Size = UDim2.new(0, 32, 1, -8);
					TextColor3 = GuiColor.Text;
					TextStrokeTransparency = 0;
					BorderColor3 = GuiColor.ButtonBorder;
					Position = UDim2.new(1, -36, 0, 4);
				};
			};
			Create'Frame'{
				Size = UDim2.new(0.5, 0, 1, 0);
				Name = "Size Group";
				Position = UDim2.new(0.5, 0, 0, 0);
				BackgroundTransparency = 1;
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size10;
					Text = "W";
					Size = UDim2.new(0, 12, 1, -8);
					TextColor3 = GuiColor.Text;
					Name = "W Label";
					Position = UDim2.new(0, 4, 0, 4);
					BackgroundTransparency = 1;
				};
				Create'TextBox'{
					FontSize = Enum.FontSize.Size9;
					Text = "";
					Size = UDim2.new(0.5, -40, 1, -16);
					TextColor3 = GuiColor.Text;
					BorderColor3 = GuiColor.FieldBorder;
					Name = "XComponent";
					Position = UDim2.new(0, 20, 0, 8);
					BackgroundColor3 = GuiColor.Field;
				};
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size10;
					Text = "H";
					Size = UDim2.new(0, 12, 1, -8);
					TextColor3 = GuiColor.Text;
					Name = "H Label";
					Position = UDim2.new(0.5, -16, 0, 4);
					BackgroundTransparency = 1;
				};
				Create'TextBox'{
					FontSize = Enum.FontSize.Size9;
					Text = "";
					Size = UDim2.new(0.5, -40, 1, -16);
					TextColor3 = GuiColor.Text;
					BorderColor3 = GuiColor.FieldBorder;
					Name = "YComponent";
					Position = UDim2.new(0.5, 0, 0, 8);
					BackgroundColor3 = GuiColor.Field;
				};
				Create'TextButton'{
					FontSize = Enum.FontSize.Size18;
					BackgroundColor3 = GuiColor.Button;
					Name = "SetToZero Button";
					Text = "0";
					Size = UDim2.new(0, 32, 1, -8);
					TextColor3 = GuiColor.Text;
					TextStrokeTransparency = 0;
					BorderColor3 = GuiColor.ButtonBorder;
					Position = UDim2.new(1, -36, 0, 4);
				};
			};
			Create'Frame'{
				BorderSizePixel = 0;
				Size = UDim2.new(0, 1, 1, 0);
				BorderColor3 = GuiColor.Border;
				Position = UDim2.new(0.5, 0, 0, 0);
			};
		};
		StandardToolbar.Frame = ComponentFrame
		return ComponentFrame
	end

	AddServiceStatus{StandardToolbar;
		Start = function(self)
			if not self.Frame then
				error("StandardToolbar must be initialized before starting",2)
			end

			local ComponentFrame = self.Frame
			local layoutMode = Settings.LayoutMode('Scale')
			local currentObject

			local PosX  = DescendantByOrder(ComponentFrame,1,2)
			local PosY  = DescendantByOrder(ComponentFrame,1,4)
			local SizeX = DescendantByOrder(ComponentFrame,2,2)
			local SizeY = DescendantByOrder(ComponentFrame,2,4)

			do
				-- Here, we're going to have the selected object update when a
				-- TextBox is edited by the user. Instead of defining the
				-- functionality for each TextBox individually, we're going to map
				-- each TextBox to its related components, and use a generic
				-- function that handles every TextBox. This will make the code
				-- shorter and easier to maintain. It's slower, but that's fine
				-- since FocusLost only fires when the user edits the text, which
				-- doesn't happen often enough to make a difference.

				-- a map of each TextBox to which components it edits
				local getComponent = {
					-- third entry is the location of the Scale component in the arguments to UDim2.new()
					[PosX]  = {'Position', 'X', 1, "The X coordinate of the Position"};
					[PosY]  = {'Position', 'Y', 3, "The Y coordinate of the Position"};
					[SizeX] = {    'Size', 'X', 1,     "The X coordinate of the Size"};
					[SizeY] = {    'Size', 'Y', 3,     "The X coordinate of the Size"};
				}

				local function textMask(textBox,text)
					if currentObject then
						local c = getComponent[textBox]
						local p = currentObject[c[1]]
						local l = layoutMode and 'Scale' or 'Offset'
						local prev = p[c[2]][l]
						local value = EvaluateInput(text,{
							n = prev;
							x = currentObject.Position.X[l];
							y = currentObject.Position.Y[l];
							w = currentObject.Size.X[l];
							h = currentObject.Size.Y[l];
						})
						if value then
							local comp = {p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset}
							-- if layoutMode is Offset, add 1 to the location
							comp[c[3] + (layoutMode and 0 or 1)] = value
							currentObject[c[1]] = UDim2.new(unpack(comp))
							-- setting the property already updates the TextBox's text
						else
							return string.format('%g',prev)
						end
					else
						return ''
					end
				end

				for textBox,data in pairs(getComponent) do
					ToolTipService:AddToolTip(textBox,data[4])
					Maid:GiveTask(Widgets.MaskedTextBox(textBox,textMask))
				end
			end

			local format = string.format
			local formatString = '%g'
			local function updateComponents(p)
				if p == 'AbsolutePosition' then
					if layoutMode then
						PosX.Text = format(formatString,currentActive.Position.X.Scale)
						PosY.Text = format(formatString,currentActive.Position.Y.Scale)
					else
						PosX.Text = currentActive.Position.X.Offset
						PosY.Text = currentActive.Position.Y.Offset
					end
				elseif p == 'AbsoluteSize' then
					if layoutMode then
						SizeX.Text = format(formatString,currentActive.Size.X.Scale)
						SizeY.Text = format(formatString,currentActive.Size.Y.Scale)
					else
						SizeX.Text = currentActive.Size.X.Offset
						SizeY.Text = currentActive.Size.Y.Offset
					end
				end
			end

			local function updateObject(object,active)
				if Maid.ComponentsChanged then
					Maid.ComponentsChanged:disconnect()
					Maid.ComponentsChanged = nil
				end
				currentObject = nil
				currentActive = nil
				if object then
					currentObject = object
					currentActive = active
					Maid.ComponentsChanged = active.Changed:connect(updateComponents)
					updateComponents('AbsolutePosition')
					updateComponents('AbsoluteSize')
				else
					PosX.Text  = ''
					PosY.Text  = ''
					SizeX.Text = ''
					SizeY.Text = ''
				end
			end

			local SetPosZero = DescendantByOrder(ComponentFrame,1,5)
			local SetSizeZero = DescendantByOrder(ComponentFrame,2,5)

			ToolTipService:AddToolTip(SetPosZero,"Set the opposite layout component of the Position to 0")
			ToolTipService:AddToolTip(SetSizeZero,"Set the opposite layout component of the Size to 0")

			Maid:GiveTask(SetPosZero.MouseButton1Click:connect(function()
				if layoutMode then
				--	for i = 1,#SelectedObjects do
					if SelectedObjects[1] then
						local object = SelectedObjects[1]
						local p = object.Position
						object.Position = UDim2.new(p.X.Scale,0,p.Y.Scale,0)
					end
				else
				--	for i = 1,#SelectedObjects do
					if SelectedObjects[1] then
						local object = SelectedObjects[1]
						local p = object.Position
						object.Position = UDim2.new(0,p.X.Offset,0,p.Y.Offset)
					end
				end
			end))
			Maid:GiveTask(SetSizeZero.MouseButton1Click:connect(function()
				if layoutMode then
				--	for i = 1,#SelectedObjects do
					if SelectedObjects[1] then
						local object = SelectedObjects[1]
						local s = object.Size
						object.Size = UDim2.new(s.X.Scale,0,s.Y.Scale,0)
					end
				else
				--	for i = 1,#SelectedObjects do
					if SelectedObjects[1] then
						local object = SelectedObjects[1]
						local s = object.Size
						object.Size = UDim2.new(0,s.X.Offset,0,s.Y.Offset)
					end
				end
			end))

			Maid.component_layout = Settings.Changed:connect(function(key,value)
				if key == 'LayoutMode' then
					layoutMode = Settings.LayoutMode('Scale')
					if currentObject then
						updateComponents('AbsolutePosition')
						updateComponents('AbsoluteSize')
					end
				end
			end)

			Maid.detect_component_selected = Selection.ObjectSelected:connect(updateObject)
			local activeLookup = Canvas.ActiveLookup
			Maid.detect_component_deselected = Selection.ObjectDeselected:connect(function()
				if #SelectedObjects > 0 then
					local object = SelectedObjects[#SelectedObjects]
					updateObject(object,activeLookup[object])
				else
					updateObject()
				end
			end)
			if #SelectedObjects > 0 then
				local object = SelectedObjects[#SelectedObjects]
				updateObject(object,activeLookup[object])
			else
				updateObject()
			end

			ComponentFrame.Visible = true
		end;
		Stop = function(self)
			self.Frame.Visible = false
			Maid:DoCleaning()
		end;
	}
end
