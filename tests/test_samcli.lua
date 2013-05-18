
local ffi = require("ffi");
local samcli = require("samcli");
local netutils_ffi = require("netutils_ffi");

local core_string = require("core_string_l1_1_0");
local JSON = require("dkjson");


--[[
NET_API_STATUS
NetLocalGroupEnum (
      LPCWSTR      servername ,
      DWORD       level,
     LPBYTE      *bufptr,
      DWORD       prefmaxlen,
     LPDWORD     entriesread,
     LPDWORD     totalentries,
      PDWORD_PTR resumehandle 
    );
--]]


local enumLocalGroups = function(params)
	local servername = nil;
	if params.servername then
		servername = core_string.toUnicode(params.servername);
	end
	level = params.level or 0;

	local bufptr = ffi.new("BYTE *[1]");
	local prefmaxlen = params.chunksize or ffi.C.MAX_PREFERRED_LENGTH;
	local entriesread = ffi.new("DWORD[1]");
	local totalentries = ffi.new("DWORD[1]");
	--local resumehandle = ffi.new("DWORD_PTR[1]");
	--local resumehandle = ffi.new("uintptr_t[1]");
	local resumehandle = ffi.new("DWORD[1]");

	local status = samcli.NetLocalGroupEnum(servername,
		level,
		bufptr,
		prefmaxlen,
		entriesread,
		totalentries,
		resumehandle);

print("STATUS ======= ", status);
print("32-bit: ", ffi.abi("32bit"));

	if status ~= ffi.C.NERR_Success then
		return nil, status;
	end

	print("Entries Read: ", entriesread[0]);
	print("Total Entries: ", totalentries[0]);
	--print("Buffptr: ", bufptr[0]);
	print("Resume Handle: ", resumehandle[0]);



	local idx = -1;

	local closure = function()
		idx = idx + 1;
--[[
		if idx >= entriesread[0] then
			-- we're either at the beginning of the enumeration
			-- or we've just run past the extent of the current batch
			-- either way, try to get the next batch
			local status = samcli.NetLocalGroupEnum(servername,
				level,
				bufptr,
				prefmaxlen,
				entriesread,
				totalentries,
				resumehandle[0]);

print("STATUS ======= ", status);

			if status ~= ffi.C.NERR_Success then
				return nil, status;
			end

			print("Entries Read: ", entriesread[0]);
			print("Total Entries: ", totalentries[0]);
			--print("Buffptr: ", bufptr[0]);
			print("Resume Handle: ", resumehandle[0]);

			idx = 0;
		end
--]]
		if idx >= entriesread[0] then
			return nil;
		end

		if level == 0 then
			local records = ffi.cast("LOCALGROUP_INFO_0 *", bufptr[0])
			return {name = core_string.toAnsi(records[idx].lgrpi0_name)};
		elseif level == 1 then
			local records = ffi.cast("LOCALGROUP_INFO_1 *", bufptr[0]);
			return {
				name = core_string.toAnsi(records[idx].lgrpi1_name),
				comment = core_string.toAnsi(records[idx].lgrpi1_comment)};
		end

		return nil;
	end

	return closure;
end

printGroups = function()
	local res = {}
	--for group in enumLocalGroups({level=1}) do
	for group in enumLocalGroups({level=0, servername="\\\\tk5-red-dc-15"}) do
		print("name: ", group.name);
		--table.insert(res, group);
	end

	--local jsonstr = JSON.encode(res, {indent=true});

	--print(jsonstr);
end

printGroups();
