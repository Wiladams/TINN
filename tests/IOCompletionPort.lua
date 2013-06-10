
local ffi = require("ffi");
local core_io = require("core_io_l1_1_1");
local errorhandling = require("core_errorhandling_l1_1_1");
local WinBase = require("WinBase");

ffi.cdef[[
typedef struct {
	HANDLE	Handle;
} IOCompletionHandle;
]]
IOCompletionHandle = ffi.typeof("IOCompletionHandle")

IOCompletionHandle_mt = {
	__index = {

	},

}


local IOCompletionPort = {}
setmetatable(IOCompletionPort, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local IOCompletionPort_mt = {
	__index = IOCompletionPort,
}

IOCompletionPort.create = function(self, ExistingCompletionPort, FileHandle, NumberOfConcurrentThreads)
	FileHandle = FileHandle or INVALID_HANDLE_VALUE;
	NumberOfConcurrentThreads = NumberOfConcurrentThreads or 0
	local CompletionKey = 0;

	local rawhandle = core_io.CreateIoCompletionPort(FileHandle,
		ExistingCompletionPort,
		CompletionKey,
		NumberOfConcurrentThreads);

	if rawhandle == nil then
		return false, errorhandling.GetLastError();
	end

	return self:init(rawhandle);
end

IOCompletionPort.init = function(self, rawhandle)

	local obj = {
		Handle = IOCompletionHandle(rawhandle);
--		ConcurrentThreads = nThreads;
--		CompletionThreads = {};
--		CompletionPortHandles = {};
	};
	setmetatable(obj, IOCompletionPort_mt);

	return obj;
end

IOCompletionPort.getNativeHandle = function(self)
	return self.Handle.Handle;
end

IOCompletionPort.addWorkerThread = function(self, newthread)
	local Key = ffi.cast("ULONG_PTR", 0);

	local rawhandle = core_io.CreateIoCompletionPort(newthread:getNativeHandle(),
		self:getNativeHandle(),
		Key,
		0);

	if rawhandle == nil then
		return false, errorhandling.GetLastError();
	end

	-- Associate the completion port handle with
	-- the thread
	--self.CompletionPortHandles[handle] = newthread
	--self.CompletionThreads[newthread] = handle

	return IOCompletionPort(rawhandle);
end

IOCompletionPort.enqueue = function(self, dwCompletionKey, dwNumberOfBytesTransferred, lpOverlapped)
	if not dwCompletionKey then
		return false, "no data specified"
	end

	dwNumberOfBytesTransferred = dwNumberOfBytesTransferred or 0;

	local status = core_io.PostQueuedCompletionStatus(self:getNativeHandle(),
		dwNumberOfBytesTransferred,
		ffi.cast("ULONG_PTR",ffi.cast("void *", dwCompletionKey)),
		lpOverlapped);
	
	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return self;
end

IOCompletionPort.dequeue = function(self, dwMilliseconds)
	dwMilliseconds = dwMilliseconds or ffi.C.INFINITE;

	local lpNumberOfBytesTransferred = ffi.new("DWORD[1]");
	local lpCompletionKey = ffi.new("ULONG_PTR [1]");	-- PULONG_PTR
	local lpOverlapped = ffi.new("LPOVERLAPPED[1]");
	local status = core_io.GetQueuedCompletionStatus(self:getNativeHandle(),
    	lpNumberOfBytesTransferred,
    	lpCompletionKey,
    	lpOverlapped,
    	dwMilliseconds);

	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return lpCompletionKey[0], lpNumberOfBytesTransferred[0], lpOverlapped[0];
end


return IOCompletionPort;
