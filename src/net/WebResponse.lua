local ffi = require "ffi"

local httpmsg = require("HttpMessage")

local HttpMessage = httpmsg.HttpMessage;
local HttpMessage_t = httpmsg.HttpMessage_t;
local HttpChunkIterator = require("HttpChunkIterator")

local HttpStatus = require ("httpstatus");

-- parse first line
-- parse lines until blank lines
local WebResponse = {}
setmetatable(WebResponse, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local WebResponse_mt = {
	__index = WebResponse;
}

WebResponse.init = function(self, body, headers, status, phrase)
	local obj = {
		-- Methods
		AppendHeader = HttpMessage_t.AppendHeader,
		AddHeader = HttpMessage_t.AddHeader,
		GetHeader = HttpMessage_t.GetHeader,
		SetHeaders = HttpMessage_t.SetHeaders,
		ReadHeaders = HttpMessage_t.ReadHeaders,
		WriteHeaders = HttpMessage_t.WriteHeaders,

		Status = status,
		Phrase = phrase,
		Version = "1.1",
		Headers = {},
	}

	setmetatable(obj, WebResponse_mt);

	-- Set the body if it's there
	obj:SetHeaders(headers)
	obj:SetBody(body);

	return obj;
end

WebResponse.create = function(self, body, headers, status, phrase)
--print("WebResponse() - 0.0");

	return self:init(body, headers, status, phrase);
end

WebResponse.OpenResponse = function(self, stream)
	local obj = WebResponse(nil, nil, nil, nil);
	obj.DataStream = stream;

	return obj
end

WebResponse.parse = function(self, stream)
--print("WebResponse.Parse() - 1.0");

	local firstline, err = stream:ReadLine(4096);

--print(string.format("WebResponse.Parse() - 1.1: '%s', %s", tostring(firstline), tostring(err)));
--print("-- ISBLANK: ", firstline == "");

	if not firstline then
		print("WebResponse.Parse(), NO First Line: ", err)
		return nil, err
	end

--print("WebResponse.Parse() - 2.0");
	-- For a response stream
	--HTTP-Version SP Status-Code SP Reason-Phrase CRLF
	local version, status, phrase = firstline:match'^HTTP/(%d+%.%d+) (%d%d%d) ?(.*)$'

	if (not status) then
		print(firstline)
		return nil, "no status"
	end


--print("WebResponse.Parse() - 3.0");
	local resp = WebResponse(body, headers, status, phrase)
	resp.Version = version;
	resp.DataStream = stream;
	resp.FirstLine = firstline;

--print("WebResponse.Parse() - 6.0");

	local lastline, err = resp:ReadHeaders(stream)
--print("WebResponse.Parse() - 7.0");

	return resp
end

function WebResponse:writeHead(status, headers)
	self.Status = tostring(status);
	self.Phrase = HttpStatus.GetPhrase(status);
	self:SetHeaders(headers);
end

function WebResponse:SetBody(body, len, offset)
	if not body then
		return
	end

	len = len or #body
	offset = offset or 0

	if len == 0 then
		return
	end

	self.Body = body
	self:AddHeader("Content-Length", tostring(len));
end


function WebResponse:WriteFirstLine(stream)
	-- Write request line
	local first_line = string.format("HTTP/%s %s %s", self.Version, self.Status, self.Phrase);

--print("WebResponse:WriteFirstLine(): ",first_line);

	return stream:WriteLine(first_line)
end


function WebResponse:WritePreamble(stream)
	stream = stream or self.DataStream;
	
	if not self.Status then
		return false, "no status indicated"
	end

	local success, err
	success, err = self:WriteFirstLine(stream)
--	print("WebResponse:WritePreamble() 1.0 - ", success, err);
	if err then
		return nil, err
	end

	success, err = self:WriteHeaders(stream);
--	print("WebResponse:WritePreamble() 2.0 - ", success, err);
	if err then
		return nil, err
	end

	-- Write blank line
	success, err = stream:WriteLine()
--	print("WebResponse:WritePreamble() 3.0 - ", success, err);

	return success, err
end

function WebResponse:send(stream)
--print("WebResponse:Send() ", stream)

	if not self.Status then
		print("-- WebResponse:Send(), Response has NO Status")
		return false, "no status specified"
	end

	local success, err = self:WritePreamble(stream);
	
	--print("-- WebResponse:Send() Preamble - ", success, err)
	if not success then
		return false, err
	end

	-- Write body
	if self.Body then
		local bodylen = self:GetHeader("Content-Length");
		--print("--WebResponse:Send(), Body: ", bodylen);
		if bodylen then
			bodylen = tonumber(bodylen)
			success, err = stream:writeBytes(ffi.cast("const uint8_t *",self.Body), bodylen, 0)
		end
	end
	
	return success, err
end

function WebResponse:writeEnd(body)
	if body then
		self:SetBody(body, #body);
	end
	
	if not self.Body then
		if not self:GetHeader("content-length") then
			self:AddHeader("Content-Length", "0")
		end
	end

	return self:Send(self.DataStream);
end

function WebResponse:chunks()
	return HttpChunkIterator.ReadChunks(self);
end

function WebResponse:readBody()
	local body = {}
	for chunk in HttpChunkIterator.ReadChunks(self) do
		table.insert(body, chunk)
	end

	return table.concat(body)
end


WebResponse.Parse = WebResponse.parse;
WebResponse.Send = WebResponse.send;


return WebResponse;

