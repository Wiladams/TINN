-- test_binlib.lua

local bin = require("bin")

local h = ""
h = h..bin.pack("A", "hello world")

print(h)