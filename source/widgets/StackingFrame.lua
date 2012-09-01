do
	local mt = {
		__index = {
			Update = function(self)
				local eid = self.event_id + 1; self.event_id = eid
				local width = 0
				local height = 0

				local padding,border = self.Padding,self.Border

				for i,child in pairs(self.List) do
					if self.event_id ~= eid then return end
					if child.Visible then
						local abs = child.AbsoluteSize
						child.Position = UDim2.new(0,border,0,height + border)
					--	width = abs.x > width and abs.x or width
						height = height + abs.y + padding
					end
				end
				if self.event_id ~= eid then return end
				if #self.List > 0 then
				--	self.GUI.Size = UDim2.new(0,width + border*2,0,height - padding + border*2)
					self.GUI.Size = UDim2.new(1,0,0,height - padding + border*2)
				else
				--	self.GUI.Size = UDim2.new(0,border*2,0,border*2)
					self.GUI.Size = UDim2.new(1,0,0,border*2)
				end
				self.event_id = 0
			end;
			AddObject = function(self,object,index)
				if object:IsA"GuiObject" then
					if type(index) == "number" then
						table.insert(self.List,index,object)
					else
						table.insert(self.List,object)
					end
					self.con_changed[object] = object.Changed:connect(function(p)
						if p == "AbsoluteSize" or p == "Visible" then
							self:Update()
						end
					end)
					object.Parent = self.GUI
					self:Update()
				end
			end;
			RemoveObject = function(self,index)
				local list = self.List
				if index == nil then
					index = #list
				elseif type(index) ~= "number" then
					for i,v in pairs(self.List) do
						if v == value then
							index = i
							break
						end
					end
				end
				if index then
					index = math.floor(index)
					index = index < 1 and 1 or index > #list and #list or index
					local object = table.remove(list,index)
					if self.con_changed[object] then
						self.con_changed[object]:disconnect()
						self.con_changed[object] = nil
					end
					object.Parent = nil
					self:Update()
					return object
				end
			end;
			Destroy = function(self)
				for object,con in pairs(self.con_changed) do
					con:disconnect()
					self.con_changed[object] = nil
				end
				for i,v in pairs(self.List) do
					v.Parent = nil
					self.List[i] = nil
				end
				self.GUI:Destroy()
				for k in pairs(self) do
					self[k] = nil
				end
				setmetatable(self,nil)
			end;
		};
	}

	function Widgets.StackingFrame(Frame)
		Frame = Frame or Instance.new("Frame")

		local Class = setmetatable({
			con_changed = {};
			event_id = 0;

			GUI = Frame;
			List = {};
			Border = 0;
			Padding = 0;
		},mt)

		for i,child in pairs(Frame:GetChildren()) do
			Class:AddObject(child,i)
		end

		Class:Update()

		return Class
	end
end
