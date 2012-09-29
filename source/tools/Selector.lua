do
	local Tool = {
		Name = "Selector";
		Icon = Widgets.Icon(nil,InternalSettings.IconMap.Tool,32,0,0);
		ToolTip = "Select and transform objects";
		KeyBinding = "f";
	}
	local SelectedObjects = Selection.SelectedObjects
	local GlobalButton = Canvas.GlobalButton
	local CanvasFrame = Canvas.CanvasFrame

	local Maid = CreateMaid()

	function Tool:Select()
		local TransformHandles = Widgets.TransformHandles(Canvas,Maid)
		Maid:GiveTask(function() TransformHandles:Destroy() end)

		local activeLookup = Canvas.ActiveLookup

		local function setScope(object)
			local newScope = Scope:GetContainer(object)
			if newScope then
				Scope:In(newScope)
			else
				Scope:Out()
			end
		end

		local clickStamp = 0
		local function checkDoubleClick(object)
			local t = tick()
			if t-clickStamp < 0.5 then
				clickStamp = 0
				setScope(object)
				return true
			end
			clickStamp = t
			return false
		end

		local function resetClick()
			clickStamp = 0
		end

		local function selectNothing()
			if not Mouse.CtrlIsDown then
				Selection:Set{}
			end
		end

		-- used to prevent actions from occurring at the same time
		local inAction = false

		Maid.move = GlobalButton.MouseMoved:connect(resetClick)
		Maid.select = GlobalButton.MouseButton1Down:connect(function(object,active,x,y)
			if inAction then return end
			inAction = true

			if object == Canvas.CurrentScreen then
			-- clicked nothing
				if checkDoubleClick() then inAction = false return end

				Maid.rubberband = Widgets.RubberbandSelect(Vector2.new(x,y),{
					OnDrag = function()
						clickStamp = 0
					end;
					OnRelease = function()
						clickStamp = 0
						Maid.rubberband = nil
						inAction = false
					end;
					OnClick = function()
						selectNothing()
						Maid.rubberband = nil
						inAction = false
					end;
				})

				return
			end
			-- clicked object

			if checkDoubleClick(object) then inAction = false return end

			local can_drag = true
			-- click to select
			if not Mouse.ShiftIsDown then
				-- act upon the clicked object's container
				local o = Scope:GetContainer(object)
				if o == nil then
				-- clicked object is above current scope
					-- for now, treat it as if it were invisible
					selectNothing()
					inAction = false
					return
				end
				object = o
				active = activeLookup[o]
			end
			if Mouse.CtrlIsDown then
			-- multi-select
				can_drag = false
				if Selection:Contains(object) then
				-- deselect selected
					Selection:Remove(object)
				else
				-- select unselected
					Selection:Add(object)
				end
			end
			if can_drag then
				-- click & drag to move
				-- on drag or on up, select object
				local dragObjects = Selection:Get()
				local activeObjects = {}
				if not Selection:Contains(object) then
					table.insert(dragObjects,1,object)
				end
				for i,object in pairs(dragObjects) do
					activeObjects[i] = activeLookup[object]
				end

				TransformHandles.Frame.Visible = false
				Maid.drag_gui = Widgets.DragGUI(activeObjects,Vector2.new(x,y),'Center',{
					OnDrag = function(x,y,hasDragged,setObjects)
						if not hasDragged then
							if not Selection:Contains(object) then
								Selection:Set{object}
								dragObjects = {object}
								activeObjects = {activeLookup[object]}
								setObjects(activeObjects)
							end
						end
					end;
					OnRelease = function(x,y,hasDragged)
						if hasDragged then
							clickStamp = 0
							for i = 1,#dragObjects do
								local object = dragObjects[i]
								local active = activeObjects[i]
								object.Position = active.Position
								object.Size = active.Size
							end
						elseif not Selection:Contains(object) then
							Selection:Set{object}
						end
						TransformHandles.Frame.Visible = true
						Maid.drag_gui = nil
						inAction = false
					end;
				})
			else
				inAction = false
			end
		end)

		Maid.selected = Selection.ObjectSelected:connect(function(object,active)
			TransformHandles:SetParent(object)
		end)
		Maid.deselected = Selection.ObjectDeselected:connect(function(object,active)
			if #SelectedObjects > 0 then
				TransformHandles:SetParent(SelectedObjects[#SelectedObjects])
			else
				TransformHandles:SetParent(nil)
			end
		end)
		if #SelectedObjects > 0 then
			TransformHandles:SetParent(SelectedObjects[#SelectedObjects])
		end

		do
			local Mouse = Mouse
			local function moveSelection(dir,scaled)
				if Mouse.CtrlIsDown then
					if scaled then
						for i,object in pairs(SelectedObjects) do
							local active = activeLookup[object]
							local dir = dir/active.Parent.AbsoluteSize
							active.Size = active.Size + UDim2.new(dir.x,0,dir.y,0)
							object.Size = active.Size
						end
					else
						for i,object in pairs(SelectedObjects) do
							local active = activeLookup[object]
							active.Size = active.Size + UDim2.new(0,dir.x,0,dir.y)
							object.Size = active.Size
						end
					end
				else
					if scaled then
						for i,object in pairs(SelectedObjects) do
							local active = activeLookup[object]
							local dir = dir/active.Parent.AbsoluteSize
							active.Position = active.Position + UDim2.new(dir.x,0,dir.y,0)
							object.Position = active.Position
						end
					else
						for i,object in pairs(SelectedObjects) do
							local active = activeLookup[object]
							active.Position = active.Position + UDim2.new(0,dir.x,0,dir.y)
							object.Position = active.Position
						end
					end
				end
			end

			local up    = string.char(17)
			local down  = string.char(18)
			local right = string.char(19)
			local left  = string.char(20)

			local arrowDirection = {
				[up   ] = Vector2.new( 0,-1);
				[down ] = Vector2.new( 0, 1);
				[right] = Vector2.new( 1, 0);
				[left ] = Vector2.new(-1, 0);
			}

			local scaled = Settings.LayoutMode('Scale')
			Maid.layout_changed = Settings.Changed:connect(function(key,value)
				if key == 'LayoutMode' then
					scaled = value('Scale')
				end
			end)

			local arrowIsDown = Mouse.KeyIsDown
			local MoveID = 0
			Maid:GiveTask(function() MoveID = MoveID + 1 end)
			local function startMoving()
				if inAction and MoveID == 0 then return end
				TransformHandles.Frame.Visible = false
				Selection:SetVisible(false)
				inAction = true

				local cid = MoveID + 1
				MoveID = cid
				do
					local moveDirection = Vector2.new(0,0)
					local nDown = 0
					for key,dir in pairs(arrowDirection) do
						if arrowIsDown[key] then
							nDown = nDown + 1
							moveDirection = moveDirection + dir
						end
					end
					moveSelection(moveDirection,scaled)
					if nDown == 1 then
						wait(0.2)
						if MoveID ~= cid then return end
					end
				end

				while true do
					if MoveID ~= cid then return end
					local running = false
					local moveDirection = Vector2.new(0,0)
					for key,dir in pairs(arrowDirection) do
						if arrowIsDown[key] then
							running = true
							moveDirection = moveDirection + dir
						end
					end
					if running then
						moveSelection(moveDirection,scaled)
						wait(0.05)
					else
						break
					end
				end
				MoveID = 0
				TransformHandles.Frame.Visible = true
				Selection:SetVisible(true)
				inAction = false
			end

			Maid.arrow_up    = Mouse.KeyDown[up   ]:connect(startMoving)
			Maid.arrow_down  = Mouse.KeyDown[down ]:connect(startMoving)
			Maid.arrow_right = Mouse.KeyDown[right]:connect(startMoving)
			Maid.arrow_left  = Mouse.KeyDown[left ]:connect(startMoving)
		end
	end

	function Tool:Deselect()
		Maid:DoCleaning()
	end

	ToolManager:AddTool(Tool)
end
