-- test_coreprocessthreads.lua

local ffi = require("ffi");
local procthreads = require("core_processthreads_l1_1_1");
local Handle = require("Handle")
local kernel32 = require("win_kernel32");
local k32Lib = kernel32.Lib;


local OSProcess={}

setmetatable(OSProcess, 
{
	__call = function(self,...) 
		return OSProcess.new(...);
	end,
});

local OSProcess_mt = {
	__index = OSProcess;
}

OSProcess.new = function(...)
	local nargs = select('#',...);
	
	local procHandle = nil;


	if nargs == 0 then
		procHandle = procthreads.GetCurrentProcess();
	elseif nargs == 1 then
		procHandle = select(1,...);
	end
	
	if procHandle == nil then
		return false, k32Lib.GetLastError();
	end

	local obj = {
		Handle = Handle(procHandle);
	}
	setmetatable(obj, OSProcess_mt);

	return obj;
end

OSProcess.clone = function(self, desiredAccess, inheritable)
	desiredAccess = desiredAccess or ffi.C.PROCESS_ALL_ACCESS;
	inheritable = inheritable or false;

	local procHandle = procthreads.OpenProcess(desiredAccess, inheritable, self:getId());

	if procHandle == nil then
		local err = k32Lib.GetLastError();
print("OpenProcess failed: ", err);

		return false, err;
	end

	return OSProcess(procHandle);
end

OSProcess.getExitCode = function(self)
	local lpExitCode = ffi.new("DWORD[1]");
	local res = procthreads.GetExitCodeProcess(self.Handle.Handle, lpExitCode);

	if res == 0 then
		return false, k32Lib.GetLastError();
	end

	return lpExitCode[0];
end

OSProcess.getHandleCount = function(self)
	local lpHandleCount = ffi.new("DWORD[1]");
	local res = procthreads.GetProcessHandleCount(self.Handle.Handle, lpHandleCount);

	if res == 0 then
		return false, k32Lib.GetLastError();
	end

	return lpHandleCount[0];
end

OSProcess.getId = function(self)
	return procthreads.GetProcessId(self.Handle.Handle);
end

OSProcess.getPriorityClass = function(self)
	local res = procthreads.GetPriorityClass(self.Handle.Handle);
	if res == 0 then
		return false, k32Lib.GetLastError();
	end

	return res;
end

OSProcess.getSessionId = function(self)
	local lpSessionId = ffi.new("DWORD[1]");
	local res = procthreads.ProcessIdToSessionId(self:getId(), lpSessionId);
	if res == 0 then
		return false, k32Lib.GetLastError();
	end

	return lpSessionId[0];
end

local	FILETIME = ffi.typeof("FILETIME");

OSProcess.getTimes = function(self)
	local lpCreationTime = FILETIME();
	local lpExitTime = FILETIME();
	local lpKernelTime = FILETIME();
	local lpUserTime = FILETIME();

	local res = procthreads.GetProcessTimes(self.Handle.Handle,
	    lpCreationTime,
    	lpExitTime,
    	lpKernelTime,
    	lpUserTime);

	if res == 0 then
		return false, k32Lib.GetLastError();
	end

	return lpCreationTime, lpExitTime, lpKernelTime, lpUserTime;
end


OSProcess.isActive = function(self)
	return self:getExitCode() == ffi.C.STILL_ACTIVE;
end

OSProcess.terminate = function(self, exitCode)
	local res = procthreads.TerminateProcess(self.Handle.Handle, exitCode);

	if res == 0 then
		return false, k32Lib.GetLastError();
	end

	return true;
end







local test_ProcessBasics = function()
	local myProcess, err = OSProcess();

	if not myProcess then
		print("Error from OSProcess(): ", err);
		return false;
	end

	print("Process ID: ", myProcess:getId());
	print("Is Inheritable: ", myProcess.Handle:isInheritable());
	print("Protected from Close: ", myProcess.Handle:isProtectedFromClose());
end

local test_CloneProcess = function()
	local myProc, err = OSProcess();
print("My Proc: ", myProc);

	local handle2, err = myProc:clone();

	print("handle2: ", handle2);
end

local test_ProcessInfo = function()
	local myProc, err = OSProcess();


	print("Handle Count: ", myProc:getHandleCount());
	print("Priority Class: ", myProc:getPriorityClass());
end


local test_TerminateProcess = function()
	local myProc, err = OSProcess();

	print("Is Active: ", myProc:isActive());

	print("Exit Code: ", myProc:getExitCode());

	print("Session ID: ", myProc:getSessionId());
end

--test_ProcessBasics();
-- test_CloneProcess();
test_ProcessInfo();
--test_TerminateProcess();
