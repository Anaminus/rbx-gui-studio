PluginActivator.Initialized:connect(function()
	UserInterface:Initialize()
	Canvas.Started:connect(function(screen)
		Scope:SetTop(screen)
		Grid:Start()
		Selection:Start()
		ToolManager:Start()
	end)
	Canvas.Stopping:connect(function()
		ToolManager:Stop()
		Grid:Stop()
	end)
	Canvas.Stopped:connect(function()
		Selection:Stop()
	end)
end)

do
	local Camera = Workspace.CurrentCamera
	local cameraCF
	local cameraFO
	PluginActivator.Activated:connect(function()
		if Camera then
			cameraCF = Camera.CoordinateFrame
			cameraFO = Camera.Focus
		end
		Mouse:Start()
		UserInterface:Start()
		ScreenManager:RunStartup()
	end)

	PluginActivator.Deactivated:connect(function()
		Canvas:Stop()
		UserInterface:Stop()
		Mouse:Stop()
		if Camera then
			Camera.CoordinateFrame = cameraCF
			Camera.Focus = cameraFO
		end
	end)
end

PluginActivator:Start()
