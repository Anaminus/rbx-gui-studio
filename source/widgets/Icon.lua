--[[Icon
Creates an icon from an icon map.

Arguments:
	IconFrame
		An existing Icon to be updated. Passing nil creates a new Icon.

	map
		A Content string referencing an image that follows the IconMap specification below.

	size
		The size of each icon in the map. May be 16, 32, or 64.

	row
		The row on the icon map of the icon to display. Starts at 0.

	col
		The column on the icon map of the icon to display. Starts at 0.

Returns:
	A Frame that displays the icon.

IconMap Specification
	IconMaps are 256x256 images that contain an array of smaller icons.
	Possible icon sizes are 16, 32, and 64.
	16:
		The image may have 14 rows and 14 columns, for a total of 196 icons.
		Each icon must have a margin of 1 pixel on each side.
		The whole image must have padding of 1 pixel on each side.
	32:
		The image may have 7 rows and 7 columns, for a total of 49 icons.
		Each icon must have a margin of 2 pixels on each side.
		The whole image must have padding of 2 pixels on each side.
	64:
		The image may have 3 rows and 3 columns, for a total of 9 icons.
		Each icon must have a margin of 8 pixels on each side.
		The whole image must have padding of 8 pixels on each side.
]]
do
	local padding = { -- padding and border
		[16] = {2,1};
		[32] = {4,0};
		[64] = {16,0};
	}

	function Widgets.Icon(IconFrame,map,size,row,col)
		local map_size = Vector2.new(256,256)
		size = size or 32
	--	if fix_blur == nil then fix_blur = true end

		if not IconFrame then
			IconFrame = Create'Frame'{
				Name = "Icon";
				BackgroundTransparency = 1;
				ClipsDescendants = true;
				Create'ImageLabel'{
					Name = "IconMap";
					Active = false;
					BackgroundTransparency = 1;
					Image = map;
					Size = UDim2.new(map_size.x/size,0,map_size.y/size,0);
				};
			}
		end

		local pad = padding[size]
		IconFrame.IconMap.Position = UDim2.new(-col - (pad[1]*(col+1) + pad[2])/size,0,-row - (pad[1]*(row+1) + pad[2])/size,0)
		return IconFrame
	end
end
