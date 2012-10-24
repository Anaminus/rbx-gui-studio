--[[MaskedTextBox
Creates a TextBox whose input is masked.

Arguments:
	textBox
		A TextBox instance to be used.

	maskValue
		A function, called when the text has been edited.
		The TextBox and new value are passed as arguments.
		The value returned by this function is set as the TextBox's text.
		If this function returns nil, the text is not updated.

Returns:
	connectionFocusLost
		The connection made to the FocusLost event.
]]

function Widgets.MaskedTextBox(textBox,maskValue)
	return textBox.FocusLost:connect(function()
		local value = maskValue(textBox,textBox.Text)
		if value ~= nil then
			textBox.Text = value
		end
	end)
end
