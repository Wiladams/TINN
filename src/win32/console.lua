local ffi = require("ffi");
local core_processenvironment = require("core_processenvironment");
local core_console = require("core_console_l1_1_0");
local core_console2 = require("core_console_l2_1_0");
local error_handling = require("core_errorhandling_l1_1_1");


local AllocConsole = function()
	local res = core_console.AllocConsole();

	if res == 0 then
		return false, error_handling.GetLastError();
	end

	return true;
end

local GetConsoleCP = function()
	local res = core_console.GetConsoleCP();

	return res
end

local GetConsoleMode = function(hConsoleHandle)
	local lpMode = ffi.new("DWORD[1]");
	local res = core_console.GetConsoleMode(hConsoleHandle, lpMode);
	
	if res == 0 then
		return false, error_handling.GetLastError();
	end

	return lpMode[0];
end

local GetConsoleOutputCP = function()
	local res = core_console.GetConsoleOutputCP();

	return res;
end

local GetNumberOfConsoleInputEvents = function(hConsoleInput)
	local lpNumberOfEvents = ffi.new("DWORD[1]");
	local res = core_console.GetNumberOfConsoleInputEvents(hConsoleInput,lpNumberOfEvents);

	if res == 0 then
		return false, error_handling.GetLastError();
	end

	return lpNumberOfEvents[0];
end

local PeekConsoleInputA = function(hConsoleInput, lpBuffer, nLength)
	local lpNumberOfEventsRead = ffi.new("DWORD[1]");
	local res = core_console.PeekConsoleInputA(
    	hConsoleInput,
    	lpBuffer,
    	nLength,
    	lpNumberOfEventsRead);

    if res == 0 then
    	return false, error_handling.GetLastError();
    end

    return lpNumberOfEventsRead[0];
end

local ReadConsole = function(hConsoleInput, lpBuffer, nNumberOfCharsToRead)
	local lpNumberOfCharsRead = ffi.new("DWORD[1]");

	local res = core_console.ReadConsoleA(
    	hConsoleInput,
    	lpBuffer,
    	nNumberOfCharsToRead,
    	lpNumberOfCharsRead,
    	pInputControl);

	if res == 0 then
		return false, error_handling.GetLastError();
	end

	return lpNumberOfCharsRead[0];
end

local ReadConsoleInput = function(hConsoleInput, lpBuffer, nLength)

	local lpNumberOfEventsRead = ffi.new("DWORD[1]");

	local res = core_console.ReadConsoleInputA(hConsoleInput,
    	lpBuffer,
    	nLength,
    	lpNumberOfEventsRead);

    if res == 0 then
    	return false, error_handling.GetLastError();
    end

    return lpNumberOfEventsRead[0];
end

local SetConsoleCtrlHandler = function(HandlerRoutine, Add)
	Add = Add or false;
	local res = core_console.SetConsoleCtrlHandler(HandlerRoutine, Add);
	if res == 0 then
		return false, error_handling.GetLastError();
	end

	return true;
end

local SetConsoleMode = function(hConsoleHandle, dwMode)
	dwMode = dwMode or 0;
	local res = core_console.SetConsoleMode(hConsoleHandle, dwMode);
	if res == 0 then
		return false, error_handling.GetLastError();
	end

	return true;
end

local WriteConsole = function(hConsoleOutput, lpBuffer, nNumberOfCharsToWrite)
	nNumberOfCharsToWrite = nNumberOfCharsToWrite or #lpBuffer;

	local lpNumberOfCharsWritten = ffi.new("DWORD[1]");
	local res =  core_console.WriteConsoleA(hConsoleOutput,
    	lpBuffer,
    	nNumberOfCharsToWrite,
     	lpNumberOfCharsWritten,
     	lpReserved);

     if res == 0 then
     	return false, error_handling.GetLastError();
     end

     return lpNumberOfCharsWritten[0];
end

local hwrite = function(handle, ...)
	handle = handle or core_console.GetStdHandle (ffi.C.STD_OUTPUT_HANDLE);

	local nargs = select('#',...);
	if nargs > 0 then
		for i=1,nargs do 
			WriteConsole (handle, tostring(select(i,...)));
		end 
	end
end

local output = function(...)
	hwrite(nil, ...);
end




return {
	hwrite = hwrite,
	output = output,

	AllocConsole = AllocConsole,
	GetConsoleCP = GetConsoleCP,
	GetConsoleMode = GetConsoleMode,
	GetConsoleOutputCP = GetConsoleOutputCP,
	GetNumberOfConsoleInputEvents = GetNumberOfConsoleInputEvents,
	PeekConsoleInput = PeekConsoleInputA,
	ReadConsole = ReadConsoleA,
	ReadConsoleInput = ReadConsoleInputA,
	SetConsoleCtrlHandler = SetConsoleCtrlHandler,
	SetConsoleMode = SetConsoleMode,
	WriteConsole = WriteConsole,
}
