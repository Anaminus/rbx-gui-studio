--[[ActionManager

A simple framework for mananging actions. It is designed so that multiple
actions can run at the same time, or conditionally, depending on other running
actions.

API:

Fields:

ActionManager.ActionRunning
	A table of actions that are currently running. The table contains
	string/bool pairs, with the string being the name of an action.

ServiceStatus.Status
	Whether the service is started or not.

Methods:

ActionManager:AddAction ( name, action )
	Adds a new action called `name`.
	`action` is a table with the following fields:
		Start: A function called when the action is started.
		Stop:  A function called when the action should stop.
	Note that stop functions should be able to handle no arguments, in the
	event that the action is automatically stopped by the service.

ActionManager:StartAction ( name, ... )
	Begins action `name`. The remaining arguments are passed to the
	action's Start function.

ActionManager:StopAction ( name, ... )
	Stops action `name`, if it is running. The remaining arguments are
	passed to the action's Start function.

ActionManager:Start ( )
	Starts the manager. If an action named "Default" is present, it will
	be started.

ActionManager:Stop ( )
	Stops the manager. Any running actions will be stopped.

Events:

ActionManager.ActionStarted ( name )
	Fired after action `name` has been started.

ActionManager.ActionStopped ( name )
	Fired after action `name` has been stopped.

]]

do
	ActionManager = {}

	local StartAction = {}
	local StopAction = {}
	local ActionRunning = {}
	ActionManager.ActionRunning = ActionRunning

	local eventActionStarted = CreateSignal(ActionManager,'ActionStarted')
	local eventActionStopped = CreateSignal(ActionManager,'ActionStopped')

	function ActionManager:AddAction(name,action)
		if action.Start and action.Stop then
			if StartAction[name] or StopAction[name] then
				error("action `" .. name .. "` was already added",2)
			else
				StartAction[name] = action.Start
				StopAction[name] = action.Stop
			end
		else
			error("2nd argument requires both a 'Start' and a 'Stop' field.",2)
		end
	end

	function ActionManager:StartAction(name,...)
		if self.Status('Stopped') or self.Status('Stopping') then return end

		if StartAction[name] then
			ActionRunning[name] = true
			StartAction[name](...)
			eventActionStarted:Fire(name)
		else
			error("`" .. name .. "` is not a valid action",2)
		end
	end

	function ActionManager:StopAction(name,...)
		if StopAction[name] then
			StopAction[name](...)
			ActionRunning[name] = nil
			eventActionStopped:Fire(name)
		else
			error("`" .. name .. "` is not a valid action",2)
		end
	end

	AddServiceStatus{ActionManager;
		Start = function(self)
			if StartAction.Default then
				self:StartAction('Default')
			end
		end;
		Stop = function(self)
			for name in pairs(StopAction) do
				if ActionRunning[name] then
					self:StopAction(name)
				end
			end
		end;
	}
end
