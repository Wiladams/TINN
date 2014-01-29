
local ffi = require("ffi")
local Application = require("Application")

local TcpSplice = {}
setmetatable(TcpSplice, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local TcpSplice_mt = {
	__index = TcpSplice,
}

TcpSplice.init = function(self, part1, part2)
	
	local obj = {
		Part1 = part1,
		Part2 = part2,
	}
	setmetatable(obj, TcpSplice_mt);

	return obj;
end

TcpSplice.create = function(self, ...)
	return self:init(...);
end

local splice = function(fromsock, tosock)
	--print("splice - BEGIN")

	local bufflen = 1462;
	local buff = ffi.new("uint8_t[?]", bufflen);
	local bytesreceived = 0;
	local recverr = nil;
	local senderr = nil;

	local bytessent = 0;

	while true do
		bytesreceived, recverr = fromsock:receive(buff, bufflen)
		
		--print("splice, bytesreceived: ", bytesreceived, err)

		if not bytesreceived then
			break;
		end

		if bytesreceived == 0 then
			recverr = "eof"
			break
		end


		bytessent, senderr = tosock:send(buff, bytesreceived)

		if not bytessent then
			break;
		end

		if bytessent == 0 then
			senderr = "eof"
			break;
		end
	end

	-- close the socket
	if recverr then
		tosock:closeDown();
	end

	if senderr then
		fromsock:closeDown();
	end
	--print("splice - END")
end

TcpSplice.run = function(self)
	-- Start a splice loop in both directions
	Application:coop(splice, self.Part1, self.Part2);
	Application:coop(splice, self.Part2, self.Part1);
end

return TcpSplice
