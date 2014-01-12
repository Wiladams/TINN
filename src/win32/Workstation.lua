local ffi = require("ffi");
local core_string = require("core_string_l1_1_0");
local wkscli = require("wkscli");
local netutils = require("netutils");


local WorkStation = {}
setmetatable(WorkStation, {
	__call = function(self, ...)
		return self:new(...);
	end,
});

local WorkStation_mt = {
	__index = WorkStation;
}

WorkStation.new = function(self, params)
	params = params or {}
	local obj = {
		ServerName = params.ServerName;
	}

	setmetatable(obj, WorkStation_mt);

	return obj;
end

function WorkStation.uses(self)
	local Level = 0;
	local BufPtr = ffi.new("BYTE *[1]");
	local PreferedMaximumSize = ffi.C.MAX_PREFERRED_LENGTH;
	local EntriesRead = ffi.new("DWORD[1]");
	local TotalEntries = ffi.new("DWORD[1]");
	local ResumeHandle = ffi.new("DWORD[1]");

print("WorkStation.uses, 1.0")

	local status = wkscli.NetUseEnum (
     self.ServerName,
     Level,
     BufPtr,
     PreferedMaximumSize,
     EntriesRead,
     TotalEntries,
     ResumeHandle);

	print("uses, STATUS: ", status);
	print("uses, Entries: ", EntriesRead[0]);
	print("uses, TotalEntries: ", TotalEntries[0]);

	local buff, err = netutils.NetApiBuffer(BufPtr[0]);

	local idx = -1;
	local function closure()
		idx = idx + 1;

		if idx >= EntriesRead[0] then
			return nil;
		end

		if Level == 0 then
			local records = ffi.cast("USE_INFO_0 *", buff.Handle);
			return {
				["local"] = core_string.toAnsi(records[idx].ui0_local),
				["remote"] = core_string.toAnsi(records[idx].ui0_remote),
			}
		end

		return nil;
	end

	return closure;
end



WorkStation.users = function(self, Level)
	params = params or {}

	Level = Level or 0;
	local BufPtr = ffi.new("BYTE *[1]");
	local PreferedMaximumSize = ffi.C.MAX_PREFERRED_LENGTH;
	local EntriesRead = ffi.new("DWORD[1]");
	local TotalEntries = ffi.new("DWORD[1]");
	local ResumeHandle = ffi.new("DWORD[1]");

	local status = wkscli.NetWkstaUserEnum (
		self.ServerName,
		Level,
    	BufPtr,
    	PreferedMaximumSize,
    	EntriesRead,
    	TotalEntries,
    	ResumeHandle);

	--print("STATUS: ", status);
	--print("Entries: ", EntriesRead[0]);
	--print("Total: ", TotalEntries[0]);
	--print("Resume: ", ResumeHandle[0]);

	local buff, err = netutils.NetApiBuffer(BufPtr[0]);


	local idx = -1;
	local closure = function()
		idx = idx + 1;

		if idx >= EntriesRead[0] then
			return nil;
		end

		if Level == 0 then
			local records = ffi.cast("WKSTA_USER_INFO_0 *", buff.Handle);
			return {
				username = core_string.toAnsi(records[idx].wkui0_username),
			}
		elseif Level == 1 then
			local records = ffi.cast("WKSTA_USER_INFO_1 *", buff.Handle);
			return {
				username = core_string.toAnsi(records[idx].wkui1_username),
				domain = core_string.toAnsi(records[idx].wkui1_logon_domain),
				otherDomains = core_string.toAnsi(records[idx].wkui1_oth_domains),
				logonServer = core_string.toAnsi(records[idx].wkui1_logon_server),
			}
		end

		return nil;
	end

	return closure;
end


WorkStation.transports = function(self)

	local Level = 0;
	local BufPtr = ffi.new("BYTE *[1]");
	local PreferedMaximumSize = ffi.C.MAX_PREFERRED_LENGTH;
	local EntriesRead = ffi.new("DWORD[1]");
	local TotalEntries = ffi.new("DWORD[1]");
	local ResumeHandle = ffi.new("DWORD[1]");

	local status = wkscli.NetWkstaTransportEnum (
		self.ServerName ,
		Level,
    	BufPtr,
    	PreferedMaximumSize,
    	EntriesRead,
    	TotalEntries,
    	ResumeHandle);

	--print("STATUS: ", status);
	--print("Entries: ", EntriesRead[0]);
	--print("Total: ", TotalEntries[0]);
	--print("Resume: ", ResumeHandle[0]);

	local buff, err = netutils.NetApiBuffer(BufPtr[0]);


	local idx = -1;
	local closure = function()
		idx = idx + 1;

		if idx >= EntriesRead[0] then
			return nil;
		end


		if Level == 0 then
			local records = ffi.cast("WKSTA_TRANSPORT_INFO_0 *", buff.Handle);
			return {
				qualityOfService = records[idx].wkti0_quality_of_service;
				numberOfvcs = records[idx].wkti0_number_of_vcs;
				transportName = core_string.toAnsi(records[idx].wkti0_transport_name);
				transportAddress = core_string.toAnsi(records[idx].wkti0_transport_address);
				WAN = records[idx].wkti0_wan_ish > 0;
			}
		end

		return nil;
	end

	return closure;
end


WorkStation.getUses = function(self)
	local res = {}
	for use in self:uses() do
		table.insert(res, use);
	end
	return res;
end

WorkStation.getUsers = function(self, level)
	local res = {}
	for user in self:users(level) do
		table.insert(res, user);
	end
	return res;
end

WorkStation.getTransports = function(self)
	local res = {}
	for transport in self:transports() do
		table.insert(res, transport);
	end
	return res;
end

return WorkStation;
