
--[[
	References: http://tools.ietf.org/html/rfc6455
]]

local ffi = require("ffi")
local bit = require("bit")
local bxor = bit.bxor
local base64 = require("base64")

local CryptUtils = require("BCryptUtils")
local UrlParser = require("url");

local WebResponse = require ("WebResponse");

local b64 = require("base64");


BinaryStream = require("BinaryStream");
BitBang = require("BitBang");

local format = string.format;
local tinsert = table.insert;

local webSocketGUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";


WebSocket_t = {}
WebSocket_mt = {
	__index = WebSocket_t,
}

local WebSocket = function(dataStream)
	local obj = {
		DataStream = dataStream;
		readyState = "CLOSED",
	}

	setmetatable(obj, WebSocket_mt);

	return obj
end

local UpgradeRequest = function(req)
	local lines = {
    	format('GET %s HTTP/1.1',req.uri or ''),
    	format('Host: %s',req.host),
    	'Upgrade: websocket',
    	'Connection: Upgrade',
    	format('Sec-WebSocket-Key: %s',req.key),
--    	format('Sec-WebSocket-Protocol: %s',table.concat(req.protocols,', ')),
    	'Sec-WebSocket-Version: 13',
	}

	if req.origin then
    	tinsert(lines,string.format('Origin: %s',req.origin))
  	end
  if req.port and req.port ~= 80 then
    lines[2] = format('Host: %s:%d',req.host,req.port)
  end
  tinsert(lines,'\r\n')
  return table.concat(lines,'\r\n')
end


WebSocket_t.InitiateClientHandshake = function(self, url, origin)
	local urlparts = UrlParser.parse(url, {port="80", path="/", scheme="ws"});

--print("WebSocket_t.InitiateClientHandshake()", urlparts.host, urlparts.port, urlparts.path, urlparts.query)

	local rngBuff, err = CryptUtils.GetRandomBytes(16)
	if not rngBuff then
		return false, err
	end
	local nonce = b64.encode(rngBuff, 16);

	local req = {
		uri = url,
		host = urlparts.host,
		port = urlparts.port,
		key = nonce,
		origin = origin,
		protocols = {},
	}

	local upgraded = UpgradeRequest(req);

--print("UPGRADED: ", upgraded);

	local status, err = self.DataStream:writeString(upgraded);

-- BUGBUG
-- the following line affects the timing of the parse
-- such that it will fail of the following line is commented out
--print("  DataStream:writeString: ", status, err);

	if not status then
		return false, err
	end

	-- Get the response back
	local response, err = WebResponse:Parse(self.DataStream);

	if not response then 
		print("Response Error: ", err);
		return false, err
	end

	if response.Status ~= "101" then
		return false, response.Status
	end

	self.readyState = "OPEN"

	return true
end

WebSocket_t.Connect = function(self, url, onconnected)
	local urlparts = URL.parse(url, {port=80});

	self.readyState = "CONNECTING"

	-- perform the client handshake
	local success, err = self:InitiateClientHandshake(urlparts)

	if not success then
		self.readyState = "DISCONNECTED"
		return onconnected(false, err)
	end

	return onconnected(self, err)
end

WebSocket_t.RespondWithServerHandshake = function(self, request, response)
	--print("WebSocket_t.RespondWithServerHandshake(): ", self, request, response)
	self.Request = request
	self.DataStream = request.DataStream;

	-- formulate a websocket handshake response
	local clientkey = request:GetHeader("sec-websocket-key");
	--print("WebSocket_t.RespondWithServerHandshake(), clientkey: ", clientkey)
	
	local acceptkey = clientkey..webSocketGUID;
	acceptkey, binbuff, binbufflen = CryptUtils.SHA1(acceptkey);
	--print("WebSocket_t.RespondWithServerHandshake(), SHA1: ", acceptkey, binbuff, binbufflen)

	acceptkey = base64.encode(binbuff, binbufflen);
--print("ACCEPT KEY: ", acceptkey);


	-- give a response
	local headers = {
		["Connection"] = "Upgrade",
		["Upgrade"] = "websocket",
		["Sec-WebSocket-Accept"] = acceptkey,
	}
	response:writeHead("101", headers)
	local byteswritten, err = response:writeEnd();

