-- test_NativeFile.lua
local Application = require("Application")
local BlockFile = require("BlockFile")
local Stream = require("stream")

main = function()
	local bf, err = BlockFile("testfile.txt")

	if not bf then
		print("BlockFile, ERROR: ", err)
		return false, err;
	end
	
	local f1, err = Stream(bf);


	print("Native File: ", f1, err)

	-- Write some stuff to the file
	f1:writeString("The Quick Brown Fox Jumped Over the Lazy Dogs Back\r\n")
end


run(main)

