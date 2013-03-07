--[[SnapService

Provides services for snapping to various things. Snapping is done using a
`snapper` function, which snaps a given point to two axes. Neither axis is
required. Static data can be initialized before continual calls to each
snapper, reducing execution time.

API:

SnapService:AddInitializer( ref, func )
	Adds an initializer function. This function can be called before the Snap
	method, and its return value will be added to a data map, referenced by
	`ref`. This map will be passed to each snapper.

SnapService:AddSnapper ( ref, func )
	Adds a new method of snapping.

	Arguments:
		`ref`
			A string used to refer to the snap interest.

		`func`
			The function that does the snapping.

			Arguments:
				`point`
					The point to be snapped.

				`data`
					A map of the data returned by each initializer.

			Returns:
				`snappedX`
					The snapped X coordinate. Return nil to not snap on this axis.

				`snappedY`
					The snapped Y coordinate. Return nil to not snap on this axis.

SnapService:ClearData ()
	Clears all data initialized by SnapService:ReadyData.

SnapService:ReadyData (...)
	Readies data from all enabled initializers.
	Arguments passed to this function are passed to each initializer.

SnapService:GetEnabled ( ref )
	Returns whether a snapper is enabled.

SnapService:SetEnabled ( ref, enabled )
	Sets whether a snapper is enabled.

SnapService:Snap ( interestPoint )
	Snaps a point by running it through each snapper function.
	Returns the snapped point.

SnapService:SetAnchorVisual( position, object )
	Sets the location where a visual representation of a snap anchor will appear.

	Arguments:
		`position`
			A UDim2 indicating the position of the anchor.
			If nil, the anchor visual is hidden.
		`object`
			The object that the anchor will appear in.
			If nil, the canvas will be used instead.

SnapService:ClearVisuals()
	Clears any visual lines and anchors that were created while snapping.

SnapService:SetParent( parent )
	Sets the parent where visual snapping lines will appear.

SnapService.StateChanged ( ref, enabled )
	Fired after a snapper is enabled or disabled.

]]

Settings.SnapEnabled = false
Settings.SnapTolerance = 8

