-- test_waitFor.lua

local IOProcessor = require("IOProcessor")
local parallel = require("parallel")()
local Timer = require("Timer")

local count = 0;


local goal1 = function()
  return count >= 5;
end

local goal2 = function()
  return count >= 10;
end

local goal3 = function()
  return count >= 15;
end

local finalGoal = function()
  waitFor(goal1)
print("Goal 1 Attained.")
  waitFor(goal2)
print("Goal 2 Attained..")
  waitFor(goal3)
print("Goal 3 Attained...")
print("All Goals Attained!!")

  -- Once all the goals have been met
  -- stop the scheduler.
  stop();
end

-- setup a timer to increment the count
-- every 500 milliseconds
local incrTimer = Timer({Period = 500; OnTime = function(timer) count = count+1 end})

spawn(finalGoal)	

run()

