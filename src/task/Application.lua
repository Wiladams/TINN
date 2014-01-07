-- Application.lua

local Scheduler = require("Scheduler")
local Stopwatch = require("StopWatch")
local Task = require("Task")
local Functor = require("Functor")

-- scheduler plug-ins
local waitForCondition = require("waitForCondition")
local waitForTime = require("waitForTime")
local waitForIO = require("waitForIO")


-- The main application object
local Application = {}
setmetatable(Application, {
	__call = function(self, ...)
		return self:create(...);
	end,
})
local Application_mt = {
	__index = Application,
}

function Application.init(self, ...)
	local sched = Scheduler();

	waitForIO.MessageQuanta = 0;

	local obj = {
		Clock = Stopwatch();
		Scheduler = sched;
		TaskID = 0;
		wfc = waitForCondition(sched);
		wft = waitForTime(sched);
		wfio = waitForIO(sched);
	}
	setmetatable(obj, Application_mt)

	-- Create a task for each add-on
	obj:spawn(obj.wfc.start, obj.wfc)
	obj:spawn(obj.wft.start, obj.wft)
	obj:spawn(obj.wfio.start, obj.wfio)

	return obj;
end

function Application.create(self, makeGlobal)
	local app = self:init()

	if makeGlobal then
		app:exportGlobals();
	end

	return app;
end


-- Add in scheduler plug-ins
--  Predicates
--  Timer
--  IOEvents

function Application.sleep(self, millis)
	self.wft:yield(millis)
end

function Application.delay(self, func, millis)
	millis = millis or 1000

	local function closure()
		self:sleep(millis)
		func();
	end

	return self:spawn(closure)
end

function Application.periodic(self, func, millis)
	millis = millis or 1000

	local closure = nil;
	closure = function()
		while true do
			self:sleep(millis)
			func();
		end
	end

	return self:spawn(closure)
end


function Application.waitFor(self, pred)
	--print("Application.waitFor: ", pred)
	self.wfc:yield(pred)
end

-- taskIsFinished
-- A function that can be used as a predicate
function Application.taskIsFinished(task)
	local function closure()
		return task:getStatus() == "dead"
	end

	return closure
end

function Application.when(self, pred, func)

	local function watchit()
		--print("watchit - BEGIN")
		self:waitFor(pred)
		func()
	end

	self:spawn(watchit)
end

function Application.whenever(self, pred, func)

	local function watchit()
		self:waitFor(pred)
		func()
		self:spawn(watchit)
	end

	self:spawn(watchit)
end

-- Put core scheduler routines in global namespace
function Application.noMoreTasks(self)
	if not self.wfc:tasksArePending() then
		--print("No Conditionals Pending")
		if (self.wft:tasksPending() < 1) then
			--print("No Timers Pending")
			if not (self.Scheduler:tasksPending() > 3) then
				--print("No Tasks Pending: ", self.Scheduler:tasksPending())
				return true;
			end
		end
	end

	return false;
end

function Application.getNewTaskID(self)
	self.TaskID = self.TaskID + 1;
	return self.TaskID;
end

function Application.spawn(self, func, ...)
	local task = Task(func, ...)
	task.TaskID = self:getNewTaskID();
	self.Scheduler:scheduleTask(task, ...);

	return task;
end


function Application.stop(self)
	self.Scheduler:stop();
end


function Application.yield(self, ...)
	return self.Scheduler.yield(...)
end


function Application.start(self)
	self.Scheduler:start()
end

function Application.run(self, func, ...)
	self:when(Functor(self.noMoreTasks, self), Functor(self.stop, self));
	
	if func ~= nil then
		self:spawn(func, ...)
	end

	return self:start();
end

function Application.exportGlobals(self)
	_G.delay = Functor(self.delay, self);
	_G.periodic = Functor(self.periodic, self);
	_G.run = Functor(self.run, self);
	_G.sleep = Functor(self.sleep, self);
	_G.spawn = Functor(self.spawn, self);
	_G.stop = Functor(self.stop, self);
	_G.waitFor = Functor(self.waitFor, self);
	_G.when = Functor(self.when, self);
	_G.whenever = Functor(self.whenever, self);
	_G.yield = Functor(self.yield, self);

	return self;
end


return Application
