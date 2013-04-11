PluginActivator.Initialized:connect(function()
	Grid:Initialize()
	TemplateManager:Initialize()
	StandardToolbar:Initialize()
	UserInterface:Initialize()

	Canvas.Started:connect(function(screen)
		Scope:SetTop(screen)
		Grid:Start()
		Selection:Start()
		StandardToolbar:Start()
		ActionManager:Start()
	end)
	Canvas.Stopping:connect(function()
		ActionManager:Stop()
		StandardToolbar:Stop()
		Grid:Stop()
	end)
	Canvas.Stopped:connect(function()
		Selection:Stop()
	end)

	SnapService:SetParent(Canvas.CanvasFrame)
end)

do
	local Camera
	local cameraCF
	local cameraFO
	local cameraType
	PluginActivator.Activated:connect(function()
		Camera = Workspace.CurrentCamera
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
		Camera = Workspace.CurrentCamera
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
