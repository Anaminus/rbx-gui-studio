--[[
Synchronizes a container to the canvas
save: the saved copy of the object; the *actual* object
active: the representation of the save object on the canvas
API:
	Canvas.CurrentScreen     the current ScreenGui the Canvas is bound to
	Canvas.CanvasFrame       the Frame instance representing the Canvas
	Canvas.ActiveLookup      save-to-active lookup table
	Canvas.GlobalButton      a representation of every button
	ServiceStatus.Status     whether the service is started or not

	Canvas:Start(screen)     starts the service with a ScreenGui to bind to
	Canvas:Stop()            stops the service
	Canvas:Restart(screen)   restarts the service with a ScreenGui to bind to

	Canvas.Started(screen)   fired after the Canvas starts
	Canvas.Stopping(screen)  fired before the Canvas stops
	Canvas.Stopped(screen)   fired after the Canvas stops
]]
local Canvas do
	local CurrentScreen
	local CanvasFrame = Create'ImageButton'{
		Create'TextLabel'{
			Name = "NullScreenLabel";
			Size = UDim2.new(1,0,1,0);
			BackgroundTransparency = 1;
			Text = "(no screen)";
			FontSize = "Size48";
			TextColor3 = Color3.new(0,0,0);
			TextStrokeColor3 = Color3.new(1,1,1);
			TextStrokeTransparency = 0;
		};
	}
	local NullScreenLabel = CanvasFrame.NullScreenLabel

	local ActiveLookup = {} -- [CurrentScreen] = CanvasFrame

	Canvas = {
		CurrentScreen      = CurrentScreen;
		CanvasFrame        = CanvasFrame;
		ActiveLookup       = ActiveLookup;
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
				activeObject.Parent = activeParent
				return activeObject
			end
		end
	end

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
		if not CurrentScreen:IsAncestorOf(saveObject) then return end
		local changed = conChangedLookup[saveObject]
		if changed then
			changed:disconnect()
			conChangedLookup[saveObject] = nil
		end
		local activeObject = ActiveLookup[saveObject]
		if activeObject then
			ActiveLookup[saveObject] = nil
			activeObject.Parent = nil
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

	local StarterGui = Game:GetService("StarterGui")
	local eventStarted = CreateSignal(Canvas,'Started')
	local eventStopped = CreateSignal(Canvas,'Stopped')
	local eventStopping = CreateSignal(Canvas,'Stopping')

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

			NullScreenLabel.Visible = false

			local descendants = {}
			r(CurrentScreen,descendants)

			ActiveLookup[CurrentScreen] = CanvasFrame

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
			conAdded:disconnect()
			conRemoved:disconnect()
			for object,con in pairs(conChangedLookup) do
				con:disconnect()
				conChangedLookup[object] = nil
			end
			for save,active in pairs(ActiveLookup) do
				ActiveLookup[save] = nil
				if active ~= CanvasFrame then
					active:Destroy()
				end
			end
			clear(ActiveLookup)
			local screen = CurrentScreen
			CurrentScreen = nil
			Canvas.CurrentScreen = nil
			eventStopped:Fire(screen)
			NullScreenLabel.Visible = true
		end;
	};

	function Canvas:Restart(container)
		self:Stop()
		self:Start(container)
	end
end
