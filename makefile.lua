option('write_path',"--[[FILE: %s]]")
--option('show_messages',0)
--option('cmd_friendly',0)

META    = data [[METADATA]]
NAME    = META.PROJECT_NAME
TYPE    = META.PROJECT_TYPE
VERSION = META.PROJECT_VERSION

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
read [[source/Plugin.lua]]        {'main'}
read [[source/Utility.lua]]       {'main'}
read [[source/Settings.lua]]      {'main'}
read [[source/Mouse.lua]]         {'main'}

widgets = [[source/widgets]]
read (widgets/[[Header.lua]])              {'main'}
read (widgets/[[ToolTipService.lua]])      {'main'}
read (widgets/[[AutoSizeLabel.lua]])       {'main'}
read (widgets/[[Graphics.lua]])            {'main'}
read (widgets/[[StackingFrame.lua]])       {'main'}
read (widgets/[[StaticStackingFrame.lua]]) {'main'}
read (widgets/[[ScrollBar.lua]])           {'main'}
read (widgets/[[ScrollingContainer.lua]])  {'main'}
read (widgets/[[ButtonMenu.lua]])          {'main'}
read (widgets/[[List.lua]])                {'main'}
read (widgets/[[DialogBase.lua]])          {'main'}
read (widgets/[[Dragger.lua]])             {'main'}
read (widgets/[[DragGUI.lua]])             {'main'}
read (widgets/[[TransformHandles.lua]])    {'main'}

dialogs = [[source/dialogs]]
read (dialogs/[[Header.lua]])       {'main'}
read (dialogs/[[InsertDialog.lua]]) {'main'}
read (dialogs/[[SelectDialog.lua]]) {'main'}

read [[source/Canvas.lua]]        {'main'}
read [[source/Scope.lua]]         {'main'}
read [[source/Selection.lua]]     {'main'}
read [[source/ScreenManager.lua]] {'main'}

tools = [[source/tools]]
read [[source/ToolManager.lua]]   {'main'}
read (tools/[[Selector.lua]])     {'main'}
read (tools/[[Insert.lua]])       {'main'}

read [[source/UserInterface.lua]] {'main'}
read [[source/Activator.lua]]     {'main'}

write 'main' (output_files)
