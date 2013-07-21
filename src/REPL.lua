
local ffi = require("ffi");
local luajit_ffi = require("luajit_ffi");
local stringzutils = require("stringzutils");
local console = require("console");
local ConsoleWindow = require("ConsoleWindow");

-- Configuration for the frontend (the luajit executable).
local LUA_PROGNAME = "tinn"  -- Fallback frontend name.
local LUA_PROMPT   = "> "  -- Interactive prompt.
local LUA_PROMPT2  = ">> " -- Continuation prompt.
local LUA_MAXINPUT = 512 -- Max. input line length.


local REPL = {}

--[[
REPL.report = function(int status)

  if (status && !lua_isnil(L, -1)) {
    const char *msg = lua_tostring(L, -1);
    if (msg == NULL) msg = "(error object is not a string)";
    l_message(progname, msg);
    lua_pop(L, 1);
  }
  return status;
end
--]]

REPL.write_prompt = function(firstline)
  if firstline then
    io.write(LUA_PROMPT);
  else
    io.write(LUA_PROMPT2);
  end
end

--[[
REPL.incomplete = function(status)

  if (status == luajit.LUA_ERRSYNTAX) then
    local lmsg;
    const char *msg = lua_tolstring(L, -1, &lmsg);
    const char *tp = msg + lmsg - (sizeof(LUA_QL("<eof>")) - 1);
    if (strstr(msg, LUA_QL("<eof>")) == tp) {
      lua_pop(L, 1);
      return 1;
    }
  end

  return false;  -- else... */
end
--]]

REPL.getline = function(firstline)

  REPL.write_prompt(firstline);
  local line, err = io.read();

--print("getline: ", line, err);

  if not line then
    return false, err;
  end

  local buf = strdup(line);
  local len = stringzutils.strlen(buf);
  if (len > 0 and buf[len-1] == string.byte'\n') then
      buf[len-1] = 0;
   end

  if firstline and (buf[0] == string.byte('=')) then
    return "return "..ffi.string(buf+1);
  end

  return ffi.string(buf);
end


REPL.loadline = function()


  local line, err = REPL.getline(true);


  if (not line) then
    return nil, err;  -- no input 
  end

  local command = {};

  while (true) do  -- repeat until gets a complete line 
    table.insert(command, line);
    local status, err = loadstring(table.concat(command,'\n'));

    if status then
      return status;
    end

    -- try to add another line
    line, err = REPL.getline(false);

    if not line then
      return nil, err;
    end
  end
  
  return nil;
end


REPL.dotty = function()
  -- make sure we have a console
  --local con = ConsoleWindow:CreateNew();
  local con = console.AllocConsole();

  --console.AllocConsole();

  while (true) do
    local func, err = REPL.loadline();
    --print("func: ", func, err);

    if not func then
      print("loadline error: ", err);
      break;
    end

    local success, values = pcall(func);

    if not success then
      print(LUA_PROGNAME, "== ERROR ==");
      print(values);
    end
  end
end


return REPL
