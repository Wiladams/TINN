local ffi = require("ffi");
local core_processenvironment = require("core_processenvironment");
local core_console = require("core_console");
local kernel32 = require("win_kernel32");
local k32Lib = kernel32.Lib;



local AllocConsole = function()
	local res = k32Lib.AllocConsole();

	if res == 0 then
		return false, k32Lib.GetLastError();
	end

	return true;
end

local GetConsoleCP = function()
	local res = k32Lib.GetConsoleCP();

	return res
end

local GetConsoleMode = function(hConsoleHandle)
	local lpMode = ffi.new("DWORD[1]");
	local res = GetConsoleMode(hConsoleHandle, lpMode);
	
	if res == 0 then
		return false, k32Lib.GetLastError();
	end

	return lpMode[0];
end

local GetConsoleOutputCP = function()
	local res = GetConsoleOutputCP(void);

	return res;
end

local GetNumberOfConsoleInputEvents = function(hConsoleInput)
	local lpNumberOfEvents = ffi.new("DWORD[1]");
	local res = GetNumberOfConsoleInputEvents(hConsoleInput,lpNumberOfEvents);

	if res == 0 then
		return false, k32Lib.GetLastError();
	end

	return lpNumberOfEvents[0];
end

local PeekConsoleInputA = function(hConsoleInput, lpBuffer, nLength)
	local lpNumberOfEventsRead = ffi.new("DWORD[1]");
	local res = k32Lib.PeekConsoleInputA(
    	hConsoleInput,
    	lpBuffer,
    	nLength,
    	lpNumberOfEventsRead);

    if res == 0 then
    	return false, k32Lib.GetLastError();
    end

    return lpNumberOfEventsRead[0];
end

local ReadConsole = function(hConsoleInput, lpBuffer, nNumberOfCharsToRead)
	local lpNumberOfCharsRead = ffi.new("DWORD[1]");

	local res = k32Lib.ReadConsoleA(
    	hConsoleInput,
    	lpBuffer,
    	nNumberOfCharsToRead,
    	lpNumberOfCharsRead,
    	pInputControl);

	if res == 0 then
		return false, k32Lib.GetLastError();
	end

	return lpNumberOfCharsRead[0];
end

local ReadConsoleInput = function(hConsoleInput, lpBuffer, nLength)

	local lpNumberOfEventsRead = ffi.new("DWORD[1]");

	local res = k32Lib.ReadConsoleInputA(hConsoleInput,
    	lpBuffer,
    	nLength,
    	lpNumberOfEventsRead);

    if res == 0 then
    	return false, k32Lib.GetLastError();
    end

    return lpNumberOfEventsRead[0];
end

local SetConsoleCtrlHandler = function(HandlerRoutine, Add)
	Add = Add or false;
	local res = SetConsoleCtrlHandler(HandlerRoutine, Add);
	if res == 0 then
		return false, k32Lib.GetLastError();
	end

	return true;
end

local SetConsoleMode = function(hConsoleHandle, dwMode)
	dwMode = dwMode or 0;
	local res = SetConsoleMode(hConsoleHandle, dwMode);
	if res == 0 then
		return false, k32Lib.GetLastError();
	end

	return true;
end

local WriteConsole = function(hConsoleOutput, lpBuffer, nNumberOfCharsToWrite)
	nNumberOfCharsToWrite = nNumberOfCharsToWrite or #lpBuffer;

	local lpNumberOfCharsWritten = ffi.new("DWORD[1]");
	local res =  k32Lib.WriteConsoleA(hConsoleOutput,
    	lpBuffer,
    	nNumberOfCharsToWrite,
     	lpNumberOfCharsWritten,
     	lpReserved);

     if res == 0 then
     	return false, k32Lib.GetLastError();
     end

     return lpNumberOfCharsWritten[0];
end

local hwrite = function(handle, ...)
	handle = handle or k32Lib.GetStdHandle (ffi.C.STD_OUTPUT_HANDLE);

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
