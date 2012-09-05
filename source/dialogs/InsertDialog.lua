do
	local select_flag = true
	function Dialogs.InsertDialog(parent)
		local Dialog = Create'ScreenGui'{
			Name = "Insert Dialog";
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
				Size = UDim2.new(0, 300, 0, 186);
				Position = UDim2.new(0.5, -146, 0.5, -89);
				BackgroundTransparency = 0.8;
				BackgroundColor3 = Color3.new(0, 0, 0);
				ZIndex = 10;
			};
			Create'Frame'{
				Size = UDim2.new(0, 300, 0, 186);
				BorderColor3 = Color3.new(0.372549, 0.372549, 0.372549);
				Name = "DialogFrame";
				Position = UDim2.new(0.5, -150, 0.5, -93);
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
						Text = "Insert ScreenGui...";
						Size = UDim2.new(1, -6, 1, -6);
						TextColor3 = Color3.new(1, 1, 1);
						TextXAlignment = Enum.TextXAlignment.Left;
						Name = "Title";
						Position = UDim2.new(0, 3, 0, 3);
						BackgroundTransparency = 1;
						ZIndex = 10;
					};
				};
				Create'Frame'{
					Size = UDim2.new(1, -16, 0, 24);
					Name = "Name TextInputGroup";
					Position = UDim2.new(0, 8, 0, 32);
					BackgroundTransparency = 1;
					ZIndex = 10;
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size10;
						Text = "Name";
						Size = UDim2.new(0.25, -8, 1, 0);
						TextColor3 = Color3.new(0, 0, 0);
						TextXAlignment = Enum.TextXAlignment.Right;
						Name = "Label";
						BackgroundTransparency = 1;
						ZIndex = 10;
					};
					Create'TextBox'{
						FontSize = Enum.FontSize.Size10;
						Size = UDim2.new(0.75, 0, 1, 0);
						TextColor3 = Color3.new(0, 0, 0);
						BorderColor3 = Color3.new(0.752941, 0.752941, 0.752941);
						Name = "InputBox";
						Text = "ScreenGui";
						Position = UDim2.new(0.25, 0, 0, 0);
						BackgroundColor3 = Color3.new(1, 1, 1);
						ZIndex = 10;
					};
				};
				Create'Frame'{
					Size = UDim2.new(1, -16, 0, 24);
					Name = "Parent SelectInputGroup";
					Position = UDim2.new(0, 8, 0, 64);
					BackgroundTransparency = 1;
					ZIndex = 10;
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size10;
						Text = "Parent";
						Size = UDim2.new(0.25, -8, 1, 0);
						TextColor3 = Color3.new(0, 0, 0);
						TextXAlignment = Enum.TextXAlignment.Right;
						Name = "Label";
						BackgroundTransparency = 1;
						ZIndex = 10;
					};
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size10;
						Text = "Select an object...";
						Size = UDim2.new(0.75, 0, 1, 0);
						TextColor3 = Color3.new(0, 0, 0);
						BorderColor3 = Color3.new(0.752941, 0.752941, 0.752941);
						Name = "SelectionLabel";
						Position = UDim2.new(0.25, 0, 0, 0);
						BackgroundColor3 = Color3.new(1, 1, 1);
						ZIndex = 10;
					};
				};
				Create'Frame'{
					Size = UDim2.new(1, -16, 0, 24);
					Name = "SetCanvas CheckInputGroup";
					Position = UDim2.new(0, 8, 0, 96);
					BackgroundTransparency = 1;
					ZIndex = 10;
					Create'TextButton'{
						FontSize = Enum.FontSize.Size18;
						BackgroundColor3 = Color3.new(1, 1, 1);
						Name = "CheckBox";
						Text = select_flag and 'X' or '';
						Selected = select_flag;
						Size = UDim2.new(0, 20, 0, 20);
						TextColor3 = Color3.new(0, 0, 0);
						BorderColor3 = Color3.new(0.752941, 0.752941, 0.752941);
						Font = Enum.Font.ArialBold;
						Position = UDim2.new(0, 0, 0, 2);
						ZIndex = 10;
					};
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size10;
						Text = "Set this ScreenGui to the Canvas";
						Size = UDim2.new(1, -28, 1, 0);
						TextColor3 = Color3.new(0, 0, 0);
						TextXAlignment = Enum.TextXAlignment.Left;
						Name = "Description";
						Position = UDim2.new(0, 28, 0, 0);
						BackgroundTransparency = 1;
						ZIndex = 10;
					};
				};
				Create'TextButton'{
					FontSize = Enum.FontSize.Size12;
					BackgroundColor3 = Color3.new(0.866667, 0.866667, 0.866667);
					Name = "OKButton";
					Text = "OK";
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

		local NameInput = Descendant(Dialog,3,2,2)
		local ParentInputLabel = Descendant(Dialog,3,3,2)
		local SetCanvasInput = Descendant(Dialog,3,4,1)

		local OKButton = Descendant(Dialog,3,5)
		local CancelButton = Descendant(Dialog,3,6)

		local ParentInput

	--[[
		local Selection = Game:GetService('Selection')
		local border_color = ParentInputLabel.BorderColor3
		local function getParent()
			ParentInput = Selection:Get()[1]
			if ParentInput then
				ParentInputLabel.BorderColor3 = border_color
				ParentInputLabel.Text = ParentInput.Name
				OKButton.Transparency = 0
			else
				ParentInputLabel.BorderColor3 = Color3.new(1,0,0)
				ParentInputLabel.Text = "Select an object..."
				OKButton.Transparency = 0.5
			end
		end
		local conSelection = Selection.SelectionChanged:connect(getParent)
		getParent()
	--[=[]]
		-- because of a roblox bug, the canvas depends on StarterGui to operate properly
		ParentInput = Game:GetService("StarterGui")
		ParentInputLabel.Text = "StarterGui"
		ParentInputLabel.TextTransparency = 0.5
	--]=]

		SetCanvasInput.MouseButton1Click:connect(function()
			SetCanvasInput.Selected = not SetCanvasInput.Selected
		end)
		SetCanvasInput.Changed:connect(function(p)
			if p == "Selected" then
				SetCanvasInput.Text = SetCanvasInput.Selected and "X" or ""
			end
		end)

		local dialog = Widgets.DialogBase()

		OKButton.MouseButton1Click:connect(function()
			if ParentInput then
				local screen = Instance.new('ScreenGui')
				screen.Name = NameInput.Text
				screen.Parent = ParentInput

				select_flag = SetCanvasInput.Selected

				dialog:Return(screen,SetCanvasInput.Selected)
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
		--	conSelection:disconnect()
			Dialog:Destroy()
			DialogFrame:Destroy()
			Shield:Destroy()
		end)
	end
end
