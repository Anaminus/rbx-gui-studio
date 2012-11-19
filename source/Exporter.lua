--[[Exporter
Serializes an Instance into a string, in a given format.

Arguments:
	object
		The Instance to export.

	format
		The format to which the object will be exported. An ExportFormat enum:

		Lua
			Objects are defined in Lua, using good-old-fashioned

		LuaCreateInstance
			Objects are defined in Lua, using Stravant's Create function.

		RobloxXML
			The XML format used by Roblox when saving places and models.

	options
		A table of options to futher control the result. May be different depending on the chosen format.

		Global (any format):

			bool IgnoreDefault
				If true, properties with default values will not be included.

		Lua:

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

			string VariableName
				If UseName is false, this is the base name to use for each variable. Defaults to "object".

		LuaCreateInstance:

			bool ExcludeFunction
				If true, the Create function will not be included in the export string.

			string FunctionName
				The name of the Create function. Defaults to "Create".

		RobloxXML:

Returns:
	string
		The string containing the serialized data.
		This value will be nil if an error has occured. The error message is printed to the output.
]]

do
	local ObjectAPI do
		local properties = { -- not hidden, not readonly, not deprecated
			BillboardGui = {
				"GuiBase";
				Active = "bool";
				Adornee = "Object";
				AlwaysOnTop = "bool";
				Enabled = "bool";
				ExtentsOffset = "Vector3";
				PlayerToHideFrom = "Object";
				Size = "UDim2";
				SizeOffset = "Vector2";
				StudsOffset = "Vector3";
			};
			Frame = {
				"GuiObject";
				Style = "FrameStyle";
			};
			GuiBase = {"Instance"};
			GuiButton = {
				"GuiObject";
				AutoButtonColor = "bool";
				Modal = "bool";
				Selected = "bool";
				Style = "ButtonStyle";
			};
			GuiLabel = {"GuiObject"};
			GuiMain = {"ScreenGui"};
			GuiObject = {
				"GuiBase";
				Active = "bool";
				BackgroundColor3 = "Color3";
				BackgroundTransparency = "float";
				BorderColor3 = "Color3";
				BorderSizePixel = "int";
				ClipsDescendants = "bool";
				Draggable = "bool";
				Position = "UDim2";
				Size = "UDim2";
				SizeConstraint = "SizeConstraint";
				Visible = "bool";
				ZIndex = "int";
			};
			ImageButton = {
				"GuiButton";
				Image = "Content";
			};
			ImageLabel = {
				"GuiLabel";
				Image = "Content";
			};
			Instance = {
				Archivable = "bool";
				Name = "string";
			};
			NotificationBox = {"GuiObject"};
			NotificationObject = {"Frame"};
			Scale9Frame = {
				"GuiObject";
				ScaleEdgeSize = "Vector2int16";
				SlicePrefix = "string";
			};
			ScreenGui = {"GuiBase"};
			TextBox = {
				"GuiObject";
				ClearTextOnFocus = "bool";
				Font = "Font";
				FontSize = "FontSize";
				MultiLine = "bool";
				Text = "string";
				TextColor3 = "Color3";
				TextScaled = "bool";
				TextStrokeColor3 = "Color3";
				TextStrokeTransparency = "float";
				TextTransparency = "float";
				TextWrapped = "bool";
				TextXAlignment = "TextXAlignment";
				TextYAlignment = "TextYAlignment";
			};
			TextButton = {
				"GuiButton";
				Font = "Font";
				FontSize = "FontSize";
				Text = "string";
				TextColor3 = "Color3";
				TextScaled = "bool";
				TextStrokeColor3 = "Color3";
				TextStrokeTransparency = "float";
				TextTransparency = "float";
				TextWrapped = "bool";
				TextXAlignment = "TextXAlignment";
				TextYAlignment = "TextYAlignment";
			};
			TextLabel = {
				"GuiLabel";
				Font = "Font";
				FontSize = "FontSize";
				Text = "string";
				TextColor3 = "Color3";
				TextScaled = "bool";
				TextStrokeColor3 = "Color3";
				TextStrokeTransparency = "float";
				TextTransparency = "float";
				TextWrapped = "bool";
				TextXAlignment = "TextXAlignment";
				TextYAlignment = "TextYAlignment";
			};
		}

		ObjectAPI = {}

		for name,class in pairs(properties) do
			local p = {}
			local c = class
			while c do
				p[#p+1] = c
				c = properties[c[1]]
			end
			local o = {{},{},{}}
			local set = o[1]
			local list = o[2]
			local alphalist = o[3]
			for i=#p,1,-1 do
				local sort = {}
				for k,v in pairs(p[i]) do
					if k ~= 1 then
						sort[#sort+1] = k
						set[k] = v
					end
				end
				table.sort(sort,function(a,b)
					return set[a] > set[b]
				end)
				for i=1,#sort do
					list[#list+1] = sort[i]
					alphalist[#alphalist+1] = sort[i]
				end
			end
			table.sort(alphalist)
			ObjectAPI[name] = o
		end
	end

	local DataTypeFormat = {}

	do
		local format = string.format
		local function num(n,t)
			if n == math.huge then
				return "math.huge"
			elseif n ~= n then
				return "0/0"
			else
				return format(t or "%g",n)
			end
		end

		DataTypeFormat.Lua = {
			   --[[default]]   function(v) return tostring(v) end;
			        ['bool'] = function(v) return tostring(v) end;
			         ['int'] = function(v) return num(v,"%i") end;
			       ['float'] = function(v) return num(v) end;
			      ['string'] = function(v) return format("%q",v) end;
			     ['Content'] = function(v) return format("%q",v) end;
			      ['Color3'] = function(v) return format("Color3.new(%s/255,%s/255,%s/255)",num(math.floor(v.r*255)),num(math.floor(v.g*255)),num(math.floor(v.b*255))) end;
			     ['Vector2'] = function(v) return format("Vector2.new(%s,%s)",num(v.x),num(v.y)) end;
			     ['Vector3'] = function(v) return format("Vector3.new(%s,%s,%s)",num(v.x),num(v.y),num(v.z)) end;
			['Vector2int16'] = function(v) return format("Vector2int16.new(%s,%s,%s)",num(v.x),num(v.y),num(v.z)) end;
			       ['UDim2'] = function(v) return format("UDim2.new(%s,%s,%s,%s)",num(v.X.Scale),num(v.X.Offset),num(v.Y.Scale),num(v.Y.Offset)) end;
		}
	end

	DataTypeFormat.LuaCreateInstance = DataTypeFormat.Lua

	do
		local format = string.format
		local function num(n,t)
			if n == math.huge then
				return "INF"
			elseif n ~= n then
				return "NAN"
			else
				return format(t or '%g',n)
			end
		end

		local escapeString do
			local namedEntity = {
				['"'] = "&quot;";
				["&"] = "&amp;";
				["'"] = "&apos;";
				["<"] = "&lt;";
				[">"] = "&gt;";
			}

			local noEscape = {} do
				local chars = "\010\013 !#$%()*+,-./0123456789:;=?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
				for i = 1,#chars do
					noEscape[chars:sub(i,i)] = true
				end
			end

			function escapeString(s)
				local o = ""
				for i = 1,#s do
					local c = s:sub(i,i)
					if namedEntity[c] then
						c = namedEntity[c]
					elseif not noEscape[c] then
						c = "&#"..c:byte()..";"
					end
					o = o .. c
				end
				return o
			end
		end

		local function validUrl(s)
			if #s > 0 then
				local p = s:match("^(.-)://")
				if p == 'rbxasset' or p == 'http' or p == 'https' then
					return true
				end
			end
			return false
		end

		DataTypeFormat.RobloxXML = {
				   --[[default]]   function(v) return tostring(v) end;
				       ['token'] = function(v) return v.Value end;
				        ["bool"] = function(v) return tostring(v) end;
				         ["int"] = function(v) return num(v,'%i') end;
				       ["float"] = function(v) return num(v,'%.9g') end;
				      ["string"] = function(v) return escapeString(v) end;
				     ["Content"] = function(v) if validUrl(v) then return "<url>"..escapeString(v).."</url>" else return "<null></null>" end end;
				      ["Color3"] = function(v) return format("%u",tonumber(format("0xFF%X%X%X",math.floor(v.r*255),math.floor(v.g*255),math.floor(v.b*255)))) end;
				     ["Vector2"] = function(v,t) return "\n"..t.."\t<X>"..num(v.x,'%.9g').."</X>\n"..t.."\t<Y>"..num(v.y,'%.9g').."</Y>\n"..t end;
				     ["Vector3"] = function(v,t) return "\n"..t.."\t<X>"..num(v.x,'%.9g').."</X>\n"..t.."\t<Y>"..num(v.y,'%.9g').."</Y>\n"..t.."\t<Z>"..num(v.z,'%.9g').."</Z>\n"..t end;
				["Vector2int16"] = function(v,t) return "\n"..t.."\t<X>"..num(v.x,'%i').."</X>\n"..t.."\t<Y>"..num(v.y,'%i').."</Y>\n"..t end;
				       ["UDim2"] = function(v,t) return "\n"..t.."\t<XS>"..num(v.X.Scale,'%.9g').."</XS>\n"..t.."\t<XO>"..num(v.X.Offset,'%i').."</XO>\n"..t.."\t<YS>"..num(v.Y.Scale,'%.9g').."</YS>\n"..t.."\t<YO>"..num(v.Y.Offset,'%i').."</YO>\n"..t end;
		}
	end

	local optionsMeta = {
		{
			IgnoreDefault = {'bool', false, ""};
		};
		Lua = {
			      Indent = {  'bool',    false, "Whether child objects will be indented."};
			  ParentLast = {  'bool',    false, "If true, the Parent of an object will be defined after its properties."};
			     UseName = {  'bool',    false, "If true, the Name of an object is used as its variable name."};
			VariableName = {'string', "object", "The base name of each variable"};
		};
		LuaCreateInstance = {
			ExcludeFunction = {  'bool',    false, "If true, the Create function will not be defined."};
			   FunctionName = {'string', "Create", "The name of the Create function."};
		};
		RobloxXML = {};
	}

	local exportMethod = {
		['Lua'] = function(object,options,typeFormat)
			local output = ""
			local rep = string.rep
			local tab = 0
			local tabStr = options.Indent and "\t" or ""
			local objCount = 0
			local objName = options.VariableName or "object"
			local objectVars = {}
			local function r(object,parentVar)
				local className = object.ClassName
				if ObjectAPI[className] then
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
					local set = ObjectAPI[className][1]
					if options.IgnoreDefault then
						local defaultInstance = defaultCache[className]
						if not defaultInstance then
							defaultInstance = Instance.new(className)
							defaultCache[className] = defaultInstance
						end
						for i,name in pairs(ObjectAPI[className][2]) do
							local value = object[name]
							if value ~= defaultInstance[name] then
								output = output .. t .. tabStr .. objVar .. "." .. name .. " = " .. (typeFormat[set[name]] or typeFormat[1])(value) .. "\n"
							end
						end
					else
						for i,name in pairs(ObjectAPI[className][2]) do
							output = output .. t .. tabStr .. objVar .. "." .. name .. " = " .. (typeFormat[set[name]] or typeFormat[1])(object[name]) .. "\n"
						end
					end
					if parentVar and options.ParentLast then
						output = output .. t .. tabStr .. objVar .. ".Parent = " .. parentVar .. "\n"
					end
					tab = tab + 1
					for i,child in pairs(object:GetChildren()) do
						r(child,objVar)
					end
					tab = tab - 1
				end
			end
			r(object)
			return output
		end;
		['LuaCreateInstance'] = function(object,options,typeFormat)
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

]])) .. "GUI ="
			local rep = string.rep
			local tab = 0
			local function r(object)
				local className = object.ClassName
				if ObjectAPI[className] then
					local t = rep('\t',tab)
					output = output .. t .. funcName .. "'" .. className .. "'{\n"
					local set = ObjectAPI[className][1]
					local list = ObjectAPI[className][2]
					local empty = true
					if options.IgnoreDefault then
						local defaultInstance = defaultCache[className]
						if not defaultInstance then
							defaultInstance = Instance.new(className)
							defaultCache[className] = defaultInstance
						end
						for i,name in pairs(ObjectAPI[className][2]) do
							local value = object[name]
							if value ~= defaultInstance[name] then
								empty = false
								output = output .. t .. '\t' .. name .. " = " .. (typeFormat[set[name]] or typeFormat[1])(value) .. ";\n"
							end
						end
					else
						for i,name in pairs(ObjectAPI[className][2]) do
							empty = false
							output = output .. t .. '\t' .. name .. " = " .. (typeFormat[set[name]] or typeFormat[1])(object[name]) .. ";\n"
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
					return true
				end
			end
			r(object)
			return output
		end;
		['RobloxXML'] = function(object,options,typeFormat)
			local output =
[[<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
	<External>null</External>
	<External>nil</External>
]]
			local rep = string.rep
			local tab = 1
			local ref = 0
			local function r(object)
				local className = object.ClassName
				if ObjectAPI[className] then
					local t = rep('\t',tab)
					local tt = t .. '\t'
					local ttt = tt .. '\t'
					output = output .. t .. "<Item class=\""..className.."\" referent=\"RBX"..ref.."\">\n"
					output = output .. tt .. "<Properties>\n"
					local set = ObjectAPI[className][1]

					local defaultInstance = defaultCache[className]
					if not defaultInstance then
						defaultInstance = Instance.new(className)
						defaultCache[className] = defaultInstance
					end
					for i,name in pairs(ObjectAPI[className][3]) do
						if name ~= "Archivable" or options.UseArchivable then
							local value = object[name]
							if not options.IgnoreDefault or value ~= defaultInstance[name] then
								local type = set[name]
								if not typeFormat[type] then
									type = 'token'
								end
								output = output .. ttt .. "<" .. type .. " name=\"" .. name .. "\">"
								output = output .. (typeFormat[type] or typeFormat[1])(value,ttt)
								output = output .. "</" .. type .. ">\n"
							end
						end
					end
					output = output .. tt .. "</Properties>\n"
					tab = tab + 1
					for i,child in pairs(object:GetChildren()) do
						ref = ref + 1
						r(child)
					end
					tab = tab - 1
					output = output .. t .. "</Item>\n"
				end
			end
			r(object)
			return output .. [[</roblox>]]
		end;
	}

	function Exporter(object,format,options)
		local data,err = exportMethod[format](object,options or {},DataTypeFormat[format])
		if not data then
			print("Exporter:",err)
		end
		return data
	end
end
