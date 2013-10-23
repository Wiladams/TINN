-- test_NativeFile.lua
require("IOProcessor")

local NativeFile = require("NativeFile")


main = function()
	local f1, err = NativeFile("testfile.txt")


	print("Native File: ", f1, err)

	-- Write some stuff to the file
	f1:writeString("The Quick Brown Fox Jumped Over the Lazy Dogs Back\r\n")
end


run(main)

