--[[
Similar to StackingFrame, but does not dynamically update
]]

function Widgets.StaticStackingFrame(Frame,conf)
	Frame = Frame or Instance.new("Frame")
	local config = {
		Border = 0;
		Padding = 0;
		LockAxis = nil;
		Horizontal = false;
		Alignment = false;
	}
	for k,v in pairs(conf) do config[k] = v end

	local border = config.Border
	local padding = config.Padding
	local alignment = config.Alignment

	local height,width = 0,0
	local children = Frame:GetChildren()

	if config.Horizontal then
		for i,child in pairs(children) do
			if child.Visible then
				local size = child.AbsoluteSize
				if alignment then
					child.Position = UDim2.new(0,width + border,1,-size.y - border)
				else
					child.Position = UDim2.new(0,width + border,0,border)
				end
				height = size.y > height and size.y or height
				width = width + size.x + padding
			end
		end
		if #children > 0 then
			if config.LockAxis then
				Frame.Size = UDim2.new(0,width - padding + border*2,config.LockAxis.Scale,config.LockAxis.Offset)
			else
				Frame.Size = UDim2.new(0,width - padding + border*2,0,height + border*2)
			end
		else
			if config.LockAxis then
				Frame.Size = UDim2.new(0,border*2,config.LockAxis.Scale,config.LockAxis.Offset)
			else
				Frame.Size = UDim2.new(0,border*2,0,border*2)
			end
		end
	else
		for i,child in pairs(children) do
			if child.Visible then
				local size = child.AbsoluteSize
				if alignment then
					child.Position = UDim2.new(1,-size.x - border,0,height + border)
				else
					child.Position = UDim2.new(0,border,0,height + border)
				end
				width = size.x > width and size.x or width
				height = height + size.y + padding
			end
		end
		if #children > 0 then
			if config.LockAxis then
				Frame.Size = UDim2.new(config.LockAxis.Scale,config.LockAxis.Offset,0,height - padding + border*2)
			else
				Frame.Size = UDim2.new(0,width + border*2,0,height - padding + border*2)
			end
		else
			if config.LockAxis then
				Frame.Size = UDim2.new(config.LockAxis.Scale,config.LockAxis.Offset,0,border*2)
			else
				Frame.Size = UDim2.new(0,border*2,0,border*2)
			end
		end
	end

	return Frame
end
