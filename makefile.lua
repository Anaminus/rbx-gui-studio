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
read [[source/Header.lua]]        {'main'}
read [[source/Utility.lua]]       {'main'}

widgets = [[source/widgets]]
read (widgets/[[Header.lua]])     {'main'}
read (widgets/[[DialogBase.lua]]) {'main'}

read [[source/Canvas.lua]]        {'main'}
read [[source/Scope.lua]]         {'main'}
read [[source/Selection.lua]]     {'main'}
read [[source/ScreenHandler.lua]] {'main'}
read [[source/GUI.lua]]           {'main'}
read [[source/Activator.lua]]     {'main'}

write 'main' (output_files)
