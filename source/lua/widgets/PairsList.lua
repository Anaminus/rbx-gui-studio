--[[PairsList
Displays a table of values in a scrollable list. Entries in the list be edited.
]]

function Widgets.PairsList(entryPairs,entryToolTips)
	local entryGuis = {}
	local keyLookup = {}
	local entryGuiValues = {}
	local entryTypes = {}

	local GuiColor = InternalSettings.GuiColor
	local scrollingContainer = Widgets.ScrollingContainer()

	local Class = {
		GUI = scrollingContainer.GUI;
		Pairs = entryPairs;
		ToolTipLookup = entryToolTips;
	}

	local height = 20

	scrollingContainer.VScroll.PageIncrement = height
	scrollingContainer.HScroll.PageIncrement = height

	local Container = scrollingContainer.Container

	local stackingFrame = Widgets.StackingFrame(Container)
	stackingFrame.Border = 2

	local entryTemplate = Create'Frame'{
		Name = "ListEntry";
		Active = true;
		BackgroundColor3 = GuiColor.Field;
		BorderColor3 = GuiColor.FieldBorder;
		Size = UDim2.new(1,-4,0,height);
		Create'TextLabel'{
			Name = "Key";
			BackgroundColor3 = GuiColor.Field;
			BorderColor3 = GuiColor.FieldBorder;
			Position = UDim2.new(0,0,0,0);
			Size = UDim2.new(0.5,0,1,0);
			TextColor3 = GuiColor.Text;
			TextXAlignment = 'Left';
			FontSize = 'Size10';
		};
		Create'Frame'{
			Name = "Value";
			BackgroundColor3 = GuiColor.Field;
			BorderColor3 = GuiColor.FieldBorder;
			Position = UDim2.new(0.5,0,0,0);
			Size = UDim2.new(0.5,0,1,0);
		};
	}

	local createGuiValue = {
		['boolean'] = function(key,value)
			local entry = Create'TextButton'{
				Name = "CheckBox";
				BackgroundColor3 = GuiColor.Field;
				BorderColor3 = GuiColor.FieldBorder;
				Position = UDim2.new(0, 2, 0, 2);
				Size = UDim2.new(1, -4, 1, -4);
				SizeConstraint = Enum.SizeConstraint.RelativeYY;
				ZIndex = 10;
				Selected = value;
				Text = value and "X" or "";
				TextColor3 = GuiColor.Text;
				FontSize = Enum.FontSize.Size14;
				Font = Enum.Font.ArialBold;
			}

			entry.MouseButton1Click:connect(function()
				Class:Set(key,not entry.Selected)
			end)
			entry.Changed:connect(function(p)
				if p == 'Selected' then
					entry.Text = entry.Selected and "X" or ""
				end
			end)

			return entry
		end;
		['number'] = function(key,value)
			local entry = Create'TextBox'{
				Name = "NumberInput";
				BackgroundTransparency = 1;
				BackgroundColor3 = GuiColor.Field;
				BorderColor3 = GuiColor.FieldBorder;
				Position = UDim2.new(0, 2, 0, 2);
				Size = UDim2.new(1, -4, 1, -4);
				ZIndex = 10;
				TextColor3 = GuiColor.Text;
				TextXAlignment = 'Left';
				FontSize = Enum.FontSize.Size9;
			}

			entry.Text = string.format('%g',value)

			Widgets.MaskedTextBox(entry,function(textBox,text)
				local value = EvaluateInput(text)
				if value then
					Class:Set(key,value)
				end
			end)

			return entry
		end;
		['string'] = function(key,value)
			local entry = Create'TextBox'{
				Name = "TextBox";
				BackgroundTransparency = 1;
				BackgroundColor3 = GuiColor.Field;
				BorderColor3 = GuiColor.FieldBorder;
				Position = UDim2.new(0, 2, 0, 2);
				Size = UDim2.new(1, -4, 1, -4);
				ZIndex = 10;
				TextColor3 = GuiColor.Text;
				TextXAlignment = 'Left';
				FontSize = Enum.FontSize.Size9;
			}

			entry.Text = value

			entry.FocusLost:connect(function()
				Class:Set(key,entry.Text)
			end)

			return entry
		end;
	}

	local updateGuiValue = {
		['boolean'] = function(entry,value)
			entry.Selected = value;
		end;
		['number'] = function(entry,value)
			entry.Text = string.format('%g',value);
		end;
		['string'] = function(entry,value)
			entry.Text = value;
		end;
	}

