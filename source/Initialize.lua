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
	local cameraType
	PluginActivator.Activated:connect(function()
		if Camera then
			cameraCF = Camera.CoordinateFrame
			cameraFO = Camera.Focus
			cameraType = Camera.CameraType
			Camera.CameraType = 'Scriptable'
		end
		Keyboard:Start()
		UserInterface:Start()
		ScreenManager:RunStartup()
	end)

	PluginActivator.Deactivated:connect(function()
		Canvas:Stop()
		UserInterface:Stop()
		Keyboard:Stop()
		if Camera then
			Camera.CameraType = cameraType
			Camera.CoordinateFrame = cameraCF
			Camera.Focus = cameraFO
		end
	end)
end

PluginActivator:Start()
