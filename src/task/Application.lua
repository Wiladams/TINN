-- Application.lua

if Application_Included then
	return Application;
end

Application_Included = true;

local parallel = require("parallel")
local Scheduler = require("Scheduler")
local Stopwatch = require("StopWatch")

local Application = {
	Clock = Stopwatch();
	Scheduler = Scheduler();
}




-- export all the functions in parallel
-- to the global namespace
parallel();

-- Create some of our own globals
function run(func, ...)
	return Application.Scheduler:run(func, ...);
end

function spawn(func, ...)
	return Application.Scheduler:spawn(func, ...);
end

function stop()
	return Application.Scheduler:stop();
end

function yield(...)
	return Application.Scheduler:yield(...);
end

