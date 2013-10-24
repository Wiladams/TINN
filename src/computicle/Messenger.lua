-- Messenger.lua

local ffi = require("ffi");

local WTypes = require("WTypes")

local ComputicleOps = require("ComputicleOps");
local Computicle = require("Computicle");


ffi.cdef[[
typedef struct {
	int32_t		Message;
	UINT_PTR	Param1;
	LONG_PTR	Param2;
} ComputicleMsg;
]]



local Messenger = {}
setmetatable(Messenger, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local Messenger_mt = {
	__index = function(self, key)
		--print("Messenger __index, LOOKUP: ", key);
		if Messenger[key] then
			return Messenger[key];
		end
	end,

	__newindex = function(self, key, value)
		--print("Messenger __newindex, Key/Value: ", key, value);
		
		local setvalue = key..'='..ComputicleOps.datumToString(value, key);

		return self:exec(setvalue);
	end,
}


Messenger.init = function(self, target)
	local obj = {
		Target = target;
	};
	setmetatable(obj, Messenger_mt);

	return obj;
end

Messenger.create = function(self, target)
--print("Messenger.create");
	return self:init(target);
end




Messenger.allocMessage = function(self, message, param1, param2)
	local msgSize = ffi.sizeof("ComputicleMsg");
	local newWork = self:allocData(msgSize);
	newWork = ffi.cast("ComputicleMsg *", newWork);
	newWork.Message = message;
	if param1 then
		newWork.Param1 = ffi.cast("UINT_PTR",param1);
	else
		newWork.Param1 = 0;
	end

	if param2 then
		newWork.Param2 = ffi.cast("LONG_PTR",param2); 
	else
		newWork.Param2 = 0;
	end

	return newWork;	
end

--[[
Computicle.freeMessage = function(self, msg)
	self:freeData(msg);
end
--]]

Messenger.exec = function(self, codechunk)
--print("Messenger.exec:");
--print(codechunk);

	if not codechunk then
		return false, "no code specified";
	end

	-- allocate some space within the computicle's heap
	-- to copy the piece of code into.
	-- This is done so that the receiving side can 
	-- safely deallocate the memory, knowing it came from 
	-- it's own heap.
	local codelen = #codechunk;

	local buff = self.Target:allocData(codelen+1);

	-- Copy the code into the newly allocated area
	-- make sure it is null terminated
	ffi.copy(buff, ffi.cast("const char *", codechunk), codelen);
	ffi.cast("uint8_t *",buff)[codelen] = 0;

	-- post the message with the code chunk
	return self.Target:receiveMessage(ComputicleOps.Messages.CODE, buff, codelen)
end

Messenger.execFile = function(self, codemodule)
	local fs = io.open(codemodule)
	if not fs then 
		return false, 'could not load file'
	end

	local codechunk = fs:read("*all");
	fs:close();

	return self:exec(codechunk);

end


return Messenger;
