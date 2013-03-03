--[[Grid
Draws a grid in a specified object.

API:
	Grid.Origin                     Returns the UDim2 origin of the grid.
	Grid.Spacing                    Returns the UDim2 spacing of the grid.
	Grid.ScaleLineColor             Returns the Color4 value of the lines of the Scale grid.
	Grid.OffsetLineColor            Returns the Color4 value of the lines of the Offset grid.
	Grid.Parent                     Returns the object the grid appears under.
	Grid.Visible                    Returns whether or not the grid is visible.
	Grid.Container                  The GUI object containing the grid lines.

	Grid:SetGrid(spacing,origin)    Sets the distance between each grid line and their offset from the starting point.
	                                `spacing` and `origin` are UDim2s.
	                                The Scale component of the UDim2 will set the spacing and origin of the Scale grid.
	                                The Offset component of the UDim2 will set the spacing and origin of the Offset grid.
	Grid:SetColor(scale,offset)     Sets the color of the grid lines.
	                                Both arguments are Color4 values, and are optional.
	Grid:SetParent(parent)          Sets the object the grid will appear in.
	Grid:SetVisible(visible)        Sets whether the grid is visible.

	Grid.Updated(layout)            Fired after the grid's Origin or Spacing updates.
	                                `layout` is the current LayoutMode.
	Grid.VisibilitySet(visible)     Fired after the grid's visibility is set.
]]

