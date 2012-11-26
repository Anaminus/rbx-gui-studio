--[[

]]
do
	function Dialogs.ExportScreen(parent,eventCancel)
		KeyBinding.Enabled = false
		local GuiColor = InternalSettings.GuiColor
		local Dialog = Create'ScreenGui'{
			Name = "ExportDialog";
			Create'ImageButton'{
				Name = "Shield";
				ZIndex = 10;
				BorderSizePixel = 0;
				BackgroundTransparency = 0.5;
				Position = UDim2.new(-0.25,0,-0.25,0);
				Size = UDim2.new(1.5,0,1.5,0);
				BackgroundColor3 = Color3.new(0,0,0);
				AutoButtonColor = false;
			};
			Create'Frame'{
				Name = "Shadow";
				ZIndex = 10;
				BorderSizePixel = 0;
				BackgroundTransparency = 0.8;
				Position = UDim2.new(0.25,6,0.125,6);
				Size = UDim2.new(0.5,0,0.75,0);
				BackgroundColor3 = Color3.new(0,0,0);
			};
			Create'Frame'{
				Name = "DialogFrame";
				ZIndex = 10;
				Position = UDim2.new(0.25,0,0.125,0);
				Size = UDim2.new(0.5,0,0.75,0);
				BorderColor3 = GuiColor.Border;
				BackgroundColor3 = GuiColor.Background;
				Create'Frame'{
					Name = "TitleBar";
					ZIndex = 10;
					Size = UDim2.new(1,0,0,24);
					BorderColor3 = GuiColor.Border;
					BackgroundColor3 = GuiColor.TitleBackground;
					Create'TextLabel'{
						Name = "Title";
						ZIndex = 10;
						BackgroundTransparency = 1;
						Position = UDim2.new(0,3,0,3);
						Size = UDim2.new(1,-6,1,-6);
						Text = "Export Screen...";
						TextStrokeTransparency = 0;
						TextXAlignment = Enum.TextXAlignment.Left;
						FontSize = Enum.FontSize.Size12;
						TextStrokeColor3 = GuiColor.Border;
						TextColor3 = Color3.new(1,1,1);
					};
				};
				Create'TextLabel'{
					Name = "Format Label";
					ZIndex = 10;
					BorderSizePixel = 0;
					BackgroundTransparency = 1;
					Position = UDim2.new(0,8,0,32);
					Size = UDim2.new(0,48,0,24);
					Text = "Format:";
					TextXAlignment = Enum.TextXAlignment.Right;
					FontSize = Enum.FontSize.Size10;
					TextColor3 = GuiColor.Text;
				};
				Create'ImageButton'{
					Name = "Format DropDown";
					ZIndex = 10;
					Position = UDim2.new(0,64,0,32);
					Size = UDim2.new(0.5,-72,0,24);
					BorderColor3 = GuiColor.FieldBorder;
					BackgroundColor3 = GuiColor.Field;
				};
				Create'TextLabel'{
					Name = "Options Label";
					ZIndex = 10;
					BackgroundTransparency = 1;
					Position = UDim2.new(0,8,0,64);
					Size = UDim2.new(1,-16,0,16);
					Text = "Format Options:";
					TextXAlignment = Enum.TextXAlignment.Left;
					FontSize = Enum.FontSize.Size10;
					TextColor3 = GuiColor.Text;
				};
				Create'Frame'{
					Name = "Options Frame";
					ZIndex = 10;
					Position = UDim2.new(0,8,0,82);
					Size = UDim2.new(1,-16,0,90);
					BorderColor3 = GuiColor.FieldBorder;
					BackgroundColor3 = GuiColor.Field;
				};
				Create'TextLabel'{
					Name = "Preview Label";
					ZIndex = 10;
					BackgroundTransparency = 1;
					Position = UDim2.new(0,8,0,180);
					Size = UDim2.new(1,-16,0,16);
					Text = "Preview:";
					TextXAlignment = Enum.TextXAlignment.Left;
					FontSize = Enum.FontSize.Size10;
					TextColor3 = GuiColor.Text;
				};
				Create'Frame'{
					Name = "Preview Frame";
					ZIndex = 10;
					ClipsDescendants = true;
					Position = UDim2.new(0,8,0,198);
					Size = UDim2.new(1,-16,1,-246);
					BorderColor3 = GuiColor.FieldBorder;
					BackgroundColor3 = GuiColor.Field;
					Create'TextLabel'{
						Name = "Preview Text";
						ZIndex = 10;
						BackgroundTransparency = 1;
						Position = UDim2.new(0,4,0,4);
						Size = UDim2.new(0,2048,2,0);
						TextWrapped = true;
						TextYAlignment = Enum.TextYAlignment.Top;
						TextXAlignment = Enum.TextXAlignment.Left;
						FontSize = Enum.FontSize.Size9;
						TextColor3 = GuiColor.TextDisabled;
					};
				};
				Create'TextButton'{
					Name = "OKButton";
					ZIndex = 10;
					Position = UDim2.new(1,-144,1,-40);
					Size = UDim2.new(0,64,0,32);
					BorderColor3 = GuiColor.ButtonBorder;
					BackgroundColor3 = GuiColor.Button;
					Text = "OK";
					FontSize = Enum.FontSize.Size10;
					TextColor3 = GuiColor.Text;
				};
				Create'TextButton'{
					Name = "CancelButton";
					ZIndex = 10;
					Position = UDim2.new(1,-72,1,-40);
					Size = UDim2.new(0,64,0,32);
					BorderColor3 = GuiColor.ButtonBorder;
					BackgroundColor3 = GuiColor.Button;
					Text = "Cancel";
					FontSize = Enum.FontSize.Size10;
					TextColor3 = GuiColor.Text;
				};
			};
		};

		local FormatInput = DescendantByOrder(Dialog,3,3)
		local OptionsInput =DescendantByOrder(Dialog,3,5)
		local PreviewFrame =DescendantByOrder(Dialog,3,7,1)

		local OKButton = DescendantByOrder(Dialog,3,8)
		local CancelButton = DescendantByOrder(Dialog,3,9)

		local formatName = 'RobloxLua'
		local formatOptions = {
			Indent = true;
			ExcludeFunction = true;
		}

		PreviewFrame.Text = Exporter:Export(Canvas.CurrentScreen,formatName,formatOptions,512)

		local dialog = Widgets.DialogBase()

		local conCancel
		if eventCancel then
			conCancel = eventCancel:connect(function()
				dialog:Return(nil)
			end)
		end

		OKButton.MouseButton1Click:connect(function()
			local exportString = Exporter:Export(Canvas.CurrentScreen,formatName,formatOptions)
			dialog:Return(exportString)
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
		--	conSelection:disconnect()
			Dialog:Destroy()
			DialogFrame:Destroy()
			Shield:Destroy()
			KeyBinding.Enabled = true
		end)
	end
end
