--[[ScreenHandler
Handles ScreenGuis for the Canvas on plugin activation.

API:
	ScreenHandler.CurrentScreen     The current ScreenGui
	                                If the plugin deactivates, this value persists, and is used to recall
	                                the last selected ScreenGui if the plugin activates again

	ScreenHandler:Select(screen)    Selects the ScreenGui that the Canvas will be bound to
	                                Deselects the current screen if nil is passed
	ScreenHandler:RunStartup()      Does the startup procedure for when the plugin is activated
	                                If the CurrentScreen exists, then it is automatically selected
	                                Otherwise, the insert or select dialog is run, depending on how many screens exist in the game
	ScreenHandler:InsertDialog()    Runs the ScreenGui insert dialog and handles the results
	                                If the dialog returns the set canvas flag, this selects the returned screen
	ScreenHandler:SelectDialog()    Runs the ScreenGui select dialog and handles the results
	                                If the dialog returns a screen, this selects it
]]
local ScreenHandler do
	ScreenHandler = {
		CurrentScreen = nil;
	}

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
