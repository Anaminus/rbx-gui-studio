do
	local Tool = {
		Name = "Selector";
		Icon = "http://www.roblox.com/asset/?id=92033578";
		ToolTip = "Select and transform objects";
		Shortcut = "";
	}
	local SelectedObjects = Selection.SelectedObjects
	local GlobalButton = Canvas.GlobalButton
	local CanvasFrame = Canvas.CanvasFrame

	local event = CreateEventManager()
	local TransformHandles

	function Tool:Select()
		TransformHandles = Widgets.TransformHandles(Canvas,Mouse,event)

		local function select_nothing()
			if not Mouse.CtrlIsDown then
				Selection:Set{}
			end
		end

		event.select = GlobalButton.MouseButton1Down:connect(function(object,active,x,y)
			local can_drag = true
			-- click to select
			if not Mouse.ShiftIsDown then
				-- act upon the clicked object's container
				local o = Scope:GetContainer(object)
				if o == nil then
				-- clicked object is above current scope
					-- for now, treat it as if it were invisible
					select_nothing()
					return
				end
				object = o
				active = Canvas.ActiveLookup[o]
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
				table.insert(dragObjects,1,object)
				for i,object in pairs(dragObjects) do
					activeObjects[i] = Canvas.ActiveLookup[object]
				end

				Widgets.DragGUI(activeObjects,Vector2.new(x,y),'Center',{
					OnDrag = function(x,y,hasDragged,setObjects)
						if not hasDragged then
							if not Selection:Contains(object) then
								Selection:Set{object}
								dragObjects = {object}
								activeObjects = {Canvas.ActiveLookup[object]}
								setObjects(activeObjects)
							end
						end
					end;
					OnRelease = function(x,y,hasDragged)
						if hasDragged then
							for i = 1,#dragObjects do
								local object = dragObjects[i]
								local active = activeObjects[i]
								object.Position = active.Position
								object.Size = active.Size
							end
						elseif not Selection:Contains(object) then
							Selection:Set{object}
						end
					end;
				})
			end
		end)
		event.select_nil = CanvasFrame.MouseButton1Down:connect(select_nothing)

		event.selected = Selection.ObjectSelected:connect(function(object,active)
			TransformHandles:SetParent(object)
		end)
		event.deselected = Selection.ObjectDeselected:connect(function(object,active)
			if #SelectedObjects > 0 then
				TransformHandles:SetParent(SelectedObjects[#SelectedObjects])
			else
				TransformHandles:SetParent(nil)
			end
		end)
		if #SelectedObjects > 0 then
			TransformHandles:SetParent(SelectedObjects[#SelectedObjects])
		end
	end

	function Tool:Deselect()
		event:clear()
		if TransformHandles then
			TransformHandles:Destroy()
			TransformHandles = nil
		end
	end

	ToolManager:AddTool(Tool)
end
