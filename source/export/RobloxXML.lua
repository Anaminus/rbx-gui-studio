--[[Export Format: RobloxXML
The XML format used by Roblox when saving places and models.

Options:
	bool IgnoreDefault
		If true, properties with default values will not be included.

	bool UseArchivable
		If true, the Archivable property will be written (it's not by default).

]]

do
	local formatName = 'RobloxXML'

	local dataTypeFormat do
		local format = string.format
		-- formats a number, handling any anomalies
		local function num(n,t)
			if n == math.huge then
				return "INF"
			elseif n ~= n then
				return "NAN"
			else
				return format(t or '%g',n)
			end
		end

		-- escapes a string so it can be written to XML
		local escapeString do
			-- some characters are escaped with specific named entities
			local namedEntity = {
				['"'] = "&quot;";
				["&"] = "&amp;";
				["'"] = "&apos;";
				["<"] = "&lt;";
				[">"] = "&gt;";
			}

			-- some characters don't need to be escaped
			local noEscape = {} do
				local chars = "\010\013 !#$%()*+,-./0123456789:;=?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
				for i = 1,#chars do
					noEscape[chars:sub(i,i)] = true
				end
			end

			function escapeString(s)
				local o = {}
				for i = 1,#s do
					local c = s:sub(i,i)
					if namedEntity[c] then
						c = namedEntity[c]
					elseif not noEscape[c] then
						-- any other characters are escaped using their decimal value
						c = "&#"..c:byte()..";"
					end
					o[i] = c
				end
				return table.concat(o)
			end
		end

		-- returns whether a Content string is a valid URL
		local function validUrl(s)
			if #s > 0 then
				local p = s:match("^(.-)://")
				if p == 'rbxasset' or p == 'rbxassetid' or p == 'http' or p == 'rbxhttp' or p == 'https' then
					-- NOTE: roblox does not properly validate rbxhttp or rbxassetid (1UP'd yo)
					return true
				end
			end
			return false
		end

		dataTypeFormat = {
			--[[default]] function(v)
				return tostring(v)
			end;
			['token'] = function(v)
				-- value is an Enum
				return v.Value
			end;
			["bool"] = function(v)
				return tostring(v)
			end;
			["int"] = function(v)
				return num(v,'%i')
			end;
			["float"] = function(v)
				return num(v,'%.9g')
			end;
			["string"] = function(v)
				return escapeString(v)
			end;
			["Content"] = function(v)
				if validUrl(v) then
					return "<url>"..escapeString(v).."</url>"
				else
					return "<null></null>"
				end
			end;
			["Color3"] = function(v)
				-- Roblox's XML writer converts Color3 to an unsigned integer
				-- though <R><G><B> tags (floats) are also acceptable
				return format("%u",
					tonumber(
						format(
							"0xFF%X%X%X",
							math.floor(v.r*255),
							math.floor(v.g*255),
							math.floor(v.b*255)
						)
					)
				)
			end;
			["Vector2"] = function(v,t)
				return "\n"
					..t.."\t<X>"..num(v.x,'%.9g').."</X>\n"
					..t.."\t<Y>"..num(v.y,'%.9g').."</Y>\n"
					..t
			end;
			["Vector3"] = function(v,t)
				return "\n"
					..t.."\t<X>"..num(v.x,'%.9g').."</X>\n"
					..t.."\t<Y>"..num(v.y,'%.9g').."</Y>\n"
					..t.."\t<Z>"..num(v.z,'%.9g').."</Z>\n"
					..t
			end;
			["Vector2int16"] = function(v,t)
				return "\n"
					..t.."\t<X>"..num(v.x,'%i').."</X>\n"
					..t.."\t<Y>"..num(v.y,'%i').."</Y>\n"
					..t
			end;
			["UDim2"] = function(v,t)
				return "\n"
					..t.."\t<XS>"..num( v.X.Scale,'%.9g').."</XS>\n"
					..t.."\t<XO>"..num(v.X.Offset,  '%i').."</XO>\n"
					..t.."\t<YS>"..num( v.Y.Scale,'%.9g').."</YS>\n"
					..t.."\t<YO>"..num(v.Y.Offset,  '%i').."</YO>\n"
					..t
			end;
		}
	end

	local function formatMethod(object,options,typeFormat,lengthLimit)
		local InstanceAPI = Exporter.InstanceAPI
		local defaultCache = Exporter.DefaultCache
		local output =
[[<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
	<External>null</External>
	<External>nil</External>
]]

		local limit = lengthLimit or math.huge
		-- maybe wait
		-- wait only if the export time for the current frame is greater than 1/30 seconds
		local mwait
		if lengthLimit then
			function mwait()end
		else
			local start = tick()
			function mwait()
				if tick()-start > 1/30 then
					start = tick()
					wait()
				end
			end
		end

		local rep = string.rep
		local tab = 1
		local ref = 0
		local function r(object)
			local className = object.ClassName
			if InstanceAPI[className] then
				local t = rep('\t',tab)
				local tt = t .. '\t'
				local ttt = tt .. '\t'
				output = output .. t .. "<Item class=\""..className.."\" referent=\"RBX"..ref.."\">\n"
				output = output .. tt .. "<Properties>\n"
				if #output > limit then return end
				local set = InstanceAPI[className][1]

				local defaultInstance = defaultCache[className]
				if not defaultInstance then
					defaultInstance = Instance.new(className)
					defaultCache[className] = defaultInstance
				end
				for i,name in pairs(InstanceAPI[className][3]) do
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
							if #output > limit then return end
						end
					end
				end
				output = output .. tt .. "</Properties>\n"
				if #output > limit then return end
				tab = tab + 1
				for i,child in pairs(object:GetChildren()) do
					ref = ref + 1
					r(child)
				end
				tab = tab - 1
				output = output .. t .. "</Item>\n"
				if #output > limit then return end
				mwait()
			end
		end
		r(object)
		output = output .. [[</roblox>]]
		if lengthLimit then
			output = output:sub(1,lengthLimit)
		end
		return output
	end

	local formatOptions = {
		IgnoreDefault = {'bool', false, "If true, properties with default values are excluded."};
		UseArchivable = {'bool', false, "If true, the Archivable property of objects will be written."};
	};

	Exporter:AddFormat(formatName,formatMethod,dataTypeFormat,formatOptions)
end
