--[==[ DialogBase

local dialog = Widgets.DialogBase()

OKButton.MouseButton1Click:connect(function()
	dialog:Return(true)
end)

CancelButton.MouseButton1Click:connect(function()
	dialog:Return(false)
end)

return dialog:Finish(function()
	button1:Destroy()
	button2:Destroy()
end)
--]==]

do
	local mt = {
		__index = {
			-- give results to dialog, thereby ending it
			Return = function(self,...)
				self.ReturnList = {...}
				self.Signal.Value = not self.Signal.Value
			end;
			-- wait for dialog to return, clean up dialog, and return results
			Finish = function(self,cleanUp)
				self.Signal.Changed:wait()
				local returnList = self.ReturnList or {}
				if cleanUp then cleanUp() end
				self.Signal:Destroy()
				return unpack(returnList)
			end;
		};
	}

	function Widgets.DialogBase()
		return setmetatable({
			Signal = Instance.new("BoolValue");
			ReturnList = {};
		},mt)
	end
end
