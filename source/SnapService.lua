--[[SnapService
Provides services for snapping to various things.

API:

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

				`object`
					A reference object, such as the object being dragged.

			Returns:
				`snappedX`
					The snapped X coordinate. Return nil to not snap on this axis.

				`snappedY`
					The snapped Y coordinate. Return nil to not snap on this axis.

SnapService:Snap ( interestPoint, interestObject )
	Snaps a point by running it through each snapper function.

SnapService:SetEnabled ( ref, enabled )
	Sets whether a snapper is enabled.

]]

do
	SnapService = {}

	local snapperList = {}
	local snapperLookup = {}
	local snapperEnabled = {}

	local snapTolerance = Settings.SnapTolerance
	Settings.Changed:connect(function(key,value)
		if key == 'SnapTolerance' then
			snapTolerance = value
		end
	end)

	function SnapService:AddSnapper(ref,snapper)
		snapperList[#snapperList+1] = snapper
		snapperLookup[ref] = snapper
		snapperEnabled[snapper] = true
	end

	function SnapService:SetEnabled(ref,enabled)
		if snapperLookup[ref] then
			snapperEnabled[snapperLookup[ref]] = not not enabled
		else
			error("`"..tostring(ref).."` does not reference an existing snapper",2)
		end
	end

	function SnapService:Snap(interestPoint,interestObject)
		-- The interest point is separated into its individual coordinates, so
		-- that objects can be snapped per axis, instead of per point.That
		-- way, axes of two different snaps can be combined to form one final
		-- snapped point.
		local pointX,pointY = interestPoint.x,interestPoint.y
		local finalX,finalY = pointX,pointY

		-- Because these variables are used to select the snaps with the
		-- nearest to the original point, they will always be lower than the
		-- starting value. So, they can be used not only select the nearest
		-- snap, but also to ensure that only snaps within the tolerance are
		-- selected.
		local diffX,diffY = snapTolerance,snapTolerance

		for i = 1,#snapperList do
			local snapper = snapperList[i]
			if snapperEnabled[snapper] then
				local snappedX,snappedY = snapper(interestPoint,interestObject)
				if snappedX then
					local diff = math.abs(snappedX - pointX)
					if diff <= diffX then
						finalX = snappedX
						diffX = diff
					end
				end
				if snappedY then
					local diff = math.abs(snappedY - pointY)
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
