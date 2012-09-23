--[[Mouse
"extends" the PluginMouse to add some extra features.

API:
	Has the same members as the PluginMouse.

	Mouse.ShiftIsDown   Returns whether the Shift modifier key is down.
	Mouse.CtrlIsDown    Returns whether thr Ctrl modifier key is down.
	Mouse.AltIsDown     Returns whether the Alt modifier key is down.
	Mouse.KeyIsDown     A table containg keys that are currently down (use Mouse.KeyIsDown[key]).
	Mouse.KeyEvents     Allows listeners to be connected to specific keys.
	                    The Mouse is passed to the listener.
	                        conn = Mouse.KeyEvents[key]:connect( {up = (listener), down = (listener)} )
	                        conn:disconnect()
]]
local Mouse do
	local PluginMouse = PluginActivator.Plugin:GetMouse()
	local Enabled = false

	local MOD_KEYS = {
		[47] = 'ShiftIsDown';
		[48] = 'ShiftIsDown';
		[49] = 'CtrlIsDown';
		[50] = 'CtrlIsDown';
		[51] = 'AltIsDown';
		[52] = 'AltIsDown';
	}

	local KeyIsDown = {}
	local KeyEvents = {}

	Mouse = {
		CtrlIsDown = false;
		ShiftIsDown = false;
		AltIsDown = false;
		KeyIsDown = KeyIsDown;
		KeyEvents = KeyEvents;
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

	setmetatable(KeyEvents,{
		__index = function(self,key)
			local v = setmetatable({},keyEventMT)
			self[key] = v
			return v
		end;
	})

	PluginMouse.KeyDown:connect(function(key)
		KeyIsDown[key] = true

		local mod_key = MOD_KEYS[key:byte()]
		if mod_key then Mouse[mod_key] = true end

		if Enabled then
			local listeners = KeyEvents[key]
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
		KeyIsDown[key] = nil

		local mod_key = MOD_KEYS[key:byte()]
		if mod_key then Mouse[mod_key] = false end

		if Enabled then
			local listeners = KeyEvents[key]
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
