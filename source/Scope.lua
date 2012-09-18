--[[Scope
Handles scoping; the object whose children are manipluated by tools.
This automatically handles hierarchy changes; if the current scope
is moved outside of the top scope, then the current scope is set to the top.

API:
	Scope.Top                   The top of the scope hierarchy.
	Scope.Current               The current scope.

	Scope:In(object)            Set the scope to a child object.
	                            The object must be a child of the current scope.
	Scope:Out()                 Set the current scope to the parent objec.
	                            Does not go above the top scope.
	Scope:SetCurrent(object)    Explicitly sets the current scope.
	                            The object must be, or be a descendant of, the top scope.
	Scope:SetTop(object)        Sets the top scope. The current scope is automatically set to the top.
	Scope:GetContainer(object)  Return the ancestor of the object whose parent is the current scope.

	Scope.ScopeChanged(object)  Fired after the scope changes, passing the new scope.
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
					print("Scope was set to",Scope.Top)
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
				print("Scope in to",child)
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
			print("Scope out to",self.Current.Parent)
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
