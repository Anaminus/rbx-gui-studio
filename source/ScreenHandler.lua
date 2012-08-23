-- handles ScreenGuis for Canvas on plugin activation
-- implements ScreenSelect and ScreenInsert dialogs
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
		print("SELECTING SCREEN:",screen)
		self.CurrentScreen = screen
		Canvas:Restart(screen)
	end

	function ScreenHandler:SelectDialog(screens)
		-- TEMP: select first screen
		self:Select(screens[1])
	end

	function ScreenHandler:InsertDialog()
		-- TEMP: insert a new screen into StarterGui
		local screen = Instance.new("ScreenGui")
		screen.Parent = Game:GetService("StarterGui")
		ScreenHandler:Select(screen)
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