do
	Grid = {
		Origin = UDim2.new(0,0,0,0);
		Spacing = UDim2.new(1/16,32,1/16,32);
		ScaleLineColor = Color4.new(0,0,0,0.75);
		OffsetLineColor = Color4.new(0,0,0,0.75);
		Container = nil;
		Parent = nil;
		Visible = false;
	}

	local gridContainer
	local lineTemplateX
	local lineTemplateY
	local GridLinesX
	local GridLinesY

	local gSpacing
	local gOrigin
	local giOriginX
	local giOriginY

	local conSizeChanged
	local conScopeChanged

	local eventUpdated = CreateSignal(Grid,'Updated')
	local eventVisibilitySet = CreateSignal(Grid,'VisibilitySet')

	local layoutMode = Settings.LayoutMode('Scale')

	local lastSize = Vector2.new(0,0)
	-- offset grid: static lines that are created and destroyed only when needed
	local function updateOffsetLines()
		local size = gridContainer.AbsoluteSize
		local span = Vector2.new(math.ceil(size.x/gSpacing.x),math.ceil(size.y/gSpacing.y))

		if size.x ~= lastSize.x then
			-- vertical lines along the X axis
			local size = size.x
			local gSpacing = gSpacing.x
			local gOrigin = gOrigin.x
			for i = 1,span.x do
				local line = GridLinesX[i]
				local pos = (i-giOriginX-1)*gSpacing+gOrigin
				if not line and pos <= size then
					line = lineTemplateX:Clone()
					GridLinesX[i] = line
					line.Position = UDim2.new(0,pos,0,0)
					line.Parent = gridContainer
				end
			end
			for i = span.x,#GridLinesX do
				if (i-giOriginX-1)*gSpacing+gOrigin > size then
					GridLinesX[i]:Destroy()
					GridLinesX[i] = nil
				end
			end
		end
		if size.y ~= lastSize.y then
			-- horizontal lines along the Y axis
			local size = size.y
			local gSpacing = gSpacing.y
			local gOrigin = gOrigin.y
			for i = 1,span.y do
				local line = GridLinesY[i]
				local pos = (i-giOriginY-1)*gSpacing+gOrigin
				if not line and pos <= size then
					line = lineTemplateY:Clone()
					GridLinesY[i] = line
					line.Position = UDim2.new(0,0,0,pos)
					line.Parent = gridContainer
				end
			end
			for i = span.y,#GridLinesY do
				if (i-giOriginY-1)*gSpacing+gOrigin > size then
					GridLinesY[i]:Destroy()
					GridLinesY[i] = nil
				end
			end
		end
		lastSize = size
	end

	-- scale grid: stretchy; only needs to be created once; Scale takes care of the rest
	local function setupScaleLines()
		for i = 1,math.ceil(1/gSpacing.x) do
			local pos = (i-giOriginX-1)*gSpacing.x+gOrigin.x
			line = lineTemplateX:Clone()
			GridLinesX[i] = line
			line.Position = UDim2.new(pos,0,0,0)
			line.Parent = gridContainer
		end
		for i = 1,math.ceil(1/gSpacing.y) do
			local pos = (i-giOriginY-1)*gSpacing.y+gOrigin.y
			line = lineTemplateY:Clone()
			GridLinesY[i] = line
			line.Position = UDim2.new(0,0,pos,0)
			line.Parent = gridContainer
		end
	end

	local function setupOffsetLines()
		conSizeChanged = gridContainer.Changed:connect(function(p)
			if p == "AbsoluteSize" then
				updateOffsetLines()
			end
		end)
		updateOffsetLines()
	end

	-- updates the grid when the spacing or origin changes
	local function updateGrid()
		if conSizeChanged then conSizeChanged:disconnect() end
		if layoutMode then
			gSpacing = Vector2.new(Grid.Spacing.X.Scale,Grid.Spacing.Y.Scale)
			gOrigin = Vector2.new(Grid.Origin.X.Scale,Grid.Origin.Y.Scale)
		else
			gSpacing = Vector2.new(Grid.Spacing.X.Offset,Grid.Spacing.Y.Offset)
			gOrigin = Vector2.new(Grid.Origin.X.Offset,Grid.Origin.Y.Offset)
		end
		giOriginX = math.floor(gOrigin.x/gSpacing.x)
		giOriginY = math.floor(gOrigin.y/gSpacing.y)
		for i = 1,#GridLinesX do
			GridLinesX[i]:Destroy()
			GridLinesX[i] = nil
		end
		for i = 1,#GridLinesY do
			GridLinesY[i]:Destroy()
			GridLinesY[i] = nil
		end
		lastSize = Vector2.new(0,0)
		if layoutMode then
			setupScaleLines()
		else
			setupOffsetLines()
		end
		eventUpdated:Fire(Settings.LayoutMode)
	end

	local function updateTemplateColor()
		local color
		if layoutMode then
			color = Grid.ScaleLineColor
		else
			color = Grid.OffsetLineColor
		end
		lineTemplateX.BackgroundColor3 = color.color3
		lineTemplateX.Transparency     = color.a
		lineTemplateY.BackgroundColor3 = color.color3
		lineTemplateY.Transparency     = color.a
	end


	Settings.Changed:connect(function(key,value)
		if key == 'LayoutMode' and gridContainer then
			layoutMode = value('Scale')
			updateTemplateColor()
			updateGrid()
		end
	end)

	local function initializeGrid()
		lineTemplateX = Create'Frame'{
			Name = "GridLine Vertical";
			BorderSizePixel = 0;
			BackgroundColor3 = layoutMode and Grid.ScaleLineColor.color3 or Grid.OffsetLineColor.color3;
			Transparency = layoutMode and Grid.ScaleLineColor.a or Grid.OffsetLineColor.a;
			ZIndex = 9;
			Size = UDim2.new(0,1,1,0);
		}

		lineTemplateY = Create(lineTemplateX:Clone()){
			Name = "GridLine Horizontal";
			Size = UDim2.new(1,0,0,1);
		}

		GridLinesX = {}
		GridLinesY = {}
		gridContainer = Create'Frame'{
			Name = "Grid";
			Transparency = 1;
			Size = UDim2.new(1,0,1,0);
		}
		Grid.Container = gridContainer

		updateGrid()
	end

	local activeLookup = Canvas.ActiveLookup

	function Grid:SetParent(parent)
		if not gridContainer then
			initializeGrid()
		end
		self.Parent = parent
		if self.Visible then
			gridContainer.Parent = activeLookup[parent]
		end
	end

	function Grid:SetVisible(visible)
		self.Visible = visible
		if gridContainer then
			if visible then
				gridContainer.Parent = activeLookup[self.Parent]
			else
				gridContainer.Parent = nil
			end
		end
		eventVisibilitySet:Fire(visible)
	end

	function Grid:SetGrid(origin,spacing)
		if origin then
			self.Origin = origin
		end
		if spacing then
			self.Spacing = spacing
		end
		if gridContainer then
			updateGrid()
		end
	end

	function Grid:SetColor(scale,offset)
		if scale then
			self.ScaleLineColor = scale
		end
		if offset then
			self.OffsetLineColor = offset
		end
		updateTemplateColor()
		local color = layoutMode and scale or offset
		for i = 1,#GridLinesX do
			local line = GridLinesX[i]
			line.BackgroundColor3 = color.color3
			line.Transparency     = color.a
		end
		for i = 1,#GridLinesY do
			local line = GridLinesY[i]
			line.BackgroundColor3 = color.color3
			line.Transparency     = color.a
		end
	end

	function Grid:ConfigDialog()
		local origin,
		spacing,
		scale_color,
		offset_color,
		snap_enabled,
		snap_tolerance = Dialogs.ConfigGrid(UserInterface.Screen,PluginActivator.Deactivated)
		if origin ~= nil then
			self:SetColor(scale_color,offset_color)
			self:SetGrid(origin,spacing)
			Settings.SnapTolerance = snap_tolerance
			Settings.SnapEnabled = snap_enabled
		end
	end

	AddServiceStatus{Grid;
		Start = function()
			conScopeChanged = Scope.ScopeChanged:connect(function(scope)
				Grid:SetParent(scope)
			end)
			Grid:SetParent(Scope.Current)
		end;
		Stop = function()
			conScopeChanged:disconnect()
			conScopeChanged = nil
			Grid:SetParent(nil)
		end;
	}
	initializeGrid()

