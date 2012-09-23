PluginData = {
	Toolbar = "Plugins";
	ActivationButton = {"", "Open "..PROJECT_NAME, "application_form_edit.png"};
}

--[[PluginActivator
A wrapper for a plugin that consists of one toolbar and a single button.
The button is used to toggle whether the wrapper is active or not.

API:
	PluginActivator.Plugin            The Plugin object.
	PluginActivator.Toolbar           The Toolbar object.
	PluginActivator.Button            The Button object.
	PluginActivator.Initialized       Whether the plugin has been initialized.
	PluginActivator.Active            Whether the plugin is active.

	PluginActivator:Start()           Starts detecting plugin events.

	PluginActivator.OnInitialize()    Called before the plugin activates for the first time.
	PluginActivator.OnActivate()      Called when the plugin activates.
	PluginActivator.OnDeactivate()    Called when then plugin deactivates.
]]

local PluginActivator do
	local Plugin = PluginManager():CreatePlugin()
	local Toolbar = Plugin:CreateToolbar(PluginData.Toolbar)
	local Button = Toolbar:CreateButton(unpack(PluginData.ActivationButton))

	PluginActivator = {
		Plugin = Plugin;
		Toolbar = Toolbar;
		Button = Button;
		Initialized = false;
		Active = false;
		OnInitialize = function()end;
		OnActivate = function()end;
		OnDeactivate = function()end;
	}

	function PluginActivator:Start()
		Button.Click:connect(function()
			if self.Active then
				self.Active = false
				Button:SetActive(false)
				if self.Initialized then
					self.OnDeactivate()
				end
			else
				if not self.Initialized then
					self.OnInitialize()
					self.Initialized = true
				end
				self.Active = true
				Plugin:Activate(true)
				Button:SetActive(true)
				self.OnActivate()
			end
		end)
		Plugin.Deactivation:connect(function()
			self.Active = false
			Button:SetActive(false)
			if self.Initialized then
				self.OnDeactivate()
			end
		end)
	end
end
