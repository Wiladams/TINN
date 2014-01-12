-- test_IPUtils.lua
local bit = require("bit");
local band = bit.band;
local bor = bit.bor;
local BitBang = require("BitBang");

local IPUtils = require("IPUtils");


print(string.format("0x0708 ==> 0x%04x",IPUtils.swap16(0x0708)));

--print(string.format("0x0008 ==> 0x%x", IPUtils.htons(0x0008)));

--print(string.format("0x%x", 0x08));

--print(string.format("0x%x", 0x0800));
