
local ffi = require ("ffi");

-- Write the number of bytes specified by the 'size'
-- parameter.
local function ReadN(sock, buff, size, verbose)
	--verbose = true;

	--if verbose then
	--	print("ReadN: ", buff, size)
	--end

	local nleft = size;
	local nread = 0;
	local err
	local ptr = buff

	while nleft > 0 do
		nread, err = sock:Receive(ptr, nleft)
		--if verbose then
			--print("RN: ", nread, err, ptr[0], string.char(ptr[0]));
		--	io.write(string.char(ptr[0]));
		--end

		if nread then
			if nread == 0 then
				break
			end

			nleft = nleft - nread
			if nleft == 0 then
				break
			end

			ptr = ptr + nread
		elseif err and err ~= WSAEWOULDBLOCK then
			break
		end

		--if verbose then
		--	print("RN: ", nread, err, ptr[0], string.char(ptr[0]));
		--end

		Runtime.Scheduler:YieldForIo(sock, POLLIN);
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

local function ReadLine(sock, buff, size)
--print("CoReadLine()")
	local nchars = 0;
	local ptr = ffi.cast("uint8_t *", buff);
	local bytesread, err

	while nchars < size do
		bytesread, err = ReadN(sock, ptr, 1);
		
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
		nwritten, err = sock:Send(ptr, nleft)
--print("nwritten, err: ", nwritten, err);
		if not nwritten then
			if err ~= WSAEWOULDBLOCK then
				return nil, err
			end
		else
			nleft = nleft - nwritten

			if nwritten == 0 then
				break
			end
			
			if nleft == 0 then
				break
			end
			
			ptr = ptr + nwritten
		end

		Runtime.Scheduler:YieldForIo(sock, POLLOUT);
	end

	return size-nleft
end

local Accept = function(sock)
	
	while true do
		local accepted, err = sock:Accept();

		if accepted then				
			return accepted
		elseif err and err ~= WSAEWOULDBLOCK then
			print("ACCEPT FAILURE: ", err);
			return nil, err;
		end

		Runtime.Scheduler:YieldForIo(sock, POLLIN);
	end
end

return {
	Accept = Accept,
	ReadN = ReadN,
	ReadLine = ReadLine,
	WriteN = WriteN,
}