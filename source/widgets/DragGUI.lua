--[[DragGUI
Performs a dragging operation on a group of GUIs.
A "modifier" can be applied to the drag, which modifies how the object's position and size are changed while dragging.
Each modifier represents an edge of the object being dragged, such that it appears that edge is being dragged.

Arguments:
	objects
		An object or a list of GUIs to manipulate.

	origin
		The Vector2 position where the mouse clicked.

	modifier
		Modifies how the drag will manipluate the object's position and size.

	callbacks
		A table of callback functions:

		OnDrag(x, y, hasDragged, setObjects)
			Called when the mouse is dragged.
			x, y
				The mouse coordinates where the button was released.
			hasDragged
				A bool indicating whether the mouse was previously dragged.
			setObjects(table)
				A function that, when called, sets the objects being dragged.

			If this function returns false, then the current drag will be canceled.
			If this function return true, then the whole dragging operation will end.
			Anything else continues the drag normlly.

		OnRelease(x, y, hasDragged)
			Called when the dragging operation ends.
			hasDragged
				A bool indicating whether the mouse was dragged before the button was released.
			x, y
				The mouse coordinates where the button was released.

	parent
		Where to put the Dragger object. Optional.

	no_hide
		If true, selection highlights are not hidden.

Returns:
	finishDrag
		A function that, when called, ends the dragging operation.
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

	function Widgets.DragGUI(objectList,originClick,modifier,callbacks,parent,no_hide)
		if type(objectList) ~= 'table' then
			objectList = {objectList}
		end

		modifier = modifier == nil and DragModifier(1) or modifier
		modifier = ModifierLookup[DragModifier(modifier)]
		if modifier == nil then
			error("DragGUI: bad argument #3, unable to cast value to DragModifier",2)
		end
		local modPos = modifier[1]
		local modSize = modifier[2]

		callbacks = callbacks or {}

		local originPos = {}
		local originSize = {}

		local function setObjects(list)
			objectList = list
			for i,object in pairs(list) do
				originPos[i] = object.Position
				originSize[i] = object.Size
			end
		end

		setObjects(objectList)

		local Dragger = Widgets.Dragger()
		local conDrag,conUp,conMode
		local hasDragged = false

		local dragFinished = false
		local function finishDrag(x,y)
			if dragFinished then return end
			dragFinished = true
			conDrag:disconnect()
			conUp:disconnect()
			conMode:disconnect()
			Dragger:Destroy()
			Selection:SetVisible(true)
			if callbacks.OnRelease then
				callbacks.OnRelease(x,y,hasDragged)
			end
		end

		local scaled = Settings.LayoutMode('Scale')
		conMode = Settings.Changed:connect(function(key,value)
			if key == 'LayoutMode' then
				-- Switching the layout mode mid-drag is fine because the
				-- drag offsets from the starting position/size of the object
				scaled = value('Scale')
			end
		end)

		local OnDrag = callbacks.OnDrag

		conUp = Dragger.MouseButton1Up:connect(finishDrag)
		conDrag = Dragger.MouseMoved:connect(function(x,y)
		--[[ amount in pixels before a click is considered a drag
			if not hasDragged and (originClick - Vector2.new(x,y)).magnitude <= Settings.ClickDragThreshold then
				return
			end
		--]]
			if OnDrag then
				local result = OnDrag(x,y,hasDragged,setObjects)
				if result == false then
					return
				elseif result == true then
					finishDrag(x,y)
					return
				end
			end

			hasDragged = true
			local diff = Vector2.new(x,y) - originClick
			if scaled then
				for i = 1,#objectList do
					local object = objectList[i]
					local oPos = originPos[i]
					local oSize = originSize[i]

					local absSize = object.Parent.AbsoluteSize

					local pos = (Vector2.new(oPos.X.Scale,oPos.Y.Scale)*absSize + diff*modPos)/absSize
					object.Position = UDim2.new(pos.x,oPos.X.Offset,pos.y,oPos.Y.Offset)

					local size = (Vector2.new(oSize.X.Scale,oSize.Y.Scale)*absSize + diff*modSize)/absSize
					object.Size = UDim2.new(size.x,oSize.X.Offset,size.y,oSize.Y.Offset)
				end
			else
				for i = 1,#objectList do
					local object = objectList[i]
					local oPos = originPos[i]
					local oSize = originSize[i]

					local pos = Vector2.new(oPos.X.Offset,oPos.Y.Offset) + diff*modPos
					object.Position = UDim2.new(oPos.X.Scale,pos.x,oPos.Y.Scale,pos.y)

					local size = Vector2.new(oSize.X.Offset,oSize.Y.Offset) + diff*modSize
					object.Size = UDim2.new(oSize.X.Scale,size.x,oSize.Y.Scale,size.y)
				end
			end
		end)
		if not no_hide then
			Selection:SetVisible(false)
		end
		Dragger.Parent = GetScreen(parent or objectList[1])
		return finishDrag
	end
end
