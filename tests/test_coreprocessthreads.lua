-- test_coreprocessthreads.lua

local ffi = require("ffi");
local procthreads = require("core_processthreads_l1_1_1");
local Handle = require("Handle")
local k32Lib = ffi.load("Kernel32");
local OSProcess = require("OSProcess");






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
