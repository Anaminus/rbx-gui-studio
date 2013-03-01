--[[DragGUI
Performs a dragging operation on a group of GUIs.
A "modifier" can be applied to the drag, which modifies how the object's position and size are changed while dragging.
Each modifier represents an edge of the object being dragged, such that it appears that edge is being dragged.

Arguments:
	objectList
		An object or a list of GUIs to manipulate.

	originObject
		The object that was clicked to begin the drag.
		If unspecified, the last object in the `objectList` table is used.

	mouseClick
		The Vector2 position where the mouse clicked.

	dragModifier
		Modifies how the drag will manipluate the object's position and size.

	callbacks
		A table of callback functions:

		OnDrag(x, y, hasDragged, setObjects)
			Called when the mouse is dragged.
			x, y
				The mouse coordinates where the button was released.
			hasDragged
				A bool indicating whether the mouse was previously dragged.
			setObjects(list, origin)
				A function that, when called, sets the objects being dragged.
				`list` becomes objectList, and `origin` becomes originObject.

			If this function returns false, then the current drag will be canceled.
			If this function return true, then the whole dragging operation will end.
			Anything else continues the drag normlly.

		OnRelease(x, y, hasDragged)
			Called when the dragging operation ends.
			hasDragged
				A bool indicating whether the mouse was dragged before the button was released.
			x, y
				The mouse coordinates where the button was released.

	dragParent
		An object whose ScreenGui the Dragger object will be added to.
		If unspecified, the Dragger will be put in the ScreenGui of the first object in the `objectList` table.

	snap_anchor
		If true, a visual indicator of the point where objects snap will be displayed.

	no_hide
		If true, selection highlights are not hidden.

	no_snap
		If true, objects will not be snapped regardless of settings.

Returns:
	finishDrag
		A function that, when called, ends the dragging operation.
]]

