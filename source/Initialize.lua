function PluginActivator.OnInitialize()
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
end

function PluginActivator.OnActivate()
	Mouse:Start()
	UserInterface:Start()
	ScreenManager:RunStartup()
end

function PluginActivator.OnDeactivate()
	Canvas:Stop()
	UserInterface:Stop()
	Mouse:Stop()
end

PluginActivator:Start()
