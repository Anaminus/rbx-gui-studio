local function Initialize()
	InitializeGUI()
end

local function Activate()
	ActivateGUI()
	ScreenHandler:RunStartup()
end

local function Deactivate()
	ToolManager:Stop()
	Canvas:Stop()
	Selection:Stop()
	DeactivateGUI()
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
