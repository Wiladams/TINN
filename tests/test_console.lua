-- test_console.lua
local ffi = require("ffi");
local bit = require("bit");
local band = bit.band;
local bor = bit.bor;
local bxor = bit.bxor;

local core_console1 = require("core_console_l1_1_0");
local core_console2 = require("core_console_l2_1_0");
local processenviron = require("core_processenvironment");

local console = require("console");
local win_kernel32 = require("win_kernel32");
local core_string = require("core_string_l1_1_0");

local Console = {}
local Console_t = {}
setmetatable(Console, {
	__call = function(self,...)
		return self:new(...);
	end,

	__index = {
		CreateNew = function(self, ...)
			-- Detach from current console if attached
			core_console2.FreeConsole();

			-- Allocate new console
			local status = console.AllocConsole();

			return Console();
		end,
	},
})

-- Metatable for Console instances
local Console_mt = {
	__index = Console,
}

Console.new = function(self, ...)
	local obj = {}
	setmetatable(obj, Console_mt);

	return obj;
end

--[[
	Input Mode attributes
--]]
Console.setMode = function(self, mode, handle)
	handle = handle or self:getStdIn();
	local status = core_console1.SetConsoleMode(handle, mode);

	if status == 0 then
		return false, error_handling.GetLastError();
	end

	return true;
end

Console.getMode = function(self, handle)
	handle = handle or self:getStdIn();
	local lpMode = ffi.new("DWORD[1]");
	local status = core_console1.GetConsoleMode(handle, lpMode);

	if status == 0 then
		return false, error_handling.GetLastError();
	end

	return lpMode[0];
end

Console.disableMode = function(self, mode, handle)
	handle = handle or self:getStdIn();

	-- get current input mode
	local currentmode = self:getMode();

	-- subtract out the desired mode
	mode = band(currentmode, bxor(mode));

	-- set the mode again
	return self:setMode(mode);
end

Console.enableMode = function(self, mode, handle)
	handle = handle or self:getStdIn();

	-- get current input mode
	local currentmode = self:getMode();

	-- add the desired mode
	mode = bor(currentmode, mode);

	-- set the mode again
	return self:setMode(mode);
end


Console.enableEchoInput = function(self)
	return self:enableMode(ffi.C.ENABLE_ECHO_INPUT);
end

Console.enableInsertMode = function(self)
	return self:enableMode(ffi.C.ENABLE_INSERT_MODE);
end

Console.enableLineInput = function(self)
	return self:enableMode(ffi.C.ENABLE_LINE_INPUT);
end

Console.enableLineWrap = function(self)
	return self:enableMode(ffi.C.ENABLE_WRAP_AT_EOL_OUTPUT, self:getStdOut());
end

Console.enableMouseInput = function(self)
	return self:enableMode(ffi.C.ENABLE_MOUSE_INPUT);
end

Console.enableProcessedInput = function(self)
	return self:enableMode(ffi.C.ENABLE_PROCESSED_INPUT);
end

Console.enableProcessedOutput = function(self)
	return self:enableMode(ffi.C.ENABLE_PROCESSED_OUTPUT, self:getStdOut());
end

Console.enableQuickEditMode = function(self)
	return self:enableMode(ffi.C.ENABLE_QUICK_EDIT_MODE);
end

Console.enableWindowEvents = function(self)
	return self:enableMode(ffi.C.ENABLE_WINDOW_INPUT);
end


--[[
	Get Standard I/O handles
--]]
Console.getStdOut = function(self)
	return processenviron.GetStdHandle(ffi.C.STD_OUTPUT_HANDLE);
end

Console.getStdIn = function(self)
	return processenviron.GetStdHandle(ffi.C.STD_INPUT_HANDLE);
end

Console.getStdErr = function(self)
	return processenviron.GetStdHandle(ffi.C.STD_ERROR_HANDLE);
end


Console.setTitle = function(self, title)
	local lpConsoleTitle = core_string.toUnicode(title);

	local status = core_console2.SetConsoleTitleW(lpConsoleTitle);
end

Console.ReadBytes = function(self, lpBuffer, nNumberOfCharsToRead, offset)
	local lpNumberOfCharsRead = ffi.new("DWORD[1]");

	local status = core_console1.ReadConsoleA(self:getStdIn(),
		lpBuffer, nNumberOfCharsToRead,
		lpNumberOfCharsRead, nil);

	if status == 0 then
		return error_handling.GetLastError();
	end

	return lpNumberOfCharsRead[0];
end




--[[
	Test Cases
--]]

local con = Console:CreateNew();

con:setTitle("New Console Title");
con:setMode(0);
con:enableLineInput();
con:enableEchoInput();
con:enableProcessedInput();

local bufflen = 256;
local buff = ffi.new("char[?]", bufflen);

while true do
	win_kernel32.SleepEx(500, true);
	
	local bytesread, err = con:ReadBytes(buff, bufflen);

	if bytesread then
		print("\b")
		--print(ffi.string(buff, bytesread));
	else
		print("Error: ", err);
	end
end