---- GRID SNAPPING

	Settings.SnapToGrid = true

	-- gridOffset is a combination of gridPos (the grid container's position)
	-- and gridOrigin (the grid's position).
	local gridSpacing,gridOffset do
		-- We want the snapper function to be speedy fast, so we'll update
		-- these variables only when they change.
		local gridContainer = Grid.Container
		local gridSize
		local function updateGridPos(p)
			if p == 'AbsolutePosition' then
				gridPos = gridContainer.AbsolutePosition
				if layoutMode then
					gridOffset = gridPos + gridSize*gOrigin
				else
					gridOffset = gridPos + gOrigin
				end
			elseif p == 'AbsoluteSize' then
				gridSize = gridContainer.AbsoluteSize
				if layoutMode then
					gridSpacing = gridSize*gSpacing
					gridOffset = gridPos + gridSize*gOrigin
				end
				-- gridSize isn't used with offset mode, so it doesn't need to
				-- be updated here.
			end
		end
		gridContainer.Changed:connect(updateGridPos)
		updateGridPos('AbsolutePosition')
		updateGridPos('AbsoluteSize')

		local function updateGrid()
			if layoutMode then
				-- Since the grid spacing and origin are in scaled
				-- coordinates, they need to be converted to global
				-- coordinates by multiplying by the gridSize.
				gridSpacing = gridSize*gSpacing
				gridOffset = gridPos + gridSize*gOrigin
			else
				gridSpacing = gSpacing
				gridOffset = gridPos + gOrigin
			end
		end

		Grid.Updated:connect(updateGrid)
		updateGrid()
	end

	local floor = math.floor
	SnapService:AddSnapper('Grid',function(point)
		-- In global coordinates, the grid container will have some arbitrary
		-- position. So, the point, which is currently in global coordinates,
		-- needs to be converted to the grid container's coordinates before
		-- snapping. This is done by subtracting gridPos (the container's
		-- position).

		-- Then, the point needs to be converted to the actual grid's
		-- coordinates, which is done by subtracting (gridOrigin).

		-- gridPos and gridOrigin are combined into gridOffset beforehand, so
		-- that it doesn't have to be done here.

		return
			floor((point.x - gridOffset.x)/gridSpacing.x + 0.5)*gridSpacing.x + gridOffset.x,
			floor((point.y - gridOffset.y)/gridSpacing.y + 0.5)*gridSpacing.y + gridOffset.y
	end)

	Settings.Changed:connect(function(key,value)
		if key == 'SnapToGrid' then
			SnapService:SetEnabled('Grid',value)
		end
	end)
end
