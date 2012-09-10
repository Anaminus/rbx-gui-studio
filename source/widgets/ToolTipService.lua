--[[ToolTipService
Allows text to be displayed when an object is hovered over.

When an object with a tooltip is hovered over, some things happen:
	- There is a delay of 0.5 seconds before the tooltip is displayed.
	- If a tooltip is already being displayed, the tooltip is displayed instantly.
	- The tooltip is displayed below the cursor (~40 pixels in size; no way to actually get this, yet)
	- The tooltip is constrained within the boundary of the screen, so that it's always readable.

API:
	ToolTipManager.DisplayingToolTip            Whether a tooltip is currently being displayed.
	ToolTipManager.Frame                        The label used to display text.
	ToolTipManager.Parent                       The parent of the Frame.

	ToolTipManager:AddToolTip(object,message)   Adds a message to be displayed when an object is hovered over.
	                                            Only removes the tooltip if `message` is nil.
	ToolTipManager:RemoveToolTip(object)        Removes a tooltip from an object.

]]
local ToolTipService do
	ToolTipService = {
		ToolTips = {}; --setmetatable({},{__mode='k'});
		CurrentToolTip = nil;
		DisplayingToolTip = false;
		HoverID = 0;
		Parent = nil;
		Frame = Create'Frame'{
			Name = "ToolTip";
			BorderColor3 = Color3.new(0,0,0);
			BackgroundColor3 = Color3.new(1,1,1);
			ZIndex = 10;
			Create'TextLabel'{
				Name = "Message";
				Position = UDim2.new(0,2,0,2);
				Size = UDim2.new(1,-4,1,-4);
				BackgroundTransparency = 1;
				TextColor3 = Color3.new(0,0,0);
				Font = "Arial";
				FontSize = "Size14";
				ZIndex = 10;
			};
		};
	}

	function ToolTipService:ShowToolTip(tooltip,pos)
		self.CurrentToolTip = tooltip
		local frame = self.Frame
		frame.Visible = false


		local message = frame.Message
		message.TextWrapped = not not tooltip.Message:match('\n')
		message.Text = tooltip.Message

		-- determine size
		frame.Size = UDim2.new(0,1000,0,1000)
		frame.Parent = self.Parent
		while message.TextBounds.magnitude == 0 do
			message.Changed:wait()
		end
		frame.Size = UDim2.new(0,message.TextBounds.x+4,0,message.TextBounds.y+4)

		-- determine position
		local fabs = frame.AbsoluteSize
		local pabs = self.Parent.AbsoluteSize
		pos = Vector2.new(pos.x,pos.y+40)
		if pos.x < 2 then
			pos = Vector2.new(2,pos.y)
		elseif pos.x + fabs.x + 2 > pabs.x then
			pos= Vector2.new(pabs.x - fabs.x - 2,pos.y)
		end
		if pos.y < 2 then
			pos = Vector2.new(pos.x,2)
		elseif pos.y + fabs.y + 2 > pabs.y then
			pos= Vector2.new(pos.x,pos.y - fabs.y - 2 - 40)
		end
		frame.Position = UDim2.new(0,pos.x,0,pos.y)

		frame.Visible = true
		self.DisplayingToolTip = true
	end

	function ToolTipService:AddToolTip(object,message)
		if self.ToolTips[object] then
			self:RemoveToolTip(object)
		end

		if message == nil then return end

		local tooltip = {
			Object = object;
			Message = message;
		}

		tooltip.conEnter = object.MouseEnter:connect(function(x,y)
			local cid = self.HoverID + 1
			self.HoverID = cid
			if self.DisplayingToolTip then
				self:ShowToolTip(tooltip,Vector2.new(x,y))
			else
				local pos = Vector2.new(x,y)
				local conMoved = object.MouseMoved:connect(function(x,y) pos = Vector2.new(x,y) end)
				wait(0.5)
				conMoved:disconnect()
				if self.HoverID == cid then
					self:ShowToolTip(tooltip,pos)
				end
			end
		end)
		tooltip.conLeave = object.MouseLeave:connect(function(x,y)
			local cid = self.HoverID + 1
			self.HoverID = cid
			if self.CurrentToolTip == tooltip then
				self.CurrentToolTip = nil
				self.Frame.Parent = nil
				if self.DisplayingToolTip then
					wait(0.2)
					if self.HoverID == cid then
						self.DisplayingToolTip = false
						self.HoverID = 0
					end
				end
			end
		end)

		self.ToolTips[object] = tooltip
	end

	function ToolTipService:RemoveToolTip(object)
		local tooltip = self.ToolTips[object]
		if tooltip then
			tooltip.conEnter:disconnect()
			tooltip.conLeave:disconnect()
			self.ToolTips[object] = nil
			if self.Frame.Parent == object then
				self.Frame.Parent = nil
			end
		end
	end
end
