local ffi = require("ffi")
local core_file = require("core_file_l1_2_0");
local core_string = require("core_string_l1_1_0")



local function logicalDriveNames()
	local nBufferLength = 255;
	local lpBuffer = ffi.new("wchar_t[256]");

	local res = core_file.GetLogicalDriveStringsW(nBufferLength, lpBuffer)

	--print("Number of chars: ", res);


	-- now we have all drives, nul terminated, in a single buffer.
	local idx = -1;
	local nameBuff = ffi.new("char[256]")

	local function closure()
		idx = idx + 1;
		local len = 0;

		while len < 255 do 
			--print("char: ", string.char(lpBuffer[idx]))
			if lpBuffer[idx] == 0 then
				break
			end
		
			nameBuff[len] = lpBuffer[idx];
			len = len + 1;
			idx = idx + 1;
		end

		if len == 0 then
			return nil;
		end

		return ffi.string(nameBuff, len);
	end

	return closure;
end

for name in logicalDriveNames() do
	print("DRIVE: ", name)
	print("Drive Type: ", core_file.GetDriveTypeA(name))
end

