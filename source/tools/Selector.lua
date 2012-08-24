do
	local Tool = {
		Name = "Selector";
		Icon = "";
		Tooltip = "Select and transform objects";
		Shortcut = "";
	}
	local SelectedObjects = Selection.SelectedObjects
	local GlobalButton = Canvas.GlobalButton
	local CanvasFrame = Canvas.CanvasFrame

	local hsize,pad = 6,2
	local handleTemplate = Create'ImageButton'{
	--	AutoButtonColor = false;
		BorderSizePixel = 0;
		BackgroundColor3 = Color3.new(1,0,0);
		Size = UDim2.new(0,hsize,0,hsize);
	}
	local transformTemplate = Create'Frame'{
		Name = "Transform";
		Transparency = 1;
		Size = UDim2.new(1,0,1,0);
		Create(handleTemplate:Clone()){
			Name = "TopLeft";
			Position = UDim2.new(0,-hsize-pad,0,-hsize-pad);
		};
		Create(handleTemplate:Clone()){
			Name = "Top";
			Position = UDim2.new(0.5,-hsize/2,0,-hsize-pad);
		};
		Create(handleTemplate:Clone()){
			Name = "TopRight";
			Position = UDim2.new(1,pad,0,-hsize-pad);
		};
		Create(handleTemplate:Clone()){
			Name = "Right";
			Position = UDim2.new(1,pad,0.5,-hsize/2);
		};
		Create(handleTemplate:Clone()){
			Name = "BottomRight";
			Position = UDim2.new(1,pad,1,pad);
		};
		Create(handleTemplate:Clone()){
			Name = "Bottom";
			Position = UDim2.new(0.5,-hsize/2,1,pad);
		};
		Create(handleTemplate:Clone()){
			Name = "BottomLeft";
			Position = UDim2.new(0,-hsize-pad,1,pad);
		};
		Create(handleTemplate:Clone()){
			Name = "Left";
			Position = UDim2.new(0,-hsize-pad,0.5,-hsize/2);
		};
	}

	local cleanUp = {}
	local TransformFrame

	function Tool:Select()
		TransformFrame = transformTemplate:Clone()

		cleanUp.select = GlobalButton.MouseButton1Down:connect(function(object,active)
			if object.Parent == Scope.Current then
			--	if not Selection:Contains(object) then
					Selection:Set{object}
			--	end
			end
		end)
		cleanUp.select_nil = CanvasFrame.MouseButton1Down:connect(function()
			Selection:Set{}
		end)

		cleanUp.selected = Selection.ObjectSelected:connect(function(object,active)
			TransformFrame.Parent = active
		end)
		cleanUp.deselected = Selection.ObjectDeselected:connect(function(object,active)
			if #SelectedObjects > 0 then
				TransformFrame.Parent = Canvas.ActiveLookup[SelectedObjects[#SelectedObjects]]
			else
				TransformFrame.Parent = nil
			end
		end)
		if #SelectedObjects > 0 then
			TransformFrame.Parent = Canvas.ActiveLookup[SelectedObjects[#SelectedObjects]]
		end
	end

	function Tool:Deselect()
		for k,v in pairs(cleanUp) do
			v:disconnect()
		end
		if TransformFrame then
			TransformFrame:Destroy()
			TransformFrame = nil
		end
	end

	ToolManager:AddTool(Tool)
end
