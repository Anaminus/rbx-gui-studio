local History do
	History = {
		UndoStack = {};
		RedoStack = {};
	}

	function History:PushState(state)
		local undo,redo = self.UndoStack,self.RedoStack
		undo[#undo+1] = state
		for i = 1,#redo do redo[i] = nil end
	end

	function History:Undo(state)
		local undo,redo = self.UndoStack,self.RedoStack
		local prev = undo[#undo]; undo[#undo] = nil
		if prev then
			redo[#redo+1] = state
			return prev
		end
	end

	function History:Redo(state)
		local undo,redo = self.UndoStack,self.RedoStack
		local next = redo[#redo]; redo[#redo] = nil
		if next then
			undo[#undo+1] = state
			return next
		end
	end
end
