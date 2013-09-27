local MemoryStream = require("MemoryStream")

-- Create a memory stream of fixed size
local size = 10
local strm = MemoryStream(size);

print("Length: ", strm.Length)
print("Bytes Written: ", strm.BytesWritten)

-- write 100 bytes to the stream
for i=0,size do
	local bytesWritten, err = strm:WriteByte(i)
	print("wrote: ", i, bytesWritten, strm.BytesWritten, strm:BytesReadyToBeRead())
end

print("Ending Position: ", strm.Position)