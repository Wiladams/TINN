-- test_SCMManager.lua
--

local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;
local band = bit.band;

local service_core = require("service_core_l1_1_1");
local service_manager = require("service_management_l1_1_0");

local core_string = require("core_string_l1_1_0")
local error_handling = require("core_errorhandling_l1_1_1");
local WinError = require("win_error");




ffi.cdef[[
typedef struct {
	HANDLE 	Handle;
} SCServiceHandle;
]]

local SCServiceHandle = ffi.typeof("SCServiceHandle");
local SCServiceHandle_t = {};
local SCServiceHandle_mt = {
	__gc = function(self)
		service_manager.CloseServiceHandle(self.Handle);
	end,

	__new = function(ct, ...)
		local obj = ffi.new(ct);

		if type(select(1, ...)) == 'cdata' then
			obj.Handle = select(1,...);
		end

		return obj;
	end,

	__index = SCServiceHandle_t,
}
ffi.metatype(SCServiceHandle, SCServiceHandle_mt);

SCServiceHandle_t.control = function(self, dwControl, reason)
	reason = reason or bor(
		ffi.C.SERVICE_STOP_REASON_FLAG_PLANNED, 
		ffi.C.SERVICE_STOP_REASON_MAJOR_NONE, 
		ffi.C.SERVICE_STOP_REASON_MINOR_NONE);

	local dwInfoLevel = ffi.C.SERVICE_CONTROL_STATUS_REASON_INFO;
	local pControlParams = ffi.new("SERVICE_CONTROL_STATUS_REASON_PARAMSW");
	pControlParams.dwReason = reason;

	local status = service_manager.ControlServiceExW(self.Handle, dwControl, dwInfoLevel, pControlParams);

	if status == 0 then
		return false, error_handling.GetLastError();
	end

	return true;
end

SCServiceHandle_t.pause = function(self, reason)
	return self:control(ffi.C.SERVICE_CONTROL_PAUSE);
end

SCServiceHandle_t.resume = function(self, reason)
	return self:control(ffi.C.SERVICE_CONTROL_CONTINUE);
end

SCServiceHandle_t.stop = function(self, reason)
	return self:control(ffi.C.SERVICE_CONTROL_STOP, reason);
end


local serviceType = {
	[ffi.C.SERVICE_KERNEL_DRIVER] = "KERNEL_DRIVER",
	[ffi.C.SERVICE_FILE_SYSTEM_DRIVER] = "FILE_SYSTEM_DRIVER",
	[ffi.C.SERVICE_ADAPTER] = "ADAPTER",
	[ffi.C.SERVICE_RECOGNIZER_DRIVER] = "RECOGNIZER_DRIVER",
	[ffi.C.SERVICE_INTERACTIVE_PROCESS] = "INTERACTIVE_PROCESS",
	[ffi.C.SERVICE_WIN32_OWN_PROCESS] = "WIN32_OWN_PROCESS",
	[ffi.C.SERVICE_WIN32_SHARE_PROCESS] = "WIN32_SHARE_PROCESS",
	[ffi.C.SERVICE_INTERACTIVE_PROCESS] = "INTERACTIVE_PROCESS",
};

local getServiceType = function(which)
	if serviceType[which] then
		return serviceType[which];
	end

	if band(ffi.C.SERVICE_INTERACTIVE_PROCESS, which) > 0 then
		if band(which, ffi.C.SERVICE_WIN32_SHARE_PROCESS) >0 then
			return "INTERACTIVE, WIN32_SHARE_PROCESS";
		elseif band(which, ffi.C.SERVICE_WIN32_OWN_PROCESS) >0 then
			return "INTERACTIVE, WIN32_SHARE_PROCESS";
		end
	end

	return string.format("0x%x", which);
end


local serviceState = {
	[ffi.C.SERVICE_STOPPED] = "STOPPED",
	[ffi.C.SERVICE_START_PENDING] = "START_PENDING",
	[ffi.C.SERVICE_STOP_PENDING] = "STOP_PENDING",
	[ffi.C.SERVICE_RUNNING] = "RUNNING",
	[ffi.C.SERVICE_CONTINUE_PENDING] = "CONTINUE_PENDING",
	[ffi.C.SERVICE_PAUSE_PENDING] = "PAUSE_PENDING",
	[ffi.C.SERVICE_PAUSED] = "PAUSED",
};

