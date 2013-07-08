
local ffi = require ("ffi");

-- Read the number of bytes specified by the 'size'
-- parameter.
local function ReadN(socket, buff, size)

	local nleft = size;
	local nread = 0;
	local err
	local ptr = ffi.cast("uint8_t *",buff);

	while nleft > 0 do
		nread, err = socket:receive(ptr, nleft);

			--print("IOCPSocketIo.ReadN: ", nread, err)

		if not nread then
			print("IOCPSocketIo.ReadN, ERROR: ", nread, err)
			break;
		end

		if nread == 0 then
			break
		end

		nleft = nleft - nread;
		if nleft == 0 then
			break
		end

		ptr = ptr + nread;
	end

	if err then
		print("ReadN, ERROR: ", err);
	end

	local bytesread = size - nleft

	if bytesread == 0 then
		return nil, "eof"
	end

	return bytesread
end


--[[
	Read a single line terminated with one of:
	\r\n
	\n
--]]

local CR = string.byte("\r")
local LF = string.byte("\n")

local function ReadLine(socket, buff, size)
--print("IOCPSocketIo.ReadLine()")
	local nchars = 0;
	local ptr = ffi.cast("uint8_t *", buff);
	local bytesread, err

	while nchars < size do
		bytesread, err = ReadN(socket, ptr, 1);
		
		if not bytesread then
			-- err is either "eof" or some other socket error
			break
		else
			if ptr[0] == LF then
				--io.write("LF]\n")
				break
			elseif ptr[0] == CR then
				--io.write("[CR")
			else
				-- Just a regular character
				ptr = ptr + 1
				nchars = nchars+1
			end
		end
	end

--print("END OF WHILE:", err, nchars)
	if err and err ~= "eof" then
		return nil, err
	end

	return nchars
end


--[[
	Writing routines
--]]
local function WriteN(sock, buff, size)
--io.write("WriteN: ", buff, size, '\n')
	local nleft = size;
	local nwritten = 0;
	local err
	local ptr = ffi.cast("const uint8_t *", buff)

	while nleft > 0 do
		nwritten, err = sock:send(ptr, nleft)

--print("WriteN, send, err: ", nwritten, err);
		if not nwritten then
			break;
		end

		nleft = nleft - nwritten

		if nwritten == 0 then
			break
		end
					
		ptr = ptr + nwritten;
	end

	return size-nleft
end

return {
	ReadN = ReadN,
	ReadLine = ReadLine,
	WriteN = WriteN,
}