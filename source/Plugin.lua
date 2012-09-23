local Plugin = PluginManager():CreatePlugin()
local PluginToolbar = Plugin:CreateToolbar("Plugins")
local PluginButton = PluginToolbar:CreateButton("","Open "..PROJECT_NAME,"application_form_edit.png")
local pluginInitialized = false
local pluginActive = false
