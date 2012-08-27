--[[
Creates a frame used for global dragging
Common procedure:
	Button.MouseDown:
		Dragger.MouseUp:
			Disconnect Dragger
			Dragger.Parent = nil
		Dragger.Dragged:
			Update whatever
		Dragger.Parent = (screen of button)
]]
local function CreateDragger(object)
	local dragger = Create'ImageButton'{
		Name = "MouseDrag";
		Position = UDim2.new(-0.25,0,-0.25,0);
		Size = UDim2.new(1.5,0,1.5,0);
		Transparency = 1;
		AutoButtonColor = false;
		Active = true;
		ZIndex = 10;
	}
	dragger.Parent = GetScreen(object)
	return dragger
end
