-- test_events.lua

local Application = require("Application")(true)

local function waiter(num)
	num = num or 0

	local function closure()
	--print("== WAITER ==")
	print(string.format("WAITED: %d",num))
	--print("------------")
	end

	return closure;
end

local function test_waiter()
	--delay(waiter, 1000)
	print("BEFORE SLEEP: ", Application.Scheduler:tasksPending())
	print("Task is MAIN: ", Application.Scheduler:inMainFiber())
	sleep(1000)
	print("AFTER SLEEP")
	spawn(waiter)
	print("AFTER SPAWN: ", Application.Scheduler:tasksPending())
end


local function main()
	print("main, waiter: ", waiter)

	for i=1,4 do
		onSignal(waiter(i), "waiting")
	end

	print("Sleep before signaling")
	sleep(2000);
	
	print("signalOne: ", signalOne("waiting"))

	print("AFTER signalOne")
	sleep(500)
	
	print("signalAll: ", signalAll("waiting"))
	sleep(2000)
	
	print("SLEEP AFTER signalAll")
end

--spawn(test_waiter)
--Application:start()
--run(test_waiter)

run(main)