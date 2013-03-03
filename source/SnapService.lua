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

	local abs = math.abs
	function SnapService:Snap(interestPoint)
		-- The interest point is separated into its individual coordinates, so
		-- that objects can be snapped per axis, instead of per point. That
		-- way, axes of two different snaps can be combined to form one final
		-- snapped point.
		local pointX,pointY = interestPoint.x,interestPoint.y
		local finalX,finalY = pointX,pointY

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
				local snappedX,snappedY = snapper(interestPoint,snapperData)
				if snappedX then
					local diff = abs(snappedX - pointX)
					if diff <= diffX then
						finalX = snappedX
						diffX = diff
					end
				end
				if snappedY then
					local diff = abs(snappedY - pointY)
					if diff <= diffY then
						finalY = snappedY
						diffY = diff
					end
				end
			end
		end
		-- TODO: return which axes were snapped on
		return Vector2.new(finalX,finalY)
	end
end

-- LAYOUT SNAPPING
do
	Settings.SnapPadding = 8
	Settings.SnapToEdges = true
	Settings.SnapToCenter = false
	Settings.SnapToParent = true
	Settings.SnapToPadding = false

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
			SnapService:SetEnabled('LayoutEdges',value)
			SnapService:SetEnabled('LayoutEdgesPadding',value and Settings.SnapToPadding)
		elseif key == 'SnapToParent' then
			SnapService:SetEnabled('LayoutParent',value)
			SnapService:SetEnabled('LayoutParentPadding',value and Settings.SnapToPadding)
		elseif key == 'SnapToPadding' then
			SnapService:SetEnabled('LayoutEdgesPadding',value and Settings.SnapToEdges)
			SnapService:SetEnabled('LayoutParentPadding',value and Settings.SnapToParent)
		elseif key == 'SnapToCenter' then
			SnapService:SetEnabled('LayoutCenter',value)
		end
	end)
	SnapService:SetEnabled('LayoutEdges',Settings.SnapToEdges)
	SnapService:SetEnabled('LayoutParent',Settings.SnapToParent)
	SnapService:SetEnabled('LayoutEdgesPadding',Settings.SnapToPadding and Settings.SnapToEdges)
	SnapService:SetEnabled('LayoutParentPadding',Settings.SnapToPadding and Settings.SnapToParent)
	SnapService:SetEnabled('LayoutCenter',Settings.SnapToCenter)
end
