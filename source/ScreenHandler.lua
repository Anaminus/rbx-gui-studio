--[[
handles ScreenGuis for Canvas on plugin activation
implements ScreenSelect and ScreenInsert dialogs
API:
	ScreenHandler.CurrentScreen   The current ScreenGui

	ScreenHandler:Select(screen)  Selects the ScreenGui that the Canvas will be bound to
	ScreenHandler:RunStartup()    does the startup procedure for plugin activation
	ScreenHandler:InsertDialog()  runs the ScreenGui insert dialog
	ScreenHandler:SelectDialog()  runs the ScreenGui select dialog
]]
local ScreenHandler do
	ScreenHandler = {
		CurrentScreen = nil;
	}

	-- bind canvas to a screen
	function ScreenHandler:Select(screen)
		self.CurrentScreen = screen
		if screen then
			Canvas:Restart(screen)
		else
			Canvas:Stop()
		end
	end

	function ScreenHandler:SelectDialog()
		local parent = GetScreen(Canvas.CanvasFrame)
		if parent then
			local screen = Dialogs.SelectDialog(parent)
			if screen then
				self:Select(screen)
			end
		end
	end

	function ScreenHandler:InsertDialog()
		local parent = GetScreen(Canvas.CanvasFrame)
		if parent then
			local screen,set_canvas = Dialogs.InsertDialog(parent)
			if screen and set_canvas then
				Game:GetService("Selection"):Set{screen}
				ScreenHandler:Select(screen)
			end
		end
	end

	-- look for ScreenGuis on plugin startup
	function ScreenHandler:RunStartup()
		if self.CurrentScreen and Game:GetService("StarterGui"):IsAncestorOf(self.CurrentScreen) then
			self:Select(self.CurrentScreen)
		else
			local screens = GetScreens(Game:GetService("StarterGui"))
			if #screens == 0 then
				self:InsertDialog(Screen)
		--	elseif #screens == 1 then
		--		self:Select(screens[1])
			else
				self:SelectDialog(Screen)
			end
		end
	end
end
