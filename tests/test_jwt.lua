
local base64 = require("base64")
local utils = require("utils");


--[[
-- header
  {"typ":"JWT",
   "alg":"HS256"}

-- claims
 {"iss":"joe",
   "exp":1300819380,
   "http://example.com/is_root":true}


--]]

local jwtok1 = [[
eyJ0eXAiOiJKV1QiLA0KICJhbGciOiJIUzI1NiJ9
.
eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQogImh0dHA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlfQ
.
dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk
]]

--[[
--]]

local jwtok2 = [[
eyJhbGciOiJub25lIn0
.
eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQogImh0dHA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlfQ
.
]]

local segs = utils.split(jwtok1, '.');

for i=1,3 do 
	print("SEGMENT: ", segs[i])
	print("DECODED")
	print(base64.decode(segs[i]));
end

