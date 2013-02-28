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
	local Frame do
		local handleTemplate = Create'ImageButton'{
			BorderSizePixel = 0;
			BackgroundColor3 = Color3.new(1,0,0);
			Size = UDim2.new(0,hsize,0,hsize);
			ZIndex = 10;
		}
		local borderTemplate = Create'Frame'{
			BorderSizePixel = 0;
			BackgroundTransparency = 0.5;
			BackgroundColor3 = Color3.new(0, 0, 0);
		}
		Frame = Create'Frame'{
			ZIndex = 10;
			Size = UDim2.new(1, 0, 1, 0);
			Name = "Transform";
			BackgroundTransparency = 1;
			Create(handleTemplate:Clone()){
				Size = UDim2.new(0, hsize, 0, hsize);
				Name = "TopLeft";
				Position = UDim2.new(0, -hsize-pad, 0, -hsize-pad);
				Create(borderTemplate:Clone()){
					Size = UDim2.new(1, 2, 0, 1);
					Name = "Top";
					Position = UDim2.new(0, -1, 0, -1);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(0, 1, 1, -pad);
					Name = "Right";
					Position = UDim2.new(1, 0, 0, 0);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(1, -pad+1, 0, 1);
					Name = "Bottom";
					Position = UDim2.new(0, -1, 1, 0);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(0, 1, 1, 0);
					Name = "Left";
					Position = UDim2.new(0, -1, 0, 0);
				};
			};
			Create(handleTemplate:Clone()){
				Size = UDim2.new(0, hsize, 0, hsize);
				Name = "Top";
				Position = UDim2.new(0.5, -hsize/2, 0, -hsize-pad);
				Create(borderTemplate:Clone()){
					Size = UDim2.new(1, 2, 0, 1);
					Name = "Top";
					Position = UDim2.new(0, -1, 0, -1);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(0, 1, 1, -pad);
					Name = "Right";
					Position = UDim2.new(1, 0, 0, 0);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(0, 1, 1, -pad);
					Name = "Left";
					Position = UDim2.new(0, -1, 0, 0);
				};
			};
			Create(handleTemplate:Clone()){
				Size = UDim2.new(0, hsize, 0, hsize);
				Name = "TopRight";
				Position = UDim2.new(1, pad, 0, -hsize-pad);
				Create(borderTemplate:Clone()){
					Size = UDim2.new(1, 2, 0, 1);
					Name = "Top";
					Position = UDim2.new(0, -1, 0, -1);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(0, 1, 1, 0);
					Name = "Right";
					Position = UDim2.new(1, 0, 0, 0);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(0, 1, 1, -pad);
					Name = "Left";
					Position = UDim2.new(0, -1, 0, 0);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(1, -pad+1, 0, 1);
					Name = "Bottom";
					Position = UDim2.new(0, pad, 1, 0);
				};
			};
			Create(handleTemplate:Clone()){
				Size = UDim2.new(0, hsize, 0, hsize);
				Name = "Right";
				Position = UDim2.new(1, pad, 0.5, -hsize/2);
				Create(borderTemplate:Clone()){
					Size = UDim2.new(1, -pad+1, 0, 1);
					Name = "Top";
					Position = UDim2.new(0, pad, 0, -1);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(0, 1, 1, 0);
					Name = "Right";
					Position = UDim2.new(1, 0, 0, 0);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(1, -pad+1, 0, 1);
					Name = "Bottom";
					Position = UDim2.new(0, pad, 1, 0);
				};
			};
			Create(handleTemplate:Clone()){
				Size = UDim2.new(0, hsize, 0, hsize);
				Name = "BottomRight";
				Position = UDim2.new(1, pad, 1, pad);
				Create(borderTemplate:Clone()){
					Size = UDim2.new(1, -pad+1, 0, 1);
					Name = "Top";
					Position = UDim2.new(0, pad, 0, -1);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(0, 1, 1, 0);
					Name = "Right";
					Position = UDim2.new(1, 0, 0, 0);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(0, 1, 1, -pad);
					Name = "Left";
					Position = UDim2.new(0, -1, 0, pad);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(1, 2, 0, 1);
					Name = "Bottom";
					Position = UDim2.new(0, -1, 1, 0);
				};
			};
			Create(handleTemplate:Clone()){
				Size = UDim2.new(0, hsize, 0, hsize);
				Name = "Bottom";
				Position = UDim2.new(0.5, -hsize/2, 1, pad);
				Create(borderTemplate:Clone()){
					Size = UDim2.new(0, 1, 1, -pad);
					Name = "Right";
					Position = UDim2.new(1, 0, 0, pad);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(0, 1, 1, -pad);
					Name = "Left";
					Position = UDim2.new(0, -1, 0, pad);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(1, 2, 0, 1);
					Name = "Bottom";
					Position = UDim2.new(0, -1, 1, 0);
				};
			};
			Create(handleTemplate:Clone()){
				Size = UDim2.new(0, hsize, 0, hsize);
				Name = "BottomLeft";
				Position = UDim2.new(0, -hsize-pad, 1, pad);
				Create(borderTemplate:Clone()){
					Size = UDim2.new(1, -pad+1, 0, 1);
					Name = "Top";
					Position = UDim2.new(0, -1, 0, -1);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(0, 1, 1, -pad);
					Name = "Right";
					Position = UDim2.new(1, 0, 0, pad);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(0, 1, 1, 0);
					Name = "Left";
					Position = UDim2.new(0, -1, 0, 0);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(1, 2, 0, 1);
					Name = "Bottom";
					Position = UDim2.new(0, -1, 1, 0);
				};
			};
			Create(handleTemplate:Clone()){
				Size = UDim2.new(0, hsize, 0, hsize);
				Name = "Left";
				Position = UDim2.new(0, -hsize-pad, 0.5, -hsize/2);
				Create(borderTemplate:Clone()){
					Size = UDim2.new(1, -pad+1, 0, 1);
					Name = "Top";
					Position = UDim2.new(0, -1, 0, -1);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(0, 1, 1, 0);
					Name = "Left";
					Position = UDim2.new(0, -1, 0, 0);
				};
				Create(borderTemplate:Clone()){
					Size = UDim2.new(1, -pad+1, 0, 1);
					Name = "Bottom";
					Position = UDim2.new(0, -1, 1, 0);
				};
			};
		};
	end

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

	local statusRef = 'TransformHandles'
	local status = {"Resize selected objects."}
	local statusMessage

	function Handles:Destroy()
		if finishDrag then finishDrag() end
		conMode:disconnect()
		conMode = nil
		for k in pairs(self) do
			self[k] = nil
		end
		Frame:Destroy()
		Status:Remove(statusRef)
		Active = nil
	end


	for i,handle in pairs(Frame:GetChildren()) do
		local name = handle.Name
		handle.MouseButton1Down:connect(function(x,y)
			if statusMessage then statusMessage:Hide(1) end
			if Handles.Parent then
				Frame.Visible = false
				local objectList = Selection:Get()
				local activeList = {}
				local activeLookup = Canvas.ActiveLookup
				for i,object in pairs(objectList) do
					activeList[i] = activeLookup[object]
				end
				finishDrag = Widgets.DragGUI(activeList,Active,Vector2.new(x,y),name,{
					OnRelease = function()
						ResetButtonColor(handle)
						for i,active in pairs(activeList) do
							local object = objectList[i]
							object.Position = active.Position
							object.Size = active.Size
						end
						Frame.Visible = true
						finishDrag = nil
						Status:Remove(statusRef)
					end;
				},nil,true)
			end
		end)
		handle.MouseEnter:connect(function()
			statusMessage = Status:Add(statusRef,status)
			statusMessage:Show(1)
		end)
		handle.MouseLeave:connect(function()
			Status:Remove(statusRef)
		end)
	end

	return Handles
end
