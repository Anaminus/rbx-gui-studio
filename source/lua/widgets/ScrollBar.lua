--[[ScrollBar
A primative scrollbar.

API:

Fields:

ScrollBar.GUI
	The GUI object representing the scrollbar.

ScrollBar.ScrollIndex
	A number indicating the current position of the scroll bar.

ScrollBar.VisibleSpace
	A number indicating the visible span of the scrollable space.

ScrollBar.TotalSpace
	A number indicating the total span of the scrollable space.

ScrollBar.PageIncrement
	The amount to increase or decrease the ScrollIndex when ScrollDown or ScrollUp is called.


Methods:

ScrollBar:CanScrollDown ( )
ScrollBar:CanScrollLeft ( )
ScrollBar:CanScrollRight ( )
ScrollBar:CanScrollUp ( )
	Returns whether the scrollbar can be scrolled in a particular direction.

ScrollBar:ScrollDown ( )
ScrollBar:ScrollLeft ( )
ScrollBar:ScrollRight ( )
ScrollBar:ScrollUp ( )
	Scrolls the scrollbar in a particular direction by Scrollbar.PageIncrement.

ScrollBar:ScrollTo ( index )
	Scrolls to a specific location.

ScrollBar:GetScrollPercent ( )
	Returns the scroll index as a percentage between 0 and 1.

ScrollBar:SetScrollPercent ( percent )
	Sets the scroll index from a percentage between 0 and 1.

ScrollBar:Update ( )
	Updates the scrollbar.

ScrollBar:Destroy ( )
	Releases any resources used by this object. Call this if you are no longer using the object.


Callbacks:

ScrollBar.UpdateCallback ( class )
	Called when the scrollbar updates.
	If this function returns false, then the update will be cancelled.

]]

