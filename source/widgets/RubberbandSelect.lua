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
	return Widgets.DragGUI({},originClick,'BottomRight',{
		OnDrag = function(x,y,hasDragged,setObjects)
			if hasDragged then
				OnDrag(x,y)
			else
				local color = Color3.new(1,0,0)
				selectBox = Create'Frame'{
					Name = "RubberBandSelect";
					Transparency = 1;
					Create'Frame'{ -- top
						BackgroundColor3 = color;
						BorderSizePixel = 0;
						Position = UDim2.new(0,-3,0,-3);
						Size = UDim2.new(1,6,0,3);
					};
					Create'Frame'{ -- right
						BackgroundColor3 = color;
						BorderSizePixel = 0;
						Position = UDim2.new(1,0,0,0);
						Size = UDim2.new(0,3,1,0);
					};
					Create'Frame'{ -- bottom
						BackgroundColor3 = color;
						BorderSizePixel = 0;
						Position = UDim2.new(0,-3,1,0);
						Size = UDim2.new(1,6,0,3);
					};
					Create'Frame'{ -- left
						BackgroundColor3 = color;
						BorderSizePixel = 0;
						Position = UDim2.new(0,-3,0,0);
						Size = UDim2.new(0,3,1,0);
					};
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

				setObjects{selectBox}
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
	},Canvas.CanvasFrame)
end
