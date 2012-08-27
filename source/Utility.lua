local function Create(ty)
	return function(data)
		local obj
		if type(ty) == 'string' then
			obj = Instance.new(ty)
		else
			obj = ty
		end
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local function Class(ctor)
	return function(...)
		local def = {}
		ctor(def, ...)
		return def
	end
end

local Status = {
	Stopped = 0;
	Started = 1;
	Starting = 2;
	Stopping = 3;
}

local function AddServiceStatus(data)
	local service = data[1]
	local start = data.Start
	local stop = data.Stop
	service.Status = Status.Stopped
	service.Start = function(...)
		if service.Status == Status.Stopped then
			service.Status = Status.Starting
			start(...)
			service.Status = Status.Started
		end
	end
	service.Stop = function(...)
		if service.Status == Status.Started then
			service.Status = Status.Stopping
			stop(...)
			service.Status = Status.Stopped
		end
	end
end

local function CreateSignal(instance,name)
	local event = Instance.new("BindableEvent")
	instance[name] = event.Event
	return event
end

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

local function GetScreen(screen)
	if screen == nil then return nil end
	while not screen:IsA("ScreenGui") do
		screen = screen.Parent
		if screen == nil then return nil end
	end
	return screen
end

local EventManager_mt = {
	__index = {
		disconnect = function(self,...)
			for _,name in pairs{...} do
				if self[name] then
					self[name]:disconnect()
					self[name] = nil
				end
			end
		end;
		clear = function(self)
			for name in pairs(self) do
				self[name]:disconnect()
				self[name] = nil
			end
		end;
	};
}
local function CreateEventManager()
	return setmetatable({},EventManager_mt)
end
