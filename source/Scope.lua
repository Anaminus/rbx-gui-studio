--[[
handles the current scope; the object whose children are manipulated by tools
API:
	Scope.Top                   The top of the scope hierarchy
	Scope.Current               The current scope

	Scope:In(object)            Scope into a child object
	Scope:Out()                 Scope out to the parent object
	Scope:GetContainer(object)  Return the ancestor whose parent is the current scope

	Scope.ScopeChanged(object)  Fired after the scope changes
]]
local Scope do
	Scope = {
		Top = nil;
		Current = nil;
	}

	local eventScopeChanged = CreateSignal(Scope,'ScopeChanged')

	local StarterGui = Game:GetService("StarterGui")

	local function hierarchyChanged()
	--	if Scope.Top:IsDescendantOf(Game) then
		if Scope.Top:IsDescendantOf(StarterGui) then -- bug #1
			if Scope.Current ~= Scope.Top then
				if not Scope.Current:IsDescendantOf(Scope.Top) then
					Scope:SetCurrent(Scope.Top)
				end
			end
	--	else -- this is handled by the canvas
		end
	end

	local conChanged
	function Scope:SetCurrent(object)
		if object:IsDescendantOf(self.Top) or object == self.Top then
			self.Current = object
			if conChanged then conChanged:disconnect() end
			conChanged = object.AncestryChanged:connect(hierarchyChanged)
			eventScopeChanged:Fire(object)
		else
			error("Scope:SetCurrent: argument must be top scope or a descendant of top scope",2)
		end
	end

	function Scope:SetTop(object)
		if not object then
			error("Scope:SetTop: argument must be an Instance",2)
		end
		self.Top = object
		self:SetCurrent(object)
	end

	function Scope:In(child)
		if not self.Top then
			error("Scope:In: top scope not set",2)
		end
		if child:IsDescendantOf(self.Top) then
			if child.Parent == self.Current then
				self:SetCurrent(child)
			else
				error("Scope:In: argument must be child of current scope",2)
			end
		else
			error("Scope:In: argument must be descendant of top scope",2)
		end
	end

	function Scope:Out()
		if not self.Top then
			error("Scope:Out: top scope not set",2)
		end
		if self.Current ~= self.Top then
			self:SetCurrent(self.Current.Parent)
		end
	end

	function Scope:GetContainer(object)
		while object.Parent ~= Scope.Current do
			object = object.Parent
			if object == nil then return nil end
		end
		return object
	end
end
