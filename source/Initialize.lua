PluginActivator.Initialized:connect(function()
	UserInterface:Initialize()
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
end)

PluginActivator.Activated:connect(function()
	Mouse:Start()
	UserInterface:Start()
	ScreenManager:RunStartup()
end)

PluginActivator.Deactivated:connect(function()
	Canvas:Stop()
	UserInterface:Stop()
	Mouse:Stop()
end)

PluginActivator:Start()
