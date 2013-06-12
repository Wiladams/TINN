-- Computicle.lua

local ffi = require("ffi");
local Heap = require("Heap");
local TINNThread = require("TINNThread");
local IOCompletionPort = require("IOCompletionPort");
local core_synch = require("core_synch_l1_2_0");
local errorhandling = require("core_errorhandling_l1_1_1");
local WinBase = require("WinBase");

ffi.cdef[[
typedef struct {
	HANDLE HeapHandle;
	HANDLE IOCPHandle;
	HANDLE ThreadHandle;
} Computicle_t;

typedef struct {
	int32_t		Message;
	UINT_PTR	wParam;
	LONG_PTR	lParam;
} ComputicleMsg;
]]

local Computicle = {
	Threads = {},
}
setmetatable(Computicle, {
	__call = function(self, ...)
		return self:init(...);
	end,
});

local Computicle_mt = {
	__index = Computicle,
}

Computicle.init = function(self, heapHandle, iocpHandle, threadId)
	local obj = {
		Heap = Heap(heapHandle);
		IOCP = IOCompletionPort:init(iocpHandle);
		Thread = TINNThread:init(threadId);
	};

	setmetatable(obj, Computicle_mt);


	return obj;
end

Computicle.packParams = function(self, params, name)
	if not params then
		return "";
	end

	name = name or "_params";

	-- First, create a table that represents the entries
	-- as string pointers
	local res = {};
	for k,v in pairs(params) do
		table.insert(res, string.format("%s['%s'] = TINNThread:StringToPointer(%s);", 
			name, k, TINNThread:PointerToString(v)));
	end

	return table.concat(res, '\n');
end

Computicle.unpackParams = function(self, paramsstring)
end

Computicle.createThreadChunk = function(self, codechunk, params, codeparams)
	local res = {};


	local preamble = [[
local TINNThread = require("TINNThread");
local Computicle = require("Computicle");
]]
	table.insert(res, preamble);

	local paramname = "_params";


	table.insert(res, string.format("%s = {};", paramname));
	table.insert(res, self:packParams(params, paramname));
	table.insert(res, self:packParams(codeparams, paramname));

	table.insert(res, 
		string.format("SELFICLE = Computicle:init(%s.HeapHandle, %s.IOCPHandle);", paramname, paramname));


	table.insert(res, codechunk);

	return table.concat(res, '\n');
end

Computicle.compute = function(self, codechunk, params)
	return  self:create(codechunk, params);
end

-- Create a new computicle
--[[
	codechunk - a simple Lua string
	params - a table of cdata structs that are to be passed on
--]]


Computicle.create = function(self, codechunk, codeparams)
	-- First, create the heap that is going to be used to do stuff
	local heap = Heap:create();

	-- Create an iocompletion port as a receiver of 
	-- messages for the computicle.
	local iocp = IOCompletionPort:create();


	-- Assemble the chunk of code to be passed to the thread
	local params = {
		HeapHandle = heap:getNativeHandle();
		IOCPHandle = iocp:getNativeHandle();
	};
	local threadCode = Computicle:createThreadChunk(codechunk, params, codeparams);


	-- Create the thread that is the actual work 
	-- for the computicle.
	print("== THREAD CODE ==");
	print(threadCode);

	local worker, err = TINNThread({CodeChunk = threadCode, CreateSuspended = params.CreateSuspended});
	table.insert(Computicle.Threads, worker);


	local obj = {
		Heap = heap;
		IOCP = iocp;
		Thread = worker};

	setmetatable(obj, Computicle_mt);

	return obj;
end

Computicle.getStoned = function(self)
	local stone = self.Heap:alloc(ffi.sizeof("Computicle_t"));
	stone = ffi.cast("Computicle_t *", stone);
	stone.HeapHandle = self.Heap:getNativeHandle();
	stone.IOCPHandle = self.IOCP:getNativeHandle();
	stone.ThreadHandle = self.Thread:getNativeHandle();

	return stone;
end

Computicle.getMessage = function(self)
	return self.IOCP:dequeue();
end

Computicle.postMessage = function(self, msg, wParam, lParam)
	-- Create a message object to send to the thread
	local msgSize = ffi.sizeof("ComputicleMsg");
	local newWork = self.Heap:alloc(msgSize);
	newWork = ffi.cast("ComputicleMsg *", newWork);
	newWork.Message = msg;
	newWork.wParam = wParam or 0;
	newWork.lParam = lParam or 0;

	-- post it to the thread's queue
	self.IOCP:enqueue(newWork);

	return true;
end

Computicle.resume = function(self)
	self.Thread:resume();
	return self;
end

Computicle.waitForFinish = function(self)
	local status = core_synch.WaitForSingleObject(self.Thread:getNativeHandle(), ffi.C.INFINITE);
	if status == WAIT_OBJECT_0 then
		return true;
	end


	return false, status;
end


return Computicle;


