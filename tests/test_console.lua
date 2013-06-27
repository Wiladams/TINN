-- test_console.lua
local ffi = require("ffi");
local bit = require("bit");
local band = bit.band;
local bor = bit.bor;
local bxor = bit.bxor;

local core_console1 = require("core_console_l1_1_0");
local core_console2 = require("core_console_l2_1_0");
local processenviron = require("core_processenvironment");

local console = require("console");
local core_string = require("core_string_l1_1_0");
local core_synch = require("core_synch_l1_2_0");
local ConsoleWindow = require("ConsoleWindow");


--[[
	Test Cases
--]]

local con = ConsoleWindow:CreateNew();

con:setTitle("New Console Title");
con:setMode(0);
con:enableLineInput();
con:enableEchoInput();
con:enableProcessedInput();

local bufflen = 256;
local buff = ffi.new("char[?]", bufflen);

--	core_synch.SleepEx(10000, true);

while true do
	core_synch.SleepEx(3000, true);
	
	local bytesread, err = con:ReadBytes(buff, bufflen);

	if bytesread then
		print("\b")
		--print(ffi.string(buff, bytesread));
	else
		print("Error: ", err);
	end
end