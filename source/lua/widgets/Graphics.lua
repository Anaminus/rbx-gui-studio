--[[ArrowGraphic
Makes a pretty graphic of an arrow out of Frame objects.

Arguments:
	size
		A number indicating the size of the arrow. THe arrow will be (size x size).
	dir
		The direction of the arrow.
		Optional. Defaults to "Up".
	scaled
		Whether the Frames will be scale or offset.
		Optional. Defaults to false.
	template
		A template for each Frame.
		Optional.

Returns:
	graphic
		A frame containing the graphic.
]]
CreateEnum'ArrowGraphicDirection'{'Up', 'Down','Left','Right'}

function Widgets.ArrowGraphic(size,dir,scaled,template)
	local Frame = Instance.new("Frame")
	Frame.Name = "Arrow Graphic"
	Frame.BorderSizePixel = 0
	Frame.Size = UDim2.new(0,size,0,size)
	Frame.Transparency = 1
	if not template then
		template = Instance.new("Frame")
		template.BorderSizePixel = 0
	end

	local transform
	if dir == nil or Enums.ArrowGraphicDirection.Up(dir) then
		function transform(p,s) return p,s end
	elseif Enums.ArrowGraphicDirection.Down(dir) then
		function transform(p,s) return UDim2.new(0,p.X.Offset,0,size-p.Y.Offset-1),s end
	elseif Enums.ArrowGraphicDirection.Left(dir) then
		function transform(p,s) return UDim2.new(0,p.Y.Offset,0,p.X.Offset),UDim2.new(0,s.Y.Offset,0,s.X.Offset) end
	elseif Enums.ArrowGraphicDirection.Right(dir) then
		function transform(p,s) return UDim2.new(0,size-p.Y.Offset-1,0,p.X.Offset),UDim2.new(0,s.Y.Offset,0,s.X.Offset) end
	end

	local scale
	if scaled then
		function scale(p,s) return UDim2.new(p.X.Offset/size,0,p.Y.Offset/size,0),UDim2.new(s.X.Offset/size,0,s.Y.Offset/size,0) end
	else
		function scale(p,s) return p,s end
	end

	local o = math.floor(size/4)
	if size%2 == 0 then
		local n = size/2-1
		for i = 0,n do
			local t = template:Clone()
			local p,s = scale(transform(
				UDim2.new(0,n-i,0,o+i),
				UDim2.new(0,(i+1)*2,0,1)
			))
			t.Position = p
			t.Size = s
			t.Parent = Frame
		end
	else
		local n = (size-1)/2
		for i = 0,n do
			local t = template:Clone()
			local p,s = scale(transform(
				UDim2.new(0,n-i,0,o+i),
				UDim2.new(0,i*2+1,0,1)
			))
			t.Position = p
			t.Size = s
			t.Parent = Frame
		end
	end
	if size%4 > 1 then
		local t = template:Clone()
		local p,s = scale(transform(
			UDim2.new(0,0,0,size-o-1),
			UDim2.new(0,size,0,1)
		))
		t.Position = p
		t.Size = s
		t.Parent = Frame
	end
	return Frame
end

--[[GripGraphic
Makes a graphic of a grip texture out of Frame objects.

Arguments:
	size
		A Vector2 specifying the size of the grip.
	dir
		The direction of the lines in the grip.
		Optional. Defaults to horizontal.
	spacing
		The amount of pixels between each line.
		Optional. Defaults to 2.
	scaled
		Whether the Frames will be scale or offset.
		Optional. Defaults to false.
	template
		A template for each Frame.
		Optional.

Returns:
	graphic
		A frame containing the graphic.
]]

CreateEnum'GripGraphicDirection'{'Horizontal','Vertical'}

function Widgets.GripGraphic(size,dir,spacing,scaled,template)
	local Frame = Instance.new("Frame")
	Frame.Name = "Grip Graphic"
	Frame.BorderSizePixel = 0
	Frame.Size = UDim2.new(0,size.x,0,size.y)
	Frame.Transparency = 1
	if not template then
		template = Instance.new("Frame")
		template.BorderSizePixel = 0
	end

	spacing = spacing or 2

	local scale
	if scaled then
		function scale(p) return UDim2.new(p.X.Offset/size.x,0,p.Y.Offset/size.y,0) end
	else
		function scale(p) return p end
	end

	if Enums.GripGraphicDirection.Vertical(dir) then
		for i=0,size.x-1,spacing do
			local t = template:Clone()
			t.Size = scale(UDim2.new(0,1,0,size.y))
			t.Position = scale(UDim2.new(0,i,0,0))
			t.Parent = Frame
		end
	elseif dir == nil or Enums.GripGraphicDirection.Horizontal(dir) then
		for i=0,size.y-1,spacing do
			local t = template:Clone()
			t.Size = scale(UDim2.new(0,size.x,0,1))
			t.Position = scale(UDim2.new(0,0,0,i))
			t.Parent = Frame
		end
	end

	return Frame
end
