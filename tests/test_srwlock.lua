-- test_srwlock.lua

--[[
	This demonstrates how to use the SRWLock object 
	within Windows.

	The LockFirst() function applies the lock.

	The LockSecond() function tries to obtain the lock
	as well.

	Since this is in fact a single threaded application
	the second function deadlocks.
--]]

local IOProcessor = require("IOProcessor")
local SRWLock = require("SRWLock")


local LockFirst = function(lock)
	print("Lock First - BEGIN")
	print(lock:lock());

	print("Lock First - begin waiting")
	wait(3000)

	print("Lock First - done waiting")

	lock:exit();

	print("Lock First - END")
end

local LockSecond = function(lock)
	print("Lock Second - BEGIN")
	print(lock:lock())
	print("Lock Second - END")
end

local lock1 = SRWLock();

function main()

	spawn(LockFirst,lock1);

	spawn(LockSecond,lock1);
end

run(main)