do
	local mt = {
		__index = {
			GetScrollPercent = function(self)
				return self.ScrollIndex/(self.TotalSpace-self.VisibleSpace)
			end;
			CanScrollDown = function(self)
				return self.ScrollIndex + self.VisibleSpace < self.TotalSpace
			end;
			CanScrollUp = function(self)
				return self.ScrollIndex > 0
			end;
			ScrollDown = function(self)
				self.ScrollIndex = self.ScrollIndex + self.PageIncrement
				self:Update()
			end;
			ScrollUp = function(self)
				self.ScrollIndex = self.ScrollIndex - self.PageIncrement
				self:Update()
			end;
			ScrollTo = function(self,index)
				self.ScrollIndex = index
				self:Update()
			end;
			SetScrollPercent = function(self,percent)
				self.ScrollIndex = math.floor((self.TotalSpace - self.VisibleSpace)*percent + 0.5)
				self:Update()
			end;
		};
	}
	mt.__index.CanScrollRight = mt.__index.CanScrollDown
	mt.__index.CanScrollLeft = mt.__index.CanScrollUp
	mt.__index.ScrollLeft = mt.__index.ScrollUp
	mt.__index.ScrollRight = mt.__index.ScrollDown

	function Widgets.ScrollBar(horizontal)
		local GuiColor = InternalSettings.GuiColor
		local size = InternalSettings.GuiWidgetSize

		-- create row scroll bar
		local ScrollFrame = Create'Frame'{
			Name = "ScrollFrame";
			Position = horizontal and UDim2.new(0,0,1,-size) or UDim2.new(1,-size,0,0);
			Size = horizontal and UDim2.new(1,0,0,size) or UDim2.new(0,size,1,0);
			BackgroundTransparency = 1;
			Create'ImageButton'{
				Name = "ScrollDown";
				Position = horizontal and UDim2.new(1,-size,0,0) or UDim2.new(0,0,1,-size);
				Size = UDim2.new(0, size, 0, size);
				BackgroundColor3 = GuiColor.Button;
				BorderColor3 = GuiColor.Border;
				--BorderSizePixel = 0;
			};
			Create'ImageButton'{
				Name = "ScrollUp";
				Size = UDim2.new(0, size, 0, size);
				BackgroundColor3 = GuiColor.Button;
				BorderColor3 = GuiColor.Border;
				--BorderSizePixel = 0;
			};
			Create'ImageButton'{
				Name = "ScrollBar";
				Size = horizontal and UDim2.new(1,-size*2,1,0) or UDim2.new(1,0,1,-size*2);
				Position = horizontal and UDim2.new(0,size,0,0) or UDim2.new(0,0,0,size);
				AutoButtonColor = false;
				BackgroundColor3 = Color3.new(0.94902, 0.94902, 0.94902);
				BorderColor3 = GuiColor.Border;
				--BorderSizePixel = 0;
				Create'ImageButton'{
					Name = "ScrollThumb";
					AutoButtonColor = false;
					Size = UDim2.new(0, size, 0, size);
					BackgroundColor3 = GuiColor.Button;
					BorderColor3 = GuiColor.Border;
					--BorderSizePixel = 0;
				};
			};
		}

		local graphicTemplate = Create'Frame'{
			Name="Graphic";
			BorderSizePixel = 0;
			BackgroundColor3 = GuiColor.Border;
		}
		local graphicSize = math.floor(size*0.625)

		local ScrollDownFrame = ScrollFrame.ScrollDown
			local ScrollDownGraphic = Widgets.ArrowGraphic(graphicSize,horizontal and 'Right' or 'Down',true,graphicTemplate)
			ScrollDownGraphic.Position = UDim2.new(0.5,-graphicSize/2,0.5,-graphicSize/2)
			ScrollDownGraphic.Parent = ScrollDownFrame
		local ScrollUpFrame = ScrollFrame.ScrollUp
			local ScrollUpGraphic = Widgets.ArrowGraphic(graphicSize,horizontal and 'Left' or 'Up',true,graphicTemplate)
			ScrollUpGraphic.Position = UDim2.new(0.5,-graphicSize/2,0.5,-graphicSize/2)
			ScrollUpGraphic.Parent = ScrollUpFrame
		local ScrollBarFrame = ScrollFrame.ScrollBar
		local ScrollThumbFrame = ScrollBarFrame.ScrollThumb
			local Decal = Widgets.GripGraphic(Vector2.new(6,6),horizontal and 'Vertical' or 'Horizontal',2,graphicTemplate)
			Decal.Position = UDim2.new(0.5,-3,0.5,-3)
			Decal.Parent = ScrollThumbFrame

		local MouseDrag = Widgets.Dragger()

		local Class = setmetatable({
			GUI = ScrollFrame;
			ScrollIndex = 0;
			VisibleSpace = 0;
			TotalSpace = 0;
			PageIncrement = 1;
		},mt)

		local ScrollStyle = {BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0}
		local ScrollStyle_ds = {BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.7}

		local last_down
		local last_up
		local UpdateScrollThumb = horizontal
		and function()
			ScrollThumbFrame.Size = UDim2.new(Class.VisibleSpace/Class.TotalSpace,0,0,size)
			if ScrollThumbFrame.AbsoluteSize.x < size then
				ScrollThumbFrame.Size = UDim2.new(0,size,0,size)
			end
			local bar_size = ScrollBarFrame.AbsoluteSize.x
			ScrollThumbFrame.Position = UDim2.new(Class:GetScrollPercent()*(bar_size - ScrollThumbFrame.AbsoluteSize.x)/bar_size,0,0,0)
		end
		or function()
			ScrollThumbFrame.Size = UDim2.new(0,size,Class.VisibleSpace/Class.TotalSpace,0)
			if ScrollThumbFrame.AbsoluteSize.y < size then
				ScrollThumbFrame.Size = UDim2.new(0,size,0,size)
			end
			local bar_size = ScrollBarFrame.AbsoluteSize.y
			ScrollThumbFrame.Position = UDim2.new(0,0,Class:GetScrollPercent()*(bar_size - ScrollThumbFrame.AbsoluteSize.y)/bar_size,0)
		end

		local function Update()
			local t = Class.TotalSpace
			local v = Class.VisibleSpace
			local s = Class.ScrollIndex
			if v <= t then
				if s > 0 then
					if s + v > t then
						Class.ScrollIndex = t - v
					end
				else
					Class.ScrollIndex = 0
				end
			else
				Class.ScrollIndex = 0
			end

			if Class.UpdateCallback then
				if Class.UpdateCallback(Class) == false then
					return
				end
			end

			local down = Class:CanScrollDown()
			local up = Class:CanScrollUp()
			if down ~= last_down then
				last_down = down
				ScrollDownFrame.Active = down
				ScrollDownFrame.AutoButtonColor = down
			--	Create(ScrollDownGraphic:GetChildren())(down and ScrollStyle or ScrollStyle_ds)
			--	ScrollDownFrame.BackgroundTransparency = down and 0.5 or 0.7
			end
			if up ~= last_up then
				last_up = up
				ScrollUpFrame.Active = up
				ScrollUpFrame.AutoButtonColor = up
			--	Create(ScrollUpGraphic:GetChildren())(up and ScrollStyle or ScrollStyle_ds)
			--	ScrollUpFrame.BackgroundTransparency = up and 0.5 or 0.7
			end
			ScrollThumbFrame.Visible = down or up
			UpdateScrollThumb()
		end
		Class.Update = Update

		SetZIndexOnChanged(ScrollFrame)

		local scroll_event_id = 0
		ScrollDownFrame.MouseButton1Down:connect(function()
			scroll_event_id = tick()
			local current = scroll_event_id
			local up_con
			up_con = MouseDrag.MouseButton1Up:connect(function()
				scroll_event_id = tick()
				MouseDrag.Parent = nil
				ResetButtonColor(ScrollDownFrame)
				up_con:disconnect(); drag = nil
			end)
			MouseDrag.Parent = GetScreen(ScrollFrame)
			Class:ScrollDown()
			wait(0.2) -- delay before auto scroll
			while scroll_event_id == current do
				Class:ScrollDown()
				if not Class:CanScrollDown() then break end
				wait()
			end
		end)

		ScrollDownFrame.MouseButton1Up:connect(function()
			scroll_event_id = tick()
		end)

		ScrollUpFrame.MouseButton1Down:connect(function()
			scroll_event_id = tick()
			local current = scroll_event_id
			local up_con
			up_con = MouseDrag.MouseButton1Up:connect(function()
				scroll_event_id = tick()
				MouseDrag.Parent = nil
				ResetButtonColor(ScrollUpFrame)
				up_con:disconnect(); drag = nil
			end)
			MouseDrag.Parent = GetScreen(ScrollFrame)
			Class:ScrollUp()
			wait(0.2)
			while scroll_event_id == current do
				Class:ScrollUp()
				if not Class:CanScrollUp() then break end
				wait()
			end
		end)

		ScrollUpFrame.MouseButton1Up:connect(function()
			scroll_event_id = tick()
		end)

		ScrollBarFrame.MouseButton1Down:connect(horizontal
		and function(x,y)
			scroll_event_id = tick()
			local current = scroll_event_id
			local up_con
			up_con = MouseDrag.MouseButton1Up:connect(function()
				scroll_event_id = tick()
				MouseDrag.Parent = nil
				ResetButtonColor(ScrollUpFrame)
				up_con:disconnect(); drag = nil
			end)
			MouseDrag.Parent = GetScreen(ScrollFrame)
			Class:ScrollTo(Class.ScrollIndex + Class.VisibleSpace)
			wait(0.2)
			if x > ScrollThumbFrame.AbsolutePosition.x then
				while scroll_event_id == current do
					if x < ScrollThumbFrame.AbsolutePosition.x + ScrollThumbFrame.AbsoluteSize.x then break end
					Class:ScrollTo(Class.ScrollIndex + Class.VisibleSpace)
					wait()
				end
			else
				while scroll_event_id == current do
					if x > ScrollThumbFrame.AbsolutePosition.x then break end
					Class:ScrollTo(Class.ScrollIndex - Class.VisibleSpace)
					wait()
				end
			end
		end
		or function(x,y)
			scroll_event_id = tick()
			local current = scroll_event_id
			local up_con
			up_con = MouseDrag.MouseButton1Up:connect(function()
				scroll_event_id = tick()
				MouseDrag.Parent = nil
				ResetButtonColor(ScrollUpFrame)
				up_con:disconnect(); drag = nil
			end)
			MouseDrag.Parent = GetScreen(ScrollFrame)
			Class:ScrollTo(Class.ScrollIndex + Class.VisibleSpace)
			wait(0.2)
			if y > ScrollThumbFrame.AbsolutePosition.y then
				while scroll_event_id == current do
					if y < ScrollThumbFrame.AbsolutePosition.y + ScrollThumbFrame.AbsoluteSize.y then break end
					Class:ScrollTo(Class.ScrollIndex + Class.VisibleSpace)
					wait()
				end
			else
				while scroll_event_id == current do
					if y > ScrollThumbFrame.AbsolutePosition.y then break end
					Class:ScrollTo(Class.ScrollIndex - Class.VisibleSpace)
					wait()
				end
			end
		end)

		ScrollThumbFrame.MouseButton1Down:connect(horizontal
		and function(x,y)
			scroll_event_id = tick()
			local mouse_offset = x - ScrollThumbFrame.AbsolutePosition.x
			local drag_con
			local up_con
			drag_con = MouseDrag.MouseMoved:connect(function(x,y)
				local bar_abs_pos = ScrollBarFrame.AbsolutePosition.x
				local bar_drag = ScrollBarFrame.AbsoluteSize.x - ScrollThumbFrame.AbsoluteSize.x
				local bar_abs_one = bar_abs_pos + bar_drag
				x = x - mouse_offset
				x = x < bar_abs_pos and bar_abs_pos or x > bar_abs_one and bar_abs_one or x
				x = x - bar_abs_pos
				Class:SetScrollPercent(x/(bar_drag))
			end)
			up_con = MouseDrag.MouseButton1Up:connect(function()
				scroll_event_id = tick()
				MouseDrag.Parent = nil
				ResetButtonColor(ScrollThumbFrame)
				drag_con:disconnect(); drag_con = nil
				up_con:disconnect(); drag = nil
			end)
			MouseDrag.Parent = GetScreen(ScrollFrame)
		end
		or function(x,y)
			scroll_event_id = tick()
			local mouse_offset = y - ScrollThumbFrame.AbsolutePosition.y
			local drag_con
			local up_con
			drag_con = MouseDrag.MouseMoved:connect(function(x,y)
				local bar_abs_pos = ScrollBarFrame.AbsolutePosition.y
				local bar_drag = ScrollBarFrame.AbsoluteSize.y - ScrollThumbFrame.AbsoluteSize.y
				local bar_abs_one = bar_abs_pos + bar_drag
				y = y - mouse_offset
				y = y < bar_abs_pos and bar_abs_pos or y > bar_abs_one and bar_abs_one or y
				y = y - bar_abs_pos
				Class:SetScrollPercent(y/(bar_drag))
			end)
			up_con = MouseDrag.MouseButton1Up:connect(function()
				scroll_event_id = tick()
				MouseDrag.Parent = nil
				ResetButtonColor(ScrollThumbFrame)
				drag_con:disconnect(); drag_con = nil
				up_con:disconnect(); drag = nil
			end)
			MouseDrag.Parent = GetScreen(ScrollFrame)
		end)

		function Class:Destroy()
			ScrollFrame:Destroy()
			MouseDrag:Destroy()
			for k in pairs(Class) do
				Class[k] = nil
			end
			setmetatable(Class,nil)
		end

		Update()

		return Class
	end
end

