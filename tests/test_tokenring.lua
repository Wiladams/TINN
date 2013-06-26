-- test_tokenring.lua
local TokenRing = require("TokenRing");

local tr = TokenRing(10);

tr:deliver(523);
tr:deliver(345, 6);
tr:deliver(273, 9);

tr:awaitFinish();
