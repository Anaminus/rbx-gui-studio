local function RunSelectDialog(parent)
	local Dialog = Create'ScreenGui'{
		Name = "Select Dialog";
		Create'Frame'{
			Active = true;
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
			BorderColor3 = Color3.new(0.372549, 0.372549, 0.372549);
			Name = "DialogFrame";
			Position = UDim2.new(0.5, -150, 0.5, -125);
			BackgroundColor3 = Color3.new(0.917647, 0.917647, 0.917647);
			ZIndex = 10;
			Create'Frame'{
				Size = UDim2.new(1, 0, 0, 24);
				BorderColor3 = Color3.new(0.372549, 0.372549, 0.372549);
				Name = "TitleBar";
				BackgroundColor3 = Color3.new(0.588235, 0.588235, 0.588235);
				ZIndex = 10;
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size12;
					Text = "Select ScreenGui...";
					Size = UDim2.new(1, -6, 1, -6);
					TextColor3 = Color3.new(1, 1, 1);
					TextXAlignment = Enum.TextXAlignment.Left;
					Name = "Title";
					Position = UDim2.new(0, 3, 0, 3);
					BackgroundTransparency = 1;
					ZIndex = 10;
				};
			};
			Create'TextButton'{
				FontSize = Enum.FontSize.Size12;
				BackgroundColor3 = Color3.new(0.866667, 0.866667, 0.866667);
				Name = "OKButton";
				Text = "OK";
				TextTransparency = 0.5;
				Size = UDim2.new(0, 64, 0, 32);
				TextColor3 = Color3.new(0, 0, 0);
				BorderColor3 = Color3.new(0.588235, 0.588235, 0.588235);
				Position = UDim2.new(1, -144, 1, -40);
				ZIndex = 10;
			};
			Create'TextButton'{
				FontSize = Enum.FontSize.Size12;
				BackgroundColor3 = Color3.new(0.866667, 0.866667, 0.866667);
				Name = "CancelButton";
				Text = "Cancel";
				Size = UDim2.new(0, 64, 0, 32);
				TextColor3 = Color3.new(0, 0, 0);
				BorderColor3 = Color3.new(0.588235, 0.588235, 0.588235);
				Position = UDim2.new(1, -72, 1, -40);
				ZIndex = 10;
			};
		};
	};

	local OKButton = Descendant(Dialog,3,2)
	local CancelButton = Descendant(Dialog,3,3)

	local screens = GetScreens(Game:GetService("StarterGui"))

	local SelectionList = Widgets.List(screens)
	SelectionList.Boundary.BackgroundColor3 = Color3.new(1,1,1)
	SelectionList.Boundary.BorderColor3 = Color3.new(0.588235, 0.588235, 0.588235);
	SelectionList.GUI.Position = UDim2.new(0,8,0,32)
	SelectionList.GUI.Size = UDim2.new(1,-16,1,-80)
	SelectionList.GUI.Parent = Descendant(Dialog,3)

	local SelectedScreen
	local Selection = Game:GetService("Selection")
	SelectionList.ItemSelected:connect(function(screen)
		if screen then
			SelectedScreen = screen
			Selection:Set{screen}
			OKButton.TextTransparency = 0
		else
			SelectedScreen = nil
			Selection:Set{}
			OKButton.TextTransparency = 0.5
		end
	end)

	local dialog = Widgets.DialogBase()

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
		SelectionList:Destroy()
		Dialog:Destroy()
		Shield:Destroy()
		DialogFrame:Destroy()
	end)
end
