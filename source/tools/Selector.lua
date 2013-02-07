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

	local Maid = CreateMaid()

	local function initOptions()
		local GuiColor = InternalSettings.GuiColor
		local ComponentFrame = Create'Frame'{
			Size = UDim2.new(0, 530, 1, 0);
			BorderColor3 = GuiColor.Border;
			Name = "Components";
			BackgroundColor3 = GuiColor.Background;
			Create'Frame'{
				Size = UDim2.new(0.5, 0, 1, 0);
				Name = "Position Group";
				BackgroundTransparency = 1;
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size10;
					Text = "X";
					Size = UDim2.new(0, 12, 1, -8);
					TextColor3 = GuiColor.Text;
					Name = "X Label";
					Position = UDim2.new(0, 4, 0, 4);
					BackgroundTransparency = 1;
				};
				Create'TextBox'{
					FontSize = Enum.FontSize.Size9;
					Text = "";
					Size = UDim2.new(0.5, -40, 1, -16);
					TextColor3 = GuiColor.Text;
					BorderColor3 = GuiColor.FieldBorder;
					Name = "XComponent";
					Position = UDim2.new(0, 20, 0, 8);
					BackgroundColor3 = GuiColor.Field;
				};
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size10;
					Text = "Y";
					Size = UDim2.new(0, 12, 1, -8);
					TextColor3 = GuiColor.Text;
					Name = "Y Label";
					Position = UDim2.new(0.5, -16, 0, 4);
					BackgroundTransparency = 1;
				};
				Create'TextBox'{
					FontSize = Enum.FontSize.Size9;
					Text = "";
					Size = UDim2.new(0.5, -40, 1, -16);
					TextColor3 = GuiColor.Text;
					BorderColor3 = GuiColor.FieldBorder;
					Name = "YComponent";
					Position = UDim2.new(0.5, 0, 0, 8);
					BackgroundColor3 = GuiColor.Field;
				};
				Create'TextButton'{
					FontSize = Enum.FontSize.Size18;
					BackgroundColor3 = GuiColor.Button;
					Name = "SetToZero Button";
					Text = "0";
					Size = UDim2.new(0, 32, 1, -8);
					TextColor3 = GuiColor.Text;
					TextStrokeTransparency = 0;
					BorderColor3 = GuiColor.ButtonBorder;
					Position = UDim2.new(1, -36, 0, 4);
				};
			};
			Create'Frame'{
				Size = UDim2.new(0.5, 0, 1, 0);
				Name = "Size Group";
				Position = UDim2.new(0.5, 0, 0, 0);
				BackgroundTransparency = 1;
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size10;
					Text = "W";
					Size = UDim2.new(0, 12, 1, -8);
					TextColor3 = GuiColor.Text;
					Name = "W Label";
					Position = UDim2.new(0, 4, 0, 4);
					BackgroundTransparency = 1;
				};
				Create'TextBox'{
					FontSize = Enum.FontSize.Size9;
					Text = "";
					Size = UDim2.new(0.5, -40, 1, -16);
					TextColor3 = GuiColor.Text;
					BorderColor3 = GuiColor.FieldBorder;
					Name = "XComponent";
					Position = UDim2.new(0, 20, 0, 8);
					BackgroundColor3 = GuiColor.Field;
				};
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size10;
					Text = "H";
					Size = UDim2.new(0, 12, 1, -8);
					TextColor3 = GuiColor.Text;
					Name = "H Label";
					Position = UDim2.new(0.5, -16, 0, 4);
					BackgroundTransparency = 1;
				};
				Create'TextBox'{
					FontSize = Enum.FontSize.Size9;
					Text = "";
					Size = UDim2.new(0.5, -40, 1, -16);
					TextColor3 = GuiColor.Text;
					BorderColor3 = GuiColor.FieldBorder;
					Name = "YComponent";
					Position = UDim2.new(0.5, 0, 0, 8);
					BackgroundColor3 = GuiColor.Field;
				};
				Create'TextButton'{
					FontSize = Enum.FontSize.Size18;
					BackgroundColor3 = GuiColor.Button;
					Name = "SetToZero Button";
					Text = "0";
					Size = UDim2.new(0, 32, 1, -8);
					TextColor3 = GuiColor.Text;
					TextStrokeTransparency = 0;
					BorderColor3 = GuiColor.ButtonBorder;
					Position = UDim2.new(1, -36, 0, 4);
				};
			};
			Create'Frame'{
				BorderSizePixel = 0;
				Size = UDim2.new(0, 1, 1, 0);
				BorderColor3 = GuiColor.Border;
				Position = UDim2.new(0.5, 0, 0, 0);
			};
		};

		Tool.Options = ComponentFrame
	end

	local function runOptions()
		local ComponentFrame = Tool.Options
		local layoutMode = Settings.LayoutMode('Scale')
		local currentObject

		local PosX  = DescendantByOrder(ComponentFrame,1,2)
		local PosY  = DescendantByOrder(ComponentFrame,1,4)
		local SizeX = DescendantByOrder(ComponentFrame,2,2)
		local SizeY = DescendantByOrder(ComponentFrame,2,4)

		do
			--[[

			Here, we're going to have the selected object update when a
			TextBox is edited by the user. Instead of defining the
			functionality for each TextBox individually, we're going to map
			each TextBox to its related components, and use a generic function
			that handles every TextBox. This will make the code shorter and
			easier to maintain. It's slower, but that's fine since FocusLost
			only fires when the user edits the text, which doesn't happen
			often enough to make a difference.

			]]
			-- a map of each TextBox to which components it edits
			local getComponent = {
				-- third entry is the location of the Scale component in the arguments to UDim2.new()
				[PosX]  = {'Position', 'X', 1, "The X coordinate of the Position"};
				[PosY]  = {'Position', 'Y', 3, "The Y coordinate of the Position"};
				[SizeX] = {    'Size', 'X', 1,     "The X coordinate of the Size"};
				[SizeY] = {    'Size', 'Y', 3,     "The X coordinate of the Size"};
			}

			local function textMask(textBox,text)
				if currentObject then
					local c = getComponent[textBox]
					local p = currentObject[c[1]]
					local l = layoutMode and 'Scale' or 'Offset'
					local prev = p[c[2]][l]
					local value = EvaluateInput(text,{
						n = prev;
						x = currentObject.Position.X[l];
						y = currentObject.Position.Y[l];
						w = currentObject.Size.X[l];
						h = currentObject.Size.Y[l];
					})
					if value then
						local comp = {p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset}
						-- if layoutMode is Offset, add 1 to the location
						comp[c[3] + (layoutMode and 0 or 1)] = value
						currentObject[c[1]] = UDim2.new(unpack(comp))
						-- setting the property already updates the TextBox's text
					else
						return string.format('%g',prev)
					end
				else
					return ''
				end
			end

			for textBox,data in pairs(getComponent) do
				ToolTipService:AddToolTip(textBox,data[4])
				Maid:GiveTask(Widgets.MaskedTextBox(textBox,textMask))
			end
		end

		local format = string.format
		local formatString = '%g'
		local function updateComponents(p)
			if p == 'AbsolutePosition' then
				if layoutMode then
					PosX.Text = format(formatString,currentActive.Position.X.Scale)
					PosY.Text = format(formatString,currentActive.Position.Y.Scale)
				else
					PosX.Text = currentActive.Position.X.Offset
					PosY.Text = currentActive.Position.Y.Offset
				end
			elseif p == 'AbsoluteSize' then
				if layoutMode then
					SizeX.Text = format(formatString,currentActive.Size.X.Scale)
					SizeY.Text = format(formatString,currentActive.Size.Y.Scale)
				else
					SizeX.Text = currentActive.Size.X.Offset
					SizeY.Text = currentActive.Size.Y.Offset
				end
			end
		end

		local function updateObject(object,active)
			if Maid.ComponentsChanged then
				Maid.ComponentsChanged:disconnect()
				Maid.ComponentsChanged = nil
			end
			currentObject = nil
			currentActive = nil
			if object then
				currentObject = object
				currentActive = active
				Maid.ComponentsChanged = active.Changed:connect(updateComponents)
				updateComponents('AbsolutePosition')
				updateComponents('AbsoluteSize')
			else
				PosX.Text  = ''
				PosY.Text  = ''
				SizeX.Text = ''
				SizeY.Text = ''
			end
		end

		local SetPosZero = DescendantByOrder(ComponentFrame,1,5)
		local SetSizeZero = DescendantByOrder(ComponentFrame,2,5)

		ToolTipService:AddToolTip(SetPosZero,"Set the opposite layout component of the Position to 0")
		ToolTipService:AddToolTip(SetSizeZero,"Set the opposite layout component of the Size to 0")

		Maid:GiveTask(SetPosZero.MouseButton1Click:connect(function()
			if layoutMode then
			--	for i = 1,#SelectedObjects do
				if SelectedObjects[1] then
					local object = SelectedObjects[1]
					local p = object.Position
					object.Position = UDim2.new(p.X.Scale,0,p.Y.Scale,0)
				end
			else
			--	for i = 1,#SelectedObjects do
				if SelectedObjects[1] then
					local object = SelectedObjects[1]
					local p = object.Position
					object.Position = UDim2.new(0,p.X.Offset,0,p.Y.Offset)
				end
			end
		end))
		Maid:GiveTask(SetSizeZero.MouseButton1Click:connect(function()
			if layoutMode then
			--	for i = 1,#SelectedObjects do
				if SelectedObjects[1] then
					local object = SelectedObjects[1]
					local s = object.Size
					object.Size = UDim2.new(s.X.Scale,0,s.Y.Scale,0)
				end
			else
			--	for i = 1,#SelectedObjects do
				if SelectedObjects[1] then
					local object = SelectedObjects[1]
					local s = object.Size
					object.Size = UDim2.new(0,s.X.Offset,0,s.Y.Offset)
				end
			end
		end))

		Maid.component_layout = Settings.Changed:connect(function(key,value)
			if key == 'LayoutMode' then
				layoutMode = Settings.LayoutMode('Scale')
				if currentObject then
					updateComponents('AbsolutePosition')
					updateComponents('AbsoluteSize')
				end
			end
		end)

		Maid.detect_component_selected = Selection.ObjectSelected:connect(updateObject)
		local activeLookup = Canvas.ActiveLookup
		Maid.detect_component_deselected = Selection.ObjectDeselected:connect(function()
			if #SelectedObjects > 0 then
				local object = SelectedObjects[#SelectedObjects]
				updateObject(object,activeLookup[object])
			else
				updateObject()
			end
		end)
		if #SelectedObjects > 0 then
			local object = SelectedObjects[#SelectedObjects]
			updateObject(object,activeLookup[object])
		else
			updateObject()
		end
	end

	function Tool:Select()
		if not self.Options then initOptions() end
		runOptions()

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
	end

	function Tool:Deselect()
		Status:Remove('SelectorTool')
		Maid:DoCleaning()
	end

	ToolManager:AddTool(Tool)
end