local openServiceManager = function(dwDesiredAccess)
	dwDesiredAccess = dwDesiredAccess or bor(ffi.C.SC_MANAGER_CONNECT, ffi.C.SC_MANAGER_ENUMERATE_SERVICE);
	
	local lpMachineName = nil;
	local lpDatabaseName = nil;

	local handle = service_manager.OpenSCManagerW(lpMachineName, lpDatabaseName, dwDesiredAccess);

	if handle == nil then
		return false, error_handling.GetLastError();
	end

	return handle;
end




local SCManager = {}
setmetatable(SCManager, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

SCManager_mt = {
	__index = SCManager,	
}

SCManager.init = function(self, rawHandle)
	local obj = {
		Handle = rawHandle;
	};
	setmetatable(obj, SCManager_mt);

	return obj;
end

SCManager.create = function(self, desiredAccess)
	local handle = openServiceManager(desiredAccess);
	if not handle then
		return false, err;
	end

	return self:init(handle)
end

SCManager.openService = function(self, serviceName, dwDesiredAccess)
	if not serviceName then
		return false, "no service name specified";
	end

	dwDesiredAccess = dwDesiredAccess or bor(ffi.C.SERVICE_PAUSE_CONTINUE, ffi.C.SERVICE_STOP, ffi.C.SERVICE_ENUMERATE_DEPENDENTS);
	local lpServiceName = core_string.toUnicode(serviceName);

	local status = service_manager.OpenServiceW(self.Handle, lpServiceName,dwDesiredAccess);
	if status == nil then
		return false, error_handling.GetLastError();
	end

	return SCServiceHandle(status);
end

SCManager.services = function(self, dwServiceType)
	local InfoLevel = ffi.C.SC_ENUM_PROCESS_INFO;
	local dwServiceType = dwServiceType or ffi.C.SERVICE_TYPE_ALL;
	local dwServiceState = dwServiceState or ffi.C.SERVICE_STATE_ALL;
	local lpServices = nil;
	local cbBufSize = 0;
	local pcbBytesNeeded = ffi.new("DWORD[1]");
	local lpServicesReturned = ffi.new("DWORD[1]");
	local lpResumeHandle = ffi.new("DWORD[1]");
	local pszGroupName = nil;

	local status = service_core.EnumServicesStatusExA(
            self.Handle,
            InfoLevel,
            dwServiceType,
            dwServiceState,
            lpServices,
            cbBufSize,
            pcbBytesNeeded,
            lpServicesReturned,
        	lpResumeHandle,
            pszGroupName);

	if status == 0 then
		local err = error_handling.GetLastError();

		if err ~= ERROR_MORE_DATA then
			return false, err;
		end
	end

	-- we now know how much data needs to be allocated
	-- so allocate it and make the call again
	cbBufSize = pcbBytesNeeded[0];
	lpServices = ffi.new("uint8_t[?]", cbBufSize);

	local status = service_core.EnumServicesStatusExA(
            self.Handle,
            InfoLevel,
            dwServiceType,
            dwServiceState,
            lpServices,
            cbBufSize,
            pcbBytesNeeded,
            lpServicesReturned,
        	lpResumeHandle,
            pszGroupName);

	if status == 0 then
		local err = error_handling.GetLastError();
		return false, err;
	end
	
	local nServices = lpServicesReturned[0];

	local idx = -1;

	local function closure()
		idx = idx + 1;
		if idx >= nServices then
			return nil;
		end

		local res = {};


		local services = ffi.cast("ENUM_SERVICE_STATUS_PROCESSA *", lpServices);

		if services[idx].lpServiceName ~= nil then
			res.ServiceName = ffi.string(services[idx].lpServiceName);
		else
			return nil;
		end

		if services[idx].lpDisplayName ~= nil then
			res.DisplayName = ffi.string(services[idx].lpDisplayName);
		end

		-- Running Service Status
		res.State = serviceState[services[idx].ServiceStatusProcess.dwCurrentState] or "UNKNOWN";
		res.ServiceType = getServiceType(services[idx].ServiceStatusProcess.dwServiceType);
		res.ProcessId = services[idx].ServiceStatusProcess.dwProcessId;
		res.ServiceFlags = services[idx].ServiceStatusProcess.dwServiceFlags;

		return res;
	end

	return closure;
end


return SCManager;