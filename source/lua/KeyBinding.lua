--[[KeyBinding
Manages keyboard bindings.

API:
	KeyBinding.Enabled                Sets whether key bindings are enabled.

	KeyBinding:Add(key,command)       Adds a new key binding
	                                  `key` is a string that indicates the key to be bound to.
	                                  `key` may contain one or more modifiers, separated by "+" (ctrl+key", "shift+key", "alt+key")
	                                  `command` is a function that is called when the key is pressed.
	KeyBinding:Remove(key)            Removes an existing key binding

]]
do
	local Commands = {}

	KeyBinding = {
		Enabled = true;
		Commands = Commands;
	}

	local function normalize(combo)
		local bKey
		local mod = {shift=false, ctrl=false, alt=false}
		for k in combo:gmatch('[^+]+') do
			k=k:lower()
			if mod[k] ~= nil then
				mod[k] = true
			elseif #k == 1 then
				bKey = k
			end
		end
		if not bKey then error("KeyBinding: invalid key",3) end
		combo = ""
		local mKeys = {}
		if mod.ctrl  then combo = combo .. 'ctrl+'  mKeys.CtrlIsDown  = true else mKeys.CtrlIsDown  = false end
		if mod.shift then combo = combo .. 'shift+' mKeys.ShiftIsDown = true else mKeys.ShiftIsDown = false end
		if mod.alt   then combo = combo .. 'alt+'   mKeys.AltIsDown   = true else mKeys.AltIsDown   = false end
		return combo .. bKey,bKey,mKeys
	end

	function KeyBinding:Add(combo,command)
		local combo,base,mods = normalize(combo)
		if Commands[combo] then
			error("KeyBinding:Add: `"..combo.."` already has a binding",2)
		end
		Commands[combo] = Keyboard.KeyDown[base]:connect(function(keyboard)
			if self.Enabled then
				for mod,down in pairs(mods) do
					if keyboard[mod] ~= down then
						return
					end
				end
				command()
			end
		end)
	end

	function KeyBinding:Remove(combo)
		local combo = normalize(combo)
		if Commands[combo] then
			Commands[combo]:disconnect()
			Commands[combo] = nil
		end
	end
end
