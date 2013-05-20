META.PLUGIN_NAME = "GUI Studio"
META.PLUGIN_VERSION = "0.1"

read ( META )
read [[lua/Utility.lua]]
read [[lua/Plugin.lua]]
read [[lua/Settings.lua]]
read [[lua/Keyboard.lua]]
read [[lua/KeyBinding.lua]]
read [[lua/Status.lua]]
read [[lua/SnapService.lua]]
read [[lua/TemplateManager.lua]]

read [[lua/export/Exporter.lua]]
read [[lua/export/RobloxLua.lua]]
read [[lua/export/LuaCreateInstance.lua]]
read [[lua/export/RobloxXML.lua]]

read [[lua/widgets/Header.lua]]
read [[lua/widgets/ToolTipService.lua]]
read [[lua/widgets/AutoSizeLabel.lua]]
read [[lua/widgets/MaskedTextBox.lua]]
read [[lua/widgets/Graphics.lua]]
read [[lua/widgets/Icon.lua]]
read [[lua/widgets/StackingFrame.lua]]
read [[lua/widgets/StaticStackingFrame.lua]]
read [[lua/widgets/ScrollBar.lua]]
read [[lua/widgets/ScrollingContainer.lua]]
read [[lua/widgets/TabContainer.lua]]
read [[lua/widgets/ButtonMenu.lua]]
read [[lua/widgets/List.lua]]
read [[lua/widgets/PairsList.lua]]
read [[lua/widgets/DropDown.lua]]
read [[lua/widgets/DialogBase.lua]]
read [[lua/widgets/Dragger.lua]]
read [[lua/widgets/DragGUI.lua]]
read [[lua/widgets/RubberbandSelect.lua]]
read [[lua/widgets/TransformHandles.lua]]

read [[lua/dialogs/Header.lua]]
read [[lua/dialogs/InsertScreen.lua]]
read [[lua/dialogs/SelectScreen.lua]]
read [[lua/dialogs/ConfigGrid.lua]]
read [[lua/dialogs/ExportScreen.lua]]

read [[lua/Canvas.lua]]
read [[lua/Scope.lua]]
read [[lua/Grid.lua]]
read [[lua/Selection.lua]]
read [[lua/ScreenManager.lua]]

read [[lua/StandardToolbar.lua]]
read [[lua/ActionManager.lua]]
read [[lua/tools/Selector.lua]]

read [[lua/UserInterface.lua]]
read [[lua/Initialize.lua]]

write ( META.PLUGIN_NAME .. ".lua" )

-- plugin icon
read [[images/application_form_edit.png]]
bwrite [[application_form_edit.png]]
