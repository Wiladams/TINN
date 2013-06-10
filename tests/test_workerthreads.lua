-- test_workerthreads.lua

local ffi = require("ffi");
local core_synch = require("core_synch_l1_2_0");
local IOCompletionPort = require("IOCompletionPort");
local TINNThread = require("TINNThread");
local AMSG = require("AMSG");
local Heap = require("Heap");

local workerTmpl = [==[
local ffi = require("ffi");
local core_synch = require("core_synch_l1_2_0");
local Heap = require("Heap");
local IOCompletionPort = require("IOCompletionPort");
local TINNThread = require("TINNThread");
local MSG = require("AMSG");
local random = math.random;

local myThread, err = TINNThread();
local threadId = myThread:getThreadId();

local QueueHandle = ffi.cast("HANDLE", ffi.cast("intptr_t", %s));
local HeapHandle = ffi.cast("HANDLE", ffi.cast("intptr_t", %s));

local iocp, err = IOCompletionPort:init(QueueHandle);
local memman, err = Heap(HeapHandle);


while true do 
	local key, bytes, overlap = iocp:dequeue();
	
	if not key then 
		break;
	end
	
	--print("THREAD: ", ffi.cast("void *",key));
	--MSG.print(key);
	memman:free(ffi.cast("void *",key));
end
]==];





local main = function()
	local memman = Heap:create();
	local threads = {};

	local iocp, err = IOCompletionPort();

	if not iocp then
		return false, err;
	end

	-- launch worker threads
	local iocphandle = TINNThread:CreatePointerString(iocp:getNativeHandle());
	local heaphandle = TINNThread:CreatePointerString(memman:getNativeHandle());
	local codechunk = string.format(workerTmpl, iocphandle, heaphandle);

	for i=1,4 do 
		local worker, err = TINNThread({CodeChunk = codechunk});
		table.insert(threads, worker);
	end

	-- continuously put 'work' items into queue
	local numWorkItems = 1000;
	local counter = 0;
	local sleepInterval = 50;
	local workSize = ffi.sizeof("AMSG");

	while true do
		for i = 1,numWorkItems do
			local newWork = memman:alloc(workSize);
			ffi.cast("AMSG *",newWork).message = (counter*numWorkItems)+i;
			iocp:enqueue(newWork, workSize);
		end

		if (counter % 100) == 0 then
			print("Interval: ", counter);
		end

		collectgarbage();
		counter = counter + 1;
		
		-- The worker threads should continue to get work done
		-- while we sleep for a little bit
		core_synch.Sleep(sleepInterval);
	end
end

main();


