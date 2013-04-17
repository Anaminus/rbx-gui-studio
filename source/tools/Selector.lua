do
	local Tool = {
		Name = "Selector";
		Icon = Widgets.Icon(nil,InternalSettings.IconMap.Tool,32,0,0);
		ToolTip = "Select and transform objects";
		KeyBinding = "s";
	}

	local SelectedObjects = Selection.SelectedObjects
	local GlobalButton = Canvas.GlobalButton
	local CanvasFrame = Canvas.CanvasFrame
	local ViewportFrame = Canvas.ViewportFrame

	local Maid = CreateMaid()

	function Tool:Start()
		-- used to prevent actions from occurring at the same time
		local inAction = false

		local toolStatus = Status:Add('SelectorTool',{
			[1] = "Click, Ctrl+Click, or drag around objects to select them.";
			[8] = "Click unselected object to add to selection. Click selected object to remove from selection.";
			[16] = "Double-click to change scope.";
			[24] = "Hold Shift to ignore scope.";
			[32] = "Arrow keys for precise movement.";
			[33] = "Arrow keys for precise resizing.";
			[34] = "Hold Ctrl for precise resizing.";
		})
		toolStatus:Show(1,16,24)

		Maid:GiveTask(Keyboard.KeyDown['ctrl']:connect(function()
			toolStatus:Hide(1,32)
			toolStatus:Show(8,33)
		end))
		Maid:GiveTask(Keyboard.KeyUp['ctrl']:connect(function()
			toolStatus:Hide(8,33)
			toolStatus:Show(1,32)
		end))

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
			if not Keyboard.CtrlIsDown then
				Selection:Set{}
			end
		end

		local function rubberband(x,y)
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
		end

		Maid.move = GlobalButton.MouseMoved:connect(resetClick)
		Maid.select = GlobalButton.MouseButton1Down:connect(function(object,active,x,y)
			if inAction then return end
			inAction = true

			if object == Canvas.CurrentScreen then
			-- clicked nothing
				if checkDoubleClick() then inAction = false return end
				rubberband(x,y)
				return
			end
			-- clicked object

			if checkDoubleClick(object) then inAction = false return end

			local can_drag = true
			-- click to select
			if not Keyboard.ShiftIsDown then
				-- act upon the clicked object's container
				local o = Scope:GetContainer(object)
				if o == nil then
				-- clicked object is above current scope
					-- for now, treat it as if it were invisible
					rubberband(x,y)
					inAction = false
					return
				end
				object = o
				active = activeLookup[o]
			end
			if Keyboard.CtrlIsDown then
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
				Status:Add('SelectorDragging')
				Maid.drag_gui = Widgets.DragGUI(activeObjects,active,Vector2.new(x,y),'Center',{
					OnDrag = function(x,y,hasDragged,setObjects)
						if not hasDragged then
							if not Selection:Contains(object) then
								Selection:Set{object}
								dragObjects = {object}
								local active = activeLookup[object]
								activeObjects = {active}
								setObjects(activeObjects,active)
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
						Status:Remove('SelectorDragging')
						TransformHandles.Frame.Visible = true
						Maid.drag_gui = nil
						inAction = false
					end;
				},nil,true)
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

		-- precise arrow keys
		do
			local Keyboard = Keyboard
			local function moveSelection(dir,scaled)
				if Keyboard.CtrlIsDown then
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

			local arrowIsDown = Keyboard.KeyIsDown
			local MoveID = 0
			Maid:GiveTask(function() MoveID = MoveID + 1 end)
			local function startMoving()
				if inAction and MoveID == 0 then return end

				TransformHandles.Frame.Visible = false
				Selection:SetVisible(false)
				inAction = true

				Status:Add('SelectorArrows',{"Precise movement. Hold Ctrl for precise resizing."}):Show(1)

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

				Status:Remove('SelectorArrows')

				MoveID = 0
				TransformHandles.Frame.Visible = true
				Selection:SetVisible(true)
				inAction = false
			end

			Maid.arrow_up    = Keyboard.KeyDown[up   ]:connect(startMoving)
			Maid.arrow_down  = Keyboard.KeyDown[down ]:connect(startMoving)
			Maid.arrow_right = Keyboard.KeyDown[right]:connect(startMoving)
			Maid.arrow_left  = Keyboard.KeyDown[left ]:connect(startMoving)
		end

		-- viewport manipulation
		do
			local function viewportDrag(x,y)
				if inAction then return end
				inAction = true

				local Dragger = Widgets.Dragger()
				local mouseClick = Vector2.new(x,y)

				local conStop

				local function finishDrag()
					if conStop then conStop:disconnect() end
					Dragger:Destroy()
					inAction = false
				end

				local originPos = Vector2.new(CanvasFrame.Position.X.Offset,CanvasFrame.Position.Y.Offset)

				conStop = Canvas.Stopping:connect(finishDrag)

				Dragger.MouseButton2Up:connect(finishDrag)
				Dragger.MouseMoved:connect(function(x,y)
					local pos = originPos + Vector2.new(x,y) - mouseClick
					CanvasFrame.Position = UDim2.new(
						0,
						math.abs(pos.x) <= 8 and 0 or pos.x,
						0,
						math.abs(pos.y) <= 8 and 0 or pos.y
					)
				end)

				Dragger.Parent = UserInterface.Screen
			end

			Maid:GiveTask(GlobalButton.MouseButton2Down:connect(function(_,_,x,y)
				viewportDrag(x,y)
			end))
			Maid:GiveTask(ViewportFrame.MouseButton2Down:connect(viewportDrag))
		end
	end

	function Tool:Stop()
		Status:Remove('SelectorTool')
		Maid:DoCleaning()
	end

	ActionManager:AddAction('Default',Tool)
end
