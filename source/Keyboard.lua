--[[Keyboard
Allows keystrokes to be detected and whatnot.

API:
	Keyboard.ShiftIsDown   Returns whether the Shift modifier key is down.
	Keyboard.CtrlIsDown    Returns whether thr Ctrl modifier key is down.
	Keyboard.AltIsDown     Returns whether the Alt modifier key is down.
	Keyboard.KeyIsDown     A table containg keys that are currently down (use Keyboard.KeyIsDown[key]).
	Keyboard.KeyDown       Allows listeners to be connected to specific keys when they are pressed.
	                       The Keyboard is passed to the listener.
	                           conn = Keyboard.KeyDown[key]:connect( listener )
	                           conn:disconnect()
	Keyboard.KeyUp         Allows listeners to be connected to specific keys when they are depressed.
	                       The Keyboard is passed to the listener.
	                           conn = Keyboard.KeyUp[key]:connect( listener )
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

	Keyboard = {
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
		if mod_key then Keyboard[mod_key] = true end

		if Enabled then
			local listeners = KeyDown[key]
			if listeners then
				for i,listener in pairs(listeners) do
					listener(Keyboard)
				end
			end
		end
	end)

	PluginMouse.KeyUp:connect(function(key)
		KeyIsDown[key] = nil

		local mod_key = MOD_KEYS[key]
		if mod_key then Keyboard[mod_key] = false end

		if Enabled then
			local listeners = KeyUp[key]
			if listeners then
				for i,listener in pairs(listeners) do
					listener(Keyboard)
				end
			end
		end
	end)

	AddServiceStatus{Keyboard;
		Start = function(self)
			Enabled = true
		end;
		Stop = function(self)
			Enabled = false
		end;
	}
end
