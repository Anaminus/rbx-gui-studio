--[[
Synchronizes a container to the canvas
API:
	Canvas.CurrentScreen    The current ScreenGui the Canvas is bound to
	Canvas.CanvasFrame      The Frame instance representing the Canvas
	Canvas.ActiveLookup     save-to-active lookup table
	Canvas.SaveLookup       active-to-save lookup table
	Canvas.ButtonLookup     save-to-button lookup table
	ServiceStatus.Status    whether the service is started or not

	Canvas:Start(screen)    starts the service with a ScreenGui to bind to
	Canvas:Stop()           stops the service
	Canvas:Restart(screen)  restarts the service with a ScreenGui to bind to

	Canvas.Started(screen)  Fired after the Canvas starts
]]
local Canvas do
	local CurrentScreen = Game:GetService("StarterGui")
	local CanvasFrame = Instance.new("Frame")
	local ActiveLookup = {} -- [CurrentScreen] = CanvasFrame
	local SaveLookup = {}   -- [CanvasFrame] = CurrentScreen
	local ButtonLookup = {} -- [CurrentScreen.Frame] = CanvasFrame.Frame.Button

	Canvas = {
		CurrentScreen      = CurrentScreen;
		CanvasFrame        = CanvasFrame;
		ActiveLookup       = ActiveLookup;
		SaveLookup         = SaveLookup;
		ButtonLookup       = ButtonLookup;
		Replicate          = true;
	}

	local excludedProp = {
	-- read-only properties
		-- Instance
		"ClassName";
		"DataCost";
		"RobloxLocked";
		-- GuiBase
		"AbsolutePosition";
		"AbsoluteSize";
		-- GuiBase hidden
		"ReplicatingAbsoluteSize";
		"ReplicatingAbsolutePosition";
		-- GuiText
		"TextBounds";
		"TextFits";
	}

	for i = 1, #excludedProp do
		excludedProp[excludedProp[i]:lower()] = true
		excludedProp[i] = nil
	end

	local buttonTemplate = Create'ImageButton'{
		Name = "ActiveButton";
		Size = UDim2.new(1,0,1,0);
		Active = true;
		Transparency = 1;
	}

	local function makeActiveCopy(saveObject)
		if ActiveLookup[saveObject] == nil then
			local saveParent = saveObject.Parent
			local activeParent = ActiveLookup[saveParent]
			if activeParent then
				local activeObject = saveObject:Clone()
				activeObject:ClearAllChildren()
				local button = buttonTemplate:Clone()
					ButtonLookup[saveObject] = button
					button.Archivable = false
					button.Parent = activeObject
				ActiveLookup[saveObject] = activeObject
				SaveLookup[activeObject] = saveObject
				activeObject.Parent = activeParent
				return activeObject
			end
		end
	end

	local conAdded,conRemoved
	local conChangedLookup = {}

	local function saveAdded(saveObject)
		if saveObject:IsA"GuiBase" then
			local activeObject = makeActiveCopy(saveObject)
			if not activeObject then
				print("ACTIVE OBJECT NOT FOUND!",tick())
				print('---- OBJECT:',saveObject)
				print('---- PARENT:',saveObject.Parent)
				print('---- ACTIVE PARENT:',ActiveLookup[saveObject.Parent])
			end
			conChangedLookup[saveObject] = saveObject.Changed:connect(function(p)
				if Canvas.Replicate then
					if p == "Parent" and CurrentScreen:IsAncestorOf(saveObject) then
						activeObject.Parent = ActiveLookup[saveObject.Parent]
					elseif excludedProp[p:lower()] == nil then
						local v = saveObject[p]
						activeObject[p] = v
					end
				end
			end)
		end
	end

	local function saveRemoving(saveObject)
		local changed = conChangedLookup[saveObject]
		if changed then
			changed:disconnect()
			conChangedLookup[saveObject] = nil
		end
		local activeObject = ActiveLookup[saveObject]
		if activeObject then
			ActiveLookup[saveObject] = nil
			SaveLookup[activeObject] = nil
			activeObject:Destroy()
		end
	end

	local function loadActiveObject(saveObject)
		for i,saveChild in pairs(saveObject:GetChildren()) do
			if saveChild:IsA"GuiBase" then
				makeActiveCopy(saveChild)
				loadActiveObject(saveChild)
			end
		end
	end

	local eventStarted = Instance.new("BinableEvent")
	Canvas.Started = eventStarted.Event

	AddServiceStatus{Canvas;
		Start = function(self,container)
			local function r(object,list)
				for i,child in pairs(object:GetChildren()) do
					list[#list+1] = child
					r(child,list)
				end
			end

			if container then
				CurrentScreen = container
				Canvas.CurrentScreen = container
			end
			if not CurrentScreen then error("Canvas: CurrentScreen not defined",2) end

			local descendants = {}
			r(CurrentScreen,descendants)

			ActiveLookup[CurrentScreen] = CanvasFrame
			SaveLookup[CanvasFrame] = CurrentScreen

			conAdded = CurrentScreen.DescendantAdded:connect(saveAdded)
			conRemoved = CurrentScreen.DescendantRemoving:connect(saveRemoving)

			for i,descendant in pairs(descendants) do
				saveAdded(descendant)
			end

			eventStarted:Fire(CurrentScreen)
		end;
		Stop = function()
			local function clear(t)
				for k in pairs(t) do t[k] = nil end
			end
			conAdded:disconnect()
			conRemoved:disconnect()
			for object,con in pairs(conChangedLookup) do
				con:disconnect()
				conChangedLookup[object] = nil
			end
			for k in pairs(SaveLookup) do
				SaveLookup[k] = nil
			end
			for save,button in pairs(ButtonLookup) do
				ButtonLookup[save] = nil
				button:Destroy()
			end
			for save,active in pairs(ActiveLookup) do
				ActiveLookup[save] = nil
				if active ~= CanvasFrame then
					active:Destroy()
				end
			end
			clear(ActiveLookup)
		end;
	};

	function Canvas:Restart(container)
		self:Stop()
		self:Start(container)
	end
end
