
local TINNThread = require("TINNThread");
local IOCompletionPort = require("IOCompletionPort");


local Messages = {
	QUIT = 1,
	CODE = 2,
}

local datumToString = function(data, name)
	local dtype = type(data);
	local datastr = tostring(nil);

--print("DATUM TYPE: ", name, dtype);

	if dtype == "cdata" then
		-- If it is a cdata type that easily converts to 
		-- a number, then convert to a number and assign to string
		if tonumber(data) then
			datastr = tostring(tonumber(data));
		else
			-- if not easily converted to number, then just assign the pointer
			datastr = string.format("TINNThread:StringToPointer(%s);", 
				TINNThread:PointerToString(data));
		end
	elseif dtype == "table" then
		if getmetatable(data) == Computicle_mt then
			-- package up a computicle
			datastr = string.format("Computicle:init(TINNThread:StringToPointer(%s),TINNThread:StringToPointer(%s));", 
				TINNThread:PointerToString(data.Heap:getNativeHandle()), 
				TINNThread:PointerToString(data.IOCP:getNativeHandle()));
		elseif getmetatable(data) == getmetatable(self.IOCP) then
			-- The data is an iocompletion port, so handle it specially
			datastr = string.format("IOCompletionPort:init(TINNThread:StringToPointer(%s))",
				TINNThread:PointerToString(data:getNativeHandle()));
		else
			-- get a json string representation of the table
			datastr = string.format("[[ %s ]]",JSON.encode(data, {indent=true}));

			--print("=== JSON ===");
			--print(datastr)
		end
	elseif dtype == "function" then
		datastr = "loadstring([==["..string.dump(data).."]==])";
	elseif dtype == "string" then
		datastr = string.format("[==[%s]==]", data);
	else 
		datastr = tostring(data);
	end

	return datastr;
end

local packParams = function(params, name)
	if not params then
		return "";
	end

	name = name or "_params";

	-- First, create a table that represents the entries
	-- as string pointers
	local res = {};
	for k,v in pairs(params) do
		--print("packParams: ", k,v, type(v));
		table.insert(res, string.format("%s['%s'] = %s", name, k, datumToString(v, k)));
	end

	return table.concat(res, '\n');
end


return {
	Messages = Messages;
	datumToString = datumToString,
	packParams = packParams,
}

