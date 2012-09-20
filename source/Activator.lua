local function Initialize()
	InitializeGUI()
	Canvas.Started:connect(function(screen)
		Scope:SetTop(screen)
		Selection:Start()
		ToolManager:Start()
	end)
	Canvas.Stopping:connect(function()
		ToolManager:Stop()
	end)
	Canvas.Stopped:connect(function()
		Selection:Stop()
	end)
end

local function Activate()
	Mouse:Start()
	ActivateGUI()
	ScreenManager:RunStartup()
end

local function Deactivate()
	Canvas:Stop()
	DeactivateGUI()
	Mouse:Stop()
end

PluginButton.Click:connect(function()
	if pluginActive then
		pluginActive = false
		PluginButton:SetActive(false)
		if pluginInitialized then
			Deactivate()
		end
	else
		if not pluginInitialized then
			Initialize()
			pluginInitialized = true
		end
		pluginActive = true
		Plugin:Activate(true)
		PluginButton:SetActive(true)
		Activate()
	end
end)
Plugin.Deactivation:connect(function()
	pluginActive = false
	PluginButton:SetActive(false)
	if pluginInitialized then
		Deactivate()
	end
end)
