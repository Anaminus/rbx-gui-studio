Widgets = {}

-- fixes AutoButtonColor
local function ResetButtonColor(button)
	local active = button.Active
	button.Active = not active
	button.Active = active
end

local SetZIndex do
	local ZIndexLock = {}
	function SetZIndex(object,z)
		if not ZIndexLock[object] then
			ZIndexLock[object] = true
			object.ZIndex = z
			for _,child in pairs(object:GetChildren()) do
				SetZIndex(child,z)
			end
			ZIndexLock[object] = nil
		end
	end
end

local function SetZIndexOnChanged(object)
	return object.Changed:connect(function(p)
		if p == "ZIndex" then
			SetZIndex(object,object.ZIndex)
		end
	end)
end