--[[
	value	current value
	tvalue	type of current value
	prev	type of previous value

	create	add an entry to the list
	destroy	remove an entry from the list
	update	update the value of the entry
	null	do nothing


	create:
		if tvalue == primative
			add entry of type tvalue to list

	destroy:
		if entry exists
			remove entry from list

	update:
		if tvalue == prev
			set entry value to new value
		elseif tvalue ~= prev
			destroy
			create

	for a given key:
		if value == nil
			if prev == nil
				null
			elseif prev ~= nil
				destroy
		elseif value ~= nil
			if prev == nil
				create
			elseif prev ~= nil
				update

]]

	local eventPairChanged = CreateSignal(Class,'PairChanged')

	local function createEntry(key,value,noevent)
		if not entryTypes[key] then
			local tvalue = type(value)
			if createGuiValue[tvalue] then
				local entryGui = entryTemplate:Clone()
				local entryGuiKey = entryGui:GetChildren()[1]
				local entryGuiValue = createGuiValue[tvalue](key,value)

				entryGuiKey.Text = ' ' .. key
				entryGuiValue.Parent = entryGui:GetChildren()[2]

				if Class.ToolTipLookup then
					ToolTipService:AddToolTip(entryGui,Class.ToolTipLookup[key])
				end
				SetZIndex(entryGui,Container.ZIndex)
				stackingFrame:AddObject(entryGui)

				entryGuis[key] = entryGui
				keyLookup[entryGui] = key
				entryGuiValues[key] = entryGuiValue
				entryTypes[key] = tvalue
				if not noevent then
					eventPairChanged:Fire(key,value)
				end
			end
		end
	end

	local function destroyEntry(key,noevent)
		if entryTypes[key] then
			keyLookup[entryGuis[key]] = nil
			stackingFrame:RemoveObject(entryGuis[key])
			entryGuis[key]:Destroy()
			entryGuis[key] = nil

			entryGuiValues[key]:Destroy()
			entryGuiValues[key] = nil

			entryTypes[key] = nil
			if not noevent then
				eventPairChanged:Fire(key,nil)
			end
		end
	end

	local function updateEntry(key,value)
		local tvalue = type(value)
		local prev = entryTypes[key]
		if tvalue == prev then
			if updateGuiValue[tvalue] then
				updateGuiValue[tvalue](entryGuiValues[key],value)
			end
		else
			destroyEntry(key,true)
			createEntry(key,value,true)
		end
		eventPairChanged:Fire(key,value)
	end

	local function updateEntryValue(key,value)
		if type(key) == 'string' then
			local prev = entryTypes[key]
			if value == nil then
				if prev == nil then
					-- do nothing
				else
					destroyEntry(key)
				end
			else
				if prev == nil then
					createEntry(key,value)
				else
					updateEntry(key,value)
				end
			end
		end
	end

	function Class:Update(key)
		if key then
			updateEntryValue(key,self.Pairs[key])
		else
			for key in pairs(entryTypes) do
				updateEntryValue(key,self.Pairs[key])
			end
			for key,value in pairs(self.Pairs) do
				updateEntryValue(key,value)
			end
		end
	end

	function Class:Set(key,value)
		self.Pairs[key] = value
		self:Update(key)
	end

	function Class:Sort()
		local list = stackingFrame.List
		table.sort(list,function(a,b)
			a = keyLookup[a]
			b = keyLookup[b]
			return a < b
		end)
		stackingFrame:Update()
	end

	Class:Update()
	Class:Sort()


	SetZIndexOnChanged(Class.GUI)
	Class.GUI.ZIndex = 10

	do
		function Class:Destroy()
			stackingFrame:Destroy()
			for key in pairs(entryTypes) do
				keyLookup[entryGuis[key]] = nil

				entryGuis[key]:Destroy()
				entryGuis[key] = nil

				entryGuiValues[key]:Destroy()
				entryGuiValues[key] = nil

				entryTypes[key] = nil
			end
			eventPairChanged:Destroy()
			scrollingContainer:Destroy()
		end
	end
	return Class
end
