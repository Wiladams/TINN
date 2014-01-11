-- Computicle.lua

local ffi = require("ffi");

local arch = require("arch")
local Heap = require("Heap");
local core_synch = require("core_synch_l1_2_0");
local errorhandling = require("core_errorhandling_l1_1_1");
local WinBase = require("WinBase");
local JSON = require("dkjson");

local TINNThread = require("TINNThread");
local IOCompletionPort = require("IOCompletionPort");
local ComputicleOps = require("ComputicleOps");


local Computicle = {
	Threads = {},

	Prolog = [[
TINNThread = require("TINNThread");
Computicle = require("Computicle");
ComputicleOps = require("ComputicleOps");
IOCompletionPort = require("IOCompletionPort");
Heap = require("Heap");
Application = require("Application");

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
    local msg, datalen, dataPtr = SELFICLE:getMessage(gIdleTimeout);
    -- false, WAIT_TIMEOUT == timed out
    --print("MSG: ", msg, err);

    if not msg then
      if datalen == WAIT_TIMEOUT then
        --print("about to idle")
        idlecount = idlecount + 1;
        if OnIdle then
          OnIdle(idlecount);
        end
      end
    else
      msg = tonumber(msg);
      --print("MSG: ",msg);
      local msgFullyHandled = false;

      if OnMessage then
        msgFullyHandled = OnMessage(msg, dataPtr, datalen);
      end


      if not msgFullyHandled then    


        if msg == ComputicleOps.Messages.QUIT then
          if OnExit then
            OnExit();
          end
          break;
        end

        if msg == ComputicleOps.Messages.CODE then
          local len = datalen;
          local codePtr = ffi.cast("const char *", dataPtr);
    
          if codePtr ~= nil and len > 0 then
            local code = ffi.string(codePtr, len);

            -- assume the data was allocated from ourself
            -- so free it
            --SELFICLE:freeData(ffi.cast("void *",codePtr));

            -- execute the code chunk
            local func, err = loadstring(code);
            func();
            --print("MSG PUMP, loadstring: ", func, err);
            --print("FUNC(): ",func());
          end
        end

        if datalen > 0 then
          SELFICLE:freeData(dataPtr);
        end
      end
    end
  
    -- give up time to other tasks
    Application:yield();
  end

  print("BROKEN OUT")
end

Application:run(handlemessages);
]];
}
setmetatable(Computicle, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local Computicle_mt = {
	__index = Computicle;
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

Computicle.createThreadChunk = function(self, codechunk, params, codeparams)
	local res = {};


	-- What we want to load before any other code is executed
	-- This is typically some 'require' statements.
	table.insert(res, Computicle.Prolog);


	-- Package up the parameters that may want to be passed in
	local paramname = "_params";

	table.insert(res, string.format("%s = {};", paramname));
	table.insert(res, ComputicleOps.packParams(params, paramname));
	table.insert(res, ComputicleOps.packParams(codeparams, paramname));

	-- Create the Computicle instance that is running within 
	-- the Computicle
	table.insert(res, 
		string.format("SELFICLE = Computicle:init(%s.HeapHandle, %s.IOCPHandle);", paramname, paramname));


	-- Stuff in the user's code
	table.insert(res, [[_cmain = function()]]);
	table.insert(res, codechunk);
	table.insert(res, [[end]]);

	-- make sure the user's code is running in a coroutine
	table.insert(res, [[Application:spawn(_cmain)]]);

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

Computicle.__toEssence = function(self)
	local essence = string.format("Computicle:init(TINNThread:StringToPointer(%s),TINNThread:StringToPointer(%s));", 
				arch:pointerToString(self.Heap:getNativeHandle()), 
				arch:pointerToString(self.IOCP:getNativeHandle()));

	return essence;
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


Computicle.getMessage = function(self, timeout)
	return self.IOCP:dequeue(timeout);
end


Computicle.allocData = function(self, size)
	if not size then
		return false, 'no size specified';
	end

	return self.Heap:alloc(size);
end

Computicle.freeData = function(self, dataPtr, len)
	if dataPtr ~= nil then
		self.Heap:free(dataPtr);
	end

	return self;
end

Computicle.receiveMessage = function(self, message, dataPtr, dataLen)
	-- Create a message object to send to the thread
	-- post it to the thread's queue
	self.IOCP:enqueue(message, dataLen, dataPtr);

	return true;
end

Computicle.quit = function(self)
	self:receiveMessage(ComputicleOps.Messages.QUIT);
end

--[[
	Block the calling thread waiting for the computicle
	to finish.  The finish is indicated when the thread
	that is running the computicle exits.
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
