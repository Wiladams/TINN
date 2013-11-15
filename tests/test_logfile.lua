-- test_logfile.lua
local IOProcessor = require("IOProcessor")
local Stream = require("stream")
local BlockFile = require("BlockFile")

local Logfile = require("Logfile")

local log = Logfile("logfile.log")


local main = function()
	for i=1,10 do
		log:trace(string.format("trace line: %d\n",i))
	end
end

run(main)
