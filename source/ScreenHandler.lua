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

	local function getScreens(object)
		local list = {}
		for i,child in pairs(object:GetChildren()) do
			if child:IsA"ScreenGui" then
				list[#list+1] = child
			end
			for i,screen in pairs(getScreens(child)) do
				list[#list+1] = screen
			end
		end
		return list
	end

	-- bind canvas to a screen
	function ScreenHandler:Select(screen)
		self.CurrentScreen = screen
		Canvas:Restart(screen)
	end

	function ScreenHandler:SelectDialog(screens)
		-- TEMP: select first screen
		self:Select(screens[1])
	end

	function ScreenHandler:InsertDialog()
		local screen,set_canvas = RunInsertDialog(Canvas.CanvasFrame.Parent.Parent)
		if screen and set_canvas then
			ScreenHandler:Select(screen)
		end
	end

	-- look for ScreenGuis on plugin startup
	function ScreenHandler:RunStartup()
		if self.CurrentScreen and Game:IsAncestorOf(self.CurrentScreen) then
			self:Select(self.CurrentScreen)
		else
			local screens = getScreens(Game:GetService("StarterGui"))
			if #screens == 0 then
				self:InsertDialog()
			elseif #screens == 1 then
				self:Select(screens[1])
			else
				self:SelectDialog(screens) -- TEMP: pass screens
			end
		end
	end
end
