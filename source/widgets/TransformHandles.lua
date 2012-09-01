--[[
Enables the user to transform the position and size of the object bound to
API:
	TransformHandles.Frame              The GUI frame portion
	TransformHandles.Parent             The object currently bound to

	TransformHandles:SetParent(object)  Sets the save object to bind to
]]
function Widgets.TransformHandles(Canvas,Mouse,event)
	if not event then
		event = CreateEventManager()
	end

	local hsize,pad = 6,2 --handle size; padding
	local handleTemplate = Create'ImageButton'{
		BorderSizePixel = 0;
		BackgroundColor3 = Color3.new(1,0,0);
		Size = UDim2.new(0,hsize,0,hsize);
	}
	local Frame = Create'Frame'{
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

	local Dragger = Widgets.Dragger()
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
		for k in pairs(self) do
			self[k] = nil
		end
		Frame:Destroy()
		Dragger:Destroy()
		event:disconnect('mouse_up','drag')
		Active = nil
	end

	do local handle = Frame.TopLeft
		handle.MouseButton1Down:connect(function(x,y)
			if Handles.Parent then
				local offset = Vector2.new(x,y) - Active.AbsolutePosition
				local high_pos = Active.Position + Active.Size
				event.mouse_up = Dragger.MouseButton1Up:connect(function()
					event:disconnect('mouse_up','drag')
					Dragger.Parent = nil
					ResetButtonColor(handle)
					BoundObject.Position = Active.Position
					BoundObject.Size = Active.Size
				end)
				event.drag = Dragger.MouseMoved:connect(function(x,y)
					local pos = Vector2.new(x,y) - offset - Active.Parent.AbsolutePosition
					pos = UDim2.new(0,pos.x,0,pos.y)
					Active.Position = pos
					Active.Size = high_pos - pos
				end)
				Dragger.Parent = GetScreen(Active)
			end
		end)
	end

	do local handle = Frame.BottomRight
		handle.MouseButton1Down:connect(function(x,y)
			if Handles.Parent then
				local offset = Vector2.new(x,y) - Active.AbsolutePosition - Active.AbsoluteSize
				event.mouse_up = Dragger.MouseButton1Up:connect(function()
					event:disconnect('mouse_up','drag')
					Dragger.Parent = nil
					ResetButtonColor(handle)
					BoundObject.Size = Active.Size
				end)
				event.drag = Dragger.MouseMoved:connect(function(x,y)
					local pos = Vector2.new(x,y) - offset - Active.Parent.AbsolutePosition
					pos = UDim2.new(0,pos.x,0,pos.y)
					Active.Size = pos - Active.Position
				end)
				Dragger.Parent = GetScreen(Active)
			end
		end)
	end

	return Handles
end
