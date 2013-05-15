local ffi = require("ffi");
local procthreads = require("core_processthreads_l1_1_1");
local Handle = require("Handle")
local core_psapi = require("core_psapi_l1_1_0");
local core_string = require("core_string_l1_1_0");
local errorhandling = require("core_errorhandling_l1_1_1");


local OSProcess={}

setmetatable(OSProcess, 
{
	__call = function(self,...) 
		return OSProcess.new(...);
	end,

	__index = {
		open  = function(self, processId, desiredAccess, inheritable)
			desiredAccess = desiredAccess or ffi.C.PROCESS_ALL_ACCESS;
			inheritable = inheritable or false;

			local procHandle = procthreads.OpenProcess(desiredAccess, inheritable, processId);

			return OSProcess(procHandle);
		end,

		processIds = function(self)
			-- enumerate processes
			local lpidProcess = ffi.new("DWORD[1024]");
			local cb = ffi.sizeof(lpidProcess);
			local lpcbNeeded = ffi.new("DWORD[1]");

			local status = core_psapi.EnumProcesses (lpidProcess, cb, lpcbNeeded);

			if status == 0 then
				return false, errorhandling.GetLastError();
			end 

			local cbNeeded = lpcbNeeded[0];
			local nEntries = cbNeeded / ffi.sizeof("DWORD");

			local idx = -1;
			local closure = function()
				idx = idx + 1;
				if idx >= nEntries then
					return nil;
				end

				return lpidProcess[idx];
			end

			return closure;
		end,
	},
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
		return false, errorhandling.GetLastError();
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
		local err = errorhandling.GetLastError();
--print("OpenProcess failed: ", err);

		return false, err;
	end

	return OSProcess(procHandle);
end

OSProcess.getExitCode = function(self)
	local lpExitCode = ffi.new("DWORD[1]");
	local res = procthreads.GetExitCodeProcess(self.Handle.Handle, lpExitCode);

	if res == 0 then
		return false, errorhandling.GetLastError();
	end

	return lpExitCode[0];
end

OSProcess.getHandleCount = function(self)
	local lpHandleCount = ffi.new("DWORD[1]");
	local res = procthreads.GetProcessHandleCount(self.Handle.Handle, lpHandleCount);

	if res == 0 then
		return false, errorhandling.GetLastError();
	end

	return lpHandleCount[0];
end

OSProcess.getId = function(self)
	return procthreads.GetProcessId(self.Handle.Handle);
end

OSProcess.getImageName = function(self, dwFlags)
	dwFlags = dwFlags or 0;
	local lpExeName = ffi.new("WCHAR[260]");
	local lpdwSize = ffi.new("DWORD[1]", 260);

	local status = core_psapi.QueryFullProcessImageName(self.Handle.Handle, dwFlags,lpExeName, lpdwSize);

	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return core_string.toAnsi(lpExeName, lpdwSize[0]);
end

OSProcess.getPriorityClass = function(self)
	local res = procthreads.GetPriorityClass(self.Handle.Handle);
	if res == 0 then
		return false, errorhandling.GetLastError();
	end

	return res;
end

OSProcess.getSessionId = function(self)
	local lpSessionId = ffi.new("DWORD[1]");
	local res = procthreads.ProcessIdToSessionId(self:getId(), lpSessionId);
	if res == 0 then
		return false, errorhandling.GetLastError();
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
		return false, errorhandling.GetLastError();
	end

	return lpCreationTime, lpExitTime, lpKernelTime, lpUserTime;
end


OSProcess.isActive = function(self)
	return self:getExitCode() == ffi.C.STILL_ACTIVE;
end

OSProcess.terminate = function(self, exitCode)
	local res = procthreads.TerminateProcess(self.Handle.Handle, exitCode);

	if res == 0 then
		return false, errorhandling.GetLastError();
	end

	return true;
end

return OSProcess;
