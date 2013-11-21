
local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor;

local IOProcessor = require("IOProcessor")
local Stream = require("stream")
local BlockFile = require("BlockFile")
local StreamOps = require("StreamOps")


local Logfile = {}
setmetatable(Logfile,{
	__call = function(self, ...)
		return self:create(...)
	end
})

local Logfile_mt = {
	__index = Logfile	
}

Logfile.init = function(self, device)
	local obj = {
		Stream = Stream(device)
	}
	setmetatable(obj, Logfile_mt)

	return obj
end

Logfile.create = function(self, filename)
	local dwDesiredAccess = ffi.C.GENERIC_WRITE;
	local dwShareMode = bor(FILE_SHARE_READ, FILE_SHARE_WRITE);	
	local dwCreationDisposition = OPEN_ALWAYS;

	local	blkfile, err = BlockFile(filename, 
		dwDesiredAccess, 
		dwCreationDisposition)

	if not blkfile then
		return nil, err;
	end

	blkfile:seek(0, StreamOps.SEEK_END)

	return self:init(blkfile)
end

Logfile.trace = function(self, ...)
	local message = select(1, ...)
	self.Stream:writeString(message)
	self.Stream:flush();
end


return Logfile;
