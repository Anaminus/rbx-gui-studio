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
	Selection:Add(object)                       Adds an object to the selection.
	Selection:Remove(object)                    Removes an object from the selection.
	Selection:Contains(object)                  Returns whether an object is selected.
	                                            Only works with objects in the container the Canvas is bound to.
	Selection:Start()                           Starts the service.
	Selection:Stop()                            Stops the service.

	Selection.ObjectSelected(object,active)     Fired after an object is selected, passing the object and its active object
	Selection.ObjectDeselected(object,active)   Fired after an object is deselected
]]
local Selection do
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
		Size = UDim2.new(1,1,1,1);
		Position = UDim2.new(0,-1,0,-1);
		Transparency = 1;
		Create'Frame'{ -- top
			BackgroundColor3 = color;
			BorderSizePixel = 0;
			Size = UDim2.new(1,0,0,1);
		};
		Create'Frame'{ -- right
			BackgroundColor3 = color;
			BorderSizePixel = 0;
			Size = UDim2.new(0,1,1,0);
			Position = UDim2.new(1,0,0,0);
		};
		Create'Frame'{ -- bottom
			BackgroundColor3 = color;
			BorderSizePixel = 0;
			Size = UDim2.new(1,0,0,1);
			Position = UDim2.new(0,0,1,0);
		};
		Create'Frame'{ -- left
			BackgroundColor3 = color;
			BorderSizePixel = 0;
			Size = UDim2.new(0,1,1,0);
		};
	}

	local function filter(v)
		return v:IsA"GuiObject" and Canvas.ActiveLookup[v]
	end

	local eventObjectSelected = CreateSignal(Selection,'ObjectSelected')
	local eventObjectDeselected = CreateSignal(Selection,'ObjectDeselected')

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
		--	print("---- DESELECT",object)
			SelectedObjectsSet[object] = nil
			removeValue(SelectedObjects,object)

			local select_frame = SelectFrameLookup[object]
			if select_frame then
				SelectFrameLookup[object] = nil
				select_frame:Destroy()
			end

			eventObjectDeselected:Fire(object,Canvas.ActiveLookup[object])
		end
		for object in pairs(selected) do
		--	print("---- SELECT",object)
			local active = Canvas.ActiveLookup[object]

			local select_frame = selectTemplate:Clone()
			select_frame.Archivable = false
			select_frame.Parent = active
			SelectFrameLookup[object] = select_frame

			SelectedObjectsSet[object] = true
			SelectedObjects[#SelectedObjects+1] = object

			eventObjectSelected:Fire(object,active)
		end
	end

	function Selection:Add(object)
		local s = SelectionService:Get()
		s[#s+1] = object
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

	local conChanged
	AddServiceStatus{Selection;
		Start = function()
			conChanged = SelectionService.SelectionChanged:connect(updateSelection)
			updateSelection()
		end;
		Stop = function()
			conChanged:disconnect()
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
