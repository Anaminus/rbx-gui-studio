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

	local evalInput

	local function initOptions()
		local ComponentFrame = Create'Frame'{
			Size = UDim2.new(0, 530, 1, 0);
			BorderColor3 = Color3.new(0.588235, 0.588235, 0.588235);
			Name = "Components";
			BackgroundColor3 = Color3.new(0.917647, 0.917647, 0.917647);
			Create'Frame'{
				Size = UDim2.new(0.5, 0, 1, 0);
				Name = "Position Group";
				BackgroundTransparency = 1;
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size10;
					Text = "X";
					Size = UDim2.new(0, 12, 1, -8);
					TextColor3 = Color3.new(0, 0, 0);
					Name = "X Label";
					Position = UDim2.new(0, 4, 0, 4);
					BackgroundTransparency = 1;
				};
				Create'TextBox'{
					FontSize = Enum.FontSize.Size9;
					Text = "";
					Size = UDim2.new(0.5, -40, 1, -16);
					TextColor3 = Color3.new(0, 0, 0);
					BorderColor3 = Color3.new(0.752941, 0.752941, 0.752941);
					Name = "XComponent";
					Position = UDim2.new(0, 20, 0, 8);
					BackgroundColor3 = Color3.new(1, 1, 1);
				};
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size10;
					Text = "Y";
					Size = UDim2.new(0, 12, 1, -8);
					TextColor3 = Color3.new(0, 0, 0);
					Name = "Y Label";
					Position = UDim2.new(0.5, -16, 0, 4);
					BackgroundTransparency = 1;
				};
				Create'TextBox'{
					FontSize = Enum.FontSize.Size9;
					Text = "";
					Size = UDim2.new(0.5, -40, 1, -16);
					TextColor3 = Color3.new(0, 0, 0);
					BorderColor3 = Color3.new(0.752941, 0.752941, 0.752941);
					Name = "YComponent";
					Position = UDim2.new(0.5, 0, 0, 8);
					BackgroundColor3 = Color3.new(1, 1, 1);
				};
				Create'TextButton'{
					FontSize = Enum.FontSize.Size18;
					BackgroundColor3 = Color3.new(0.866667, 0.866667, 0.866667);
					Name = "SetToZero Button";
					Text = "0";
					Size = UDim2.new(0, 32, 1, -8);
					TextColor3 = Color3.new(0, 0, 0);
					TextStrokeTransparency = 0;
					BorderColor3 = Color3.new(0.588235, 0.588235, 0.588235);
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
					TextColor3 = Color3.new(0, 0, 0);
					Name = "W Label";
					Position = UDim2.new(0, 4, 0, 4);
					BackgroundTransparency = 1;
				};
				Create'TextBox'{
					FontSize = Enum.FontSize.Size9;
					Text = "";
					Size = UDim2.new(0.5, -40, 1, -16);
					TextColor3 = Color3.new(0, 0, 0);
					BorderColor3 = Color3.new(0.752941, 0.752941, 0.752941);
					Name = "XComponent";
					Position = UDim2.new(0, 20, 0, 8);
					BackgroundColor3 = Color3.new(1, 1, 1);
				};
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size10;
					Text = "H";
					Size = UDim2.new(0, 12, 1, -8);
					TextColor3 = Color3.new(0, 0, 0);
					Name = "H Label";
					Position = UDim2.new(0.5, -16, 0, 4);
					BackgroundTransparency = 1;
				};
				Create'TextBox'{
					FontSize = Enum.FontSize.Size9;
					Text = "";
					Size = UDim2.new(0.5, -40, 1, -16);
					TextColor3 = Color3.new(0, 0, 0);
					BorderColor3 = Color3.new(0.752941, 0.752941, 0.752941);
					Name = "YComponent";
					Position = UDim2.new(0.5, 0, 0, 8);
					BackgroundColor3 = Color3.new(1, 1, 1);
				};
				Create'TextButton'{
					FontSize = Enum.FontSize.Size18;
					BackgroundColor3 = Color3.new(0.866667, 0.866667, 0.866667);
					Name = "SetToZero Button";
					Text = "0";
					Size = UDim2.new(0, 32, 1, -8);
					TextColor3 = Color3.new(0, 0, 0);
					TextStrokeTransparency = 0;
					BorderColor3 = Color3.new(0.588235, 0.588235, 0.588235);
					Position = UDim2.new(1, -36, 0, 4);
				};
			};
			Create'Frame'{
				BorderSizePixel = 0;
				Size = UDim2.new(0, 1, 1, 0);
				BorderColor3 = Color3.new(0.588235, 0.588235, 0.588235);
				Position = UDim2.new(0.5, 0, 0, 0);
			};
		};

		local math_env = {
			abs = math.abs; acos = math.acos; asin = math.asin; atan = math.atan; atan2 = math.atan2;
			ceil = math.ceil; cos = math.cos; cosh = math.cosh; deg = math.deg;
			exp = math.exp; floor = math.floor; fmod = math.fmod; frexp = math.frexp;
			huge = math.huge; ldexp = math.ldexp; log = math.log; log10 = math.log10;
			max = math.max; min = math.min; modf = math.modf; pi = math.pi;
			pow = math.pow; rad = math.rad; random = math.random; sin = math.sin;
			sinh = math.sinh; sqrt = math.sqrt; tan = math.tan; tanh = math.tanh;
		}

		if _VERSION == 'Lua 5.2' then
			function evalInput(str,prev)
				local env = {}
				for k,v in pairs(math_env) do
					env[k] = v
				end
				env.x = prev
				env.n = prev
				local f = load("return "..s,nil,nil,env)
				if f then
					local s,o = pcall(f)
					if s then return tonumber(o) end
				end
				return nil
			end
		else
			function evalInput(str,prev)
				local env = {}
				for k,v in pairs(math_env) do
					env[k] = v
				end
				env.x = prev
				env.n = prev
				local f = loadstring("return "..str)
				if f then
					setfenv(f,env)
					local s,o = pcall(f)
					if s then return tonumber(o) end
				end
				return nil
			end
		end

		Tool.Options = ComponentFrame
	end

	local function runOptions()
		local ComponentFrame = Tool.Options
		local layoutMode = Settings.LayoutMode('Scale')
		local currentObject

		local PosX  = Descendant(ComponentFrame,1,2)
		local PosY  = Descendant(ComponentFrame,1,4)
		local SizeX = Descendant(ComponentFrame,2,2)
		local SizeY = Descendant(ComponentFrame,2,4)

		local format = string.format
		local formatString = '%g'

		ToolTipService:AddToolTip(PosX,"The X coordinate of the Position")
		Maid:GiveTask(PosX.FocusLost:connect(function()
			if currentObject then
				local p = currentObject.Position
				if layoutMode then
					local prev = p.X.Scale
					local num = evalInput(PosX.Text,prev)
					if num then
					--	PosX.Text = format(formatString,num)
						currentObject.Position = UDim2.new(num,p.X.Offset,p.Y.Scale,p.Y.Offset)
					else
						PosX.Text = format(formatString,prev)
					end
				else
					local prev = p.X.Offset
					local num = evalInput(PosX.Text,prev)
					if num then
					--	PosX.Text = format(formatString,num)
						currentObject.Position = UDim2.new(p.X.Scale,num,p.Y.Scale,p.Y.Offset)
					else
						PosX.Text = format(formatString,prev)
					end
				end
			end
		end))
		ToolTipService:AddToolTip(PosY,"The Y coordinate of the Position")
		Maid:GiveTask(PosY.FocusLost:connect(function()
			if currentObject then
				local p = currentObject.Position
				if layoutMode then
					local prev = p.Y.Scale
					local num = evalInput(PosY.Text,prev)
					if num then
					--	PosY.Text = format(formatString,num)
						currentObject.Position = UDim2.new(p.X.Scale,p.X.Offset,num,p.Y.Offset)
					else
						PosY.Text = format(formatString,prev)
					end
				else
					local prev = p.Y.Offset
					local num = evalInput(PosY.Text,prev)
					if num then
					--	PosY.Text = format(formatString,num)
						currentObject.Position = UDim2.new(p.X.Scale,p.X.Offset,p.Y.Scale,num)
					else
						PosY.Text = format(formatString,prev)
					end
				end
			end
		end))
		ToolTipService:AddToolTip(SizeX,"The X coordinate of the Size")
		Maid:GiveTask(SizeX.FocusLost:connect(function()
			if currentObject then
				local s = currentObject.Size
				if layoutMode then
					local prev = s.X.Scale
					local num = evalInput(SizeX.Text,prev)
					if num then
					--	SizeX.Text = format(formatString,num)
						currentObject.Size = UDim2.new(num,s.X.Offset,s.Y.Scale,s.Y.Offset)
					else
						SizeX.Text = format(formatString,prev)
					end
				else
					local prev = s.X.Offset
					local num = evalInput(SizeX.Text,prev)
					if num then
					--	SizeX.Text = format(formatString,num)
						currentObject.Size = UDim2.new(s.X.Scale,num,s.Y.Scale,s.Y.Offset)
					else
						SizeX.Text = format(formatString,prev)
					end
				end
			end
		end))
		ToolTipService:AddToolTip(SizeY,"The Y coordinate of the Size")
		Maid:GiveTask(SizeY.FocusLost:connect(function()
			if currentObject then
				local s = currentObject.Size
				if layoutMode then
					local prev = s.Y.Scale
					local num = evalInput(SizeY.Text,prev)
					if num then
					--	SizeY.Text = format(formatString,num)
						currentObject.Size = UDim2.new(s.X.Scale,s.X.Offset,num,s.Y.Offset)
					else
						SizeY.Text = format(formatString,prev)
					end
				else
					local prev = s.Y.Offset
					local num = evalInput(SizeY.Text,prev)
					if num then
					--	SizeY.Text = format(formatString,num)
						currentObject.Size = UDim2.new(s.X.Scale,s.X.Offset,s.Y.Scale,num)
					else
						SizeY.Text = format(formatString,prev)
					end
				end
			end
		end))
		-- yeah who cares

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

		local SetPosZero = Descendant(ComponentFrame,1,5)
		local SetSizeZero = Descendant(ComponentFrame,2,5)

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
			if not Mouse.ShiftIsDown then
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