do
	Settings.SnapFromCorners = true
	Settings.SnapFromEdges = true
	Settings.SnapFromCenter = true

	local DragModifier = CreateEnum'DragModifier'{'TopLeft','Top','TopRight','Right','BottomRight','Bottom','BottomLeft','Left','Center'}
	--[[

	When dragging, these modifiers are multiplied by the final Position and
	Size of an object, which constrains the changes made by the drag in
	certain ways, depending on the modifer chosen.

	Some Size modifiers are negative. In this case, when an object is dragged,
	its position is offset, and its size offset in the opposite direction by
	the exact same amount, which effectively makes that opposite edge appear
	static.

	]]
	local ModifierLookup = {	   -- Position           Size                Snap Adjust
		[DragModifier.TopLeft    ] = {Vector2.new(1, 1), Vector2.new(-1,-1), Vector2.new(0  , 0  )};
		[DragModifier.Top        ] = {Vector2.new(0, 1), Vector2.new( 0,-1), Vector2.new(0.5, 0  )};
		[DragModifier.TopRight   ] = {Vector2.new(0, 1), Vector2.new( 1,-1), Vector2.new(1  , 0  )};
		[DragModifier.Right      ] = {Vector2.new(0, 0), Vector2.new( 1, 0), Vector2.new(1  , 0.5)};
		[DragModifier.BottomRight] = {Vector2.new(0, 0), Vector2.new( 1, 1), Vector2.new(1  , 1  )};
		[DragModifier.Bottom     ] = {Vector2.new(0, 0), Vector2.new( 0, 1), Vector2.new(0.5, 1  )};
		[DragModifier.BottomLeft ] = {Vector2.new(1, 0), Vector2.new(-1, 1), Vector2.new(0  , 1  )};
		[DragModifier.Left       ] = {Vector2.new(1, 0), Vector2.new(-1, 0), Vector2.new(0  , 0.5)};
		[DragModifier.Center     ] = {Vector2.new(1, 1), Vector2.new( 0, 0), Vector2.new(0.5, 0.5)};
	}

	local NegCorrection do
		--[[

			If a coordinate of the AbsoluteSize of an object is negative, then
			the object wont resize as expected. That's why we map the given
			drag modifier to a corrected modifier, depending on which
			coordinates are negative.

			For example, if both coordinates are negative, and the given
			modifier is TopLeft, it would map to BottomRight, because that's
			the opposite corner on both axes.

		]]

		local TopLeft     = DragModifier.TopLeft
		local Top         = DragModifier.Top
		local TopRight    = DragModifier.TopRight
		local Right       = DragModifier.Right
		local BottomRight = DragModifier.BottomRight
		local Bottom      = DragModifier.Bottom
		local BottomLeft  = DragModifier.BottomLeft
		local Left        = DragModifier.Left
		local Center      = DragModifier.Center

		NegCorrection = {	-- AbsoluteSize: X>=0; Y>=0            X>=0; Y<0                      X<0; Y>=0             X<0; Y<0
			[ TopLeft     ]={[true]={[true]= TopLeft     ,[false]= BottomLeft  },[false]={[true]= TopRight    ,[false]= BottomRight }};
			[ Top         ]={[true]={[true]= Top         ,[false]= Bottom      },[false]={[true]= Top         ,[false]= Bottom      }};
			[ TopRight    ]={[true]={[true]= TopRight    ,[false]= BottomRight },[false]={[true]= TopLeft     ,[false]= BottomLeft  }};
			[ Right       ]={[true]={[true]= Right       ,[false]= Right       },[false]={[true]= Left        ,[false]= Left        }};
			[ BottomRight ]={[true]={[true]= BottomRight ,[false]= TopRight    },[false]={[true]= BottomLeft  ,[false]= TopLeft     }};
			[ Bottom      ]={[true]={[true]= Bottom      ,[false]= Top         },[false]={[true]= Bottom      ,[false]= Top         }};
			[ BottomLeft  ]={[true]={[true]= BottomLeft  ,[false]= TopLeft     },[false]={[true]= BottomRight ,[false]= TopRight    }};
			[ Left        ]={[true]={[true]= Left        ,[false]= Left        },[false]={[true]= Right       ,[false]= Right       }};
			[ Center      ]={[true]={[true]= Center      ,[false]= Center      },[false]={[true]= Center      ,[false]= Center      }};
		}
	end

	local CenterSnapPoints = {
		{
			Name = "SnapFromCorners";
			Vector2.new(0,0);
			Vector2.new(1,0);
			Vector2.new(1,1);
			Vector2.new(0,1);
		};
		{
			Name = "SnapFromEdges";
			Vector2.new(0.5,0  );
			Vector2.new(1  ,0.5);
			Vector2.new(0.5,1  );
			Vector2.new(0  ,0.5);
		};
		{
			Name = "SnapFromCenter";
			Vector2.new(0.5,0.5);
		};
	}

	function Widgets.DragGUI(objectList,originObject,mouseClick,dragMod,callbacks,dragParent,snap_anchor,no_hide,no_snap)
		if type(objectList) ~= 'table' then
			objectList = {objectList}
		end

		dragMod = dragMod == nil and DragModifier(1) or DragModifier(dragMod)
		if dragMod == nil then
			error("DragGUI: bad argument #4, unable to cast value to DragModifier",2)
		end

		callbacks = callbacks or {}

		local Maid = CreateMaid()

		--[[

		Objects are dragged by first getting the point where the user clicked
		to begin the drag (mouseClick), and the Position/Size of each object
		at that point (originPos/Size). Then, as the user drags, the
		Position/Size of each object is offset from their origin by applying
		the difference between the originClick and the current position of the
		mouse.

		originClick is the point that all objects are offset from when dragging.
		If snapping is enabled, this point is constrained to the grid.

		]]
		local originClick = mouseClick
		local mouseOffset
		local originPos = {}
		local originSize = {}

		local originObjectPos
		local originObjectSize

		local dragModifier = dragMod
		local modPos
		local modSize
		local modSnap

		-- These values are used every time a drag occurs, so they are
		-- calculated only when they need to be.
		local layoutScaled = Settings.LayoutMode('Scale')
		local snapEnabled = Settings.SnapEnabled and not no_snap

		-- When snapping, because the originClick isnt always at the exact
		-- position where the mouse clicked, a visual indicator is displayed.
		local snapAnchorFrame
		if snap_anchor then
			snapAnchorFrame = Create'Frame'{
				Name = "SnapAnchor VisualEffect";
				BackgroundColor3 = Color3.new(1,1,1);
				BorderColor3 = Color3.new(0,0,0);
				Transparency = 0.25;
				Size = UDim2.new(0,8,0,8);
			}
			Maid:GiveTask(function() snapAnchorFrame:Destroy() end)
		end

		local snapAnchor = Vector2.new(0,0)
		local function updateSnapAnchorFrame(cx,cy)
			--[[

			The position of the visual indicator must be adjusted depending on
			which coordinates of the absolute size are negative, because GUIs
			are drawn based on their apparent size (how they look), and not
			their actual size.

			]]
			if snapAnchorFrame then
				if cx then
					if cy then
						snapAnchorFrame.Position = UDim2.new(snapAnchor.x,-4,snapAnchor.y,-4)
					else
						snapAnchorFrame.Position = UDim2.new(snapAnchor.x,-4,1-snapAnchor.y,-4)
					end
				else
					if cy then
						snapAnchorFrame.Position = UDim2.new(1-snapAnchor.x,-4,snapAnchor.y,-4)
					else
						snapAnchorFrame.Position = UDim2.new(1-snapAnchor.x,-4,1-snapAnchor.y,-4)
					end
				end
			end
		end

		local function updateOriginClick()
			--[[

			There is a Snap Adjust component of the drag modifier, which is
			used only when snapping is enabled. When enabled, instead of using
			the mouseClick, the snap adjust is multiplied by the Size and
			offset by the Position of the first object, which is then used as
			the originClick. This fixes the originClick to a corner or edge of
			the object, which ensures that the snap is properly aligned.

			The Center snap adjust is a special case. Since there is a large
			area of points that map to the Center, the point that is closest
			to the provided mouseClick is chosen. This can be an edge or
			corner or even the center of the object, depending on the snap
			settings.

			]]
			local anchor
			if snapEnabled then
				if originObject then
					if dragModifier('Center') then
						local nearest = mouseClick
						local dist = math.huge
						local mx,my = mouseClick.x,mouseClick.y
						for i = 1,#CenterSnapPoints do
							local points = CenterSnapPoints[i]
							if Settings[points.Name] then
								for n = 1,#points do
									local p = originObjectPos + originObjectSize*points[n]
									local d = (mx - p.x)*(mx - p.x) + (my - p.y)*(my - p.y)
									if d <= dist then --later points get priority
										nearest = p
										dist = d
										anchor = points[n]
									end
								end
							end
						end
						originClick = nearest
					else
						originClick = originObjectPos + originObjectSize*modSnap
						anchor = modSnap
					end
				else
					originClick = mouseClick
				end
			else
				originClick = mouseClick
			end
			if snapAnchorFrame then
				if anchor then
				-- implies originObject ~= nil
					local abs = originObject.AbsoluteSize
					snapAnchor = anchor
					updateSnapAnchorFrame(abs.x >= 0,abs.y >= 0)
					snapAnchorFrame.Parent = originObject
				else
					snapAnchorFrame.Parent = nil
				end
			end
			mouseOffset = originClick - mouseClick
		end

		Maid:GiveTask(Settings.Changed:connect(function(key,value)
			if key == 'LayoutMode' then
				--[[

				Because objects are offset from an origin, there wont be any
				odd effects from switching the layout mode mid-drag. The
				Position/Size will simply be offset using the other layout
				component.

				However, switching the layout mode will not update each object
				by itself. The mouse must also move so that a drag is
				detected, which does the updating. This doesn't seem like it
				would be much of a problem, so it will be left alone for now.

				]]
				layoutScaled = value('Scale')
			elseif key == 'SnapEnabled' then
				snapEnabled = value and not no_snap
				updateOriginClick()
			end
		end))

		--[[

		setObjects is passed through the OnDrag callback, which lets the list
		of dragged objects be switched mid-drag. For example, this is used in
		the Insert tool to begin a drag when the user clicks, but create a new
		object only on the first drag.

		]]

		local function setObjects(list,origin)
			objectList = list
			originObject = origin or objectList[#objectList]
			originObjectPos = origin and origin.AbsolutePosition or Vector2.new(0,0)
			originObjectSize = origin and origin.AbsoluteSize or Vector2.new(0,0)
			for i,object in pairs(list) do
				originPos[i] = object.Position
				originSize[i] = object.Size
			end

			if originObject then
				local abs = originObject.AbsoluteSize
				dragModifier = NegCorrection[dragMod][abs.x >= 0][abs.y >= 0]
			else
				dragModifier = dragMod
			end

			local modifier = ModifierLookup[dragModifier]
			modPos = modifier[1]
			modSize = modifier[2]
			modSnap = modifier[3]

			updateOriginClick()

			if snapEnabled then
				SnapService:ReadyData(originObject)
			end
		end

		setObjects(objectList,originObject)

		local Dragger = Widgets.Dragger()
		local conDrag,conUp,conMode
		local hasDragged = false

		-- finishDrag is returned by the DragGUI, allowing the operation to be
		-- finished remotely. Useful if the plugin deactivates unexpectedly.

		local dragFinished = false
		local function finishDrag(x,y)
			if dragFinished then return end
			dragFinished = true
			Maid:DoCleaning()
			Dragger:Destroy()
			if snapEnabled then
				SnapService:ClearData()
			end
			Selection:SetVisible(true)
			if callbacks.OnRelease then
				callbacks.OnRelease(x,y,hasDragged)
			end
		end

		if snapEnabled then
			SnapService:ReadyData(originObject)
		end

		local OnDrag = callbacks.OnDrag
		Maid:GiveTask(Dragger.MouseButton1Up:connect(finishDrag))
		local negAbsX
		local negAbsY
		Maid:GiveTask(Dragger.MouseMoved:connect(function(x,y)
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

			local dragPos
			if snapEnabled then
				-- The mouseOffset is added so the object moves in relation to the original mouse click.
				dragPos = SnapService:Snap(Vector2.new(x,y) + mouseOffset)
			else
				dragPos = Vector2.new(x,y)
			end

			local mouseDelta = dragPos - originClick
			if layoutScaled then
				for i = 1,#objectList do
					local object = objectList[i]
					local oPos = originPos[i]
					local oSize = originSize[i]

					local absSize = object.Parent.AbsoluteSize

					local pos = (Vector2.new(oPos.X.Scale,oPos.Y.Scale)*absSize + mouseDelta*modPos)/absSize
					object.Position = UDim2.new(pos.x,oPos.X.Offset,pos.y,oPos.Y.Offset)

					local size = (Vector2.new(oSize.X.Scale,oSize.Y.Scale)*absSize + mouseDelta*modSize)/absSize
					object.Size = UDim2.new(size.x,oSize.X.Offset,size.y,oSize.Y.Offset)
				end
			else
				for i = 1,#objectList do
					local object = objectList[i]
					local oPos = originPos[i]
					local oSize = originSize[i]

					local pos = Vector2.new(oPos.X.Offset,oPos.Y.Offset) + mouseDelta*modPos
					object.Position = UDim2.new(oPos.X.Scale,pos.x,oPos.Y.Scale,pos.y)

					local size = Vector2.new(oSize.X.Offset,oSize.Y.Offset) + mouseDelta*modSize
					object.Size = UDim2.new(oSize.X.Scale,size.x,oSize.Y.Scale,size.y)
				end
			end

			if snapAnchorFrame and originObject then
			-- updates the snapAnchorFrame when the abs size is dragged from positive to negative, and vice-versa
				local abs = originObject.AbsoluteSize
				local x = abs.x >= 0
				local y = abs.y >= 0
				if x ~= negAbsX or y ~= negAbsY then
					negAbsX = x
					negAbsY = y
					updateSnapAnchorFrame(x,y)
				end
			end
		end))
		if not no_hide then
			Selection:SetVisible(false)
		end
		Dragger.Parent = GetScreen(dragParent or objectList[1])
		return finishDrag
	end
end
