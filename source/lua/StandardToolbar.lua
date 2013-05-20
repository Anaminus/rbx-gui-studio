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
				Position = UDim2.new(0,4,0,4);
				Size = UDim2.new(0.4,-8,1,-8);
				Name = "Position Group";
				BackgroundTransparency = 1;
				Create'Frame'{
					Position = UDim2.new(0,0,0,0);
					Size = UDim2.new(0.5,-4,1,0);
					Name = "X Component Group";
					BackgroundTransparency = 1;
					Create'TextLabel'{
						Position = UDim2.new(0, 0, 0, 0);
						Size = UDim2.new(0, 12, 1, 0);
						FontSize = Enum.FontSize.Size10;
						Text = "X";
						TextColor3 = GuiColor.Text;
						Name = "X Label";
						BackgroundTransparency = 1;
					};
					Create'TextBox'{
						Position = UDim2.new(0, 16, 0, 0);
						Size = UDim2.new(1, -16, 1, 0);
						FontSize = Enum.FontSize.Size9;
						Text = "";
						TextColor3 = GuiColor.Text;
						BorderColor3 = GuiColor.FieldBorder;
						Name = "XComponent";
						BackgroundColor3 = GuiColor.Field;
					};
				};
				Create'Frame'{
					Position = UDim2.new(0.5,0,0,0);
					Size = UDim2.new(0.5,-4,1,0);
					Name = "Y Component Group";
					BackgroundTransparency = 1;
					Create'TextLabel'{
						Position = UDim2.new(0, 0, 0, 0);
						Size = UDim2.new(0, 12, 1, 0);
						FontSize = Enum.FontSize.Size10;
						Text = "Y";
						TextColor3 = GuiColor.Text;
						Name = "Y Label";
						BackgroundTransparency = 1;
					};
					Create'TextBox'{
						Position = UDim2.new(0, 16, 0, 0);
						Size = UDim2.new(1, -16, 1, 0);
						FontSize = Enum.FontSize.Size9;
						Text = "";
						TextColor3 = GuiColor.Text;
						BorderColor3 = GuiColor.FieldBorder;
						Name = "YComponent";
						BackgroundColor3 = GuiColor.Field;
					};
				};
				Create'Frame'{
					Name = "Seperator";
					Position = UDim2.new(1, 0, 0, -4);
					Size = UDim2.new(0, 1, 1, 8);
					BorderSizePixel = 0;
					BorderColor3 = GuiColor.Border;
				};
			};
			Create'Frame'{
				Position = UDim2.new(0.4,4,0,4);
				Size = UDim2.new(0.4,-8,1,-8);
				Name = "Size Group";
				BackgroundTransparency = 1;
				Create'Frame'{
					Position = UDim2.new(0,0,0,0);
					Size = UDim2.new(0.5,-4,1,0);
					Name = "W Component Group";
					BackgroundTransparency = 1;
					Create'TextLabel'{
						Position = UDim2.new(0, 0, 0, 0);
						Size = UDim2.new(0, 12, 1, 0);
						FontSize = Enum.FontSize.Size10;
						Text = "W";
						TextColor3 = GuiColor.Text;
						Name = "W Label";
						BackgroundTransparency = 1;
					};
					Create'TextBox'{
						Position = UDim2.new(0, 16, 0, 0);
						Size = UDim2.new(1, -16, 1, 0);
						FontSize = Enum.FontSize.Size9;
						Text = "";
						TextColor3 = GuiColor.Text;
						BorderColor3 = GuiColor.FieldBorder;
						Name = "XComponent";
						BackgroundColor3 = GuiColor.Field;
					};
				};
				Create'Frame'{
					Position = UDim2.new(0.5,0,0,0);
					Size = UDim2.new(0.5,-4,1,0);
					Name = "H Component Group";
					BackgroundTransparency = 1;
					Create'TextLabel'{
						Position = UDim2.new(0, 0, 0, 0);
						Size = UDim2.new(0, 12, 1, 0);
						FontSize = Enum.FontSize.Size10;
						Text = "H";
						TextColor3 = GuiColor.Text;
						Name = "H Label";
						BackgroundTransparency = 1;
					};
					Create'TextBox'{
						Position = UDim2.new(0, 16, 0, 0);
						Size = UDim2.new(1, -16, 1, 0);
						FontSize = Enum.FontSize.Size9;
						Text = "";
						TextColor3 = GuiColor.Text;
						BorderColor3 = GuiColor.FieldBorder;
						Name = "YComponent";
						BackgroundColor3 = GuiColor.Field;
					};
				};
				Create'Frame'{
					Name = "Seperator";
					Position = UDim2.new(1, 0, 0, -4);
					Size = UDim2.new(0, 1, 1, 8);
					BorderSizePixel = 0;
					BorderColor3 = GuiColor.Border;
				};
			};
			Create'Frame'{
				Position = UDim2.new(0.8,4,0,4);
				Size = UDim2.new(0.2,-8,1,-8);
				Name = "SnapPadding Group";
				BackgroundTransparency = 1;
				Create'TextLabel'{
					Position = UDim2.new(0, 0, 0, 0);
					Size = UDim2.new(0, 12, 1, 0);
					FontSize = Enum.FontSize.Size10;
					Text = "Sp";
					TextColor3 = GuiColor.Text;
					Name = "Sp Label";
					BackgroundTransparency = 1;
				};
				Create'TextBox'{
					Position = UDim2.new(0, 16, 0, 0);
					Size = UDim2.new(1, -16, 1, 0);
					FontSize = Enum.FontSize.Size9;
					Text = "";
					TextColor3 = GuiColor.Text;
					BorderColor3 = GuiColor.FieldBorder;
					Name = "SnapPaddingField";
					BackgroundColor3 = GuiColor.Field;
				};
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

			local PosX  = DescendantByOrder(ComponentFrame,1,1,2)
			local PosY  = DescendantByOrder(ComponentFrame,1,2,2)
			local SizeX = DescendantByOrder(ComponentFrame,2,1,2)
			local SizeY = DescendantByOrder(ComponentFrame,2,2,2)

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

			-- SnapPadding field
			do
				local SnapPaddingField = DescendantByOrder(ComponentFrame,3,2)
				local prev = Settings.SnapPadding
				Settings.Changed:connect(function(key,value)
					if key == 'SnapPadding' then
						SnapPaddingField.Text = string.format('%i',value)
						prev = value
					end
				end)

				ToolTipService:AddToolTip(SnapPaddingField,"Snap padding")
				Maid:GiveTask(Widgets.MaskedTextBox(SnapPaddingField,function(textBox,text)
					local value = EvaluateInput(text)
					if value then
						Settings.SnapPadding = value
						return nil
					else
						return string.format('%i',prev)
					end
				end))

				SnapPaddingField.Text = prev
			end

			ComponentFrame.Visible = true
		end;
		Stop = function(self)
			self.Frame.Visible = false
			Maid:DoCleaning()
		end;
	}
end
