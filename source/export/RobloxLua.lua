--[[Export Format: RobloxLua
Objects are defined in Lua, using good-old-fashioned set-every-single-property-manually style.

Options:
	bool IgnoreDefault
		If true, properties with default values will not be included.

	bool Indent
		If true, child objects will be indented.

	bool ParentLast
		If true, the Parent of an object will be defined after its properties.
		If false, it is defined first.

	bool UseName
		If true, the Name of the object will be used as the variable name. Example:
		false:
			object1 = Instance.new("Frame")
			object1.Name = "Derp"
		true:
			Derp = Instance.new("Frame")
			Derp.Name = "Derp"

		If multiple instances use the same name, an incremented number will be appended to the variable.
			Derp
			Derp1
			Derp2
			etc
]]

do
	local formatName = 'RobloxLua'

	local dataTypeFormat do
		local format = string.format
		-- formats a number, handling any anomalies
		local function num(n,t)
			if n == math.huge then
				return "math.huge"
			elseif n ~= n then
				return "0/0"
			else
				return format(t or "%g",n)
			end
		end

		dataTypeFormat = {
			--[[default]] function(v)
				return tostring(v)
			end;
			['bool'] = function(v)
				return tostring(v)
			end;
			['int'] = function(v)
				return num(v,"%i")
			end;
			['float'] = function(v)
				return num(v)
			end;
			['string'] = function(v)
				return format("%q",v)
			end;
			['Content'] = function(v)
				return format("%q",v)
			end;
			['Color3'] = function(v)
				-- values are converted to a more useable format
				return format(
					"Color3.new(%s/255,%s/255,%s/255)",
					num(math.floor(v.r*255)),
					num(math.floor(v.g*255)),
					num(math.floor(v.b*255))
				)
			end;
			['Vector2'] = function(v)
				return format(
					"Vector2.new(%s,%s)",
					num(v.x),
					num(v.y)
				)
			end;
			['Vector3'] = function(v)
				return format(
					"Vector3.new(%s,%s,%s)",
					num(v.x),
					num(v.y),
					num(v.z)
				)
			end;
			['Vector2int16'] = function(v)
				return format(
					"Vector2int16.new(%s,%s,%s)",
					num(v.x),
					num(v.y),
					num(v.z)
				)
			end;
			['UDim2'] = function(v)
				return format(
					"UDim2.new(%s,%s,%s,%s)",
					num(v.X.Scale),
					num(v.X.Offset),
					num(v.Y.Scale),
					num(v.Y.Offset)
				)
			end;
		}
	end

	local function formatMethod(object,options,typeFormat,lengthLimit)
		local InstanceAPI = Exporter.InstanceAPI
		local defaultCache = Exporter.DefaultCache
		local output = ""
		local rep = string.rep
		local tab = 0
		local tabStr = options.Indent and "\t" or ""
		local objCount = 0
		local objName = options.VariableName or "object"
		local objectVars = {}

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

		local function r(object,parentVar)
			local className = object.ClassName
			if InstanceAPI[className] then
				local objVar = options.UseName and object.Name or objName
				if objectVars[objVar] then
					local n = objectVars[objVar] + 1
					objectVars[objVar] = n
					objVar = objVar .. n
				else
					objectVars[objVar] = 0
				end
				local t = rep(tabStr,tab)
				output = output .. t .. objVar .. " = Instance.new(\"" .. className .. "\"".. (parentVar and not options.ParentLast and (", " .. parentVar) or "") .. ")\n"
				if #output > limit then return end
				local set = InstanceAPI[className][1]
				if options.IgnoreDefault then
					local defaultInstance = defaultCache[className]
					if not defaultInstance then
						defaultInstance = Instance.new(className)
						defaultCache[className] = defaultInstance
					end
					for i,name in pairs(InstanceAPI[className][2]) do
						local value = object[name]
						if value ~= defaultInstance[name] then
							output = output .. t .. tabStr .. objVar .. "." .. name .. " = " .. (typeFormat[set[name]] or typeFormat[1])(value) .. "\n"
							if #output > limit then return end
						end
					end
				else
					for i,name in pairs(InstanceAPI[className][2]) do
						output = output .. t .. tabStr .. objVar .. "." .. name .. " = " .. (typeFormat[set[name]] or typeFormat[1])(object[name]) .. "\n"
						if #output > limit then return end
					end
				end
				if parentVar and options.ParentLast then
					output = output .. t .. tabStr .. objVar .. ".Parent = " .. parentVar .. "\n"
					if #output > limit then return end
				end
				tab = tab + 1
				for i,child in pairs(object:GetChildren()) do
					r(child,objVar)
				end
				tab = tab - 1
				mwait()
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
		       Indent = {  'bool',    false, "Whether child objects will be indented."};
		   ParentLast = {  'bool',    false, "If true, the Parent of an object will be defined after its properties."};
		      UseName = {  'bool',    false, "If true, the Name of an object is used as its variable name."};
		 VariableName = {'string', "object", "The base name of each variable"};
	}

	Exporter:AddFormat(formatName,formatMethod,dataTypeFormat,formatOptions)
end
