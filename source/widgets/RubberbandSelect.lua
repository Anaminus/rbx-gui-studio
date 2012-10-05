--[[RubberbandSelect
Performs a rubberband selection. That is, the user clicks and drags to create a box, then all objects in the box become selected.

Arguments:
	originClick
		The point were the click & drag begins.

	callbacks
		A table of callback functions:

		OnDrag(x, y)
			Called when the mouse is dragged.
			x, y
				The mouse coordinates where the button was released.

		OnRelease(x, y)
			Called when the dragging operation ends.
			x, y
				The mouse coordinates where the button was released.

		OnClick(x, y)
			Called when the dragging operation ends without the mouse having been dragged.
			x, y
				The mouse coordinates where the button was released.

Returns:
	finishDrag
		A function that, when called, ends the rubberband selection.
]]

function Widgets.RubberbandSelect(originClick,callbacks)
	callbacks = callbacks or {}
	local OnDrag = callbacks.OnDrag or function()end

	local selectBox
	return Widgets.DragGUI({},nil,originClick,'BottomRight',{
		OnDrag = function(x,y,hasDragged,setObjects)
			if hasDragged then
				OnDrag(x,y)
			else
				local width = 2
				local color = Color3.new(1,1,1)
				selectBox = Create'Frame'{
					Name = "RubberBandSelect";
					Transparency = 1;
					Create'Frame'{ -- top
						BackgroundColor3 = color;
						BorderSizePixel = 0;
						Position = UDim2.new(0,-width,0,-width);
						Size = UDim2.new(1,width*2,0,width);
					};
					Create'Frame'{ -- right
						BackgroundColor3 = color;
						BorderSizePixel = 0;
						Position = UDim2.new(1,0,0,0);
						Size = UDim2.new(0,width,1,0);
					};
					Create'Frame'{ -- bottom
						BackgroundColor3 = color;
						BorderSizePixel = 0;
						Position = UDim2.new(0,-width,1,0);
						Size = UDim2.new(1,width*2,0,width);
					};
					Create'Frame'{ -- left
						BackgroundColor3 = color;
						BorderSizePixel = 0;
						Position = UDim2.new(0,-width,0,0);
						Size = UDim2.new(0,width,1,0);
					};
--[ [
					Create'Frame'{
						Name = "Border";
						Transparency = 1;
						Size = UDim2.new(1,0,1,0);
						-- outer border
						Create'Frame'{ -- top
							Name = "Outer Top";
							BackgroundColor3 = Color3.new(0,0,0);
							BackgroundTransparency = 0.5;
							BorderSizePixel = 0;
							Position = UDim2.new(0,-width-1,0,-width-1);
							Size = UDim2.new(1,width*2+2,0,1);
						};
						Create'Frame'{ -- right
							Name = "Outer Right";
							BackgroundColor3 = Color3.new(0,0,0);
							BackgroundTransparency = 0.5;
							BorderSizePixel = 0;
							Position = UDim2.new(1,width,0,-width);
							Size = UDim2.new(0,1,1,width*2);
						};
						Create'Frame'{ -- bottom
							Name = "Outer Bottom";
							BackgroundColor3 = Color3.new(0,0,0);
							BackgroundTransparency = 0.5;
							BorderSizePixel = 0;
							Position = UDim2.new(0,-width-1,1,width);
							Size = UDim2.new(1,width*2+2,0,1);
						};
						Create'Frame'{ -- left
							Name = "Outer Left";
							BackgroundColor3 = Color3.new(0,0,0);
							BackgroundTransparency = 0.5;
							BorderSizePixel = 0;
							Position = UDim2.new(0,-width-1,0,-width);
							Size = UDim2.new(0,1,1,width*2);
						};
						-- inner border
						Create'Frame'{ -- top
							Name = "Inner Top";
							BackgroundColor3 = Color3.new(0,0,0);
							BackgroundTransparency = 0.5;
							BorderSizePixel = 0;
							Position = UDim2.new(0,0,0,0);
							Size = UDim2.new(1,0,0,1);
						};
						Create'Frame'{ -- right
							Name = "Inner Right";
							BackgroundColor3 = Color3.new(0,0,0);
							BackgroundTransparency = 0.5;
							BorderSizePixel = 0;
							Position = UDim2.new(1,-1,0,1);
							Size = UDim2.new(0,1,1,-2);
						};
						Create'Frame'{ -- bottom
							Name = "Inner Bottom";
							BackgroundColor3 = Color3.new(0,0,0);
							BackgroundTransparency = 0.5;
							BorderSizePixel = 0;
							Position = UDim2.new(0,0,1,-1);
							Size = UDim2.new(1,0,0,1);
						};
						Create'Frame'{ -- left
							Name = "Inner Left";
							BackgroundColor3 = Color3.new(0,0,0);
							BackgroundTransparency = 0.5;
							BorderSizePixel = 0;
							Position = UDim2.new(0,0,0,1);
							Size = UDim2.new(0,1,1,-2);
						};
					};
--]]
				}
				local canvasFrame = Canvas.CanvasFrame
				selectBox.Parent = canvasFrame

				local pos = originClick - canvasFrame.AbsolutePosition
				if Settings.LayoutMode('Scale') then
					pos = pos/canvasFrame.AbsoluteSize
					selectBox.Position = UDim2.new(pos.x,0,pos.y,0)
				else
					selectBox.Position = UDim2.new(0,pos.x,0,pos.y)
				end

				setObjects({selectBox},nil)
			end
		end;
		OnRelease = function(x,y,hasDragged)
			if hasDragged then
				if callbacks.OnRelease then callbacks.OnRelease(x,y) end
				if selectBox then
					local low = selectBox.AbsolutePosition
					local high = low + selectBox.AbsoluteSize
					selectBox:Destroy()

					low,high =
						Vector2.new(math.min(low.x,high.x),math.min(low.y,high.y)),
						Vector2.new(math.max(low.x,high.x),math.max(low.y,high.y))

					local activeLookup = Canvas.ActiveLookup
					local selectionList = {}
					for i,child in pairs(Scope.Current:GetChildren()) do
						local active = activeLookup[child]
						if active then
							local checkLow = active.AbsolutePosition
							local checkHigh = checkLow + active.AbsoluteSize

							if   checkLow.x >=  low.x and  checkLow.y >=  low.y
							and checkHigh.x <= high.x and checkHigh.y <= high.y then
								selectionList[#selectionList+1] = child
							end
						end
					end
					if Mouse.CtrlIsDown then
						Selection:Add(selectionList)
					else
						Selection:Set(selectionList)
					end
				end
			else
				if callbacks.OnClick then callbacks.OnClick(x,y) end
			end
		end;
	},Canvas.CanvasFrame,false,true,true)
end
