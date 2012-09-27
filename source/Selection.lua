--[[Selection
Handles selection of GUIs the Canvas is bound to.
When Selection service selects a save object, it's corresponding active object in Canvas is highlighted.

API:
	Selection.SelectedObjects                   A list of objects that are currently selected (don't edit).
	                                            Only contains objects in the container the Canvas is bound to.
	Selection.SelectFrameLookup                 Gets the selection highlight frame from a selected object.
	ServiceStatus.Status                        whether the service is started.

	Selection:Get()                             Returns a copy of Selecton.SelectedObjects.
	Selection:Set(objects)                      Sets the selection to a list of objects.
	                                            Same as the Selection service's Set.
	Selection:Add(objects)                      Adds one or more objects to the selection.
	Selection:Remove(object)                    Removes an object from the selection.
	Selection:Contains(object)                  Returns whether an object is selected.
	                                            Only works with objects in the container the Canvas is bound to.
	Selection:Start()                           Starts the service.
	Selection:Stop()                            Stops the service.

	Selection.ObjectSelected(object,active)     Fired after an object is selected, passing the object and its active object
	Selection.ObjectDeselected(object,active)   Fired after an object is deselected
]]
do
	local SelectionService = Game:GetService("Selection")
	local SelectedObjects = {}
	local SelectedObjectsSet = {}
	local SelectFrameLookup = {}

	Selection = {
		SelectedObjects = SelectedObjects;
		SelectFrameLookup = SelectFrameLookup;
	}

	local color = Color3.new(1,0,0)
	local selectTemplate = Create'Frame'{
		Name = "Select";
		Size = UDim2.new(1,0,1,0);
		Transparency = 1;
		Create'Frame'{ -- top
			Name = "Top";
			BackgroundColor3 = color;
			BorderSizePixel = 0;
			Position = UDim2.new(0,-3,0,-3);
			Size = UDim2.new(1,6,0,1);
		};
		Create'Frame'{ -- right
			Name = "Right";
			BackgroundColor3 = color;
			BorderSizePixel = 0;
			Position = UDim2.new(1,2,0,-2);
			Size = UDim2.new(0,1,1,4);
		};
		Create'Frame'{ -- bottom
			Name = "Bottom";
			BackgroundColor3 = color;
			BorderSizePixel = 0;
			Position = UDim2.new(0,-3,1,2);
			Size = UDim2.new(1,6,0,1);
		};
		Create'Frame'{ -- left
			Name = "Left";
			BackgroundColor3 = color;
			BorderSizePixel = 0;
			Position = UDim2.new(0,-3,0,-3);
			Size = UDim2.new(0,1,1,5);
		};
		Create'Frame'{
			Name = "Border";
			Transparency = 1;
			Size = UDim2.new(1,0,1,0);
			-- outer border
			Create'Frame'{ -- top
				Name = "Outer Top";
				BackgroundColor3 = Color3.new(0,0,0);
				BackgroundTransparency = 0.5;
				BorderSizePixel = 0;
				Position = UDim2.new(0,-4,0,-4);
				Size = UDim2.new(1,8,0,1);
			};
			Create'Frame'{ -- right
				Name = "Outer Right";
				BackgroundColor3 = Color3.new(0,0,0);
				BackgroundTransparency = 0.5;
				BorderSizePixel = 0;
				Position = UDim2.new(1,3,0,-3);
				Size = UDim2.new(0,1,1,6);
			};
			Create'Frame'{ -- bottom
				Name = "Outer Bottom";
				BackgroundColor3 = Color3.new(0,0,0);
				BackgroundTransparency = 0.5;
				BorderSizePixel = 0;
				Position = UDim2.new(0,-4,1,3);
				Size = UDim2.new(1,8,0,1);
			};
			Create'Frame'{ -- left
				Name = "Outer Left";
				BackgroundColor3 = Color3.new(0,0,0);
				BackgroundTransparency = 0.5;
				BorderSizePixel = 0;
				Position = UDim2.new(0,-4,0,-3);
				Size = UDim2.new(0,1,1,6);
			};
			-- inner border
			Create'Frame'{ -- top
				Name = "Inner Top";
				BackgroundColor3 = Color3.new(0,0,0);
				BackgroundTransparency = 0.5;
				BorderSizePixel = 0;
				Position = UDim2.new(0,-2,0,-2);
				Size = UDim2.new(1,4,0,1);
			};
			Create'Frame'{ -- right
				Name = "Inner Right";
				BackgroundColor3 = Color3.new(0,0,0);
				BackgroundTransparency = 0.5;
				BorderSizePixel = 0;
				Position = UDim2.new(1,1,0,-1);
				Size = UDim2.new(0,1,1,2);
			};
			Create'Frame'{ -- bottom
				Name = "Inner Bottom";
				BackgroundColor3 = Color3.new(0,0,0);
				BackgroundTransparency = 0.5;
				BorderSizePixel = 0;
				Position = UDim2.new(0,-2,1,1);
				Size = UDim2.new(1,4,0,1);
			};
			Create'Frame'{ -- left
				Name = "Inner Left";
				BackgroundColor3 = Color3.new(0,0,0);
				BackgroundTransparency = 0.5;
				BorderSizePixel = 0;
				Position = UDim2.new(0,-2,0,-1);
				Size = UDim2.new(0,1,1,2);
			};
		};
	}

	local function layoutChanged(key,value)
		if key == 'LayoutMode' then
			if value('Offset') then
				local offsetModeColor = InternalSettings.OffsetModeColor
				for _,frame in pairs(SelectFrameLookup) do
					for i,v in pairs(frame:GetChildren()) do
						v.BackgroundColor3 = offsetModeColor
					end
				end
				for i,v in pairs(selectTemplate:GetChildren()) do
					v.BackgroundColor3 = offsetModeColor
				end
			else
				local scaleModeColor = InternalSettings.ScaleModeColor
				for _,frame in pairs(SelectFrameLookup) do
					for i,v in pairs(frame:GetChildren()) do
						v.BackgroundColor3 = scaleModeColor
					end
				end
				for i,v in pairs(selectTemplate:GetChildren()) do
					v.BackgroundColor3 = scaleModeColor
				end
			end
		end
	end

	Settings.Changed:connect(layoutChanged)
	layoutChanged('LayoutMode',Settings.LayoutMode)

	local activeLookup = Canvas.ActiveLookup

	local function filter(v)
		return v:IsA"GuiObject" and activeLookup[v]
	end

	local eventObjectSelected = CreateSignal(Selection,'ObjectSelected')
	local eventObjectDeselected = CreateSignal(Selection,'ObjectDeselected')

	-- remove all instances of a value from a list
	local function removeValue(list,value)
		local i,n = 0,#list
		while i <= n do
			if list[i] == value then
				table.remove(list,i)
				n = n - 1
			else
				i = i + 1
			end
		end
	end

	local function updateSelection()
		local selected = {}
		local deselected = {}
		for object in pairs(SelectedObjectsSet) do
			deselected[object] = true
		end
		for i,object in pairs(SelectionService:Get()) do
			if SelectedObjectsSet[object] then
				deselected[object] = nil -- object is still selected
			elseif filter(object) then
				selected[object] = true -- object is newly selected
			end
		end
		for object in pairs(deselected) do
			SelectedObjectsSet[object] = nil
			removeValue(SelectedObjects,object)

			local select_frame = SelectFrameLookup[object]
			if select_frame then
				SelectFrameLookup[object] = nil
				select_frame:Destroy()
			end

			eventObjectDeselected:Fire(object,activeLookup[object])
		end
		for object in pairs(selected) do
			local active = activeLookup[object]

			local select_frame = selectTemplate:Clone()
			select_frame.Archivable = false
			select_frame.Parent = active
			SelectFrameLookup[object] = select_frame

			SelectedObjectsSet[object] = true
			SelectedObjects[#SelectedObjects+1] = object

			eventObjectSelected:Fire(object,active)
		end
	end

	function Selection:Add(objects)
		if type(objects) ~= 'table' then
			objects = {objects}
		end
		local s = SelectionService:Get()
		local n = #s
		for i = 1,#objects do
			s[n+i] = objects[i]
		end
		SelectionService:Set(s)
	end

	function Selection:Remove(object)
		local s = SelectionService:Get()
		removeValue(s,object)
		SelectionService:Set(s)
	end

	function Selection:Get()
		local s = {}
		for i = 1,#SelectedObjects do
			s[i] = SelectedObjects[i]
		end
		return s
	end

	function Selection:Set(...)
		SelectionService:Set(...)
	end

	function Selection:Contains(object)
		return not not SelectedObjectsSet[object]
	end

	local conChanged,conScope
	AddServiceStatus{Selection;
		Start = function(self)
			conChanged = SelectionService.SelectionChanged:connect(updateSelection)
			conScope = Scope.ScopeChanged:connect(function(scope)
				-- changing the scope deselects everything
				self:Set{}
			end)
			updateSelection()
		end;
		Stop = function()
			conChanged:disconnect()
			conScope:disconnect()
			for k in pairs(SelectedObjectsSet) do
				SelectedObjectsSet[k] = nil
			end
			for i in pairs(SelectedObjects) do
				SelectedObjects[i] = nil
			end
			for object,select_frame in pairs(SelectFrameLookup) do
				eventObjectDeselected:Fire(object,select_frame)
				SelectFrameLookup[object] = nil
				select_frame:Destroy()
			end
		end;
	}
end
