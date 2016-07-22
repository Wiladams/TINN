-- test_OSModule.lua
--
--
--[[
	OSModule - This is a rough substitute for 
	using ffi.load, ffi.C and ffi.typeof

	Usage:
	local k32 = OSModule("kernel32")
	local GetConsoleMode = k32.GetConsoleMode;

	print("GetConsoleMode", GetConsoleMode);

	local lpMode = ffi.new("DWORD[1]");
	local status = GetConsoleMode(nil, lpMode);

	The advantage of this construct is that you get at all the 
	constants and types as well as functions through a single 
	interface.
--]]
local ffi = require("ffi");

local libraryloader = require("core_libraryloader_l1_1_1");
local errorhandling = require("core_errorhandling_l1_1_1");



local OSModule = {}
setmetatable(OSModule,{
	__call = function(self, ...)
		return self:new(...);
	end,
})

local function getLibSymbol(lib, symbol)
	return pcall(function() return lib[symbol] end)
end

local function getCInfo(key)
	local success, info = pcall(function() return ffi.C[key] end)
	if success then return info end

	success, info = pcall(function() return ffi.typeof(key) end)

	if success then return info end

	return nil, "neither a function nor a type";
end

--[[
	Metatable for instances of the OSModule 
--]]
local OSModule_mt = {
	__index = function(self, key)
		--print("OSModule_mt.__index: ", key)

		-- get the type of the thing
		local success, ffitype = getCInfo(key);
		--print("OSModule_mt.__index, ffitype: ", success, ffitype)
		if not success then 
			return false, "declaration for type not found"
		end

		-- if it's a datatype, or constant, then 
		-- just return that

		-- if it's a function, then return a pointer to 
		-- the function.

		-- turn the function information into a function pointer
		local proc = libraryloader.GetProcAddress(self.Handle, key);

--print("OSModule.__index, getProcAddress: ", proc)

		if proc ~= nil then
			ffitype = ffi.typeof("$ *", ffitype);
			local castval = ffi.cast(ffitype, proc);
			rawset(self, key, castval)

			return castval;
		end

		-- at this point we need to convert the type 
		-- into something interesting, and return that
		return ffitype;
	end,
}



function OSModule.init(self, handle)
	local obj = {
		Handle = handle;
	};

	setmetatable(obj, OSModule_mt);

	return obj;
end

function OSModule.new(self, name, flags)
	flags = flags or 0

	local handle = libraryloader.LoadLibraryExA(name, nil, flags);
	
	if handle == nil then
		return nil, errorhandling.GetLastError();
	end
	
	ffi.gc(handle, libraryloader.FreeLibrary);

	return self:init(handle);
end

function OSModule.getNativeHandle(self)
	return self.Handle
end

function OSModule.getProcAddress(self, procName)
	local addr = libraryloader.GetProcAddress(self:getNativeHandle(), procName);
	if not addr then
		return nil, errorhandling.GetLastError();
	end

	return addr;
end


return OSModule
