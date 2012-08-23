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
