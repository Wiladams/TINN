-- test_ConsoleStream.lua
local ffi = require("ffi")
local ConsoleStream = require("ConsoleStream")

local con = ConsoleStream();

con:writeString("Here you go: > ")

local buff = ffi.new("char[10]")
local bytesRead, err = con:readBytes(buff, 10)

print("Bytes Read: ", bytesRead, err)

