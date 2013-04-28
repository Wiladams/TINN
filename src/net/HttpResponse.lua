local ffi = require "ffi"

local httpmsg = require("HttpMessage")

local HttpMessage = httpmsg.HttpMessage;
local HttpMessage_t = httpmsg.HttpMessage_t;

local HttpStatus = require ("httpstatus");

-- parse first line
-- parse lines until blank lines
local HttpResponse_t = {}
local HttpResponse_mt = {
	__index = HttpResponse_t;
}

-- Uses HTTP/1.1 by default
local HttpResponse = function(body, headers, status, phrase)
--print("HttpResponse() - 0.0");

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

	setmetatable(obj, HttpResponse_mt);

	-- Set the body if it's there
	obj:SetHeaders(headers)
	obj:SetBody(body);

	return obj;
end


function HttpResponse_t:writeHead(status, headers)
	self.Status = tostring(status);
	self.Phrase = HttpStatus.GetPhrase(status);
	self:SetHeaders(headers);
end

function HttpResponse_t:SetBody(body, len, offset)
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


function HttpResponse_t:WriteFirstLine(stream)
	-- Write request line
	local first_line = string.format("HTTP/%s %s %s", self.Version, self.Status, self.Phrase);

--print("HttpResponse:WriteFirstLine(): ",first_line);

	return stream:WriteLine(first_line)
end


function HttpResponse_t:WritePreamble(stream)
	stream = stream or self.DataStream;
	
	if not self.Status then
		return false, "no status indicated"
	end

	local success, err
	success, err = self:WriteFirstLine(stream)
--	print("HttpResponse:WritePreamble() 1.0 - ", success, err);
	if err then
		return nil, err
	end

	success, err = self:WriteHeaders(stream);
--	print("HttpResponse:WritePreamble() 2.0 - ", success, err);
	if err then
		return nil, err
	end

	-- Write blank line
	success, err = stream:WriteLine()
--	print("HttpResponse:WritePreamble() 3.0 - ", success, err);

	return success, err
end

function HttpResponse_t:Send(stream)
	if not self.Status then
		print("-- HttpResponse:Send(), Response has NO Status")
		return false, "no status specified"
	end

	local success, err = self:WritePreamble(stream);
	
	--print("-- HttpResponse:Send() Preamble - ", success, err)
	if not success then
		return false, err
	end
	
	-- Write body
	if self.Body then
		local bodylen = self:GetHeader("Content-Length");
		--print("--HttpResponse:Send(), Body: ", bodylen);
		if bodylen then
			bodylen = tonumber(bodylen)
			success, err = stream:WriteBytes(ffi.cast("const uint8_t *",self.Body), bodylen, 0)
		end
	end
	
	return success, err
end

function HttpResponse_t:writeEnd(body)
	if body then
		self:SetBody(body);
	end
	
	if not self.Body then
		if not self:GetHeader("content-length") then
			self:AddHeader("Content-Length", "0")
		end
	end

	return self:Send(self.DataStream);
end

local OpenResponse = function(stream)
	local obj = HttpResponse(nil, nil, nil, nil);
	obj.DataStream = stream;

	return obj
end

local Parse = function(stream)
--print("HttpResponse.Parse() - 1.0");

	local firstline, err = stream:ReadLine(4096)

print(string.format("HttpResponse.Parse() - 1.1: '%s', %s", tostring(firstline), tostring(err)));
print("-- ISBLANK: ", firstline == "");

	if not firstline then
		print("HttpResponse.Parse(), NO First Line: ", err)
		return nil, err
	end

--print("HttpResponse.Parse() - 2.0");
	-- For a response stream
	--HTTP-Version SP Status-Code SP Reason-Phrase CRLF
	local version, status, phrase = firstline:match'^HTTP/(%d+%.%d+) (%d%d%d) ?(.*)$'

	if (not status) then
		--print(firstline)
		return nil, "no status"
	end


--print("HttpResponse.Parse() - 3.0");
	local resp = HttpResponse(body, headers, status, phrase)
	resp.Version = version;
	resp.DataStream = stream;
	resp.FirstLine = firstline;

--print("HttpResponse.Parse() - 6.0");

	local lastline, err = resp:ReadHeaders(stream)
--print("HttpResponse.Parse() - 7.0");

	return resp
end

return {
	new = HttpResponse,
	Open = OpenResponse,
	Parse = Parse,
}
