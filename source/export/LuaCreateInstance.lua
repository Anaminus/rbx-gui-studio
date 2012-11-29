--[[Export Format: LuaCreateInstance
Objects are defined in Lua, using Stravant's Create function.

Options:
	bool IgnoreDefault
		If true, properties with default values will not be included.

	bool ExcludeFunction
		If true, the Create function will not be included in the export string.

	string FunctionName
		The name of the Create function. Defaults to "Create".

]]

do
	local formatName = 'LuaCreateInstance'

	local dataTypeFormat = Exporter.DataTypeFormat.RobloxLua

	local function formatMethod(object,options,typeFormat,lengthLimit)
		local InstanceAPI = Exporter.InstanceAPI
		local defaultCache = Exporter.DefaultCache
		local funcName = (options.FunctionName or "Create")
		local output = (options.ExcludeFunction and "" or
([[local function ]]..funcName..[[(ty)
	return function(data)
		local obj = Instance.new(ty)
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

]]))

		local limit = lengthLimit or math.huge
		-- maybe wait
		-- wait only if the export time for the current frame is greater than 1/30 seconds
		local mwait
		if lengthLimit then
			function mwait()end
		else
			local start = tick()
			function mwait()
				if tick()-start > 1/20 then
					start = tick()
					wait()
				end
			end
		end

		local rep = string.rep
		local tab = 0
		local function r(object)
			local className = object.ClassName
			if InstanceAPI[className] then
				local t = rep('\t',tab)
				output = output .. t .. funcName .. "'" .. className .. "'{\n"
				if #output > limit then return end
				local set = InstanceAPI[className][1]
				local list = InstanceAPI[className][2]
				local empty = true
				if options.IgnoreDefault then
					local defaultInstance = defaultCache[className]
					if not defaultInstance then
						defaultInstance = Instance.new(className)
						defaultCache[className] = defaultInstance
					end
					for i,name in pairs(InstanceAPI[className][2]) do
						local value = object[name]
						if value ~= defaultInstance[name] then
							empty = false
							output = output .. t .. '\t' .. name .. " = " .. (typeFormat[set[name]] or typeFormat[1])(value) .. ";\n"
							if #output > limit then return end
						end
					end
				else
					for i,name in pairs(InstanceAPI[className][2]) do
						empty = false
						output = output .. t .. '\t' .. name .. " = " .. (typeFormat[set[name]] or typeFormat[1])(object[name]) .. ";\n"
						if #output > limit then return end
					end
				end
				tab = tab + 1
				for i,child in pairs(object:GetChildren()) do
					if r(child) then
						empty = false
					end
				end
				tab = tab - 1
				if empty then
					output = output:sub(1,-2) .. "};\n"
				else
					output = output .. t .. "};\n"
				end
				if #output > limit then return end
				mwait()
				return true
			end
		end
		r(object)
		if lengthLimit then
			output = output:sub(1,lengthLimit)
		end
		return output
	end

	local formatOptions = {
		  IgnoreDefault = {  'bool',    false, "If true, properties with default values are excluded."};
		ExcludeFunction = {  'bool',    false, "If true, the Create function will not be defined."};
		   FunctionName = {'string', "Create", "The name of the Create function."};
	};

	Exporter:AddFormat(formatName,formatMethod,dataTypeFormat,formatOptions)
end
