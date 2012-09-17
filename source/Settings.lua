--[[Settings
Manages user settings.

API:
	Settings[key]                  Gets a setting.
	Settings[key] = value          Sets a setting.

	Settings.Changed(key,value)    Fired after a setting changes value.
]]

local Settings do
	Settings = {}

	local eventChanged = CreateSignal(Settings,'Changed')

	local internalSettings = {}
	-- deserialize settings
	setmetatable(Settings,{
		__index = function(self,k)
			return internalSettings[k]
		end;
		__newindex = function(self,k,v)
			local o = internalSettings[k]
			if v ~= o then
				internalSettings[k] = v
				-- serialize settings
				eventChanged:Fire(k,v)
			end
		end;
	})
end
