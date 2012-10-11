--[[Select Screen Dialog
Let's the user select a ScreenGui that exists in the game*.

Because of bug #1, the selection is limited to the StarterGui.

Arguments:
	parent
		Where to put the dialog.
		Because of bug #2, this should be a ScreenGui
		When this bug is fixed, this will be the parent of a ScreenGui

	eventCancel
		An event that the dialog connects to. If the event fires, the dialog will automatically cancel. Optional.

Returns:
	screen
		The selected screen.
		If the dialog is canceled, or no screen is selected, this will be nil.
]]

function Dialogs.SelectScreen(parent,eventCancel)
	KeyBinding.Enabled = false
	local GuiColor = InternalSettings.GuiColor
	local Dialog = Create'ScreenGui'{
		Name = "Select Dialog";
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
			Size = UDim2.new(0, 300, 0, 250);
			BorderColor3 = GuiColor.Border;
			Name = "DialogFrame";
			Position = UDim2.new(0.5, -150, 0.5, -125);
			BackgroundColor3 = GuiColor.Background;
			ZIndex = 10;
			Create'Frame'{
				Size = UDim2.new(1, 0, 0, 24);
				BorderColor3 = GuiColor.Border;
				Name = "TitleBar";
				BackgroundColor3 = Color3.new(178/255, 178/255, 178/255);
				ZIndex = 10;
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size12;
					Text = "Select ScreenGui...";
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
			Create'TextButton'{
				FontSize = Enum.FontSize.Size12;
				BackgroundColor3 = GuiColor.Button;
				Name = "OKButton";
				Text = "OK";
				Size = UDim2.new(0, 64, 0, 32);
				TextColor3 = GuiColor.TextDisabled;
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
	};

	local OKButton = Descendant(Dialog,3,2)
	local CancelButton = Descendant(Dialog,3,3)

	local screens = GetScreens(Game:GetService("StarterGui")) -- bug #1

	local SelectionList = Widgets.List(screens)
	SelectionList.Boundary.BackgroundColor3 = GuiColor.Field
	SelectionList.Boundary.BorderColor3 = GuiColor.Border
	SelectionList.GUI.Position = UDim2.new(0,8,0,32)
	SelectionList.GUI.Size = UDim2.new(1,-16,1,-80)
	SelectionList.GUI.Parent = Descendant(Dialog,3)

	local SelectedScreen
	local Selection = Game:GetService("Selection")
	SelectionList.ItemSelected:connect(function(screen)
		if screen then
			SelectedScreen = screen
			Selection:Set{screen}
			OKButton.TextColor3 = GuiColor.Text
		else
			SelectedScreen = nil
			Selection:Set{}
			OKButton.TextColor3 = GuiColor.TextDisabled
		end
	end)

	local dialog = Widgets.DialogBase()

	local conCancel
	if eventCancel then
		conCancel = eventCancel:connect(function()
			dialog:Return(nil)
		end)
	end

	OKButton.MouseButton1Click:connect(function()
		if SelectedScreen then
			dialog:Return(SelectedScreen)
		end
	end)

	CancelButton.MouseButton1Click:connect(function()
		dialog:Return(nil)
	end)

--[[
	Dialog.Parent = Game:GetService("CoreGui")
--[=[]]
	-- roblox bug: drawing order of ScreenGuis behaves erratically
	local DialogFrame = Descendant(Dialog,3)
	local Shield = Descendant(Dialog,1)

	Shield.Parent = parent
	DialogFrame.Parent = parent
--]=]
	return dialog:Finish(function()
		if conCancel then conCancel:disconnect() end
		SelectionList:Destroy()
		Dialog:Destroy()
		Shield:Destroy()
		DialogFrame:Destroy()
		KeyBinding.Enabled = true
	end)
end
