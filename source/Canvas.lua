--[[Canvas
Provides basic services for interacting with and manipulating a GUI.
When started, the Canvas binds to a ScreenGui (referred to as "save" copy).
It then replicates the save copy to the "active" copy. This is a representation of the
save copy that can be interacted with by the user.
Changes to the save copy are detected, and the active copy is synchronized accordingly.
This includes property changes and additions, removals, and changes to the hierarchy.

API:
	Canvas.CurrentScreen            The current ScreenGui the Canvas is bound to
	Canvas.CanvasFrame              The GuiObject instance representing the Canvas
	Canvas.ActiveLookup             Save-to-active lookup table
	Canvas.SaveLookup               Active-to-save lookup table
	Canvas.GlobalButton             A representation of every button in the canvas
	ServiceStatus.Status            Whether the service is started or not

	Canvas:Start(screen)            Starts the service with a ScreenGui to bind to
	Canvas:Stop()                   Stops the service, unbinding from the current screen
	                                This
	Canvas:Restart(screen)          Restarts the service with a ScreenGui to bind to
	                                This really just does a Stop(), then a Start()
	!Canvas:LockObject(object)      Prevents an active object from synchronizing
	                                with its save counterpart, allowing it to be manipluated.
	                                `object` is a save object, not an active object.
	!Canvas:ReleaseObject(object)   Releases a locked object, allowing it to synchronize again.
	                                When the object is released, the save object is updated
	                                to reflect any changes made to the active object.
	Canvas:WaitForObject(object)    Wait until an object has been added to the canvas.
	                                Returns the object's corresponding active object.

	Canvas.Started(screen)          Fired after the Canvas starts
	                                Used to start other services that require the Canvas
	Canvas.Stopping(screen)         Fired before the Canvas stops
	                                Used to stop other services that require the Canvas to be started
	Canvas.Stopped(screen)          Fired after the Canvas stops
	                                This can probably be removed in favor of Canvas.Stopping,
	                                unless there are services that require the Canvas to be stopped before stopping
	Canvas.ObjectAdded              Fired after an object is added to the Canvas.
	                                Passes the object and its active counterpart.
	Canvas.ObjectRemoving           Fired before an object is removed from the Canvas.
]]
do
	local CurrentScreen
	local CanvasFrame = Create'ImageButton'{}
	local NullScreenLabel = Create'TextLabel'{
		Name = "NullScreenLabel";
		Size = UDim2.new(1,0,1,0);
		BackgroundTransparency = 1;
		Text = "(no screen)";
		FontSize = "Size48";
		TextColor3 = Color3.new(0,0,0);
		TextStrokeColor3 = Color3.new(1,1,1);
		TextStrokeTransparency = 0;
		Parent = CanvasFrame;
	};

	local ActiveLookup = {} -- [CurrentScreen] = CanvasFrame
	local SaveLookup = {} -- [CanvasFrame] = CurrentScreen

	Canvas = {
		CurrentScreen      = CurrentScreen;
		CanvasFrame        = CanvasFrame;
		ActiveLookup       = ActiveLookup;
		SaveLookup         = SaveLookup;
		Replicate          = true;
	}
	local Canvas = Canvas

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

	local globalEventMT = {
		__index = {
			connect = function(self,listener)
				table.insert(self,listener)
				return {
					disconnect = function()
						for i,v in pairs(self) do
							if v == listener then
								table.remove(self,i)
							end
						end
					end;
				}
			end;
		};
	}
	local function globalEvent()
		return setmetatable({},globalEventMT)
	end

	Canvas.GlobalButton = {
		MouseButton1Click	= globalEvent();
		MouseButton1Down	= globalEvent();
		MouseButton1Up		= globalEvent();
		MouseButton2Click	= globalEvent();
		MouseButton2Down	= globalEvent();
		MouseButton2Up		= globalEvent();
		MouseEnter			= globalEvent();
		MouseLeave			= globalEvent();
		MouseMoved			= globalEvent();
	}

	local function connectButton(save,active,button)
		for event,global in pairs(Canvas.GlobalButton) do
			button[event]:connect(function(...)
				for _,listener in pairs(global) do
					listener(save,active,...)
				end
			end)
		end
	end

	local function makeActiveCopy(saveObject)
		if ActiveLookup[saveObject] == nil then
			local saveParent = saveObject.Parent
			local activeParent = ActiveLookup[saveParent]
			if activeParent then
				local activeObject = saveObject:Clone()
				activeObject:ClearAllChildren()
				local button = buttonTemplate:Clone()
					button.Archivable = false
					button.Parent = activeObject
					connectButton(saveObject,activeObject,button)
				ActiveLookup[saveObject] = activeObject
				SaveLookup[activeObject] = saveObject
				activeObject.Parent = activeParent
				return activeObject
			end
		end
	end

	local eventObjectAdded = CreateSignal(Canvas,'ObjectAdded')
	local eventObjectRemoving = CreateSignal(Canvas,'ObjectRemoving')

	local conAdded,conRemoved
	local conChangedLookup = {}

	local function saveAdded(saveObject)
		if not CurrentScreen:IsAncestorOf(saveObject) then return end
		if saveObject:IsA"GuiBase" then
			local activeObject = makeActiveCopy(saveObject)
			if not activeObject then
				print("ACTIVE OBJECT NOT FOUND!",tick())
				print('---- OBJECT:',saveObject)
				print('---- PARENT:',saveObject.Parent)
				print('---- ACTIVE PARENT:',ActiveLookup[saveObject.Parent])
			end
			conChangedLookup[saveObject] = saveObject.Changed:connect(function(p)
				if p == "Parent" and CurrentScreen:IsAncestorOf(saveObject) then
					activeObject.Parent = ActiveLookup[saveObject.Parent]
				elseif excludedProp[p:lower()] == nil then
					local v = saveObject[p]
					activeObject[p] = v
				end
			end)
			eventObjectAdded:Fire(saveObject,activeObject)
		end
	end

	local function saveRemoving(saveObject)
		if not saveObject:IsDescendantOf(CurrentScreen) then return end
		local activeObject = ActiveLookup[saveObject]

		eventObjectRemoving:Fire(saveObject,activeObject)

		local changed = conChangedLookup[saveObject]
		if changed then
			changed:disconnect()
			conChangedLookup[saveObject] = nil
		end
		if activeObject then
			ActiveLookup[saveObject] = nil
			SaveLookup[activeObject] = nil
			activeObject.Parent = nil
		end
	end

	function Canvas:WaitForObject(object)
		while ActiveLookup[object] == nil do
			Canvas.ObjectAdded:wait()
		end
		return ActiveLookup[object]
	end

	local StarterGui = Game:GetService("StarterGui")
	local eventStarted = CreateSignal(Canvas,'Started')
	local eventStopped = CreateSignal(Canvas,'Stopped')
	local eventStopping = CreateSignal(Canvas,'Stopping')

	local conScreenChanged
	local function screenChanged()
	--  if not CurrentScreen:IsDescendantOf(Game) then
		if not CurrentScreen:IsDescendantOf(StarterGui) then -- bug #1
			Canvas:Stop()
		end
	end

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

			conScreenChanged = CurrentScreen.AncestryChanged:connect(screenChanged)

			NullScreenLabel.Parent = nil

			local descendants = {}
			r(CurrentScreen,descendants)

			ActiveLookup[CurrentScreen] = CanvasFrame
			SaveLookup[CanvasFrame] = CurrentScreen
			local button = buttonTemplate:Clone()
				button.Archivable = false
				button.Parent = CanvasFrame
				connectButton(CurrentScreen,CanvasFrame,button)

			conAdded = StarterGui.DescendantAdded:connect(saveAdded)
			conRemoved = StarterGui.DescendantRemoving:connect(saveRemoving)

			for i,descendant in pairs(descendants) do
				saveAdded(descendant)
			end

			eventStarted:Fire(CurrentScreen)
		end;
		Stop = function()
			eventStopping:Fire(screen)
			local function clear(t)
				for k in pairs(t) do t[k] = nil end
			end
			conScreenChanged:disconnect(); conScreenChanged = nil
			conAdded:disconnect(); conAdded = nil
			conRemoved:disconnect(); conRemoved = nil
			for object,con in pairs(conChangedLookup) do
				con:disconnect()
				conChangedLookup[object] = nil
			end
			for save,active in pairs(ActiveLookup) do
				ActiveLookup[save] = nil
				SaveLookup[active] = nil
				if active ~= CanvasFrame then
					active:Destroy()
				end
			end
			clear(ActiveLookup)
			local screen = CurrentScreen
			CurrentScreen = nil
			Canvas.CurrentScreen = nil
			CanvasFrame:ClearAllChildren()
			eventStopped:Fire(screen)
			NullScreenLabel.Parent = CanvasFrame
		end;
	};

	function Canvas:Restart(container)
		self:Stop()
		self:Start(container)
	end
end
