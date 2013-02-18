do
	local Tool = {
		Name = "InsertObject";
		Icon = Widgets.Icon(nil,InternalSettings.IconMap.Tool,32,0,1);
		ToolTip = "Insert new objects";
		KeyBinding = "i";
	}

	local Options = {
		InsertType = nil;
	}

	local SelectedObjects = Selection.SelectedObjects
	local GlobalButton = Canvas.GlobalButton
	local CanvasFrame = Canvas.CanvasFrame

	local Maid = CreateMaid()

	local function initOptions()
		local insertTypes = {
			{Name="Frame",       Icon=Widgets.Icon(nil,InternalSettings.IconMap.Insert,32,0,0), ToolTip="Frame"};
			{Name="ImageLabel",  Icon=Widgets.Icon(nil,InternalSettings.IconMap.Insert,32,0,1), ToolTip="ImageLabel"};
			{Name="TextLabel",   Icon=Widgets.Icon(nil,InternalSettings.IconMap.Insert,32,0,2), ToolTip="TextLabel"};
			{Name="ImageButton", Icon=Widgets.Icon(nil,InternalSettings.IconMap.Insert,32,0,3), ToolTip="ImageButton"};
			{Name="TextButton",  Icon=Widgets.Icon(nil,InternalSettings.IconMap.Insert,32,0,4), ToolTip="TextButton"};
			{Name="TextBox",     Icon=Widgets.Icon(nil,InternalSettings.IconMap.Insert,32,0,5), ToolTip="TextBox"};
		}

		local buttonSize = InternalSettings.GuiButtonSize
		local GuiColor = InternalSettings.GuiColor
		local InsertTypeFrame = Widgets.ButtonMenu(insertTypes,Vector2.new(buttonSize,buttonSize),true,function(type)
			Options.InsertType.Button.BorderColor3 = GuiColor.ButtonBorder
			Options.InsertType = type
			type.Button.BorderColor3 = GuiColor.ButtonSelected
		end)
		Create(InsertTypeFrame){
			Name = "Insert ToolOptions";
		}
		Options.InsertType = insertTypes[1]
		insertTypes[1].Button.BorderColor3 = GuiColor.ButtonSelected

		Tool.Options = InsertTypeFrame
	end

	function Tool:Select()
		if not self.Options then initOptions() end

		Status:Add('InsertTool',{
			"Click and drag to insert an object. Click an object to select it. Double-click to change scope.";
		}):Show(1)

		local TransformHandles = Widgets.TransformHandles(Canvas)
		Maid:GiveTask(function() TransformHandles:Destroy() end)
		do
			local br = TransformHandles.Frame.BottomRight
			for i,handle in pairs(TransformHandles.Frame:GetChildren()) do
				if handle ~= br then
					handle:Destroy()
				end
			end
			Create(br){
				Size = UDim2.new(0,8,0,8);
			--	BackgroundColor3 = Color3.new(1,1,1);
				BorderColor3 = Color3.new(0,0,0);
			}
			Create(br.Top){
				Size = UDim2.new(1, -1, 0, 1);
				Position = UDim2.new(0, 2, 0, -1);
			};
			Create(br.Right){
				Size = UDim2.new(0, 1, 1, 0);
				Position = UDim2.new(1, 0, 0, 0);
			};
			Create(br.Left){
				Size = UDim2.new(0, 1, 1, -2);
				Position = UDim2.new(0, -1, 0, 2);
			};
			Create(br.Bottom){
				Size = UDim2.new(1, 2, 0, 1);
				Position = UDim2.new(0, -1, 1, 0);
			};
		end

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

		local function addNewObject(x,y)
			local object,active

			local originClick
			if Settings.SnapEnabled then
				originClick = SnapService:Snap(Vector2.new(x,y))
			else
				originClick = Vector2.new(x,y)
			end

			Maid.drag_gui = Widgets.DragGUI({},nil,originClick,'BottomRight',{
				OnDrag = function(x,y,hasDragged,setObjects)
					if hasDragged then
						clickStamp = 0
					else
						object = Instance.new(Options.InsertType.Name,Scope.Current)
						active = Canvas:WaitForObject(object)

						local pos = originClick - active.Parent.AbsolutePosition
						if Settings.LayoutMode('Scale') then
							pos = pos/active.Parent.AbsoluteSize
							active.Position = UDim2.new(pos.x,0,pos.y,0)
						else
							active.Position = UDim2.new(0,pos.x,0,pos.y)
						end

						setObjects({active},active)
					end
				end;
				OnRelease = function(x,y,hasDragged)
					if hasDragged then
						clickStamp = 0
						if object and active then
							object.Position = active.Position
							object.Size = active.Size
							Selection:Set{object}
						end
					else
						Selection:Set{}
					end
					Maid.drag_gui = nil
				end;
			},Canvas.CanvasFrame,true,true)
		end

		Maid.move = GlobalButton.MouseMoved:connect(resetClick)
		Maid.select = GlobalButton.MouseButton1Down:connect(function(object,active,x,y)
			if object == Canvas.CurrentScreen then
				if checkDoubleClick() then return end
				addNewObject(x,y)
				return
			end

			if checkDoubleClick(object) then return end

			-- click to select
			if not Keyboard.ShiftIsDown then
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

			TransformHandles.Frame.Visible = false
			local finishDrag = Widgets.DragGUI(active,active,Vector2.new(x,y),'Center',{
				OnDrag = function(x,y,hasDragged)
					if not hasDragged then
					--[[ if this object isn't selected, insert a new object instead
						if not Selection:Contains(object) then
							finishDrag(x,y)
							addNewObject(x,y)
							return
						end
					--]]
						Selection:Set{object}
					end
				end;
				OnRelease = function(x,y,hasDragged)
					if hasDragged then
						clickStamp = 0
						object.Position = active.Position
					elseif not Selection:Contains(object) then
						Selection:Set{object}
					end
					TransformHandles.Frame.Visible = true
					Maid.drag_gui = nil
				end;
			},nil,true)
			Maid.drag_gui = finishDrag
		end)

		Maid.selected = Selection.ObjectSelected:connect(function(object,active)
			if #SelectedObjects > 1 then
				TransformHandles:SetParent(nil)
			else
				TransformHandles:SetParent(object)
			end
		end)
		Maid.deselected = Selection.ObjectDeselected:connect(function(object,active)
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
		Status:Remove('InsertTool')
		Maid:DoCleaning()
	end

	ToolManager:AddTool(Tool)
end
