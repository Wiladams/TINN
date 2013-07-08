-- Computicle.lua

local ffi = require("ffi");

local Heap = require("Heap");
local core_synch = require("core_synch_l1_2_0");
local errorhandling = require("core_errorhandling_l1_1_1");
local WinBase = require("WinBase");
local JSON = require("dkjson");

local TINNThread = require("TINNThread");
local IOCompletionPort = require("IOCompletionPort");

ffi.cdef[[
typedef struct {
	HANDLE HeapHandle;
	HANDLE IOCPHandle;
	HANDLE ThreadHandle;
} Computicle_t;

typedef struct {
	int32_t		Message;
	UINT_PTR	Param1;
	LONG_PTR	Param2;
} ComputicleMsg;
]]




local Computicle = {
	Threads = {},
	Messages = {
		QUIT = -1,
		CODE = -2,
	},

	Prolog = [[
TINNThread = require("TINNThread");
Computicle = require("Computicle");
IOCompletionPort = require("IOCompletionPort");
Heap = require("Heap");
IOProcessor = require("IOProcessor");

exit = function()
    SELFICLE:quit();
end
]];

	Epilog = [[

local ffi = require("ffi");

-- This is a basic message pump
-- 

-- default to 15 millisecond timeout
gIdleTimeout = gIdleTimeout or 15


local idlecount = 0;

local handlemessages = function()
  while true do
    local msg, err = SELFICLE:getMessage(gIdleTimeout);
    -- false, WAIT_TIMEOUT == timed out
    --print("MSG: ", msg, err);

    if not msg then
      if err == WAIT_TIMEOUT then
        --print("about to idle")
        idlecount = idlecount + 1;
        if OnIdle then
          OnIdle(idlecount);
        end
      end
    else
      local msgFullyHandled = false;
      msg = ffi.cast("ComputicleMsg *", msg);

      if OnMessage then
        msgFullyHandled = OnMessage(msg);
      end

      if not msgFullyHandled then
        msg = ffi.cast("ComputicleMsg *", msg);
        local Message = msg.Message;
        --print("Message: ", Message, msg.Param1, msg.Param2);
    
        if Message == Computicle.Messages.QUIT then
          if OnExit then
            OnExit();
          end
          break;
        end

        if Message == Computicle.Messages.CODE then
          local len = msg.Param2;
          local codePtr = ffi.cast("const char *", msg.Param1);
    
          if codePtr ~= nil and len > 0 then
            local code = ffi.string(codePtr, len);

            SELFICLE:freeData(ffi.cast("void *",codePtr));


            local func, err = loadstring(code);
            func();
            --print("MSG PUMP, loadstring: ", func, err);
            --print("FUNC(): ",func());
          end
        end
        SELFICLE:freeMessage(msg);
      end
    end
  
    -- give up time to other computicles
    IOProcessor:yield();
  end
end

IOProcessor:spawn(handlemessages);
IOProcessor:run();
]];
}
setmetatable(Computicle, {
	__call = function(self, ...)
		return self:init(...);
	end,
});

local Computicle_mt = {
	__index = function(self, key)
		if Computicle[key] then
			return Computicle[key];
		end
		print("Computicle LOOKUP: ", key);
	end,

	__newindex = function(self, key, value)
		--print("Setting Value: ", key, value);
		
		local setvalue = key..'='..self:datumToString(value, key);

		return self:exec(setvalue);
	end,
}

Computicle.init = function(self, heapHandle, iocpHandle, threadId)
	local obj = {
		Heap = Heap(heapHandle);
		IOCP = IOCompletionPort:init(iocpHandle);
		Thread = TINNThread:init(threadId);
	};

	setmetatable(obj, Computicle_mt);

	return obj;
end


Computicle.datumToString = function(self, data, name)
	local dtype = type(data);
	local datastr = tostring(nil);

--print("DATUM TYPE: ", name, dtype);

	if type(data) == "cdata" then
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



Computicle.packParams = function(self, params, name)
	if not params then
		return "";
	end

	name = name or "_params";

	-- First, create a table that represents the entries
	-- as string pointers
	local res = {};
	for k,v in pairs(params) do
		--print("packParams: ", k,v, type(v));
		table.insert(res, string.format("%s['%s'] = %s", name, k, self:datumToString(v, k)));
	end

	return table.concat(res, '\n');
end





