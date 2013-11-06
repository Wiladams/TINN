-- test_nativeflestream.lua

local NativeFile = require("NativeFile")
local Stream = require("stream")
local IOProcessor = require("IOProcessor")


local function main()

	local filedev, err = NativeFile("./sample.txt", nil, OPEN_EXISTING, FILE_SHARE_READ)

print("filedev, err: ", filedev, err)

	local filestrm = Stream(filedev)


	local line1, err = filestrm:readLine();
	local line2, err = filestrm:readLine();
	local line3, err = filestrm:readLine()

	print("line1: ", line1, err)
	print("line2: ", line2, err)
	print("line3: ", line3, err)
end

run(main)
