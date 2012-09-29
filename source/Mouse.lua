--[[Mouse
"extends" the PluginMouse to add some extra features.

API:
	Has the same members as the PluginMouse.

	Mouse.ShiftIsDown   Returns whether the Shift modifier key is down.
	Mouse.CtrlIsDown    Returns whether thr Ctrl modifier key is down.
	Mouse.AltIsDown     Returns whether the Alt modifier key is down.
	Mouse.KeyIsDown     A table containg keys that are currently down (use Mouse.KeyIsDown[key]).
	Mouse.KeyDown       Allows listeners to be connected to specific keys when they are pressed.
	                    The Mouse is passed to the listener.
	                        conn = Mouse.KeyDown[key]:connect( listener )
	                        conn:disconnect()
	Mouse.KeyUp         Allows listeners to be connected to specific keys when they are depressed.
	                    The Mouse is passed to the listener.
	                        conn = Mouse.KeyUp[key]:connect( listener )
	                        conn:disconnect()
]]

do
	local PluginMouse = PluginActivator.Plugin:GetMouse()
	local Enabled = false

	local MOD_KEYS = {
		[string.char(47)] = 'ShiftIsDown';
		[string.char(48)] = 'ShiftIsDown';
		[string.char(49)] = 'CtrlIsDown';
		[string.char(50)] = 'CtrlIsDown';
		[string.char(51)] = 'AltIsDown';
		[string.char(52)] = 'AltIsDown';
	}

	local KeyIsDown = {}
	local KeyDown = {}
	local KeyUp = {}

	Mouse = {
		CtrlIsDown = false;
		ShiftIsDown = false;
		AltIsDown = false;
		KeyIsDown = KeyIsDown;
		KeyDown = KeyDown;
		KeyUp = KeyUp;
	}

	do
		local keyConnectionMT = {
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
		local keyEventMT = {
			__index = function(self,key)
				local v = setmetatable({},keyConnectionMT)
				self[key] = v
				return v
			end;
		}
		setmetatable(KeyDown,keyEventMT)
		setmetatable(KeyUp,keyEventMT)
	end

	PluginMouse.KeyDown:connect(function(key)
		KeyIsDown[key] = true

		local mod_key = MOD_KEYS[key]
		if mod_key then Mouse[mod_key] = true end

		if Enabled then
			local listeners = KeyDown[key]
			if listeners then
				for i,listener in pairs(listeners) do
					listener(Mouse)
				end
			end
		end
	end)

	PluginMouse.KeyUp:connect(function(key)
		KeyIsDown[key] = nil

		local mod_key = MOD_KEYS[key]
		if mod_key then Mouse[mod_key] = false end

		if Enabled then
			local listeners = KeyUp[key]
			if listeners then
				for i,listener in pairs(listeners) do
					listener(Mouse)
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
