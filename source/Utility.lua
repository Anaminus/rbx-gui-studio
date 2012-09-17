local InternalSettings = {
	GuiButtonSize = 22;
	GuiWidgetSize = 16;
}

-- Sets the properties of a new or existing Instance using values from a table.
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

--Gets a descendant of an object by child order
local function Descendant(object,...)
	local children = object:GetChildren()
	for i,v in pairs{...} do
		object = children[v]
		if not object then return nil end
		children = object:GetChildren()
	end
	return object
end

local function Preload(content)
	Game:GetService('ContentProvider'):Preload(content)
	return content
end

--[[Enums, CreateEnum
A system for custom enums.

API:
	CreateEnum(string)(table)    Returns a new enum. This Enum is also added to the Enums table.

	Enums[string]                Returns an Enum.

	Enum.EnumItemName            Gets an EnumItem.
	EnumItem:GetEnumItems()      Returns a list of the Enum's EnumItems.
	Enum(value)                  Returns the EnumItem that matches the value, by the EnumItem, or its Name or Value.
	                             Returns nil if no match is found.

	EnumItem.Name                The name of the EnumItem.
	EnumItem.Value               The EnumItem's Value.
	EnumItem(value)              Returns whether the value matches the EnumItem, or its Name or Value.
]]
local Enums,CreateEnum do
	Enums = {}
	local EnumName = {} -- used as unique key for enum name
	local enum_mt = {
		__call = function(self,value)
			return self[value] or self[tonumber(value)]
		end;
		__index = {
			GetEnumItems = function(self)
				local t = {}
				for i,item in pairs(self) do
					if type(i) == 'number' then
						t[#t+1] = item
					end
				end
				table.sort(t,function(a,b) return a.Value < b.Value end)
				return t
			end;
		};
		__tostring = function(self)
			return "Enum." .. self[EnumName]
		end;
	}
	local item_mt = {
		__call = function(self,value)
			return value == self or value == self.Name or value == self.Value
		end;
		__tostring = function(self)
			return "Enum." .. self[EnumName] .. "." .. self.Name
		end;
	}
	function CreateEnum(enumName)
		return function(t)
			local e = {[EnumName] = enumName}
			for i,name in pairs(t) do
				local item = setmetatable({Name=name,Value=i,Enum=e,[EnumName]=enumName},item_mt)
				e[i] = item
				e[name] = item
				e[item] = item
			end
			Enums[enumName] = e
			return setmetatable(e,enum_mt)
		end
	end
end

-- Adds values to a class that enable it to be started and stopped.
CreateEnum'ServiceStatus'{'Stopped','Started','Starting','Stopping'}
local function AddServiceStatus(data)
	local service = data[1]
	local start = data.Start
	local stop = data.Stop
	service.Status = Enums.ServiceStatus.Stopped
	service.Start = function(...)
		if Enums.ServiceStatus.Stopped(service.Status) then
			service.Status = Enums.ServiceStatus.Starting
			start(...)
			service.Status = Enums.ServiceStatus.Started
		end
	end
	service.Stop = function(...)
		if Enums.ServiceStatus.Started(service.Status) then
			service.Status = Enums.ServiceStatus.Stopping
			stop(...)
			service.Status = Enums.ServiceStatus.Stopped
		end
	end
end

local function CreateSignal(instance,name)
	local connections = {}
	local waitEvent = Instance.new('BoolValue')
	local waitArguments = {} -- holds arguments from Fire to be returned by event:wait()

	local Event = {}
	local Invoker = {Event = Event}

	function Event:connect(func)
		local connection = {connected = true}
		function connection:disconnect()
			for i = 1,#connections do
				if connections[i][2] == self then
					table.remove(connections,i)
					break
				end
			end
			self.connected = false
		end
		connections[#connections+1] = {func,connection}
		return connection
	end

	function Event:wait()
		waitEvent.Changed:wait()
		return unpack(waitArguments) -- leaky
	end

	function Invoker:Fire(...)
		waitArguments = {...}
		waitEvent.Value = not waitEvent.Value
		for i,conn in pairs(connections) do
			conn[1](...)
		end
	end

	function Invoker:Destroy()
		instance[name] = nil
		for k in pairs(Event) do
			Event[k] = nil
		end
		for k in pairs(Invoker) do
			Invoker[k] = nil
		end
		for i in pairs(connections) do
			connections[i] = nil
		end
		for i in pairs(waitArguments) do
			waitArguments[i] = nil
		end
		waitEvent:Destroy()
	end

	instance[name] = Event
	return Invoker
end

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

-- returns the ascendant ScreenGui of an object
local function GetScreen(screen)
	if screen == nil then return nil end
	while not screen:IsA("ScreenGui") do
		screen = screen.Parent
		if screen == nil then return nil end
	end
	return screen
end

-- gets a list of all ScreenGuis in an object
local function GetScreens(object,list)
	list = list or {}
	if object:IsA("ScreenGui") and object ~= Screen then
		list[#list+1] = object
	end
	for i,child in pairs(object:GetChildren()) do
		GetScreens(child,list)
	end
	return list
end

--[[CreateEventManager
API:
	EventManager[key] = (event connection)    Adds an event connection to the manager.
	EventManager:disconnect(...)              Disconnects one or more events.
	EventManager:clear()                      Disconnects all events.
]]
local CreateEventManager do
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
	function CreateEventManager()
		return setmetatable({},EventManager_mt)
	end
end
