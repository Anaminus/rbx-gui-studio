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
	local Dragger

	function Tool:Select()
		Dragger = Widgets.Dragger()
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
				local has_dragged = false
				local click_pos = Vector2.new(x,y)

				local selectedObjects = Selection:Get()
				for i,object in pairs(selectedObjects) do
					local active = Canvas.ActiveLookup[object]
					selectedObjects[i] = {object,active,click_pos - active.AbsolutePosition}
				end

				local drag_pos
				event.mouse_up = Dragger.MouseButton1Up:connect(function()
					event:disconnect('mouse_up','drag')
					Dragger.Parent = nil
					if has_dragged then
						for i = 1,#selectedObjects do
							local v = selectedObjects[i]
							local pos = drag_pos - v[3] - v[2].Parent.AbsolutePosition
							v[1].Position = UDim2.new(0,pos.x,0,pos.y)
						end
					elseif not Selection:Contains(object) then
						Selection:Set{object}
					end
				end)
				event.drag = Dragger.MouseMoved:connect(function(x,y)
					if not has_dragged then
						has_dragged = true
						if not Selection:Contains(object) then
							Selection:Set{object}
							for i in pairs(selectedObjects) do
								selectedObjects[i] = nil
							end
							selectedObjects[1] = {object,active,click_pos - active.AbsolutePosition}
						end
					end
					drag_pos = Vector2.new(x,y)
					for i = 1,#selectedObjects do
						local v = selectedObjects[i]
						local active = v[2]
						local pos = drag_pos - v[3] - active.Parent.AbsolutePosition
						active.Position = UDim2.new(0,pos.x,0,pos.y)
					end
				end)
				Dragger.Parent = GetScreen(active)
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
		if Dragger then
			Dragger:Destroy()
			Dragger = nil
		end
	end

	ToolManager:AddTool(Tool)
end
