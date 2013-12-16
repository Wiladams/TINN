
local ffi = require("ffi");

--local lua = require("luajit_ffi");
local errorhandling = require("core_errorhandling_l1_1_1");
local core_process = require("core_processthreads_l1_1_1");
local WinBase = require("WinBase");
local tinn = ffi.load("tinn.exe");


-- Definition of RunLuaThread
-- coming from tinn.c
ffi.cdef[[
int RunLuaScript(void *s);
]]



local TINNThread = {}
setmetatable(TINNThread, {
	__call = function(self, ...)
		return self:create(...);
	end,

	__index = {

		StringToPointer = function(self, str)
			local num = tonumber(str);
			if not num then
				return nil, "invalid number";
			end

			return ffi.cast("void *", ffi.cast("intptr_t", num));
		end,


		-- This helper routine will take a pointer
		-- to cdata, and return a string that contains
		-- the memory address
		-- tonumber(ffi.cast('intptr_t', ffi.cast('void *', ptr)))
		PointerToString = function(self, instance)
			if ffi.abi("64bit") then
				return string.format("0x%016x", tonumber(ffi.cast("int64_t", ffi.cast("void *", instance))))
			elseif ffi.abi("32bit") then
				return string.format("0x%08x", tonumber(ffi.cast("int32_t", ffi.cast("void *", instance))))
			end

			return nil;
		end,
		
	};
});

local TINNThread_mt = {
	__index = TINNThread;
}

TINNThread.init = function(self, rawhandle)
	local obj = {
		Handle = rawhandle;
	};
	setmetatable(obj, TINNThread_mt);

	return obj;
end

TINNThread.create = function(self, params)
	local rawhandle = nil;

	if not params then
		rawhandle = core_process.GetCurrentThread();
	else
		if not params.CodeChunk then
			return false, 'no code chunk specified';
		end

		local flags = 0
		if params.CreateSuspended then
			flags = CREATE_SUSPENDED;
		end

		--local obj = {
		--	ThreadParam = params.Param,
		--	Flags = flags,
		--};


		local pthreadId = ffi.new("DWORD[1]")
		rawhandle = core_process.CreateThread(nil,
			0,
			tinn.RunLuaScript,
			ffi.cast("void *", params.CodeChunk),
			flags,
			pthreadId);
		--	local threadId = pthreadId[0];
	end

	if rawhandle == nil then
		return false, errorhandling.GetLastError();
	end


	return self:init(rawhandle);
end



TINNThread.getNativeHandle = function(self)
	return self.Handle;
end

TINNThread.getProcessId = function(self)
	local status = core_process.GetProcessIdOfThread(self:getNativeHandle());
	
	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return status;
end


TINNThread.getThreadId = function(self)
	local status = core_process.GetThreadId(self.Handle);
	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return status;
end


TINNThread.resume = function(self)
-- need the following thread access right
--THREAD_SUSPEND_RESUME

	local result = core_process.ResumeThread(self.Handle);
end

TINNThread.suspend = function(self)
	local status = core_process.SuspendThread(self.Handle);
	return status;
end

TINNThread.yield = function(self)
	local status = core_process.SwitchToThread();

	return status;
end


return TINNThread;
