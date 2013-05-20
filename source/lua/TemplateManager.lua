--[[TemplateManager

Handles GUI templates.

API:

Fields:

TemplateManager.Frame
	The GUI object associated with the manager.

Methods:

TemplateManager:Initialize ( )
	Initializes the template manager.

TemplateManager:AddDefault ( name, template )
	Adds a non-user template.

	`name` is a string used to refer to the template.
	`template` is a table containing properties and subtables representing a GUI object.

TemplateManager:AddTemplate ( name, template )
	Adds a new user template.

TemplateManager:RemoveTemplate ( name )
	Removes a user template.

TemplateManager:InitializeTemplate ( name )
	Create an instance from template `name`.

TemplateManager:StartDrag ( name )
	Performs a dragging action.

]]

do
	TemplateManager = {}

	local initialized = false

	local UserTemplates = {}
	local DefaultTemplates = {}
	local TemplateIcons = {}

	local listItemLookup = {}
	local addListItem
	local removeListItem

	function TemplateManager:Initialize()
		local GuiColor = InternalSettings.GuiColor
		local frame = Create'Frame'{
			Name = "Templates Panel";
			Position = UDim2.new(0,0,0,92);
			Size = UDim2.new(0,200,1,-152);
			BackgroundColor3 = GuiColor.Background;
			BorderColor3 = GuiColor.Border;
			Create'TextLabel'{
				Name = "PanelLabel";
				BackgroundTransparency = 1;
				Position = UDim2.new(0,4,0,4);
				Size = UDim2.new(1,-24,0,8);
				Text = "Templates";
				TextXAlignment = Enum.TextXAlignment.Left;
				FontSize = Enum.FontSize.Size10;
				TextColor3 = GuiColor.Text;
			};
			Create'TextButton'{
				Name = "CollapseButton";
				AutoButtonColor = false;
				Position = UDim2.new(1,-16,0,0);
				Size = UDim2.new(0,16,1,0);
				BackgroundColor3 = GuiColor.TitleBackground;
				BorderColor3 = GuiColor.Border;
				Text = "<<";
				TextStrokeTransparency = 0;
				FontSize = Enum.FontSize.Size9;
				TextColor3 = Color3.new(1,1,1);
				TextStrokeColor3 = GuiColor.Border;
			};
		};

		local templateList = Widgets.ScrollingContainer()
		Create(templateList.GUI){
			Name = "TemplateList";
			Position = UDim2.new(0,4,0,18);
			Size = UDim2.new(1,-24,1,-22);
			BackgroundColor3 = GuiColor.Field;
			BorderColor3 = GuiColor.Border;
		}
		templateList.GUI.Parent = frame

		local listContainer = Widgets.StackingFrame(templateList.Container)
		listContainer.Border = 2

		local listItemTemplate = Create'ImageButton'{
			BorderSizePixel = 0;
			Size = UDim2.new(0,176,0,38);
			BackgroundColor3 = GuiColor.Field;
			BorderSizePixel = 0;
			BackgroundTransparency = 1;
			AutoButtonColor = false;
			Create'TextLabel'{
				Name = "ItemText";
				BackgroundTransparency = 1;
				Position = UDim2.new(0,42,0,0);
				Size = UDim2.new(1,-42,1,0);
				TextXAlignment = Enum.TextXAlignment.Left;
				FontSize = Enum.FontSize.Size10;
				TextColor3 = GuiColor.Text;
			};
		}

		function addListItem(name)
			local template = DefaultTemplates[name] or UserTemplates[name]
			local icon = TemplateIcons[name]

			local listItem = listItemTemplate:Clone()

			if type(icon) == 'string' then
				Create'ImageLabel'{
					Name = "Icon";
					Image = icon;
					BackgroundTransparency = 1;
					Position = UDim2.new(0,0,0,0);
					Size = UDim2.new(0,38,0,38);
					Parent = listItem;
				}
			elseif icon ~= nil then
				Create(icon:Clone()){
					Position = UDim2.new(0,0,0,0);
					Size = UDim2.new(0,38,0,38);
					Parent = listItem;
				}
			end
			listItem.ItemText.Text = name

			listItem.MouseButton1Down:connect(function(x,y)
				self:StartDrag(name,Vector2.new(x,y))
			end)

			listContainer:AddObject(listItem)
			listItemLookup[name] = listItem
		end

		function removeListItem(name)
			if DefaultTemplates[name] then
				return nil,"cannot remove default"
			end
			if listItemLookup[name] then
				listContainer:RemoveObject(listItemLookup[name])
				listItemLookup[name] = nil
			end
		end

		self.Frame = frame

		do -- default templates
			local templates = {
				"Frame";
				"ImageLabel";
				"TextLabel";
				"ImageButton";
				"TextButton";
				"TextBox";
			}

			for i = 1,#templates do
				local name = templates[i]
				local template = {
					ClassName = name;
					Name = name;
					Size = UDim2.new(0,64,0,64);
				}
				self:AddDefault(name,template,Widgets.Icon(nil,InternalSettings.IconMap.Insert,32,0,i-1))
			end
		end

		do -- add existing templates
			local sorted = {}
			for k in pairs(DefaultTemplates) do
				sorted[#sorted+1] = k
			end
			table.sort(sorted)
			for i = 1,#sorted do
				addListItem(sorted[i])
			end
		end

		initialized = true
	end
--[[
	local function findParameters(template)
		local offsets = {}
		local count = 0
		local s,e,param = 0,0
		while true do
			s,e,param = template:find('{{(.-)}}',e+1)
			if s then
				if param == '' or param == '#' then
					count = count + 1
					param = count
				end
				offsets[param] = {s,e}
			else
				break
			end
		end
		return offsets
	end
--]]

	function TemplateManager:AddDefault(name,template,icon)
		if DefaultTemplates[name] or UserTemplates[name] then
			return nil,"template `" .. name .. "` already exists"
		end

		DefaultTemplates[name] = template
		TemplateIcons[name] = icon

		if initialized then
			addListItem(name)
		end

		return true
	end

	function TemplateManager:AddTemplate(name,template)
		if DefaultTemplates[name] or UserTemplates[name] then
			return nil,"template `" .. name .. "` already exists"
		end

		UserTemplates[name] = true

		if initialized then
			addListItem(name)
		end

		return true
	end

	function TemplateManager:RemoveTemplate(name)
		if UserTemplates[name] then
			UserTemplates[name] = nil
		elseif DefaultTemplates[name] then
			return nil,"cannot remove default template `" .. name .. "`"
		else
			return nil,"`" .. name .. "` is not an existing template"
		end

		if initialized then
			removeListItem(name)
		end

		return true
	end

	do
		local function recurse(template,parent)
			local object = Instance.new(template.ClassName,parent)
			for k,v in pairs(template) do
				if type(k) == 'string' and k ~= 'ClassName' then
					object[k] = v
				elseif type(k) == 'number' then
					recurse(v,object)
				end
			end
			return object
		end
		function TemplateManager:InitializeTemplate(name)
			local template
			if UserTemplates[name] then
				template = UserTemplates[name]
			elseif DefaultTemplates[name] then
				template = DefaultTemplates[name]
			else
				return error("`" .. name .. "` is not an existing template",2)
			end
			return recurse(template)
		end
	end

	function TemplateManager:StartDrag(name,mouseClick)
		local listItem = listItemLookup[name]
		if not listItem then
			error("`" .. tostring(name) .. "` is not a valid template",2)
		end

		ActionManager:StopAction('Default')

		local dragGhost = listItem:Clone()

		local onCanvas = false
		local conHover; conHover = Canvas.ViewportFrame.MouseMoved:connect(function(object,active,x,y)
			conHover:disconnect()
			onCanvas = true
		end)

		local conCanvas,finishDrag
		conCanvas = Canvas.Stopping:connect(function()
			conCanvas:disconnect()
			if finishDrag then finishDrag() end
		end)

		dragGhost.Position = UDim2.new(0,listItem.AbsolutePosition.x,0,listItem.AbsolutePosition.y)
		dragGhost.Size = UDim2.new(0,listItem.AbsoluteSize.x,0,listItem.AbsoluteSize.y)
		dragGhost.BackgroundTransparency = 0.5
		dragGhost.Parent = GetScreen(Canvas.CanvasFrame)
		finishDrag = Widgets.DragGUI(dragGhost,dragGhost,mouseClick,'Center',{
			OnDrag = function(x,y,hasDragged,setObjects)
				if onCanvas then
					onCanvas = false
					dragGhost:Destroy()
					local object = self:InitializeTemplate(name)
					object.Parent = Scope.Current
					local active = Canvas:WaitForObject(object)

					local pos = mouseClick - active.Parent.AbsolutePosition - active.AbsoluteSize/2
					if Settings.LayoutMode('Scale') then
						pos = pos/active.Parent.AbsoluteSize
						active.Position = UDim2.new(pos.x,0,pos.y,0)
					else
						active.Position = UDim2.new(0,pos.x,0,pos.y)
					end

					--------
					-- temporary fix for adapting size based on layout mode
					-- remove when implementing user-templates
					if Settings.LayoutMode('Scale') then
						local size = active.AbsoluteSize/active.Parent.AbsoluteSize
						object.Size = UDim2.new(size.x,0,size.y,0)
					end
					--------

					Selection:Set{object}
					setObjects({active},active)
				end
			end;
			OnRelease = function()
				conCanvas:disconnect()
				dragGhost:Destroy()
				ActionManager:StartAction('Default')
			end;
		},Canvas.CanvasFrame,false,false,true)
	end
end
