
local ffi = require("ffi");

local lua = require("luajit_ffi");
local core_process = require("core_processthreads_l1_1_1");
local WinBase = require("WinBase");


-- Definition of RunLuaThread
-- coming from tinn.c
ffi.cdef[[
int RunLuaThread(void *s);
]]

--
-- This helper routine will take a pointer
-- to cdata, and return a string that contains
-- the memory address
local function CreatePointerString(instance)
	if ffi.abi("64bit") then
		return string.format("0x%016x", tonumber(ffi.cast("int64_t", ffi.cast("void *", instance))))
	elseif ffi.abi("32bit") then
		return string.format("0x%08x", tonumber(ffi.cast("int32_t", ffi.cast("void *", instance))))
	end

	return nil
end


local function PrependThreadParam(codechunk, threadparam)
	if threadparam == nil or codechunk == nil then return codechunk end

	local paramAsString = CreatePointerString(threadparam)

	return string.format("local _ThreadParam = %s\n\n%s", paramAsString, codechunk)
end



local TINNThread = {}
setmetatable(TINNThread, {
	__call = function(self, ...)
		return self:new(...);
	end,
});
local TINNThread_mt = {
	__index = TINNThread;
}


TINNThread.new = function(self, codechunk, param, createSuspended)
	createSuspended = createSuspended or false
	local flags = 0
	if createSuspended then
		flags = CREATE_SUSPENDED
	end

	param = param or nil

	local obj = {
		CodeChunk = codechunk,
		ThreadParam = param,
		Flags = flags,
	};
	setmetatable(obj, TINNThread_mt);

	-- prepend the param to the code chunk if it was supplied
	local threadprogram = PrependThreadParam(codechunk, param)
	local threadId = ffi.new("DWORD[1]")
	obj.Handle = core_process.CreateThread(nil,
		0,
		ffi.C.RunLuaThread,
		ffi.cast("void *", threadprogram),
		flags,
		threadId);

	threadId = threadId[0];
	obj.ThreadId = threadId;

	return obj;
end

function TINNThread:resume()
-- need the following thread access right
--THREAD_SUSPEND_RESUME

	local result = core_process.ResumeThread(self.Handle);
end

function TINNThread:suspend()
	local status = core_process.SuspendThread(self.Handle);
	return status;
end

function TINNThread:yield()
	local status = core_process.SwitchToThread();
	return status;
end