--print("RespondWithServerHandshake, END: ", byteswritten, err);

	return byteswritten, err;
end

--[[
      0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     +-+-+-+-+-------+-+-------------+-------------------------------+
     |F|R|R|R| opcode|M| Payload len |    Extended payload length    |
     |I|S|S|S|  (4)  |A|     (7)     |             (16/64)           |
     |N|V|V|V|       |S|             |   (if payload len==126/127)   |
     | |1|2|3|       |K|             |                               |
     +-+-+-+-+-------+-+-------------+ - - - - - - - - - - - - - - - +
     |     Extended payload length continued, if payload len == 127  |
     + - - - - - - - - - - - - - - - +-------------------------------+
     |                               |Masking-key, if MASK set to 1  |
     +-------------------------------+-------------------------------+
     | Masking-key (continued)       |          Payload Data         |
     +-------------------------------- - - - - - - - - - - - - - - - +
     :                     Payload Data continued ...                :
     + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
     |                     Payload Data continued ...                |
     +---------------------------------------------------------------+

--]]

WebSocket_t.OnClose = function(self)
	print("CLOSE RECEIVED");
end

WebSocket_t.OnPing = function(self)
	print("PING RECEIVED");
end

local unmaskdata =  function(buff, bufflen, mask)
	local buffptr = ffi.cast("uint8_t *", buff);
	local maskptr = ffi.cast("const uint8_t *", mask);

	for i=0,bufflen-1 do
		buff[i] = bxor(buffptr[i], maskptr[i % 4])
	end
end

WebSocket_t.ReadFrameHeader = function(self)
--print("WebSocket_t.ReadFrameHeader()")
	local headerbuff = ffi.new("uint8_t[4]")
	local BStream = BinaryStream.new(self.DataStream, true);

	-- Read the first two bytes to get up to the initial
	-- payload length
	local bytesread, err = self.DataStream:readBytes(headerbuff, 2);
--print("WebSocket_t.ReadFrameHeader, 2 byte header: ", bytesread, err)

	if not bytesread then
		print("Could not read first 2 bytes of frame")
		return false, err
	end

--	print("WS:ReadFrame: ", BitBang.bytestobinary(headerbuff, 2, 0, true));
--print(string.format("0x%x 0x%x", headerbuff[0], headerbuff[1]))
	local frameHeader = {}
	frameHeader.FIN = BitBang.getbitsfrombytes(headerbuff, 0, 1, true)
	frameHeader.RSV1 = BitBang.getbitsfrombytes(headerbuff, 1, 1, true)
	frameHeader.RSV2 = BitBang.getbitsfrombytes(headerbuff, 2, 1, true)
	frameHeader.RSV3 = BitBang.getbitsfrombytes(headerbuff, 3, 1, true)
	frameHeader.opcode = BitBang.getbitsfrombytes(headerbuff, 4, 4, true)
	frameHeader.MASK = BitBang.getbitsfrombytes(headerbuff, 8, 1, true) > 0;
	frameHeader.PayloadLen = BitBang.getbitsfrombytes(headerbuff, 9, 7, true)

--print("FRAME HEADER")
--for k,v in pairs(frameHeader) do
--	print(k,v);
--end


	-- if payload length == 126 then next two bytes
	-- indicate 16-bit unsigned short payload length
	if frameHeader.PayloadLen == 126 then
		local value, err = BStream:ReadUInt16();
		if not value then
			return false, err
		end
		frameHeader.PayloadLen = value;
	elseif frameHeader.PayloadLen == 127 then
		local value, err = BStream:ReadUInt64();
		if not value then
			return false, err
		end
		frameHeader.PayloadLen = value;
	end

--print("Extended PayloadLen: ", frameHeader.PayloadLen);


	-- If the mask bit is set, then there must be a mask field
	-- otherwise it is absent.
	if frameHeader.MASK then
		frameHeader.maskingkey = ffi.new("uint8_t[4]");
		local bytesread, err = self.DataStream:ReadBytes(frameHeader.maskingkey, 4);
		if not bytesread then
			return false, err
		end
	end


	return frameHeader;
end

