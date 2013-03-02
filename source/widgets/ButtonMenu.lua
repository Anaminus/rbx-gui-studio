--[[ButtonMenu
Creates a menu of clickable buttons from a list of button data.
Button data are tables that contain the following fields:
	Name       The name of the button.
	Icon       An icon to display on the button.
	           This can be a Content string referencing an icon image, or an Icon widget.
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
	local GuiColor = InternalSettings.GuiColor
	local ButtonMenuFrame = Create'Frame'{
		Name = "ButtonFrame";
		BackgroundColor3 = GuiColor.Background;
		BorderColor3 = GuiColor.Border;
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
					BackgroundColor3 = GuiColor.Border;
					Position = vertical and UDim2.new(0,-2,0,2) or UDim2.new(0,2,0,-2);
					Size = vertical and UDim2.new(1,4,0,1) or UDim2.new(0,1,1,4);
				};
				Parent = ButtonMenuFrame;
			}
		else
			local ButtonFrame = Create'ImageButton'{
				Name = button.Name .. " MenuButton";
				BackgroundColor3 = GuiColor.Button;
				BorderColor3 = GuiColor.ButtonBorder;
				Size = UDim2.new(0,size.x,0,size.y);
				(function()
					if type(button.Icon) == 'string' then
						return Create'ImageLabel'{
							Name = "MenuButtonIcon";
							BackgroundTransparency = 1;
							Position = UDim2.new(0,3,0,3);
							Size = UDim2.new(1,-6,1,-6);
							Image = button.Icon;
						}
					elseif button.Icon == nil then
						return Create'Frame'{
							Name = "MenuButtonIcon";
							BackgroundTransparency = 1;
							Position = UDim2.new(0,3,0,3);
							Size = UDim2.new(1,-6,1,-6);
						}
					else
						return Create(button.Icon){
							Name = "MenuButtonIcon";
							BackgroundTransparency = 1;
							Position = UDim2.new(0,3,0,3);
							Size = UDim2.new(1,-6,1,-6);
						}
					end
				end)();
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
		Padding = 3;
		Horizontal = horizontal;
	})

	return ButtonMenuFrame
end
