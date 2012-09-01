do
	local mt = {
		__index = {
			Update = function(self)
				self.VScroll:Update()
				self.HScroll:Update()
			end;
			Destroy = function(self)
				self.VScroll.GUI.Parent = nil
				self.HScroll.GUI.Parent = nil
				self.GUI:Destroy()
				self.VScroll:Destroy()
				self.HScroll:Destroy()
				for k in pairs(self) do
					self[k] = nil
				end
				setmetatable(self,nil)
			end;
		};
	}

	function Widgets.ScrollingContainer()
		local scroll_width = 16

		local ParentFrame = Create'Frame'{
			Name = "ScrollingContainer";
			Size = UDim2.new(0,300,0,200);
			BackgroundTransparency = 1;
		}

		local Boundary = Create'Frame'{
			Name = "Boundary";
			BackgroundColor3 = Color3.new(0,0,0);
			BorderColor3 = Color3.new(1,1,1);
			ClipsDescendants = true;
			Parent = ParentFrame;
		}

		local Container = Create'Frame'{
			Name = "Container";
			BackgroundTransparency = 1;
			Parent = Boundary;
		}

		local VScroll = Widgets.ScrollBar(false)
		VScroll.PageIncrement = scroll_width
		VScroll.GUI.Name = "ScollFrame Vertical"
		VScroll.GUI.Position = UDim2.new(1,-scroll_width,0,0)
		VScroll.GUI.Size = UDim2.new(0,scroll_width,1,-scroll_width)
		VScroll.GUI.Parent = ParentFrame
		VScroll.UpdateCallback = function(self)
		--[[
			local visible = self:CanScrollUp() or self:CanScrollDown()
			self.GUI.Visible = visible
			Boundary.Size = visible
				and UDim2.new(1,-scroll_width,Boundary.Size.Y.Scale,0)
				or  UDim2.new(1,            0,Boundary.Size.Y.Scale,0)
		--]]
			Container.Position = UDim2.new(0,Container.Position.X.Offset,0,-VScroll.ScrollIndex)
		--	return visible
		end
		local HScroll = Widgets.ScrollBar(true)
		HScroll.PageIncrement = scroll_width
		HScroll.GUI.Name = "ScollFrame Horizontal"
		HScroll.GUI.Position = UDim2.new(0,0,1,-scroll_width)
		HScroll.GUI.Size = UDim2.new(1,-scroll_width,0,scroll_width)
		HScroll.GUI.Parent = ParentFrame
		HScroll.UpdateCallback = function(self)
		--[[
			local visible = self:CanScrollUp() or self:CanScrollDown()
			self.GUI.Visible = visible
			Boundary.Size = visible
				and UDim2.new(Boundary.Size.X.Scale,0,1,-scroll_width)
				or  UDim2.new(Boundary.Size.X.Scale,0,1,            0)
		--]]
			Container.Position = UDim2.new(0,-HScroll.ScrollIndex,0,Container.Position.Y.Offset)
		--	return visible
		end

		HScroll.GUI.Visible = false
		VScroll.GUI.Size = UDim2.new(0,scroll_width,1,0)
		Boundary.Size = UDim2.new(1,-scroll_width,1,0)

		local Class = setmetatable({
			GUI = ParentFrame;
			Boundary = Boundary;
			Container = Container;
			VScroll = VScroll;
			HScroll = HScroll;
		},mt)

		local function SizeChanged(p)
			if p == "AbsoluteSize" then
				VScroll.TotalSpace = Container.AbsoluteSize.y
				VScroll.VisibleSpace = Boundary.AbsoluteSize.y
				HScroll.TotalSpace = Container.AbsoluteSize.x
				HScroll.VisibleSpace = Boundary.AbsoluteSize.x
				Class:Update()
			end
		end
		Boundary.Changed:connect(SizeChanged)
		Container.Changed:connect(SizeChanged)
		SizeChanged("AbsoluteSize")

		Class:Update()
		return Class
	end
end
