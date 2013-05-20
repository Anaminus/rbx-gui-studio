--[[Configure Grid Dialog
Configures options for the grid.

Arguments:
	parent
		Where to put the dialog.
		Because of bug #2, this should be a ScreenGui.
		When this bug is fixed, this will be an object that contains ScreenGuis, such as CoreGui or PlayerGui.

	eventCancel
		An event that the dialog connects to. If the event fires, the dialog will automatically cancel. Optional.

Returns:
	grid_origin
		A UDim2 representing the new origin of the grid.

	grid_spacing
		A UDim2 representing the new spacing of the grid.

	scale_color
		A Color4 representing the new color of the Scale grid.

	offset_color
		A Color4 representing the new color of the Offset grid.

	snapping_enabled
		A bool indicating whether grid snapping is enabled.

	snapping_tolerance
		A number indicating how close the snapping point must be to a grid line before snapping to it, in pixels.
]]

do
	local currentTab = {1}
	function Dialogs.ConfigGrid(parent,eventCancel)
		KeyBinding.Enabled = false
		local GuiColor = InternalSettings.GuiColor
		local ScaleTab = Create'Frame'{
			Size = UDim2.new(1, 0, 1, 0);
			BorderColor3 = GuiColor.Border;
			Name = "Scale Grid";
			BackgroundColor3 = GuiColor.Background;
			ZIndex = 10;
			Create'Frame'{
				Size = UDim2.new(1, -16, 1, -8);
				Name = "PaddingContainer";
				Position = UDim2.new(0, 8, 0, 8);
				BackgroundTransparency = 1;
				ZIndex = 10;
				Create'Frame'{
					Size = UDim2.new(1, 8, 0.166667, -8);
					Name = "PaddingContainer";
					BackgroundTransparency = 1;
					ZIndex = 10;
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size10;
						Text = "Width";
						Size = UDim2.new(0.375, -8, 1, 0);
						TextColor3 = GuiColor.Text;
						Name = "Width Label";
						Position = UDim2.new(0.25, 0, 0, 0);
						TextYAlignment = Enum.TextYAlignment.Bottom;
						BackgroundTransparency = 1;
						ZIndex = 10;
					};
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size10;
						Text = "Height";
						Size = UDim2.new(0.375, -8, 1, 0);
						TextColor3 = GuiColor.Text;
						Name = "Height Label";
						Position = UDim2.new(0.625, 0, 0, 0);
						TextYAlignment = Enum.TextYAlignment.Bottom;
						BackgroundTransparency = 1;
						ZIndex = 10;
					};
				};
				Create'Frame'{
					Size = UDim2.new(1, 8, 0.166667, -8);
					Name = "PaddingContainer";
					Position = UDim2.new(0, 0, 0.166667, 0);
					BackgroundTransparency = 1;
					ZIndex = 10;
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size10;
						Text = "Origin";
						Size = UDim2.new(0.25, -8, 1, 0);
						TextColor3 = GuiColor.Text;
						TextXAlignment = Enum.TextXAlignment.Right;
						Name = "Origin Label";
						BackgroundTransparency = 1;
						ZIndex = 10;
					};
					Create'TextBox'{
						FontSize = Enum.FontSize.Size9;
						Text = "0";
						Size = UDim2.new(0.375, -8, 1, 0);
						TextColor3 = GuiColor.Text;
						BorderColor3 = GuiColor.FieldBorder;
						Name = "Origin Width NumberInput";
						Position = UDim2.new(0.25, 0, 0, 0);
						BackgroundColor3 = GuiColor.Field;
						ZIndex = 10;
					};
					Create'TextBox'{
						FontSize = Enum.FontSize.Size9;
						Text = "0";
						Size = UDim2.new(0.375, -8, 1, 0);
						TextColor3 = GuiColor.Text;
						BorderColor3 = GuiColor.FieldBorder;
						Name = "Origin Height NumberInput";
						Position = UDim2.new(0.625, 0, 0, 0);
						BackgroundColor3 = GuiColor.Field;
						ZIndex = 10;
					};
				};
				Create'Frame'{
					Size = UDim2.new(1, 8, 0.166667, -8);
					Name = "PaddingContainer";
					Position = UDim2.new(0, 0, 0.333333, 0);
					BackgroundTransparency = 1;
					ZIndex = 10;
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size10;
						Text = "Spacing";
						Size = UDim2.new(0.25, -8, 1, 0);
						TextColor3 = GuiColor.Text;
						TextXAlignment = Enum.TextXAlignment.Right;
						Name = "Spacing Label";
						BackgroundTransparency = 1;
						ZIndex = 10;
					};
					Create'TextBox'{
						FontSize = Enum.FontSize.Size9;
						Text = "0";
						Size = UDim2.new(0.375, -8, 1, 0);
						TextColor3 = GuiColor.Text;
						BorderColor3 = GuiColor.FieldBorder;
						Name = "Spacing Width NumberInput";
						Position = UDim2.new(0.25, 0, 0, 0);
						BackgroundColor3 = GuiColor.Field;
						ZIndex = 10;
					};
					Create'TextBox'{
						FontSize = Enum.FontSize.Size9;
						Text = "0";
						Size = UDim2.new(0.375, -8, 1, 0);
						TextColor3 = GuiColor.Text;
						BorderColor3 = GuiColor.FieldBorder;
						Name = "Spacing Height NumberInput";
						Position = UDim2.new(0.625, 0, 0, 0);
						BackgroundColor3 = GuiColor.Field;
						ZIndex = 10;
					};
				};
				Create'Frame'{
					Size = UDim2.new(1, 8, 0.166667, -8);
					Name = "PaddingContainer";
					Position = UDim2.new(0, 0, 0.5, 0);
					BackgroundTransparency = 1;
					ZIndex = 10;
				--[[
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size10;
						Text = "Color";
						Size = UDim2.new(0.25, -8, 1, 0);
						TextColor3 = GuiColor.Text;
						TextXAlignment = Enum.TextXAlignment.Right;
						Name = "Color Label";
						BackgroundTransparency = 1;
						ZIndex = 10;
					};
					Create'ImageButton'{
						Size = UDim2.new(0.75, -8, 1, 0);
						BorderColor3 = GuiColor.FieldBorder;
						AutoButtonColor = false;
						Name = "GridlineColor ColorInput";
						Position = UDim2.new(0.25, 0, 0, 0);
						BackgroundColor3 = GuiColor.Field;
						ZIndex = 10;
					};
				--]]
				};
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size11;
					Text = "Many GUI objects may have to be rendered, which could result in reduced performance.";
					Size = UDim2.new(1, 0, 0.333333, -8);
					TextColor3 = Color3.new(0.721569, 0, 0);
					TextWrap = true;
					Visible = false;
					Name = "SpacingWarning";
					Position = UDim2.new(0, 0, 0.666667, 0);
					BackgroundTransparency = 1;
					ZIndex = 10;
				};
			};
		};

		local OffsetTab = ScaleTab:Clone()
		OffsetTab.Name = "Offset Grid"

		local SnapTab = Create'Frame'{
			Name = "Snapping";
			Size = UDim2.new(1, 0, 1, 0);
			BackgroundColor3 = GuiColor.Background;
			BorderColor3 = GuiColor.Border;
			ZIndex = 10;
			Create'Frame'{
				Name = "PaddingContainer";
				Size = UDim2.new(1, -16, 1, -8);
				Position = UDim2.new(0, 8, 0, 8);
				BackgroundTransparency = 1;
				ZIndex = 10;
				Create'Frame'{
					Name = "PaddingContainer";
					Size = UDim2.new(1, 8, 0.166667, -8);
					BackgroundTransparency = 1;
					ZIndex = 10;
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size10;
						Text = "Enabled";
						ZIndex = 10;
						Size = UDim2.new(0.25, -8, 1, 0);
						TextColor3 = GuiColor.Text;
						TextXAlignment = Enum.TextXAlignment.Right;
						Name = "SnapEnabled Label";
						BackgroundTransparency = 1;
					};
					Create'TextButton'{
						FontSize = Enum.FontSize.Size18;
						SizeConstraint = Enum.SizeConstraint.RelativeYY;
						ZIndex = 10;
						BackgroundColor3 = GuiColor.Field;
						Name = "SnapEnabled CheckBox";
						Text = "X";
						Selected = true;
						Size = UDim2.new(1, 0, 1, 0);
						TextColor3 = GuiColor.Text;
						BorderColor3 = GuiColor.FieldBorder;
						Font = Enum.Font.ArialBold;
						Position = UDim2.new(0.25, 0, 0, 0);
					};
				};
				Create'Frame'{
					ZIndex = 10;
					Size = UDim2.new(1, 8, 0.166667, -8);
					Name = "PaddingContainer";
					Position = UDim2.new(0, 0, 0.166667, 0);
					BackgroundTransparency = 1;
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size10;
						Text = "Tolerance";
						ZIndex = 10;
						Size = UDim2.new(0.25, -8, 1, 0);
						TextColor3 = GuiColor.Text;
						TextXAlignment = Enum.TextXAlignment.Right;
						Name = "SnapTolerance Label";
						BackgroundTransparency = 1;
					};
					Create'TextBox'{
						FontSize = Enum.FontSize.Size9;
						Text = "0";
						ZIndex = 10;
						Size = UDim2.new(0.25, -8, 1, 0);
						TextColor3 = GuiColor.Text;
						BorderColor3 = GuiColor.FieldBorder;
						Name = "SnapTolerance NumberInput";
						Position = UDim2.new(0.25, 0, 0, 0);
						BackgroundColor3 = GuiColor.Field;
					};
				};
			};
		};
		local Dialog = Create'ScreenGui'{
			Name = "ConfigGrid Dialog";
			Create'ImageButton'{
				Active = true;
				AutoButtonColor = false;
				BorderSizePixel = 0;
				Size = UDim2.new(1.5, 0, 1.5, 0);
				Name = "Shield";
				Position = UDim2.new(-0.25, 0, -0.25, 0);
				BackgroundTransparency = 0.5;
				BackgroundColor3 = Color3.new(0, 0, 0);
				ZIndex = 10;
			};
			Create'Frame'{
				Name = "Shadow";
				BorderSizePixel = 0;
				Size = UDim2.new(0, 300, 0, 250);
				Position = UDim2.new(0.5, -146, 0.5, -121);
				BackgroundTransparency = 0.8;
				BackgroundColor3 = Color3.new(0, 0, 0);
				ZIndex = 10;
			};
			Create'Frame'{
				Size = UDim2.new(0, 350, 0, 300);
				BorderColor3 = GuiColor.Border;
				Name = "DialogFrame";
				Position = UDim2.new(0.5, -175, 0.5, -150);
				BackgroundColor3 = GuiColor.Background;
				ZIndex = 10;
				Create'Frame'{
					Size = UDim2.new(1, 0, 0, 24);
					BorderColor3 = GuiColor.Border;
					Name = "TitleBar";
					BackgroundColor3 = GuiColor.TitleBackground;
					ZIndex = 10;
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size12;
						Text = "Configure Grid";
						Size = UDim2.new(1, -6, 1, -6);
						TextColor3 = Color3.new(1, 1, 1);
						TextStrokeTransparency = 0;
						TextStrokeColor3 = GuiColor.Border;
						TextXAlignment = Enum.TextXAlignment.Left;
						Name = "Title";
						Position = UDim2.new(0, 3, 0, 3);
						BackgroundTransparency = 1;
						ZIndex = 10;
					};
				};
				Create(Widgets.TabContainer(nil,{ScaleTab,OffsetTab,SnapTab},currentTab)){
					Position = UDim2.new(0,8,0,32);
					Size = UDim2.new(1,-16,1,-80);
				};
				Create'TextButton'{
					FontSize = Enum.FontSize.Size12;
					BackgroundColor3 = GuiColor.Button;
					Name = "OKButton";
					Text = "OK";
					Size = UDim2.new(0, 64, 0, 32);
					TextColor3 = GuiColor.Text;
					BorderColor3 = GuiColor.ButtonBorder;
					Position = UDim2.new(1, -144, 1, -40);
					ZIndex = 10;
				};
				Create'TextButton'{
					FontSize = Enum.FontSize.Size12;
					BackgroundColor3 = GuiColor.Button;
					Name = "CancelButton";
					Text = "Cancel";
					Size = UDim2.new(0, 64, 0, 32);
					TextColor3 = GuiColor.Text;
					BorderColor3 = GuiColor.ButtonBorder;
					Position = UDim2.new(1, -72, 1, -40);
					ZIndex = 10;
				};
			};
		}

		local OriginXScale   = DescendantByOrder(ScaleTab, 1,2,2)
		local OriginXOffset  = DescendantByOrder(OffsetTab,1,2,2)
		local OriginYScale   = DescendantByOrder(ScaleTab, 1,2,3)
		local OriginYOffset  = DescendantByOrder(OffsetTab,1,2,3)

		local SpacingXScale  = DescendantByOrder(ScaleTab, 1,3,2)
		local SpacingXOffset = DescendantByOrder(OffsetTab,1,3,2)
		local SpacingYScale  = DescendantByOrder(ScaleTab, 1,3,3)
		local SpacingYOffset = DescendantByOrder(OffsetTab,1,3,3)

		local gridProperties = {
			Origin = Grid.Origin;
			Spacing = Grid.Spacing;
			SnapEnabled = Settings.SnapEnabled;
			SnapTolerance = Settings.SnapTolerance;
			ScaleColor = Grid.ScaleLineColor;
			OffsetColor = Grid.OffsetLineColor;
		}

		local clearToolTips = {}

		do	-- map TextBoxes to grid components
			local inputComponents = {
				[ OriginXScale ] = { 'Origin', 'X',  'Scale', 1,   "Grid.Origin.Scale.X"};
				[ OriginXOffset] = { 'Origin', 'X', 'Offset', 2,  "Grid.Origin.Offset.X"};
				[ OriginYScale ] = { 'Origin', 'Y',  'Scale', 3,   "Grid.Origin.Scale.Y"};
				[ OriginYOffset] = { 'Origin', 'Y', 'Offset', 4,  "Grid.Origin.Offset.Y"};
				[SpacingXScale ] = {'Spacing', 'X',  'Scale', 1,  "Grid.Spacing.Scale.X"};
				[SpacingXOffset] = {'Spacing', 'X', 'Offset', 2, "Grid.Spacing.Offset.X"};
				[SpacingYScale ] = {'Spacing', 'Y',  'Scale', 3,  "Grid.Spacing.Scale.Y"};
				[SpacingYOffset] = {'Spacing', 'Y', 'Offset', 4, "Grid.Spacing.Offset.Y"};
			}

			local function textMask(textBox,text)
				local c = inputComponents[textBox]
				local prev = gridProperties[c[1]][c[2]][c[3]]
				local value = EvaluateInput(text,{n = prev})
				if value then
					if c[3] == 'Offset' then
						value = math.floor(value)
					end
					if value > 0 or c[1] == 'Origin' then
						local p = gridProperties[c[1]]
						local comp = {p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset}
						comp[c[4]] = value
						gridProperties[c[1]] = UDim2.new(unpack(comp))
						return string.format('%g',value)
					end
				end
				return string.format('%g',prev)
			end

			for textBox,c in pairs(inputComponents) do
				textBox.Text = string.format('%g',gridProperties[c[1]][c[2]][c[3]])
				ToolTipService:AddToolTip(textBox,c[5])
				clearToolTips[#clearToolTips+1] = textBox
				Widgets.MaskedTextBox(textBox,textMask)
			end
		end

		do	-- display warning for Scale grid
			local smallNum = 1/32
			local Warning = DescendantByOrder(ScaleTab,1,5)
			local xSmall = tonumber(SpacingXScale.Text) and tonumber(SpacingXScale.Text) < smallNum
			local ySmall = tonumber(SpacingYScale.Text) and tonumber(SpacingYScale.Text) < smallNum
			SpacingXScale.Changed:connect(function(p)
				if p == 'Text' then
					local num = tonumber(SpacingXScale.Text)
					xSmall = num and num < smallNum
					Warning.Visible = xSmall or ySmall
				end
			end)
			SpacingYScale.Changed:connect(function(p)
				if p == 'Text' then
					local num = tonumber(SpacingYScale.Text)
					ySmall = num and num < smallNum
					Warning.Visible = xSmall or ySmall
				end
			end)
			Warning.Visible = xSmall or ySmall
		end

		do	-- display warning for Offset grid
			local smallNum = 12
			local Warning = DescendantByOrder(OffsetTab,1,5)
			local xSmall = tonumber(SpacingXOffset.Text) and tonumber(SpacingXOffset.Text) <= smallNum
			local ySmall = tonumber(SpacingYOffset.Text) and tonumber(SpacingYOffset.Text) <= smallNum
			SpacingXOffset.Changed:connect(function(p)
				if p == 'Text' then
					local num = tonumber(SpacingXOffset.Text)
					xSmall = num and num <= smallNum
					Warning.Visible = xSmall or ySmall
				end
			end)
			SpacingYOffset.Changed:connect(function(p)
				if p == 'Text' then
					local num = tonumber(SpacingYOffset.Text)
					ySmall = num and num <= smallNum
					Warning.Visible = xSmall or ySmall
				end
			end)
			Warning.Visible = xSmall or ySmall
		end

		local SnapEnabled   = DescendantByOrder(SnapTab,1,1,2)
		local SnapTolerance = DescendantByOrder(SnapTab,1,2,2)

		ToolTipService:AddToolTip(SnapEnabled,"Toggles whether objects will snap to the grid.")
		clearToolTips[#clearToolTips+1] = SnapEnabled
		SnapEnabled.MouseButton1Click:connect(function()
			SnapEnabled.Selected = not SnapEnabled.Selected
		end)
		SnapEnabled.Changed:connect(function(p)
			if p == "Selected" then
				local enabled = SnapEnabled.Selected
				SnapEnabled.Text = enabled and "X" or ""
				gridProperties.SnapEnabled = enabled
			end
		end)
		SnapEnabled.Selected = gridProperties.SnapEnabled

		ToolTipService:AddToolTip(SnapTolerance,"Sets the maximum distance a snapping point must be from a grid line to snap to it, in pixels.")
		clearToolTips[#clearToolTips+1] = SnapTolerance
		SnapTolerance.Text = gridProperties.SnapTolerance
		Widgets.MaskedTextBox(SnapTolerance,function(textBox,text)
			local prev = gridProperties.SnapTolerance
			local value = EvaluateInput(text,{n=prev})
			if value then
				value = math.floor(value)
				value = value < 0 and 0 or value
				gridProperties.SnapTolerance = value
				return value
			else
				return prev
			end
		end)

	--	local ScaleLineColor  = DescendantByOrder(ScaleTab, 1,4,2)
	--	local OffsetLineColor = DescendantByOrder(OffsetTab,1,4,2)

		local OKButton = DescendantByOrder(Dialog,3,3)
		local CancelButton = DescendantByOrder(Dialog,3,4)

		local dialog = Widgets.DialogBase()

		local conCancel
		if eventCancel then
			conCancel = eventCancel:connect(function()
				dialog:Return(nil)
			end)
		end

		OKButton.MouseButton1Click:connect(function()
			dialog:Return(
				gridProperties.Origin,
				gridProperties.Spacing,
				gridProperties.ScaleColor,
				gridProperties.OffsetColor,
				gridProperties.SnapEnabled,
				gridProperties.SnapTolerance
			)
		end)

		CancelButton.MouseButton1Click:connect(function()
			dialog:Return(nil)
		end)

	--[[
		Dialog.Parent = Game:GetService("CoreGui")
	--[=[]]
		-- roblox bug: drawing order of ScreenGuis behaves erratically
		local DialogFrame = DescendantByOrder(Dialog,3)
		local Shield = DescendantByOrder(Dialog,1)

		Shield.Parent = parent
		DialogFrame.Parent = parent
	--]=]

		return dialog:Finish(function()
			if conCancel then conCancel:disconnect() end
			for object in pairs(clearToolTips) do
				ToolTipService:RemoveToolTip(object)
			end
			Dialog:Destroy()
			DialogFrame:Destroy()
			Shield:Destroy()
			KeyBinding.Enabled = true
		end)
	end
end
