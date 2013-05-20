local core_debug = require("core_debug_l1_1_1");
local errorhandling = require("core_errorhandling_l1_1_1");


--[[
	DebuggerCore

	Description: This is the DebuggerCore, which can attach to a process and
	wait for debug events to occur.

	You can create multiple instances of DebuggerCores, each attached to 
	a single process.
--]]

local DebuggerCore = {}
setmetatable(DebuggerCore, {
	__call = function(self, processId)
		return self:new(processId);
	end,
});

local DebuggerCore_mt = {
	__index = DebuggerCore;
}

DebuggerCore.new = function(self, processId)
	if not processId then
		return nil;
	end

	local success, err = self:attachToProcess(processId);
	if not success then
		return nil, err;
	end

	local obj = {
		ProcessId = processId;
	}

	setmetatable(obj, DebuggerCore_mt);

	return obj;
end

DebuggerCore.attachToProcess = function(self, processId)
	if not processId then
		return false, "no process id specified";
	end

	local status = core_debug.DebugActiveProcess(processId);
	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return true;
end

DebuggerCore.continue = function(self, dwThreadId, dwContinueStatus)
	dwThreadId = dwThreadId or self.LastThreadId;

	if not dwThreadId then
		return false, "no thread id specified";
	end

	dwContinueStatus = dwContinueStatus or ffi.C.DBG_CONTINUE;

	local status = core_debug.ContinueDebugEvent(self.ProcessId, dwThreadId, dwContinueStatus);

	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return true;
end

DebuggerCore.stop = function(self)
	local status = core_debug.DebugActiveProcessStop(self.ProcessId);
	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return true;
end



DebuggerCore.waitForEvent = function(self, lpDebugEvent, dwMilliseconds)
	dwMilliseconds = dwMilliseconds or ffi.C.INFINITE;
	lpDebugEvent = lpDebugEvent or ffi.new("DEBUG_EVENT");

	local status = core_debug.WaitForDebugEvent(lpDebugEvent, dwMilliseconds);
	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return debugEvent;
end

DebuggerCore.tryWaitForEvent = function(self, debugEvent)
	return self:waitForEvent(debugEvent, 0);
end

