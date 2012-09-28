--[[Grid
Draws a grid in a specified object.

API:
	Grid.Offset                 Returns the UDim2 offset of the grid.
	Grid.Size                   Returns the UDim2 size of the grid.
	Grid.Parent                 Returns the object the grid appears under.
	Grid.Visible                Returns whether or not the grid is visible.
	Grid.Container              The GUI object containing the grid lines.

	Grid:SetGrid(size,offset)   Sets the distance between each grid line and their offset from the starting point.
	                            `size` and `offset` are UDim2s.
	                            The Scale component of the UDim2 will set the size and offset of the Scale grid.
	                            The Offset component of the UDim2 will set the size and offsetof the Offset grid.
	Grid:SetParent(parent)      Sets the object the grid will appear in.
	Grid:SetVisible(visible)    Sets whether the grid is visible.
]]

do
	Grid = {
		Offset = UDim2.new(0,0,0,0);
		Size = UDim2.new(1/16,32,1/16,32);
		Container = nil;
		Parent = nil;
		Visible = false;
	}

	local gridContainer
	local lineTemplateX
	local lineTemplateY
	local GridLinesX
	local GridLinesY

	local gSize
	local gOffset
	local giOffsetX
	local giOffsetY

	local conSizeChanged
	local conScopeChanged

	local layoutMode = Settings.LayoutMode('Scale')

	local lastSize = Vector2.new(0,0)
	-- offset grid: static lines that are created and destroyed only when needed
	local function updateOffsetLines()
		local size = gridContainer.AbsoluteSize
		local span = Vector2.new(math.ceil(size.x/gSize.x),math.ceil(size.y/gSize.y))

		if size.x ~= lastSize.x then
			-- vertical lines along the X axis
			local size = size.x
			local gSize = gSize.x
			local gOffset = gOffset.x
			for i = 1,span.x do
				local line = GridLinesX[i]
				local pos = (i-giOffsetX-1)*gSize+gOffset
				if not line and pos <= size then
					line = lineTemplateX:Clone()
					GridLinesX[i] = line
					line.Position = UDim2.new(0,pos,0,0)
					line.Parent = gridContainer
				end
			end
			for i = span.x,#GridLinesX do
				if (i-giOffsetX-1)*gSize+gOffset > size then
					GridLinesX[i]:Destroy()
					GridLinesX[i] = nil
				end
			end
		end
		if size.y ~= lastSize.y then
			-- horizontal lines along the Y axis
			local size = size.y
			local gSize = gSize.y
			local gOffset = gOffset.y
			for i = 1,span.y do
				local line = GridLinesY[i]
				local pos = (i-giOffsetY-1)*gSize+gOffset
				if not line and pos <= size then
					line = lineTemplateY:Clone()
					GridLinesY[i] = line
					line.Position = UDim2.new(0,0,0,pos)
					line.Parent = gridContainer
				end
			end
			for i = span.y,#GridLinesY do
				if (i-giOffsetY-1)*gSize+gOffset > size then
					GridLinesY[i]:Destroy()
					GridLinesY[i] = nil
				end
			end
		end
		lastSize = size
	end

	-- scale grid: stretchy; only needs to be created once; Scale takes care of the rest
	local function setupScaleLines()
		for i = 1,math.ceil(1/gSize.x) do
			local pos = (i-giOffsetX-1)*gSize.x+gOffset.x
			line = lineTemplateX:Clone()
			GridLinesX[i] = line
			line.Position = UDim2.new(pos,0,0,0)
			line.Parent = gridContainer
		end
		for i = 1,math.ceil(1/gSize.y) do
			local pos = (i-giOffsetY-1)*gSize.y+gOffset.y
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

	-- updates the grid for when the size or offset changes
	local function updateGrid()
		if conSizeChanged then conSizeChanged:disconnect() end
		if layoutMode then
			gSize = Vector2.new(Grid.Size.X.Scale,Grid.Size.Y.Scale)
			gOffset = Vector2.new(Grid.Offset.X.Scale,Grid.Offset.Y.Scale)
		else
			gSize = Vector2.new(Grid.Size.X.Offset,Grid.Size.Y.Offset)
			gOffset = Vector2.new(Grid.Offset.X.Offset,Grid.Offset.Y.Offset)
		end
		giOffsetX = math.floor(gOffset.x/gSize.x)
		giOffsetY = math.floor(gOffset.y/gSize.y)
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
	end


	Settings.Changed:connect(function(key,value)
		if key == 'LayoutMode' and gridContainer then
			layoutMode = value('Scale')
--[[
			if layoutMode then
				lineTemplateX.BackgroundColor3 = InternalSettings.ScaleModeColor
				lineTemplateY.BackgroundColor3 = InternalSettings.ScaleModeColor
			else
				lineTemplateX.BackgroundColor3 = InternalSettings.OffsetModeColor
				lineTemplateY.BackgroundColor3 = InternalSettings.OffsetModeColor
			end
--]]
			updateGrid()
		end
	end)

	local function initializeGrid()
		lineTemplateX = Create'Frame'{
			Name = "GridLine Vertical";
			BorderSizePixel = 0;
			BackgroundColor3 = Color3.new(0,0,0);
			Transparency = 0.75;
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
	end

	function Grid:SetGrid(size,offset)
		if size then
			self.Size = size
		end
		if offset then
			self.Offset = offset
		end
		if gridContainer then
			updateGrid()
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
end
