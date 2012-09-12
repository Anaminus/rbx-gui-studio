--[[ButtonMenu
Creates a menu of clickable buttons from a list of button data.
Button data are tables that contain the following fields:
	Name       The name of the button.
	Icon       An icon to display on the button.
	ToolTip    (optional) A tooltip to display when the button is hovered over.
	Select     (optional) A function called when the button is clicked.

If an item in the list is a string, then it is counted as a seperator.

Arguments:
	buttons
		The list of button data.
	size
		The Vector2 size of each button.
	horizontal
		Whether the menu will layout horizontally or vertically.
	on_click
		A callback called when any button is clicked.
		If this argument is defined, then it wil be called instead of button.Select.

Returns:
	The button menu GUI.

]]
function Widgets.ButtonMenu(buttons,size,horizontal,on_click)
	local ButtonMenuFrame = Create'Frame'{
		Name = "ButtonFrame";
		BackgroundColor3 = Color3.new(0.917647, 0.917647, 0.917647);
		BorderColor3 = Color3.new(0.588235, 0.588235, 0.588235);
	}
	for i,button in pairs(buttons) do
		if type(button) == 'string' then
			Create'Frame'{
				Name = "Seperator";
				Transparency = 1;
				Size = vertical and UDim2.new(0,size.x,0,3) or UDim2.new(0,4,0,size.y);
				Create'Frame'{
					Name = "SeperatorDecal";
					BorderSizePixel = 0;
					BackgroundColor3 = Color3.new(0.588235, 0.588235, 0.588235);
					Position = vertical and UDim2.new(0,-2,0,2) or UDim2.new(0,2,0,-2);
					Size = vertical and UDim2.new(1,4,0,1) or UDim2.new(0,1,1,4);
				};
				Parent = ButtonMenuFrame;
			}
		else
			local ButtonFrame = Create'ImageButton'{
				Name = button.Name .. " MenuButton";
				BackgroundColor3 = Color3.new(0.866667, 0.866667, 0.866667);
				BorderColor3 = Color3.new(0.588235, 0.588235, 0.588235);
				Size = UDim2.new(0,size.x,0,size.y);
			--	Image = button.Icon;
				Create'ImageLabel'{
					Name = "MenuButtonIcon";
					BackgroundTransparency = 1;
					Position = UDim2.new(0,3,0,3);
					Size = UDim2.new(1,-6,1,-6);
					Image = button.Icon;
				};
				Parent = ButtonMenuFrame;
			}
			button.Button = ButtonFrame
			if on_click then
				ButtonFrame.MouseButton1Click:connect(function()
					on_click(button)
				end)
			else
				ButtonFrame.MouseButton1Click:connect(function()
					button:Select()
				end)
			end
			ToolTipService:AddToolTip(ButtonFrame,button.ToolTip)
		end
	end

	Widgets.StaticStackingFrame(ButtonMenuFrame,{
		Border = 4;
		Padding = 2;
		Horizontal = horizontal;
	})

	return ButtonMenuFrame
end
