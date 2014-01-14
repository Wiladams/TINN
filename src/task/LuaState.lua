
local ffi = require("ffi")
local lua = require "luajit_ffi"



local function report_errors(L, status)
	if status ~= 0 then
		print("-- ", ffi.string(lua.lua_tostring(L, -1)))
		lua.lua_pop(L, 1); -- remove error message
	end
end


local LuaState = {
	Defaults = {}
}
setmetatable(LuaState, {
	__call = function(self, ...)
		return self:new(...);
	end,
});

local LuaState_mt = {
	__index = LuaState;
}

	-- Must at least load base library
	-- or 'require' and print won't work
	-- MUST load jit, or JIT won't work

	--[[
			lua.luaopen_base(L)
			lua.luaopen_string(L);
			lua.luaopen_math(L);
			lua.luaopen_io(L);
			lua.luaopen_table(L);

			lua.luaopen_bit(L);
			lua.luaopen_jit(L);
			lua.luaopen_ffi(L);
	--]]

LuaState.loadBaseLibraries = function(self, L)
	lua.luaL_openlibs(L);	
end


LuaState.new = function(self, codechunk, autorun)
	local L = lua.luaL_newstate();  -- create state
	

	if L == nil then
		return nil, "cannot create state: not enough memory"; 
	end

	local obj = {
		State = L;
	}
	setmetatable(obj, LuaState_mt);

	LuaState:loadBaseLibraries(L);

	if LuaState.Init then
		self.InitStatus = self:run(LuaState.Init);
	end

	if codechunk then
		self.CodeChunk = codechunk
		if autorun then
			self:run(codechunk)
		end
	end

	return obj;
end

function LuaState:loadChunk(s)
	local result = lua.luaL_loadstring(self.State, s)
	report_errors(self.State, result)

	return result
end

function LuaState:run(codechunk)
	local result
	if codechunk then
		result = self:LoadChunk(codechunk)
	end


	if result == 0 then
		result = lua.lua_pcall(self.State, 0, lua.LUA_MULTRET, 0)
		report_errors(self.State, result)
	else
		return result
	end

	return result
end

return LuaState;

