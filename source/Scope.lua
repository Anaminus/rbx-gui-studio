--[[
handles the current scope; the object whose children are manipulated by tools
API:
	Scope.Top                   The top of the scope hierarchy
	Scope.Current               The current scope

	Scope:In(object)            Scope into a child object
	Scope:Out()                 Scope out to the parent object

	Scope.ScopeChanged(object)  Fired after the scope changes
]]
local Scope do
	Scope = {
		Top = nil;
		Current = nil;
	}

	local eventScopeChanged = CreateSignal(Scope,'ScopeChanged')

	function Scope:SetTop(object)
		if not object then
			error("Scope:SetTop: argument must be an Instance",2)
		end
		self.Top = object
		self.Current = object
		eventScopeChanged:Fire(object)
	end

	function Scope:In(child)
		if not self.Top then
			error("Scope:In: top scope not set",2)
		end
		if self.Top:IsAncestorOf(child) then
			if child.Parent == self.Current then
				self.Current = child
				eventScopeChanged:Fire(child)
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
			self.Current = self.Current.Parent
			eventScopeChanged:Fire(self.Current)
		end
	end

	Canvas.Started:connect(function(screen)
		Scope:SetTop(screen)
	end)
end
