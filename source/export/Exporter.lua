--[[Exporter
Serializes an Instance into a string, in a given format.

API:
	Exporter.DataTypeFormat
		A table of string/table pairs, exposing the type formatters for each export format.
		Each key is the name of an export format.
		Each value corresponds to the `types` argument of the AddFormat method.

	Exporter.FormatMethod
		A table of string/function pairs, containing the functions for exporting to a specific format.
		Each key is the format name, and each function is the method for exporting to that format.

	Exporter.DefaultCache
		A table where Instances may be cached, which are used for determining the default value of a property.

	Exporter.InstanceAPI
		A table of string/table pairs, used for getting the properties of an Instance.
		Each key is the name of an Instance, and each value contains the following entries:
			[1]
				A table of string/string pairs.
				Each key is the name of the property, and each value is the value type of the property.
			[2]
				A list of property names, sorted in a specific way.
				Properties are sorted by most primative class, then by value type, then by name.
			[3]
				A list of property names, sorted alphabetically.

	Exporter:AddFormat(name,method,types,options)
		Adds a new format to the exporter.

		Arguments:
			string `name`
				The name of the format.

			function `method` (object,options,types)
				The function that does the formatting.
				object:  The Instance to be exported.
				options: The options that have been specified.
				types:   Same as the `types` table.
				This function should return the final exported string.
				If an error occurs, this function can return nil, followed by an error string.

			table `types`
				A table of string/function pairs.
				Each string is the name of a value type, and each function converts that type into a string.
				The arguments passed to each function is implemented in the `method` function.

			table `options`
				A table of the possible options available for the format.
				The table consists of string/table pairs. Each key is an option name.
				Each value should contain the following entries:
					[1]
						The value type of the option.
					[2]
						The default value.
					[3]
						A short description of the option.

	Exporter:Export(object,format,options,limit)
		Serializes an object into a string using a specified format.

		Arguments:
			Instance `object`
				The object to be exported.

			string `format`
				The name of the format to use.

			table `options`
				A table of options to use for the format.

			number `limit`
				Optional. Limits the amount of characters in the resulting string.
				Used to prevent unecessary processing while getting the preview string.

		Returns:
			string `exported_string`
				The final serialized string.
				This value may be nil, in which case an error has occurred.
]]
do
	Exporter = {
		DefaultCache = {};
		DataTypeFormat = {};
		FormatMethod = {};
		FormatOptions = {};
	}

	 do -- InstanceAPI
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

		local InstanceAPI = {}

		for name,class in pairs(properties) do
			local p = {}
			local c = class
			while c do
				-- get each superclass of this class
				p[#p+1] = c
				c = properties[c[1]]
			end
			local o = {{},{},{}}
			local set = o[1]
			local list = o[2]
			local alphalist = o[3]
			for i=#p,1,-1 do
			-- order properties by most primative class first
				local sort = {}
				for k,v in pairs(p[i]) do
					if k ~= 1 then
						sort[#sort+1] = k
						set[k] = v
					end
				end
				table.sort(sort,function(a,b)
					local ta = set[a]
					local tb = set[b]
					if ta == tb then
						-- if the property types match, sort by name instead
						return a < b
					else
						-- order properties in the same class by type
						-- since primative types tend to be lower case, the order is reversed so that they appear first
						-- this also gets the Name property to appear first, which is nice
						return ta > tb
					end
				end)
				for i=1,#sort do
					list[#list+1] = sort[i]
					-- we're also maintaining a separate, alphabetical list for RobloxXML
					alphalist[#alphalist+1] = sort[i]
				end
			end
			table.sort(alphalist)
			InstanceAPI[name] = o
		end
		Exporter.InstanceAPI = InstanceAPI
	end

	function Exporter:AddFormat(name,method,types,options)
		self.FormatMethod[name] = method
		self.DataTypeFormat[name] = types
		self.FormatOptions[name] = options
	end

	function Exporter:Export(object,format,options,limit)
		local data,err = self.FormatMethod[format](object,options or {},self.DataTypeFormat[format],limit)
		if not data then
			print("Exporter:",err)
		end
		return data
	end

	function Exporter:ExportDialog()
		local exportString = Dialogs.ExportScreen(UserInterface.Screen,PluginActivator.Deactivated)
		if exportString then
			local exportScript = Create'Script'{
				Name = "Screen GUI Export Data";
				Disabled = true;
				Archivable = false;
				Source = exportString;
			}
			exportScript.Parent = Workspace
			Selection:Set{exportScript}
		end
	end
end
