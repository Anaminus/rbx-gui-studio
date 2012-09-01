do
	local mt = {
		__index = {
			Update = function(self)
				local bounds = self.GUI.TextBounds
				local padding = self.Padding
				local x = self.LockXAxis or UDim.new(0,bounds.x+padding+padding)
				local y = self.LockYAxis or UDim.new(0,bounds.y+padding+padding)
				self.GUI.Size = UDim2.new(
					x.Scale,x.Offset,
					y.Scale,y.Offset
				)
			end;
			Destroy = function(self)
				self.GUI:Destroy()
				for k in pairs(self) do
					self[k] = nil
				end
				setmetatable(self,nil)
			end;
		};
	}

	function Widgets.AutoSizeLabel(Label)
		local Class = setmetatable({
			GUI = Label or Instance.new("TextLabel");
			Padding = 0;
		},mt)
		Class.GUI.Changed:connect(function(p)
			if p == "TextBounds" then
				Class:Update()
			end
		end)
		Class:Update()
		return Class
	end
end
