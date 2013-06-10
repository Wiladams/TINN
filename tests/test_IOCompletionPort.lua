-- test_IOCompletionPort.lua

local ffi = require("ffi");
local IOCompletionPort = require("IOCompletionPort");
local StopWatch = require("StopWatch");

local test_queue = function()
	local iop1, err = IOCompletionPort();

	print(iop1, err);


ffi.cdef[[
	typedef struct {
    HWND hwnd;
    UINT message;
    WPARAM wParam;
    LPARAM lParam;
    DWORD time;
    POINT pt;
} AMSG, *PAMSG;
]]

	printAMSG = function(msg)
		print("time: ", msg.time);
		print("message: ", msg.message);
	end

	-- enqueue a message into the completion port 
	local msg = ffi.new("AMSG");
	msg.message = 42;
	msg.time = 1942;


	-- enqueue the message
	print("== Message to QUEUE ==")
	printAMSG(msg);

	print(iop1:enqueue(msg, ffi.sizeof(msg)));


	-- dequeue the message
	local key, bytes, overlapped = iop1:dequeue(15);

	print("Dequeue: ", key, bytes, overlapped);

	local keymsg = ffi.cast("AMSG *", key);

	print("== Message DEQUEUED ==")
	printAMSG(keymsg);
end

local test_timeout = function()
	local iocp, err = IOCompletionPort();
	local sw = StopWatch();

	local interval = 500;
	local seconds = 30;

	for i=1,seconds*1000/interval do 
		iocp:dequeue(interval);
		print(sw:Seconds());
	end
end

--test_queue();
test_timeout();
