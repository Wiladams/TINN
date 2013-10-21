-- test_NativeFile.lua

local NativeFile = require("NativeFile")


local f1, err = NativeFile("testfile.txt")


print("Native File: ", f1, err)

-- Write some stuff to the file
f1:writeString("The Quick Brown Fox Jumped Over the Lazy Dogs Back\r\n")

