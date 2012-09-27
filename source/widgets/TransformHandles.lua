--[[
Enables the user to transform the position and size of the object bound to
API:
	TransformHandles.Frame              The GUI frame portion
	TransformHandles.Parent             The object currently bound to

	TransformHandles:Destroy()          Destroys the handles
	TransformHandles:SetParent(object)  Sets the save object to bind to
]]
function Widgets.TransformHandles(Canvas)
	local hsize,pad = 6,2 --handle size; padding
	local handleTemplate = Create'ImageButton'{
		BorderSizePixel = 0;
		BackgroundColor3 = Color3.new(1,0,0);
		Size = UDim2.new(0,hsize,0,hsize);
		ZIndex = 10;
	}
	local Frame = Create'Frame'{
		Name = "Transform";
		Transparency = 1;
		Size = UDim2.new(1,0,1,0);
		ZIndex = 10;
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

	local function layoutChanged(key,value)
		if key == 'LayoutMode' then
			if value('Offset') then
				local offsetModeColor = InternalSettings.OffsetModeColor
				for i,v in pairs(Frame:GetChildren()) do
					v.BackgroundColor3 = offsetModeColor
				end
			else
				local scaleModeColor = InternalSettings.ScaleModeColor
				for i,v in pairs(Frame:GetChildren()) do
					v.BackgroundColor3 = scaleModeColor
				end
			end
		end
	end

	local finishDrag
	local conMode = Settings.Changed:connect(layoutChanged)
	layoutChanged('LayoutMode',Settings.LayoutMode)

	local BoundObject
	local Active = nil

	local Handles = {
		Frame = Frame;
		Parent = nil;
	}

	function Handles:SetParent(parent)
		self.Parent = parent
		BoundObject = parent
		Active = Canvas.ActiveLookup[parent]
		Frame.Parent = Active
	end

	function Handles:Destroy()
		if finishDrag then finishDrag() end
		conMode:disconnect()
		conMode = nil
		for k in pairs(self) do
			self[k] = nil
		end
		Frame:Destroy()
		Active = nil
	end

	for i,handle in pairs(Frame:GetChildren()) do
		local name = handle.Name
		handle.MouseButton1Down:connect(function(x,y)
			if Handles.Parent then
				Frame.Visible = false
				finishDrag = Widgets.DragGUI(Active,Vector2.new(x,y),name,{
					OnRelease = function()
						ResetButtonColor(handle)
						BoundObject.Position = Active.Position
						BoundObject.Size = Active.Size
						Frame.Visible = true
						finishDrag = nil
					end;
				})
			end
		end)
	end

	return Handles
end
