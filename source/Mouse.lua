local Mouse do
	local PluginMouse = Plugin:GetMouse()
	local Enabled = false

	local MOD_KEYS = {
		[47] = 'ShiftIsDown';
		[48] = 'ShiftIsDown';
		[49] = 'CtrlIsDown';
		[50] = 'CtrlIsDown';
		[51] = 'AltIsDown';
		[52] = 'AltIsDown';
	}

	Mouse = {
		CtrlIsDown = false;
		ShiftIsDown = false;
		AltIsDown = false;
		KeyIsDown = {};
		KeyEvents = {};
	}

	local keyEventMT = {
		__index = {
			connect = function(self,listener)
				table.insert(self,listener)
				return {
					disconnect = function()
						for i,v in pairs(self) do
							if v == listener then
								table.remove(self,i)
								break
							end
						end
					end;
				}
			end;
		};
	}

	setmetatable(Mouse.KeyEvents,{
		__index = function(self,key)
			local v = setmetatable({},keyEventMT)
			self[key] = v
			return v
		end;
	})

	PluginMouse.KeyDown:connect(function(key)
		Mouse.KeyIsDown[key] = true

		local mod_key = MOD_KEYS[key:byte()]
		if mod_key then Mouse[mod_key] = true end

		if Enabled then
			local listeners = Mouse.KeyEvents[key]
			if listeners then
				for i,listener in pairs(listeners) do
					if listener.down then
						listener.down(Mouse)
					end
				end
			end
		end
	end)

	PluginMouse.KeyUp:connect(function(key)
		Mouse.KeyIsDown[key] = nil

		local mod_key = MOD_KEYS[key:byte()]
		if mod_key then Mouse[mod_key] = false end

		if Enabled then
			local listeners = Mouse.KeyEvents[key]
			if listeners then
				for i,listener in pairs(listeners) do
					if listener.up then
						listener.up(Mouse)
					end
				end
			end
		end
	end)

	AddServiceStatus{Mouse;
		Start = function(self)
			Enabled = true
		end;
		Stop = function(self)
			Enabled = false
		end;
	}

	 setmetatable(Mouse,{
		-- "inherit" from PluginMouse
		__index = PluginMouse;
		__newindex = PluginMouse;
	})
end
