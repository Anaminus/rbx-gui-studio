function Widgets.TabContainer(TabContainerFrame,ContentList,currentTab)
	local selectedTabHeight = 24
	local tabHeight = 20

	local stackConfig = {
		Border = 0;
		Padding = 0;
		LockAxis = UDim.new(0,selectedTabHeight);
		Horizontal = true;
		Alignment = true;
	}

	local selectedIndex = 0
	local contentList = {}
	local tabLookup = {}

	local GuiColor = InternalSettings.GuiColor

	if not TabContainerFrame then
		TabContainerFrame = Create'Frame'{
			Name = "TabContainer";
			Size = UDim2.new(0,300,0,200);
			BackgroundTransparency = 1;
			ZIndex = 10;
			Create'Frame'{
				Name = "Content";
				Size = UDim2.new(1,0,1,-selectedTabHeight);
				Position = UDim2.new(0,0,0,selectedTabHeight);
				BackgroundColor3 = GuiColor.Background;
				BorderColor3 = GuiColor.Border;
				ZIndex = 10;
			};
			Create'Frame'{
				Name = "Tabs";
				BackgroundTransparency = 1;
				ZIndex = 10;
			};
		}
	end

	local BorderHide = Create'Frame'{
		Name = "BorderHide";
		Position = UDim2.new(0, 1, 1, -1);
		Size = UDim2.new(1, 0, 0, 1);
		BackgroundColor3 = GuiColor.Background;
		BorderSizePixel = 0;
		ZIndex = 10;
	}


	local TabContentFrame = TabContainerFrame.Content
	local TabHeaderFrame = TabContainerFrame.Tabs

	local function selectTab(index)
		if index ~= selectedIndex then
			if selectedIndex > 0 then
				local content = contentList[selectedIndex]
				content.Visible = false

				local Tab = tabLookup[content]
				Tab.LockYAxis = UDim.new(0,tabHeight)
				Tab:Update()
			end

			local content = contentList[index]
			content.Visible = true

			local Tab = tabLookup[content]
			Tab.LockYAxis = UDim.new(0,selectedTabHeight)
			Tab:Update()
			BorderHide.Parent = Tab.GUI

			Widgets.StaticStackingFrame(TabHeaderFrame,stackConfig)
			selectedIndex = index
			currentTab[1] = index
		end
	end

	local function addTab(content,index)
		table.insert(contentList,index,content)

		content.Visible = false
		content.Parent = TabContentFrame

		local TabFrame = Create'TextButton'{
			Name = "Tab";
			Text = content.Name;
			BackgroundColor3 = GuiColor.Background;
			BorderColor3 = GuiColor.Border;
			TextColor3 = GuiColor.Text;
			FontSize = "Size10";
			ZIndex = 10;
		}

		local Tab = Widgets.AutoSizeLabel(TabFrame)
		Tab.Padding = 4
		Tab.LockYAxis = UDim.new(0,tabHeight)
		Tab:Update()
		tabLookup[content] = Tab

		TabFrame.MouseButton1Click:connect(function()
			selectTab(index)
		end)

		TabFrame.Parent = TabHeaderFrame

		Spawn(function()
			while TabFrame.TextBounds.magnitude == 0 do
				TabFrame.Changed:wait()
			end
			Widgets.StaticStackingFrame(TabHeaderFrame,stackConfig)
		end)

		if currentTab[1] == index then
			selectTab(index)
		end
	end

	if ContentList then
		for i = 1,#ContentList do
			addTab(ContentList[i],i)
		end
	end

	Widgets.StaticStackingFrame(TabHeaderFrame,stackConfig)

	return TabContainerFrame
end