WebSocket_t.ReadFrame = function(self)
--print("WebSocket_t.ReadFrame")
	local frameHeader, err = self:ReadFrameHeader();

	if not frameHeader then
		print("WebSocket.ReadFrame(), reading header Error: ", err);
		return false, err
	end

	-- Finally, read the payload data
	local payloaddata = ffi.new("uint8_t[?]", frameHeader.PayloadLen);
	local bytesread, err = self.DataStream:ReadBytes(payloaddata, frameHeader.PayloadLen)

--print("PAYLOAD: ", bytesread, err)

	if not bytesread then
		return false, err
	end

	if frameHeader.MASK then
		unmaskdata(payloaddata, bytesread, frameHeader.maskingkey)
	end
	
	frameHeader.Data = payloaddata;
	frameHeader.DataLength = bytesread;

	return frameHeader
end

WebSocket_t.WriteFrameHeader = function(self, frameHeader)
--print("WebSocket_t.ReadFrameHeader()")
	local headerbuff = ffi.new("uint8_t[4]")
	local BStream = BinaryStream.new(self.DataStream, true);

--	print("WS:WriteFrameHeader: ", BitBang.bytestobinary(headerbuff, 2, 0, true));
--print(string.format("0x%x 0x%x", headerbuff[0], headerbuff[1]))
	BitBang.setbitstobytes(headerbuff, 0, 1, frameHeader.FIN, true);
	BitBang.setbitstobytes(headerbuff, 1, 1, frameHeader.RSV1, true);
	BitBang.setbitstobytes(headerbuff, 2, 1, frameHeader.RSV2, true);
	BitBang.setbitstobytes(headerbuff, 3, 1, frameHeader.RSV3, true);
	BitBang.setbitstobytes(headerbuff, 4, 4, frameHeader.opcode, true);

	if frameHeader.MASK then
		BitBang.setbitstobytes(headerbuff, 8, 1, 1, true);
	else
		BitBang.setbitstobytes(headerbuff, 8, 1, 0, true);
	end

	if frameHeader.PayloadLen < 126 then
		BitBang.setbitstobytes(headerbuff, 9, 7, frameHeader.PayloadLen, true);
		self.DataStream:WriteBytes(headerbuff, 2);
	elseif frameHeader.PayloadLen < 65535 then
		BitBang.setbitstobytes(headerbuff, 9, 7, 126, true);
		self.DataStream:WriteBytes(headerbuff, 2);
		BStream:WriteUInt16(frameHeader.PayloadLen);
	else
		BitBang.setbitstobytes(headerbuff, 9, 7, 127, true);
		self.DataStream:WriteBytes(headerbuff, 2);
		BStream:WriteUInt64(frameHeader.PayloadLen);
	end

	-- If the mask bit is set, then there must be a mask field
	-- otherwise it is absent.
	if frameHeader.MASK then
		local byteswritten, err = self.DataStream:WriteBytes(frameHeader.maskingkey, 4);
		if not byteswritten then
			return false, err
		end
	end


	return frameHeader;
end

WebSocket_t.WriteFrame = function(self, message, FIN, opcode, shouldmask)
	FIN = FIN or 1;
	opcode = opcode or 1;
	shouldmask = shouldmask or 0;

	local payloadlen = #message;
	local payloaddata = ffi.new("uint8_t[?]", payloadlen);
	ffi.copy(payloaddata, ffi.cast("const uint8_t *", message), payloadlen);

--print("WebSocket_t.ReadFrame")
	local frameHeader = {
		FIN = FIN;
		RSV1 = 0;
		RSV2 = 0;
		RSV3 = 0;
		opcode = opcode;
		MASK = shouldmask;
		PayloadLen = payloadlen;
	}

	if shouldmask then
		frameHeader.maskingkey = CryptUtils.GetRandomBytes(4);
		unmaskdata(payloaddata, payloadlen, frameHeader.maskingkey)
	end

	-- Write the header out
	self:WriteFrameHeader(frameHeader);


	-- Finally, write the payload data
	local byteswritten, err = self.DataStream:WriteBytes(payloaddata, payloadlen);
--print("PAYLOAD: ", byteswritten, err)
	if not byteswritten then
		return false, err
	end
	
	return true
end

return WebSocket