do
	local Tool = {
		Name = "InsertObject";
		Icon = "http://www.roblox.com/asset/?id=92518186";
		ToolTip = "Insert new objects";
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
		TransformHandles = Widgets.TransformHandles(Canvas,Mouse)
		do
			local br = TransformHandles.Frame.BottomRight
			for i,handle in pairs(TransformHandles.Frame:GetChildren()) do
				if handle ~= br then
					handle:Destroy()
				end
			end
			Create(br){
				Position = UDim2.new(1,-4,1,-4);
				Size = UDim2.new(0,8,0,8);
				BackgroundColor3 = Color3.new(1,1,1);
				BorderColor3 = Color3.new(0,0,0);
				BorderSizePixel = 1;
			}
		end

		local function addNewObject(x,y)
			local object,active,click_offset

			local has_dragged = false

			local drag_pos
			event.mouse_up = Dragger.MouseButton1Up:connect(function()
				event:disconnect('mouse_up','drag')
				Dragger.Parent = nil

				if has_dragged then
					local diff = drag_pos - click_offset - active.Parent.AbsolutePosition
					object.Size = UDim2.new(0,diff.x,0,diff.y)
					Selection:Set{object}
				else
					Selection:Set{}
				end
			end)
			event.drag = Dragger.MouseMoved:connect(function(x,y)
				if not has_dragged then
					has_dragged = true
					object = Instance.new("Frame",Scope.Current)
					active = Canvas:WaitForObject(object)

					click_offset = Vector2.new(x,y) - active.Parent.AbsolutePosition
					object.Position = UDim2.new(0,click_offset.x,0,click_offset.y) -- scale/offset
				end
				drag_pos = Vector2.new(x,y)
				local diff = drag_pos - click_offset - active.Parent.AbsolutePosition
				active.Size = UDim2.new(0,diff.x,0,diff.y)
			end)
			Dragger.Parent = GetScreen(Canvas.CanvasFrame)
		end

		event.select = GlobalButton.MouseButton1Down:connect(function(object,active,x,y)
			-- click to select
			if not Mouse.ShiftIsDown then
				-- act upon the clicked object's container
				local o = Scope:GetContainer(object)
				if o == nil then
				-- clicked object is above current scope
					-- for now, treat it as if it were invisible
					addNewObject(x,y)
					return
				end
				object = o
				active = Canvas.ActiveLookup[o]
			end

			-- click & drag to move
			-- on drag or on up, select object
			local has_dragged = false
			local click_pos = Vector2.new(x,y)

			local clickOffset = click_pos - active.AbsolutePosition

			local drag_pos
			event.mouse_up = Dragger.MouseButton1Up:connect(function()
				event:disconnect('mouse_up','drag')
				Dragger.Parent = nil
				if has_dragged then
					local pos = drag_pos - clickOffset - active.Parent.AbsolutePosition
					object.Position = UDim2.new(0,pos.x,0,pos.y)
				elseif not Selection:Contains(object) then
					Selection:Set{object}
				end
			end)
			event.drag = Dragger.MouseMoved:connect(function(x,y)
				if not has_dragged then
				--[[ if this object isn't selected, insert a new object instead
					if not Selection:Contains(object) then
						event:disconnect('mouse_up','drag')
						Dragger.Parent = nil
						addNewObject(x,y)
						return
					end
				--]]
					has_dragged = true
					Selection:Set{object}
					clickOffset = click_pos - active.AbsolutePosition
				end
				drag_pos = Vector2.new(x,y)
				local pos = drag_pos - clickOffset - active.Parent.AbsolutePosition
				active.Position = UDim2.new(0,pos.x,0,pos.y)
			end)
			Dragger.Parent = GetScreen(active)
		end)
		event.select_nil = CanvasFrame.MouseButton1Down:connect(addNewObject)

		event.selected = Selection.ObjectSelected:connect(function(object,active)
			if #SelectedObjects > 1 then
				TransformHandles:SetParent(nil)
			else
				TransformHandles:SetParent(object)
			end
		end)
		event.deselected = Selection.ObjectDeselected:connect(function(object,active)
			if #SelectedObjects == 0 then
				TransformHandles:SetParent(SelectedObjects[#SelectedObjects])
			else
				TransformHandles:SetParent(nil)
			end
		end)
		if #SelectedObjects == 1 then
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
