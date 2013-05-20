META.PLUGIN_NAME = "GUI Studio"
META.PLUGIN_VERSION = "0.1"

read ( META )
read [[Utility.lua]]
read [[Plugin.lua]]
read [[Settings.lua]]
read [[Keyboard.lua]]
read [[KeyBinding.lua]]
read [[Status.lua]]
read [[SnapService.lua]]
read [[TemplateManager.lua]]

read [[export/Exporter.lua]]
read [[export/RobloxLua.lua]]
read [[export/LuaCreateInstance.lua]]
read [[export/RobloxXML.lua]]

read [[widgets/Header.lua]]
read [[widgets/ToolTipService.lua]]
read [[widgets/AutoSizeLabel.lua]]
read [[widgets/MaskedTextBox.lua]]
read [[widgets/Graphics.lua]]
read [[widgets/Icon.lua]]
read [[widgets/StackingFrame.lua]]
read [[widgets/StaticStackingFrame.lua]]
read [[widgets/ScrollBar.lua]]
read [[widgets/ScrollingContainer.lua]]
read [[widgets/TabContainer.lua]]
read [[widgets/ButtonMenu.lua]]
read [[widgets/List.lua]]
read [[widgets/PairsList.lua]]
read [[widgets/DropDown.lua]]
read [[widgets/DialogBase.lua]]
read [[widgets/Dragger.lua]]
read [[widgets/DragGUI.lua]]
read [[widgets/RubberbandSelect.lua]]
read [[widgets/TransformHandles.lua]]

read [[dialogs/Header.lua]]
read [[dialogs/InsertScreen.lua]]
read [[dialogs/SelectScreen.lua]]
read [[dialogs/ConfigGrid.lua]]
read [[dialogs/ExportScreen.lua]]

read [[Canvas.lua]]
read [[Scope.lua]]
read [[Grid.lua]]
read [[Selection.lua]]
read [[ScreenManager.lua]]

read [[StandardToolbar.lua]]
read [[ActionManager.lua]]
read [[tools/Selector.lua]]

read [[UserInterface.lua]]
read [[Initialize.lua]]

write ( META.PLUGIN_NAME .. ".lua" )
