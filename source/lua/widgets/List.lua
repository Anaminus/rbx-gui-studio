function Widgets.List(items)
	local GuiColor = InternalSettings.GuiColor
	local Class = Widgets.ScrollingContainer()

	local labelTemplate = Create'TextLabel'{
		Name = "ListItem AutoSizeLabel";
		BackgroundColor3 = GuiColor.Field;
		BorderSizePixel = 0;
		TextColor3 = GuiColor.Text;
		TextXAlignment = "Left";
		FontSize = "Size10";
	}

	local height = 15

	Class.VScroll.PageIncrement = height
	Class.HScroll.PageIncrement = height

	for i,item in pairs(items) do
		local label = Widgets.AutoSizeLabel(labelTemplate:Clone())
		label.LockXAxis = UDim.new(1,0)
		label.GUI.Text = tostring(item)
		label.GUI.Parent = Class.Container
	end

	local Container = Widgets.StackingFrame(Class.Container)
	Container.Border = 2
	Container:Update()

	local SelectorButton = Create'ImageButton'{
		Name = "SelectorButton";
		Transparency = 1;
		AutoButtonColor = false;
		Size = UDim2.new(1,0,1,0);
	}

	Container.GUI.Changed:connect(function(p)
		if p == "AbsoluteSize" or p == "AbsolutePosition" then
			SelectorButton.Position = Container.GUI.Position
			SelectorButton.Size = Container.GUI.Size
		end
	end)

	local eventItemSelected = CreateSignal(Class,'ItemSelected')

	local d = true
	SelectorButton.MouseButton1Down:connect(function(x,y)
		if not d then return end
		d = false
		local entry = math.floor((y-SelectorButton.AbsolutePosition.y-Container.Border)/height)+1
		if items[entry] then
			local label = Class.SelectedLabel
			if label then
				label.TextColor3 = GuiColor.Text
				label.BackgroundColor3 = GuiColor.Field
			end

			local label = Container.List[entry]
			label.TextColor3 = GuiColor.TextSelected
			label.BackgroundColor3 = GuiColor.Selected
			Class.SelectedItem = items[entry]
			Class.SelectedLabel = label
			eventItemSelected:Fire(Class.SelectedItem)
		end
		d = true
	end)
	SelectorButton.MouseWheelForward:connect(function()
		Class.VScroll:ScrollUp()
	end)
	SelectorButton.MouseWheelBackward:connect(function()
		Class.VScroll:ScrollDown()
	end)
	SelectorButton.Parent = Class.Boundary

	SetZIndex(Class.GUI,10)

	local destroy = Class.Destroy
	function Class:Destroy()
		eventItemSelected:Destroy()
		destroy(self)
	end

	return Class
end
