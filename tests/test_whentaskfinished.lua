-- test_when.lua

local Application = require("Application")


local counter = 0;


local sleepForAwhile = function()
	local insideJob = function()
		sleep(3*1000)
		return true
	end

	return spawn(insideJob)
end

local countTo25 = function()
	while true do
		sleep(200)
		if counter >= 25 then 
			return true;
		end
	end
end

local function showAppreciation()
	print("Thanks Sleeper!")
end



local function main()

	-- do some other work to prove that life will
	-- continue, even after the sleeper task completes
	periodic(function() counter = counter + 1; print("Counter: ", counter) end, 500)

	-- start a task which will just sleep for a while
	when(taskIsFinished(sleepForAwhile()), showAppreciation)


	when(taskIsFinished(spawn(countTo25)), function()  print("End of Time!!"); stop() end)
end


run(main)
