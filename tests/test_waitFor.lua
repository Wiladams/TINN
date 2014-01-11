-- test_waitFor.lua

local Application = require("Application")

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
periodic(function() count = count+1 end, 500)

spawn(finalGoal)	

run()

