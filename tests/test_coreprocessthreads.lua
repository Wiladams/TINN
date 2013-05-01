-- test_coreprocessthreads.lua

local ffi = require("ffi");
local procthreads = require("core_processthreads_l1_1_1");
local Handle = require("Handle")

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
	
	local processHandle = nil;
	if nargs == 0 then
		local procHandle = procthreads.GetCurrentProcess();
		if procHandle == nil then
			return false, k32Lib.GetLastError();
		end

		processHandle = Handle(procHandle);
	end

	local obj = {
		Handle = processHandle;
	}
	setmetatable(obj, OSProcess_mt);

	return obj;
end

OSProcess.getID = function(self)
	return procthreads.GetProcessId(self.Handle.Handle);
end


local test_ProcessBasics = function()
	local myProcess, err = OSProcess();

	if not myProcess then
		print("Error from OSProcess(): ", err);
		return false;
	end

	print("Process ID: ", myProcess:getID());
	print("Is Inheritable: ", myProcess.Handle:isInheritable());
	print("Protected from Close: ", myProcess.Handle:isProtectedFromClose());
end


test_ProcessBasics();
