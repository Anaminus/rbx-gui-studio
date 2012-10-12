--[[NumberTextBox
Creates a TextBox that evalutes input into a number.

Input to the TextBox is evalated as Lua, allowing mathematical expressions to be used.
All members of the math library can be used (i.e. "sqrt(2)").
The variables "x" and "n" are also defined, whose values are the previous input to the TextBox.

Arguments:
	getEnabled
		A function, called when the text has been edited, which determines whether the TextBox is enabled.
		The TextBox is passed as an argument.
		It should return 2 values: `isEnabled`, and `previousValue`.
		`isEnabled` is a bool indicating whether or not the TextBox is enabled.
		`previousValue` is the previous value of the text box, before the text was edited.
		If `inEnabled` is false, then the new value of the text box simply reverts to `previousValue`.
		If `isEnabled` is true, then the new value of the text box is valiaated, and only
		reverts to `previousValue` if the new value is invalid.

	updateValue
		A function, called when the text has been edited.
		The TextBox and the new value are passed as arguments.
		Only called if the new value has been successfully validated as a number.
		If this function returns true, the TextBox's text wont be updated.

	textBox
		A TextBox instance to be used.
		Optional; defaults to a new TextBox.

	formatString
		The string passed to string.format when the value is converted to a string to be displayed on the TextBox.
		Optional; defaults to "%g".

Returns:
	textBox
		The TextBox.

	connectionFocusLost
		The connection made to the FocusLost event.
]]
do
	local mathEnvironment = {
		abs = math.abs; acos = math.acos; asin = math.asin; atan = math.atan; atan2 = math.atan2;
		ceil = math.ceil; cos = math.cos; cosh = math.cosh; deg = math.deg;
		exp = math.exp; floor = math.floor; fmod = math.fmod; frexp = math.frexp;
		huge = math.huge; ldexp = math.ldexp; log = math.log; log10 = math.log10;
		max = math.max; min = math.min; modf = math.modf; pi = math.pi;
		pow = math.pow; rad = math.rad; random = math.random; sin = math.sin;
		sinh = math.sinh; sqrt = math.sqrt; tan = math.tan; tanh = math.tanh;
	}

	local evalInput
	if _VERSION == 'Lua 5.2' then
		function evalInput(str,prev)
			local env = {}
			for k,v in pairs(mathEnvironment) do
				env[k] = v
			end
			env.x = prev
			env.n = prev
			local f = load("return "..s,nil,nil,env)
			if f then
				local s,o = pcall(f)
				if s then return tonumber(o) end
			end
			return nil
		end
	else
		function evalInput(str,prev)
			local env = {}
			for k,v in pairs(mathEnvironment) do
				env[k] = v
			end
			env.x = prev
			env.n = prev
			local f = loadstring("return "..str)
			if f then
				setfenv(f,env)
				local s,o = pcall(f)
				if s then return tonumber(o) end
			end
			return nil
		end
	end

	function Widgets.NumberTextBox(getEnabled,updateValue,textBox,formatString)
		textBox = textBox or Instance.new("TextBox")
		formatString = formatString or '%g'
		return textBox,textBox.FocusLost:connect(function()
			local enabled,prev = getEnabled(textBox)
			prev = tonumber(prev)
			if enabled then
				local num = evalInput(textBox.Text,prev)
				if num then
					if not updateValue(textBox,num) then
						textBox.Text = string.format(formatString,num)
					end
				else
					if prev then
						textBox.Text = string.format(formatString,prev)
					else
						textBox.Text = ''
					end
				end
			else
				if prev then
					textBox.Text = string.format(formatString,prev)
				else
					textBox.Text = ''
				end
			end
		end)
	end
end
