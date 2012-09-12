--[[DragGUI
Performs a dragging operation on a GUI.
A "modifier" can be applied to the drag, which modifies how the object's position and size are changed while dragging.
Each modifier represents an edge of the object being dragged, such that it appears that edge is being dragged.

Arguments:
	object
		The GUI to manipulate
	origin
		The point where the mouse clicked
	modifier
		Modifies how the drag will manipluate the object's position and size
	scaled
		Whether the Scale or Offset component is being manipulated

Returns:
	position
		The new position of the object after the drag
	size
		The new size of the object after the drag
]]

do
	local DragModifier = CreateEnum'DragModifier'{'TopLeft','Top','TopRight','Right','BottomRight','Bottom','BottomLeft','Left','Center'}

	local ModifierLookup = {       -- Position           Size
		[DragModifier.TopLeft]     = {Vector2.new(1, 1), Vector2.new(-1,-1)};
		[DragModifier.Top]         = {Vector2.new(0, 1), Vector2.new( 0,-1)};
		[DragModifier.TopRight]    = {Vector2.new(0, 1), Vector2.new( 1,-1)};
		[DragModifier.Right]       = {Vector2.new(0, 0), Vector2.new( 1, 0)};
		[DragModifier.BottomRight] = {Vector2.new(0, 0), Vector2.new( 1, 1)};
		[DragModifier.Bottom]      = {Vector2.new(0, 0), Vector2.new( 0, 1)};
		[DragModifier.BottomLeft]  = {Vector2.new(1, 0), Vector2.new(-1, 1)};
		[DragModifier.Left]        = {Vector2.new(1, 0), Vector2.new(-1, 0)};
		[DragModifier.Center]      = {Vector2.new(1, 1), Vector2.new( 0, 0)};
	}

	function Widgets.DragGUI(object,originClick,modifier,scaled)
		modifier = modifier == nil and DragModifier(1) or modifier
		modifier = ModifierLookup[DragModifier(modifier)]
		if modifier == nil then
			error("DragGUI: bad argument #3, unable to cast value to DragModifier",2)
		end
		local modPos = modifier[1]
		local modSize = modifier[2]

		local originPos = object.Position
		local originSize = object.Size

		local Dragger = Widgets.Dragger()
		local conDrag,conUp

		local dialog = Widgets.DialogBase()

		conUp = Dragger.MouseButton1Up:connect(function()
			conDrag:disconnect()
			conUp:disconnect()
			Dragger:Destroy()
			dialog:Return(object.Position,object.Size)
		end)
		conDrag = Dragger.MouseMoved:connect(function(x,y)
			local diff = Vector2.new(x,y) - originClick
			if scaled then

			else
				local pos = Vector2.new(originPos.X.Offset,originPos.Y.Offset) + diff * modPos
				object.Position = UDim2.new(originPos.X.Scale,pos.x,originPos.Y.Scale,pos.y)

				local size = Vector2.new(originSize.X.Offset,originSize.Y.Offset) + diff * modSize
				object.Size = UDim2.new(originSize.X.Scale,size.x,originSize.Y.Scale,size.y)
			end
		end)
		Dragger.Parent = GetScreen(object)
		return dialog:Finish()
	end
end
