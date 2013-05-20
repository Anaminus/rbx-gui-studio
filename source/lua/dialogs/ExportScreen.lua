--[[

]]
do
	local formatNamePersist = Exporter.FormatList[1]
	local formatOptionsPersist = {}
	for format,data in pairs(Exporter.FormatOptions) do
		local options = {}
		for k,v in pairs(data) do
			options[k] = v[2]
		end
		formatOptionsPersist[format] = options
	end
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
				Create'Frame'{
					Name = "Format DropDownContainer";
					BackgroundTransparency = 1;
					ZIndex = 10;
					Position = UDim2.new(0,64,0,32);
					Size = UDim2.new(0,148,0,24);
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
				Create'TextLabel'{
					Name = "Message";
					ZIndex = 10;
					BackgroundTransparency = 1;
					Visible = false;
					Position = UDim2.new(0,8,1,-40);
					Size = UDim2.new(1,-160,0,32);
					Text = "Exporting...";
					TextXAlignment = Enum.TextXAlignment.Right;
					FontSize = Enum.FontSize.Size10;
					TextColor3 = GuiColor.Text;
				};
			};
		};

		local FormatInput  = DescendantByOrder(Dialog,3,3)
		local OptionsInput = DescendantByOrder(Dialog,3,5)
		local PreviewFrame = DescendantByOrder(Dialog,3,7,1)

		local OKButton = DescendantByOrder(Dialog,3,8)
		local CancelButton = DescendantByOrder(Dialog,3,9)
		local ExportMessage = DescendantByOrder(Dialog,3,10)

		local formatName = formatNamePersist
		local formatOptions = formatOptionsPersist[formatName]

		local OptionsList do
			local tt = {}
			for k,v in pairs(Exporter.FormatOptions[formatName]) do
				tt[k] = v[3]
			end
			OptionsList = Widgets.PairsList(formatOptions,tt)
			OptionsList.GUI.Size = UDim2.new(1,0,1,0)
			OptionsList.GUI.Parent = OptionsInput
		end

		local function updatePreview()
			local preview = Exporter:Export(Canvas.CurrentScreen,formatName,formatOptions,512)
			if #preview >= 512 then
				preview = preview:sub(1,509) .. '...'
			end
			PreviewFrame.Text = preview
		end

		local function updateFormat()
			formatOptions = formatOptionsPersist[formatName]
			OptionsList.Pairs = formatOptions

			local tt = {}
			for k,v in pairs(Exporter.FormatOptions[formatName]) do
				tt[k] = v[3]
			end
			OptionsList.ToolTipLookup = tt

			OptionsList:Update()
			OptionsList:Sort()
			updatePreview()
		end

		updateFormat()

		OptionsList.PairChanged:connect(function()
			updatePreview()
		end)

		local FormatDropDown do
			local list = Exporter.FormatList
			local index = 1
			local desc = Exporter.FormatDescription
			local tooltips = {}
			for i=1,#list do
				if list[i] == formatName then
					index = i
				end
				tooltips[i] = desc[list[i]] or false
			end
			FormatDropDown = Widgets.DropDown(list,index,tooltips)
		end
		Create(FormatDropDown.GUI){
			Position = UDim2.new(0,0,0,0);
			Size = UDim2.new(1,0,1,0);
			ZIndex = 10;
			Parent = FormatInput;
		}
		FormatDropDown.SelectionChanged:connect(function(format)
			formatName = format
			formatNamePersist = format
			updateFormat()
		end)

		local dialog = Widgets.DialogBase()

		local exporting = false

		local conCancel
		if eventCancel then
			conCancel = eventCancel:connect(function()
				if exporting then return end
				exporting = true
				dialog:Return(nil)
			end)
		end

		OKButton.MouseButton1Click:connect(function()
			if exporting then return end
			exporting = true
			OKButton.TextColor3 = GuiColor.TextDisabled
			CancelButton.TextColor3 = GuiColor.TextDisabled
			ExportMessage.Visible = true
			local exportString = Exporter:Export(Canvas.CurrentScreen,formatName,formatOptions)
			ExportMessage.Text = "Exported!"
			dialog:Return(exportString)
		end)

		CancelButton.MouseButton1Click:connect(function()
			-- TODO: have cancel button halt thead
			if exporting then return end
			exporting = true
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
			FormatDropDown:Destroy()
			Dialog:Destroy()
			DialogFrame:Destroy()
			Shield:Destroy()
			KeyBinding.Enabled = true
		end)
	end
end
