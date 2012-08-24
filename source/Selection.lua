--[[
handles selection of GUIs the Canvas is bound to
when Selection service selects a GUI, it's corresponding active object in Canvas is highlighted
API:
	Selection.SelectedObjects                  A set of selected objects
	Selection.SelectFrameLookup                object-to-select lookup table
	ServiceStatus.Status                       whether the service is started

	Selection:Start()                          Starts the service
	Selection:Stop()                           Stops the service

	Selection.ObjectSelected(object,select)    Fired after an object is selected, passing the object and the highlighting frame
	Selection.ObjectDeselected(object,select)  Fired before an object is deselected
]]
local Selection do
	local SelectionService = Game:GetService("Selection")
	local SelectedObjects = {}
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
		for object in pairs(SelectedObjects) do
			deselected[object] = true
		end
		for i,object in pairs(SelectionService:Get()) do
			if SelectedObjects[object] then
				deselected[object] = nil -- object is still selected
			elseif filter(object) then
				selected[object] = true -- object is newly selected
			end
		end
		for object in pairs(deselected) do
		--	print("---- DESELECT",object)
			SelectedObjects[object] = nil
			local select_frame = SelectFrameLookup[object]
			if select_frame then
				eventObjectDeselected:Fire(object,select_frame)
				SelectFrameLookup[object] = nil
				select_frame:Destroy()
			end
		end
		for object in pairs(selected) do
		--	print("---- SELECT",object)
			local select_frame = selectTemplate:Clone()
			SelectFrameLookup[object] = select_frame
			select_frame.Archivable = false
			select_frame.Parent = Canvas.ActiveLookup[object]
			SelectedObjects[object] = true
			eventObjectSelected:Fire(object,select_frame)
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

	local conChanged
	AddServiceStatus{Selection;
		Start = function()
			conChanged = SelectionService.SelectionChanged:connect(updateSelection)
			updateSelection()
		end;
		Stop = function()
			conChanged:disconnect()
			for k in pairs(SelectedObjects) do
				SelectedObjects[k] = nil
			end
			for object,select_frame in pairs(SelectFrameLookup) do
				eventObjectDeselected:Fire(object,select_frame)
				SelectFrameLookup[object] = nil
				select_frame:Destroy()
			end
		end;
	}
end
