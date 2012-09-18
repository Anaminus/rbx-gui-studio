do
	local Tool = {
		Name = "InsertObject";
		Icon = Preload"http://www.roblox.com/asset/?id=92518186";
		ToolTip = "Insert new objects";
		Shortcut = "";
	}

	local Options = {
		InsertType = nil;
	}

	local SelectedObjects = Selection.SelectedObjects
	local GlobalButton = Canvas.GlobalButton
	local CanvasFrame = Canvas.CanvasFrame

	local event = CreateEventManager()
	local TransformHandles
	local Dragger

	local function initOptions()
		local insertTypes = {
			{Name="Frame",       Icon=Preload"http://www.roblox.com/asset/?id=92581491", ToolTip="Frame"};
			{Name="ImageLabel",  Icon=Preload"http://www.roblox.com/asset/?id=92581501", ToolTip="ImageLabel"};
			{Name="TextLabel",   Icon=Preload"http://www.roblox.com/asset/?id=92581513", ToolTip="TextLabel"};
			{Name="ImageButton", Icon=Preload"http://www.roblox.com/asset/?id=92581528", ToolTip="ImageButton"};
			{Name="TextButton",  Icon=Preload"http://www.roblox.com/asset/?id=92581517", ToolTip="TextButton"};
			{Name="TextBox",     Icon=Preload"http://www.roblox.com/asset/?id=92581517", ToolTip="TextBox"};
		}

		local buttonSize = InternalSettings.GuiButtonSize
		local InsertTypeFrame = Widgets.ButtonMenu(insertTypes,Vector2.new(buttonSize,buttonSize),true,function(type)
			Options.InsertType.Button.BorderColor3 = Color3.new(0.588235, 0.588235, 0.588235)
			Options.InsertType = type
			type.Button.BorderColor3 = Color3.new(1,0,0)
		end)
		Create(InsertTypeFrame){
			Name = "Insert ToolOptions";
		}
		Options.InsertType = insertTypes[1]
		insertTypes[1].Button.BorderColor3 = Color3.new(1,0,0)

		Tool.Options = InsertTypeFrame
	end

	function Tool:Select()
		if not self.Options then initOptions() end

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
			local object,active
			local originClick = Vector2.new(x,y)

			Widgets.DragGUI({},originClick,'BottomRight',{
				OnDrag = function(x,y,hasDragged,setObjects)
					if not hasDragged then
						object = Instance.new(Options.InsertType.Name,Scope.Current)
						active = Canvas:WaitForObject(object)

						local pos = originClick - active.Parent.AbsolutePosition
						if scaled then

						else
							object.Position = UDim2.new(0,pos.x,0,pos.y)
						end

						setObjects{active}
					end
				end;
				OnRelease = function(x,y,hasDragged)
					if hasDragged then
						if object and active then
							object.Size = active.Size
							Selection:Set{object}
						end
					else
						Selection:Set{}
					end
				end;
			},Canvas.CanvasFrame)
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

			local finishDrag = Widgets.DragGUI(active,Vector2.new(x,y),'Center',{
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
						object.Position = active.Position
					elseif not Selection:Contains(object) then
						Selection:Set{object}
					end
				end;
			})
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
