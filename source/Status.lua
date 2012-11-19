--[[Status
Displays the current status of the program.

Messages added to the Status are added to a stack. The message on the top of the stack is displayed.
Messages consist of multiple strings, which are ordered using a numerical index.
The visiblity of these "message parts" may be toggled, so that only certain parts of the message are displayed.

Status:Add('Example',{[1] = 'herp', [2] = 'derp'})    -> ""
Status['Example'][1] = true                           -> "herp"
Status['Example'][2] = true                           -> "herp; derp"
Status['Example'][1] = false                          -> "derp"

API:
	Status.StatusFrame              The GUI that displays the status message.
	Status:Add(ref,parts)           Adds a new Message to the top of the stack.
	                                `parts` is a table of strings that make up the message.
	                                Returns the new message.
	Status:Remove(ref)              Removes the Message referenced by `ref`.
	Status[ref]                     Returns the Message referenced by `ref`.

	Message:GetString()             Returns the string generated by this message.
	Message[index] = bool           Sets a whether a message part is visible.
	Message{[index]=bool, ...}      Sets visibility of multiple message parts at once.
]]

do
	local StatusFrame = Create'TextLabel'{
		Name = "Status Label";
		BackgroundTransparency = 1;
		Text = "";
		TextColor3 = InternalSettings.GuiColor.Text;
		FontSize = 'Size9';
		TextWrapped = true;
		TextXAlignment = 'Left';
		TextYAlignment = 'Top';
	}

	local MessageLookup = {}
	local MessageStack = {}

	Status = {
		StatusFrame = StatusFrame;
	}

	local function updateDisplay()
		if #MessageStack > 0 then
			StatusFrame.Text = MessageLookup[MessageStack[#MessageStack]]:GetString()
		else
			StatusFrame.Text = ""
		end
	end

	local mtMessage = {
		__index = {
			Destroy = function(self)
				setmetatable(self,nil)
			end;
			GetString = function(self)
				local messageSet = self.messageSet
				local visibleSet = self.visibleSet
				local sorted = {}
				for i,v in pairs(messageSet) do
					if visibleSet[i] and type(i) == 'number' then
						sorted[#sorted+1] = i
					end
				end
				table.sort(sorted)
				local message = {}
				for _,i in pairs(sorted) do
					message[#message+1] = tostring(messageSet[i])
				end
				return table.concat(message," ")
			end;
		};
		__newindex = function(self,k,v)
			self.visibleSet[k] = v
			updateDisplay()
		end;
		__call = function(self,set)
			local visibleSet = self.visibleSet
			for i,v in pairs(set) do
				if v == false then
					visibleSet[i] = nil
				else
					visibleSet[i] = true
				end
			end
			updateDisplay()
		end;
	}

	local function createMessage(data)
		return setmetatable({ messageSet = data or {}, visibleSet = {} },mtMessage)
	end

	function Status:Add(ref,data)
		-- if the reference doesn't exist, add it to the stack
		if not MessageLookup[ref] then
			table.insert(MessageStack,ref)
			MessageLookup[ref] = createMessage(data)
		end
		updateDisplay()
		return MessageLookup[ref]
	end

	function Status:Remove(ref)
		local message = MessageLookup[ref]
		if message ~= nil then
			for i = #MessageStack,1,-1 do
				if MessageStack[i] == ref then
					table.remove(MessageStack,i)
					break
				end
			end
			MessageLookup[ref] = nil
			message:Destroy()
			updateDisplay()
		end
	end

	setmetatable(Status,{__index = MessageLookup})
end