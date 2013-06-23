-- comp_msgpump.lua

local ffi = require("ffi");

local IOCPEventScheduler = require("IOCPEventScheduler");
local IOCompletionPort = require("IOCompletionPort")


-- Some global variables
Scheduler = IOCPEventScheduler();


-- IO Completion port for networking
ioport = IOCompletionPort:create();

-- default to 15 millisecond timeout
gIdleTimeout = gIdleTimeout or 15


local idlecount = 0;

-- This is a basic message pump
-- 
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

    if OnMessage then
      msgFullyHandled = OnMessage(msg);
    end

    if not msgFullyHandled then
      msg = ffi.cast("ComputicleMsg *", msg);
      local Message = msg.Message;
      --print("Message: ", Message, msg.Param1, msg.Param2);
		
      if Message == Computicle.Messages.QUIT then
        break;
      end

      if Message == Computicle.Messages.CODE then
        local len = msg.Param2;
        local codePtr = ffi.cast("const char *", msg.Param1);
		
        if codePtr ~= nil and len > 0 then
          local code = ffi.string(codePtr, len);

          SELFICLE:freeData(ffi.cast("void *",codePtr));

          local func = loadstring(code);
          func();
        end
      end
      SELFICLE:freeMessage(msg);
    end
  end
end