Computicle.createThreadChunk = function(self, codechunk, params, codeparams)
	local res = {};


	-- What we want to load before any other code is executed
	-- This is typically some 'require' statements.
	table.insert(res, Computicle.Prolog);


	-- Package up the parameters that may want to be passed in
	local paramname = "_params";

	table.insert(res, string.format("%s = {};", paramname));
	table.insert(res, self:packParams(params, paramname));
	table.insert(res, self:packParams(codeparams, paramname));

	-- Create the Computicle instance that is running within 
	-- the Computicle
	table.insert(res, 
		string.format("SELFICLE = Computicle:init(%s.HeapHandle, %s.IOCPHandle);", paramname, paramname));


	-- Stuff in the user's code
	table.insert(res, [[main = function()]]);
	table.insert(res, codechunk);
	table.insert(res, [[end]]);

	-- make sure the user's code is running in a coroutine
	table.insert(res, [[IOProcessor:spawn(main)]]);

	-- What we want to execute after the user's code is loaded
	-- By default, this will be a message pump
	table.insert(res, Computicle.Epilog);

	return table.concat(res, '\n');
end


-- Create a new computicle
--[[
	codechunk - a simple Lua string
	codeparams - a table of cdata structs that are to be passed on
--]]


Computicle.create = function(self, codechunk, codeparams)
	-- First, create the heap that is going to be used to do stuff
	local heap = Heap:create();

	-- Create an iocompletion port as a receiver of 
	-- messages for the computicle.
	local iocp = IOCompletionPort:create();


	-- Assemble the chunk of code to be passed to the thread
	local params = {
		HeapHandle = heap:getNativeHandle();
		IOCPHandle = iocp:getNativeHandle();
	};
	local threadCode = Computicle:createThreadChunk(codechunk, params, codeparams);

--print("== CODE ==");
--print(threadCode);
--print("** CODE **");

	local worker, err = TINNThread({CodeChunk = threadCode, CreateSuspended = params.CreateSuspended});
	table.insert(Computicle.Threads, worker);


	local obj = {
		Heap = heap;
		IOCP = iocp;
		Thread = worker};

	setmetatable(obj, Computicle_mt);

	return obj;
end

Computicle.createFromFile = function(self, filename, codeparams)
	local fs = io.open(filename)
	if not fs then 
		return nil, 'could not load file'
	end

	local codechunk = fs:read("*all");
	fs:close();

	return self:create(codechunk, codeparams);
end

Computicle.load = function(self, name, codeparams)
	local comp = self:create(string.format("require('%s');", name), codeparams);

	return comp;
end


Computicle.loadAndRun = function(self, name, codeparams)
	local comp, err = self:load(name, codeparams);
	if not comp then
		return false, err;
	end

	return comp:waitForFinish();
end

Computicle.getStoned = function(self)
	local stone = self:allocData(ffi.sizeof("Computicle_t"));
	stone = ffi.cast("Computicle_t *", stone);
	stone.HeapHandle = self.Heap:getNativeHandle();
	stone.IOCPHandle = self.IOCP:getNativeHandle();
	stone.ThreadHandle = self.Thread:getNativeHandle();

	return stone;
end

Computicle.exec = function(self, codechunk)
--print("Computicle.exec:");
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

	local buff = self:allocData(codelen+1);

	-- Copy the code into the newly allocated area
	-- make sure it is null terminated
	ffi.copy(buff, ffi.cast("const uint8_t *", codechunk), codelen);
	ffi.cast("uint8_t *",buff)[codelen] = 0;

	-- post the message with the code chunk
	return self:receiveMessage(Computicle.Messages.CODE, buff, codelen)
end

Computicle.import = function(self, codemodule)
	local fs = io.open(codemodule)
	if not fs then 
		return false, 'could not load file'
	end

	local codechunk = fs:read("*all");
	fs:close();

	return self:exec(codechunk);

end

Computicle.getMessage = function(self, timeout)
	return self.IOCP:dequeue(timeout);
end


Computicle.allocData = function(self, size)
	if not size then
		return false, 'no size specified';
	end

	return self.Heap:alloc(size);
end

Computicle.freeData = function(self, msg)
	if msg ~= nil then
		self.Heap:free(msg);
	end

	return self;
end

Computicle.allocMessage = function(self, message, param1, param2)
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

Computicle.freeMessage = function(self, msg)
	self:freeData(msg);
end

Computicle.receiveMessage = function(self, message, param1, param2)
	-- Create a message object to send to the thread
	-- post it to the thread's queue
	self.IOCP:enqueue(self:allocMessage(message, param1, param2));

	return true;
end

Computicle.quit = function(self)
	self:receiveMessage(Computicle.Messages.QUIT);
end

--[[
Computicle.resume = function(self)
	self.Thread:resume();
	return self;
end
--]]

Computicle.waitForFinish = function(self, timeout)
	local timeout = timeout or ffi.C.INFINITE;
	local status = core_synch.WaitForSingleObject(self.Thread:getNativeHandle(), timeout);
	
	if status == WAIT_OBJECT_0 then
		return true;
	end


	return false, status;
end


return Computicle;


