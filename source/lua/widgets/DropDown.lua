--[[DropDown
Creates a drop-down widget, which allows a user to select a single item from a list.

DropDown Class:
	GUI
		The GUI instance associated with this object.
	List
		Gets or sets the list that the drop-down widget displays.
	ToolTips
		Gets or sets a list of tooltips that are displayed for each list item.
	Selection
		The value of the current selection.
	SelectionIndex
		The index of the current selection in the list.

	Methods:
		ShowDropDown ()
			Starts dislaying the drop-down list.
		HideDropDown ()
			Stops displaying the drop-down list.
		Destroy ()
			Ensures all resources used by this object can be released.

	Events:
		SelectionChanged ()

Arguments:
	table `list`
		A list of values that the drop down widget will select from.
	int `default`
		The index of the default value in the list.
		If this value is nil, no item will be initially selected.
	GuiText `dropDownText`
		The object that will display the selected value.
		This object may be a TextLabel, TextButton, or TextBox.
		Optional; defaults to a new TextLabel.

Returns:
	DropDown `dropDown`
		A new DropDown widget.
]]

function Widgets.DropDown(list,default,tooltips,dropDownText)
	local GuiColor = InternalSettings.GuiColor
	local dropDownFrame = Create'ImageButton'{
		Name = "DropDown";
		Size = UDim2.new(0,140,0,24);
		BackgroundColor3 = GuiColor.Field;
		BorderColor3 = GuiColor.FieldBorder;
		AutoButtonColor = false;
		Create(dropDownText or 'TextLabel'){
			Name = "Label";
			BackgroundTransparency = 1;
			Position = UDim2.new(0,4,0,4);
			Size = UDim2.new(1,-30,1,-8);
			FontSize = Enum.FontSize.Size10;
			TextColor3 = GuiColor.Text;
			TextXAlignment = 'Left';
		};
		Create'ImageButton'{
			Name = "Button";
			Position = UDim2.new(1,-22,0,2);
			Size = UDim2.new(0,20,1,-4);
			BackgroundColor3 = GuiColor.Button;
			BorderColor3 = GuiColor.ButtonBorder;
			AutoButtonColor = false;
		};
	};

	local dropDownText = DescendantByOrder(dropDownFrame,1)
	local dropDownButton = DescendantByOrder(dropDownFrame,2)
	local dropDownDragger
	local dropDownList

	do
		local arrow = Widgets.ArrowGraphic(11,'Down',false,Create'Frame'{
			BorderSizePixel = 0;
			BackgroundColor3 = GuiColor.Border;
		})
		arrow.Position = UDim2.new(0.5,-5,0.5,-5)
		arrow.Parent = dropDownButton
	end

	local function updateListPosition(p)
		if p == 'AbsolutePosition' or p == 'AbsoluteSize' then
			if dropDownList and dropDownList.Parent then
				local pos = dropDownFrame.AbsolutePosition
				+ Vector2.new(0,dropDownFrame.AbsoluteSize.y)
				- dropDownList.Parent.AbsolutePosition
				dropDownList.Position = UDim2.new(0,pos.x,0,pos.y)
			end
		end
	end

	dropDownFrame.Changed:connect(updateListPosition)

	local Class = {
		GUI = dropDownFrame;
		List = list;
		ToolTips = tooltips;
		SelectionIndex = default;
		Selection = list[default];
	}

	local function updateLabelText()
		if Class.SelectionIndex then
			dropDownText.Text = tostring(Class.List[Class.SelectionIndex])
		end
	end
	updateLabelText()

	local eventSelectionChanged = CreateSignal(Class,'SelectionChanged')

	local itemFrameList = {}
	function Class:ShowDropDown()
		self:HideDropDown()
		dropDownDragger = Create(Widgets.Dragger(dropDownFrame)){
			BackgroundTransparency = 0.9;
			BackgroundColor3 = Color3.new(0,0,0);
			BorderSizePixel = 0;
		}
		dropDownList = Create'ImageButton'{
			Name = "List";
			Position = UDim2.new(0,0,1,0);
			BackgroundColor3 = GuiColor.Field;
			BorderColor3 = GuiColor.FieldBorder;
			AutoButtonColor = false;
		}
		dropDownList.Parent = dropDownDragger

		updateListPosition('AbsolutePosition')

		local valueList = self.List
		local tooltipList = self.ToolTips
		for i = 1,#valueList do
			local item = Create'TextLabel'{
				Name = "ListItem";
				BorderSizePixel = 0;
				Active = true;
				BackgroundColor3 = GuiColor.Field;
				Text = tostring(valueList[i]);
				FontSize = 'Size10';
				TextXAlignment = 'Left';
				TextColor3 = GuiColor.Text;
				Parent = dropDownList;
			}
			local auto = Widgets.AutoSizeLabel(item)
			auto.LockXAxis = UDim.new(0,dropDownText.AbsoluteSize.x)
			auto.Padding = 2
			auto:Update()
			itemFrameList[i] = auto

			-- affected by mouseover priority bugs
		--	if tooltipList then
		--		ToolTipService:AddToolTip(item,tooltipList[i])
		--	end
		end
		SetZIndex(dropDownList,dropDownFrame.ZIndex)
		Widgets.StaticStackingFrame(dropDownList,{
			Border = 4;
		})

		local listIndex
		dropDownList.MouseMoved:connect(function(x,y)
			listIndex = math.floor((y - dropDownList.AbsolutePosition.y)/(dropDownList.AbsoluteSize.y+1)*#valueList)+1
			for i = 1,#itemFrameList do
				local item = itemFrameList[i].GUI
				if i == listIndex then
					item.BackgroundColor3 = GuiColor.Selected
					item.TextColor3 = GuiColor.TextSelected
				else
					item.BackgroundColor3 = GuiColor.Field
					item.TextColor3 = GuiColor.Text
				end
			end
		end)
		dropDownList.MouseLeave:connect(function()
			for i = 1,#itemFrameList do
				local item = itemFrameList[i].GUI
				item.BackgroundColor3 = GuiColor.Field
				item.TextColor3 = GuiColor.Text
			end
		end)

		dropDownDragger.MouseButton1Down:connect(function()
			self:HideDropDown()
		end)
		dropDownDragger.Changed:connect(updateListPosition)
		dropDownList.MouseButton1Down:connect(function()
			self:HideDropDown()
			if listIndex then
				if self.SelectionIndex ~= listIndex then
					self.SelectionIndex = listIndex
					self.Selection = list[listIndex]
					updateLabelText()
					eventSelectionChanged:Fire(list[listIndex],listIndex)
				end
			end
		end)
	end

	function Class:HideDropDown()
		if dropDownDragger then
			for i=1,#itemFrameList do
			--	ToolTipService:RemoveToolTip(itemFrameList[i].GUI)
				itemFrameList[i]:Destroy()
				itemFrameList[i] = nil
			end
			dropDownDragger:Destroy()
			dropDownDragger = nil
			dropDownList = nil
		end
	end

	function Class:Destroy()
		self:HideDropDown()
		eventSelectionChanged:Destroy()
		self.GUI:Destroy()
	end

	if dropDownFrame:IsA"GuiButton" then
		dropDownFrame.MouseButton1Down:connect(function()
			Class:ShowDropDown()
		end)
	end
	dropDownButton.MouseButton1Down:connect(function()
		Class:ShowDropDown()
	end)

	SetZIndexOnChanged(dropDownFrame)

	return Class
end
