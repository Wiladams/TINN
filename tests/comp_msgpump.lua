-- comp_msgpump.lua

--print("comp_msgpump, loading...");

local ffi = require("ffi");
require("IOProcessor");

-- This is a basic message pump
-- 

-- default to 15 millisecond timeout
gIdleTimeout = gIdleTimeout or 15


local idlecount = 0;

while true do
  if IOProcessor then
    IOProcessor:step();
  end

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

          local func = loadstring(code);
          func();
        end
      end
      SELFICLE:freeMessage(msg);
    end
  end
end
