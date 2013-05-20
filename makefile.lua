option('write_path',"--[[FILE: %s]]")
--option('show_messages',0)
--option('cmd_friendly',0)

META    = data [[METADATA]]
NAME    = META.PLUGIN_NAME
TYPE    = META.PLUGIN_TYPE
VERSION = META.PLUGIN_VERSION

if os_version == "Windows XP" then
	rbx_plugins = [[%USERPROFILE%/Local Settings/Application Data/Roblox/plugins]]
elseif os_version == "Windows Vista" or os_version == "Windows 7" then
	rbx_plugins = [[%USERPROFILE%/AppData/Local/Roblox/plugins]]
elseif os_version == "Mac OS X" then
	rbx_plugins = [[%HOME%/Documents/Roblox/plugins]]
end

-- a list of files to output to
local output_files = {
	[[build]]/NAME/NAME..[[.lua]];
	rbx_plugins/NAME/NAME..[[.lua]];
}

read [[METADATA]]                 {'main'}
read [[source/Utility.lua]]       {'main'}
read [[source/Plugin.lua]]        {'main'}
read [[source/Settings.lua]]      {'main'}
read [[source/Keyboard.lua]]      {'main'}
read [[source/KeyBinding.lua]]    {'main'}
read [[source/Status.lua]]        {'main'}
read [[source/SnapService.lua]]   {'main'}
read [[source/TemplateManager.lua]] {'main'}

export = [[source/export]]
read (export/[[Exporter.lua]])          {'main'}
read (export/[[RobloxLua.lua]])         {'main'}
read (export/[[LuaCreateInstance.lua]]) {'main'}
read (export/[[RobloxXML.lua]])         {'main'}

widgets = [[source/widgets]]
read (widgets/[[Header.lua]])              {'main'}
read (widgets/[[ToolTipService.lua]])      {'main'}
read (widgets/[[AutoSizeLabel.lua]])       {'main'}
read (widgets/[[MaskedTextBox.lua]])       {'main'}
read (widgets/[[Graphics.lua]])            {'main'}
read (widgets/[[Icon.lua]])                {'main'}
read (widgets/[[StackingFrame.lua]])       {'main'}
read (widgets/[[StaticStackingFrame.lua]]) {'main'}
read (widgets/[[ScrollBar.lua]])           {'main'}
read (widgets/[[ScrollingContainer.lua]])  {'main'}
read (widgets/[[TabContainer.lua]])        {'main'}
read (widgets/[[ButtonMenu.lua]])          {'main'}
read (widgets/[[List.lua]])                {'main'}
read (widgets/[[PairsList.lua]])           {'main'}
read (widgets/[[DropDown.lua]])            {'main'}
read (widgets/[[DialogBase.lua]])          {'main'}
read (widgets/[[Dragger.lua]])             {'main'}
read (widgets/[[DragGUI.lua]])             {'main'}
read (widgets/[[RubberbandSelect.lua]])    {'main'}
read (widgets/[[TransformHandles.lua]])    {'main'}

dialogs = [[source/dialogs]]
read (dialogs/[[Header.lua]])       {'main'}
read (dialogs/[[InsertScreen.lua]]) {'main'}
read (dialogs/[[SelectScreen.lua]]) {'main'}
read (dialogs/[[ConfigGrid.lua]])   {'main'}
read (dialogs/[[ExportScreen.lua]]) {'main'}

read [[source/Canvas.lua]]        {'main'}
read [[source/Scope.lua]]         {'main'}
read [[source/Grid.lua]]          {'main'}
read [[source/Selection.lua]]     {'main'}
read [[source/ScreenManager.lua]] {'main'}


read [[source/StandardToolbar.lua]] {'main'}
read [[source/ActionManager.lua]] {'main'}
read [[source/tools/Selector.lua]] {'main'}

read [[source/UserInterface.lua]] {'main'}
read [[source/Initialize.lua]]    {'main'}

write 'main' (output_files)