local SnapService do
	SnapService = {}

	local snapperList = {}
	local snapperLookup = {}
	local snapperEnabled = {}
	local snapperInit = {}
	local snapperData = {}

	local eventStateChanged = CreateSignal(SnapService,'StateChanged')

	function SnapService:AddInitializer(ref,init)
		snapperInit[ref] = init
	end

	function SnapService:AddSnapper(ref,snapper)
		snapperList[#snapperList+1] = snapper
		snapperLookup[ref] = snapper
		snapperEnabled[snapper] = true
	end

	function SnapService:GetEnabled(ref)
		if snapperLookup[ref] then
			return snapperEnabled[snapperLookup[ref]]
		else
			error("`"..tostring(ref).."` does not reference an existing snapper",2)
		end
	end

	function SnapService:SetEnabled(ref,enabled)
		local snapper = snapperLookup[ref]
		if snapper then
			enabled = not not enabled
			snapperEnabled[snapper] = enabled
			eventStateChanged:Fire(ref,enabled)
		else
			error("`"..tostring(ref).."` does not reference an existing snapper",2)
		end
	end

	function SnapService:ReadyData(...)
		for ref,init in pairs(snapperInit) do
			snapperData[ref] = init(...)
		end
	end

	function SnapService:ClearData()
		for ref in pairs(snapperData) do
			snapperData[ref] = nil
		end
	end

	local setXLine,setYLine do
		local screen
		local screenPosX,screenPosY
		local screenSizeX,screenSizeY
		local screenConn

		function SnapService:SetParent(parent)
			if screenConn then screenConn:disconnect() end
			screen = parent
			screenPos = screen.Position
			screenSizeX = screen.AbsoluteSize.x
			screenSizeY = screen.AbsoluteSize.y
			screenConn = screen.Changed:connect(function(p)
				if p == 'AbsoluteSize' then
					screenSizeX = screen.AbsoluteSize.x
					screenSizeY = screen.AbsoluteSize.y
				elseif p == 'AbsolutePosition' then
					screenPosX = screen.AbsolutePosition.x
					screenPosY = screen.AbsolutePosition.y
				end
			end)
		end

		local lineXFrame = Create'Frame'{
			BackgroundColor3 = Color3.new(1,0,0);
			BorderSizePixel = 0;
			Create'Frame'{
				Name = "Border";
				Transparency = 1;
				Size = UDim2.new(1,0,1,0);
				Create'Frame'{
					Name = "Top";
					BackgroundColor3 = Color3.new(0,0,0);
					BackgroundTransparency = 0.5;
					BorderSizePixel = 0;
					Position = UDim2.new(0,-1,0,-1);
					Size = UDim2.new(1,2,0,1);
				};
				Create'Frame'{
					Name = "Right";
					BackgroundColor3 = Color3.new(0,0,0);
					BackgroundTransparency = 0.5;
					BorderSizePixel = 0;
					Position = UDim2.new(1,0,0,0);
					Size = UDim2.new(0,1,1,0);
				};
				Create'Frame'{
					Name = "Bottom";
					BackgroundColor3 = Color3.new(0,0,0);
					BackgroundTransparency = 0.5;
					BorderSizePixel = 0;
					Position = UDim2.new(0,-1,1,0);
					Size = UDim2.new(1,2,0,1);
				};
				Create'Frame'{
					Name = "Left";
					BackgroundColor3 = Color3.new(0,0,0);
					BackgroundTransparency = 0.5;
					BorderSizePixel = 0;
					Position = UDim2.new(0,-1,0,0);
					Size = UDim2.new(0,1,1,0);
				};
			};
		}
		local lineYFrame = lineXFrame:Clone()

		function setXLine(px,line)
			if px then
				local ly,hy
				if line then
					ly = line.x - screenPosY
					hy = line.y - screenPosY
				else
					ly = -screenPosY
					hy = screenSizeY
				end
				lineXFrame.Position = UDim2.new(0,px - screenPosX,0,ly)
				lineXFrame.Size = UDim2.new(0,1,0,hy - ly)
				lineXFrame.Parent = screen
			else
				lineXFrame.Parent = nil
			end
		end

		function setYLine(py,line)
			if py then
				local lx,hx
				if line then
					lx = line.x - screenPosX
					hx = line.y - screenPosX
				else
					lx = -screenPosX
					hx = screenSizeX
				end
				lineYFrame.Position = UDim2.new(0,lx,0,py - screenPosY)
				lineYFrame.Size = UDim2.new(0,hx - lx,0,1)
				lineYFrame.Parent = screen
			else
				lineYFrame.Parent = nil
			end
		end

	---- SNAP ANCHOR VISUAL
		local size = 4
		local anchorFrame = Create'Frame'{
			Name = "SnapAnchor VisualEffect";
			BackgroundColor3 = Color3.new(1,1,1);
			BorderColor3 = Color3.new(0,0,0);
			Transparency = 0.25;
			Size = UDim2.new(0,size*2,0,size*2);
		}

		local anchorParent
		local anchorConn

		local anchorPos
		local anchorPosNegX
		local anchorPosNegY
		local anchorPosNegXY

		local absNegX
		local absNegY

		local updateAnchor do
			function updateAnchor()
				-- The position of the visual indicator must be adjusted depending
				-- on which coordinates of the absolute size are negative, because
				-- GUIs are drawn based on their apparent size (how they look),
				-- and not their actual size.
				local x = anchorParent.AbsoluteSize.x >= 0
				local y = anchorParent.AbsoluteSize.y >= 0
				if x ~= absNegX or y ~= absNegY then
					absNegX = x
					absNegY = y
					if x then
						if y then
							anchorFrame.Position = anchorPos
						else
							anchorFrame.Position = anchorPosNegY
						end
					else
						if y then
							anchorFrame.Position = anchorPosNegX
						else
							anchorFrame.Position = anchorPosNegXY
						end
					end
				end
			end
		end

		function SnapService:SetAnchorVisual(pos,parent)
			if anchorConn then anchorConn:disconnect() end
			if pos then
				local usize = UDim2.new(0,size,0,size)
				absNegX = nil
				absNegY = nil

				anchorPos = pos - usize
				anchorPosNegY = UDim2.new(pos.X.Scale,pos.X.Offset,1-pos.Y.Scale,pos.Y.Offset) - usize
				anchorPosNegX = UDim2.new(1-pos.X.Scale,pos.X.Offset,pos.Y.Scale,pos.Y.Offset) - usize
				anchorPosNegXY = UDim2.new(1-pos.X.Scale,pos.X.Offset,1-pos.Y.Scale,pos.Y.Offset) - usize

				anchorParent = parent or screen
				anchorConn = anchorParent.Changed:connect(function(p)
					if p == 'AbsoluteSize' then
						updateAnchor()
					end
				end)

				anchorFrame.Parent = anchorParent
				updateAnchor()
			else
				anchorFrame.Parent = nil
				anchorParent = nil
			end
		end

		function SnapService:ClearVisuals()
			lineXFrame.Parent = nil
			lineYFrame.Parent = nil
			if anchorConn then anchorConn:disconnect() end
			anchorFrame.Parent = nil
			anchorParent = nil
		end
	end

	local abs = math.abs
	function SnapService:Snap(interestPoint)
		-- The interest point is separated into its individual coordinates, so
		-- that objects can be snapped per axis, instead of per point. That
		-- way, axes of two different snaps can be combined to form one final
		-- snapped point.
		local pointX,pointY = interestPoint.x,interestPoint.y
		local finalX,finalY
		local lineX,lineY

		-- Because these variables are used to select the snaps with the
		-- nearest to the original point, they will always be lower than the
		-- starting value. So, they can be used not only select the nearest
		-- snap, but also to ensure that only snaps within the tolerance are
		-- selected.
		local diffX = Settings.SnapTolerance
		local diffY = diffX

		for i = 1,#snapperList do
			local snapper = snapperList[i]
			if snapperEnabled[snapper] then
				local snappedX,snappedY,lnX,lnY = snapper(interestPoint,snapperData)
				if snappedX then
					local diff = abs(snappedX - pointX)
					if diff <= diffX then
						finalX = snappedX
						diffX = diff
						lineX = lnX
					end
				end
				if snappedY then
					local diff = abs(snappedY - pointY)
					if diff <= diffY then
						finalY = snappedY
						diffY = diff
						lineY = lnY
					end
				end
			end
		end

		setXLine(finalX,lineX)
		setYLine(finalY,lineY)
		return Vector2.new(finalX or pointX,finalY or pointY)
	end
end

-- LAYOUT SNAPPING
do
	Settings.SnapPadding = 8
	Settings.SnapToEdges = true
	Settings.SnapToCenter = false
	Settings.SnapToParent = true
	Settings.SnapToPadding = false
	Settings.SnapConstrained = false

	local snapPadding = Settings.SnapPadding
	Settings.Changed:connect(function(key,value)
		if key == 'SnapPadding' then
			snapPadding = value
		end
	end)

	local abs = math.abs

	SnapService:AddInitializer('LayoutSiblings',function(active)
		local object = Canvas.SaveLookup[active]
		if not object then return end

		local activeLookup = Canvas.ActiveLookup

		local siblings = object.Parent:GetChildren()
		local i,n = 1,#siblings
		while i <= n do
			local sibling = siblings[i]
			if Selection:Contains(sibling) or not activeLookup[sibling] or sibling == object then
				table.remove(siblings,i)
				n = n - 1
			else
				siblings[i] = activeLookup[siblings[i]]
				i = i + 1
			end
		end
		return {active,siblings}
	end)

	-- Each edge is competing with one another. We could add snappers for each
	-- edge, so that the nearest edge is found using the nearest-point solver,
	-- but that's obviously a bad idea. Instead, this function implements its
	-- own nearest-edge solver, which is similar to the nearest-point solver,
	-- but works per edge, instead of per snapper.
	SnapService:AddSnapper('LayoutEdges',function(point,data)
		data = data.LayoutSiblings
		if not data then return end
		local object = data[1]
		local siblings = data[2]

		local finalX
		local finalY

		local diffX = Settings.SnapTolerance
		local diffY = Settings.SnapTolerance

		local px = point.x
		local py = point.y

		local function check(edgeX,edgeY)
			local diff = abs( edgeX - px )
			if diff < diffX then
				finalX = edgeX
				diffX = diff
			end
			local diff = abs( edgeY - py )
			if diff < diffY then
				finalY = edgeY
				diffY = diff
			end
		end
		for i = 1,#siblings do
			local slow = siblings[i].AbsolutePosition
			local shigh = slow + siblings[i].AbsoluteSize

			check(slow.x, slow.y)
			check(shigh.x, shigh.y)
		end
		return finalX,finalY
	end)

	SnapService:AddSnapper('LayoutEdgesConstrained',function(point,data)
		data = data.LayoutSiblings
		if not data then return end
		local object = data[1]
		local siblings = data[2]

		local finalX
		local finalY

		local diffX = Settings.SnapTolerance
		local diffY = Settings.SnapTolerance

		local lineX
		local lineY

		local px = point.x
		local py = point.y

		for i = 1,#siblings do
			local slow = siblings[i].AbsolutePosition
			local shigh = slow + siblings[i].AbsoluteSize
			if py >= slow.y and py <= shigh.y then
				-- low x
				local diff = abs( slow.x - px )
				if diff < diffX then
					finalX = slow.x
					diffX = diff
					lineX = Vector2.new(slow.y,shigh.y)
				end
				-- high x
				local diff = abs( shigh.x - px )
				if diff < diffX then
					finalX = shigh.x
					diffX = diff
					lineX = Vector2.new(slow.y,shigh.y)
				end
			end

			if px >= slow.x and px <= shigh.x then
				-- low y
				local diff = abs( slow.y - py )
				if diff < diffY then
					finalY = slow.y
					diffY = diff
					lineY = Vector2.new(slow.x,shigh.x)
				end
				-- high y
				local diff = abs( shigh.y - py )
				if diff < diffY then
					finalY = shigh.y
					diffY = diff
					lineY = Vector2.new(slow.x,shigh.x)
				end
			end
		end
		return finalX,finalY,lineX,lineY
	end)

	SnapService:AddSnapper('LayoutEdgesPadding',function(point,data)
		data = data.LayoutSiblings
		if not data then return end
		local object = data[1]
		local siblings = data[2]

		local finalX
		local finalY

		local diffX = Settings.SnapTolerance
		local diffY = Settings.SnapTolerance

		local px = point.x
		local py = point.y

		local function check(edgeX,edgeY)
			local diff = abs( edgeX - px )
			if diff < diffX then
				finalX = edgeX
				diffX = diff
			end
			local diff = abs( edgeY - py )
			if diff < diffY then
				finalY = edgeY
				diffY = diff
			end
		end
		for i = 1,#siblings do
			local slow = siblings[i].AbsolutePosition
			local shigh = slow + siblings[i].AbsoluteSize

			check(slow.x - snapPadding, slow.y - snapPadding)
			check(shigh.x + snapPadding, shigh.y + snapPadding)
		end
		return finalX,finalY
	end)

	SnapService:AddSnapper('LayoutEdgesPaddingConstrained',function(point,data)
		data = data.LayoutSiblings
		if not data then return end
		local object = data[1]
		local siblings = data[2]

		local finalX
		local finalY

		local diffX = Settings.SnapTolerance
		local diffY = Settings.SnapTolerance

		local lineX
		local lineY

		local px = point.x
		local py = point.y

		for i = 1,#siblings do
			local slow = siblings[i].AbsolutePosition
			local shigh = slow + siblings[i].AbsoluteSize
			if py >= slow.y - snapPadding and py <= shigh.y + snapPadding then
				-- low x
				local edge = slow.x - snapPadding
				local diff = abs( edge - px )
				if diff < diffX then
					finalX = edge
					diffX = diff
					lineX = Vector2.new(slow.y-snapPadding,shigh.y+snapPadding)
				end
				-- high x
				local edge = shigh.x + snapPadding
				local diff = abs( edge - px )
				if diff < diffX then
					finalX = edge
					diffX = diff
					lineX = Vector2.new(slow.y-snapPadding,shigh.y+snapPadding)
				end
			end

			if px >= slow.x - snapPadding and px <= shigh.x + snapPadding then
				-- low y
				local edge = slow.y - snapPadding
				local diff = abs( edge - py )
				if diff < diffY then
					finalY = edge
					diffY = diff
					lineY = Vector2.new(slow.x-snapPadding,shigh.x+snapPadding)
				end
				-- high y
				local edge = shigh.y + snapPadding
				local diff = abs( edge - py )
				if diff < diffY then
					finalY = edge
					diffY = diff
					lineY = Vector2.new(slow.x-snapPadding,shigh.x+snapPadding)
				end
			end
		end
		return finalX,finalY,lineX,lineY
	end)

	SnapService:AddSnapper('LayoutCenter',function(point,data)
		data = data.LayoutSiblings
		if not data then return end
		local object = data[1]
		local siblings = data[2]

		local finalX
		local finalY

		local diffX = Settings.SnapTolerance
		local diffY = Settings.SnapTolerance

		local px = point.x
		local py = point.y

		for i = 1,#siblings do
			local scenter = siblings[i].AbsolutePosition + siblings[i].AbsoluteSize/2

			local diff = abs( scenter.x - px )
			if diff < diffX then
				finalX = scenter.x
				diffX = diff
			end
			local diff = abs( scenter.y - py )
			if diff < diffY then
				finalY = scenter.y
				diffY = diff
			end
		end
		return finalX,finalY
	end)

	SnapService:AddSnapper('LayoutCenterConstrained',function(point,data)
		data = data.LayoutSiblings
		if not data then return end
		local object = data[1]
		local siblings = data[2]

		local finalX
		local finalY

		local snapTol = Settings.SnapTolerance
		local diffX = snapTol
		local diffY = snapTol

		local lineX
		local lineY

		local px = point.x
		local py = point.y

		for i = 1,#siblings do
			local slow = siblings[i].AbsolutePosition
			local shigh = slow + siblings[i].AbsoluteSize
			local scenter = slow + siblings[i].AbsoluteSize/2

			if py >= slow.y and py <= shigh.y then
				local diff = abs( scenter.x - px )
				if diff < diffX then
					finalX = scenter.x
					diffX = diff
					lineX = Vector2.new(slow.y,shigh.y)
				end
			end
			if px >= slow.x and px <= shigh.x then
				local diff = abs( scenter.y - py )
				if diff < diffY then
					finalY = scenter.y
					diffY = diff
					lineY = Vector2.new(slow.x,shigh.x)
				end
			end
		end
		return finalX,finalY,lineX,lineY
	end)

	SnapService:AddInitializer('LayoutParent',function(active)
		return active and active.Parent or false
	end)

	SnapService:AddSnapper('LayoutParent',function(point,data)
		local parent = data.LayoutParent
		if not parent then return end
		local finalX
		local finalY

		local diffX = Settings.SnapTolerance
		local diffY = Settings.SnapTolerance

		local px = point.x
		local py = point.y

		local plow = parent.AbsolutePosition
		local phigh = plow + parent.AbsoluteSize

		local function check(edgeX,edgeY)
			local diff = abs( edgeX - px )
			if diff < diffX then
				finalX = edgeX
				diffX = diff
			end
			local diff = abs( edgeY - py )
			if diff < diffY then
				finalY = edgeY
				diffY = diff
			end
		end

		check(plow.x, plow.y)
		check(phigh.x, phigh.y)

		return finalX,finalY
	end)

	SnapService:AddSnapper('LayoutParentPadding',function(point,data)
		local parent = data.LayoutParent
		if not parent then return end
		local finalX
		local finalY

		local diffX = Settings.SnapTolerance
		local diffY = Settings.SnapTolerance

		local px = point.x
		local py = point.y

		local plow = parent.AbsolutePosition
		local phigh = plow + parent.AbsoluteSize

		local function check(edgeX,edgeY)
			local diff = abs( edgeX - px )
			if diff < diffX then
				finalX = edgeX
				diffX = diff
			end
			local diff = abs( edgeY - py )
			if diff < diffY then
				finalY = edgeY
				diffY = diff
			end
		end

		check(plow.x + snapPadding, plow.y + snapPadding)
		check(phigh.x - snapPadding, phigh.y - snapPadding)

		return finalX,finalY
	end)

	Settings.Changed:connect(function(key,value)
		if key == 'SnapToEdges' then
			SnapService:SetEnabled('LayoutEdges',value and not Settings.SnapConstrained)
			SnapService:SetEnabled('LayoutEdgesPadding',value and Settings.SnapToPadding and not Settings.SnapConstrained)
			SnapService:SetEnabled('LayoutEdgesConstrained',value and Settings.SnapConstrained)
			SnapService:SetEnabled('LayoutEdgesPaddingConstrained',value and Settings.SnapToPadding and Settings.SnapConstrained)
		elseif key == 'SnapToCenter' then
			SnapService:SetEnabled('LayoutCenter',value and not Settings.SnapConstrained)
			SnapService:SetEnabled('LayoutCenterConstrained',value and Settings.SnapConstrained)
		elseif key == 'SnapToParent' then
			SnapService:SetEnabled('LayoutParent',value)
			SnapService:SetEnabled('LayoutParentPadding',value and Settings.SnapToPadding)
		elseif key == 'SnapToPadding' then
			SnapService:SetEnabled('LayoutEdgesPadding',value and Settings.SnapToEdges and not Settings.SnapConstrained)
			SnapService:SetEnabled('LayoutParentPadding',value and Settings.SnapToParent)
			SnapService:SetEnabled('LayoutEdgesPaddingConstrained',value and Settings.SnapToEdges and Settings.SnapConstrained)
		elseif key == 'SnapConstrained' then
			SnapService:SetEnabled('LayoutEdges',not value and Settings.SnapToEdges)
			SnapService:SetEnabled('LayoutCenter',not value and Settings.SnapToCenter)
			SnapService:SetEnabled('LayoutEdgesPadding',not value and Settings.SnapToEdges and Settings.SnapToPadding)
			SnapService:SetEnabled('LayoutEdgesConstrained',value and Settings.SnapToEdges)
			SnapService:SetEnabled('LayoutCenterConstrained',value and Settings.SnapToCenter)
			SnapService:SetEnabled('LayoutEdgesPaddingConstrained',value and Settings.SnapToEdges and Settings.SnapToPadding)
		end
	end)

	SnapService:SetEnabled('LayoutEdges',Settings.SnapToEdges and not Settings.SnapConstrained)
	SnapService:SetEnabled('LayoutCenter',Settings.SnapToCenter and not Settings.SnapConstrained)
	SnapService:SetEnabled('LayoutParent',Settings.SnapToParent)

	SnapService:SetEnabled('LayoutEdgesPadding',Settings.SnapToEdges and Settings.SnapToPadding and not Settings.SnapConstrained)
	SnapService:SetEnabled('LayoutParentPadding',Settings.SnapToParent and Settings.SnapToPadding)

	SnapService:SetEnabled('LayoutEdgesConstrained',Settings.SnapToEdges and Settings.SnapConstrained)
	SnapService:SetEnabled('LayoutCenterConstrained',Settings.SnapToCenter and Settings.SnapConstrained)
	SnapService:SetEnabled('LayoutEdgesPaddingConstrained',Settings.SnapToEdges and Settings.SnapToPadding and Settings.SnapConstrained)
end
