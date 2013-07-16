local ffi = require "ffi"

local MemoryStream = require "MemoryStream"

local HttpMessage = require ("HttpMessage").HttpMessage;
local HttpMessage_t = require("HttpMessage").HttpMessage_t;


local WebRequest = {}
setmetatable(WebRequest, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local WebRequest_mt = {
--[[
	__tostring = function(self)
		local mstream = MemoryStream.new(8192)
		self:Send(mstream)

		local str = mstream:ToString()

		return str
	end,
--]]
	__index = WebRequest;
}


WebRequest.init = function(self, method, resource, headers, body)
	headers = headers or {}

	local obj = {
		AppendHeader = HttpMessage_t.AppendHeader,
		AddHeader = HttpMessage_t.AddHeader,
		CopyHeaders = HttpMessage_t.CopyHeaders,
		GetHeader = HttpMessage_t.GetHeader,
		SetHeaders = HttpMessage_t.SetHeaders,
		ReadHeaders = HttpMessage_t.ReadHeaders,
		WriteHeaders = HttpMessage_t.WriteHeaders,


		Method = method,
		Version = "1.1",
		Resource = resource,
		Headers = {}
	}

	setmetatable(obj, WebRequest_mt);

	obj:SetHeaders(headers);
	obj:SetBody(body);

	return obj;
end



WebRequest.create = function(self, method, resource, headers, body)
	return self:init(method, resource, headers, body);
end

---[[
WebRequest.SetBody = function(self, body)
	if not body then
		self.Body = nil;
		return self;
	end

	len = #body;

--print("--WebRequest:SetBody()")
--print(body)

	self.Body = body;
	self:AddHeader("Content-Length", len);
end


WebRequest.WritePreamble = function(self, stream)
--print("WebRequest:WritePreamble()")
	if not self.Method or not self.Resource then
		return nil, "malformed http request"
	end

	local success, err

	-- Write request line
	local req_line = string.format("%s %s HTTP/%s", self.Method, self.Resource,self.Version);
	success, err = stream:WriteLine(req_line)
--print("-- WebRequest:WritePreamble(), Line Success: ", success, err);
	if not success then
		return nil, err
	end

	-- Write Headers
	success, err = self:WriteHeaders(stream);
--print("-- WebRequest:WritePreamble(), Headers Success: ", success, err);
	if not success then
		return nil, err
	end

	-- Write blank line
	success, err = stream:WriteLine()
--print("-- WebRequest:WritePreamble(), Blank Success: ", success, err);

	return success, err
end

WebRequest.Send = function(self, stream)
	--self.DataStream = stream

	local success, err = self:WritePreamble(stream)

	if not success then
		return nil, err
	end

	-- Write body
	if self.Body then
		local len = self:GetHeader("content-length")
		local bodylen = tonumber(len);
		local bodyptr = ffi.cast("const uint8_t *", self.Body);
		success, err = stream:WriteBytes(bodyptr, bodylen, 0)
	end

	return success, err
end

--[[
	Parsing
--]]


WebRequest.Parse = function(self, stream)
	--print("WebRequest.Parse() - 1.0");



	local firstline, err = stream:readLine(4096)

--print(string.format("WebRequest.Parse() - 1.1: '%s', %s", tostring(firstline), tostring(err)));
--print("-- ISBLANK: ", firstline == "");

	if not firstline or firstline == "" then
		print("WebRequest.Parse(), First Line: ", firstline, err)
		return nil, err
	end

--print("WebRequest.Parse() - 2.0");

	-- For a request 
	local method, uri, version = firstline:match'^([^ ]+) ([^ ]+) HTTP/(%d+%.%d+)$'

	--local method, uri, reqmajor, reqminor
	--method, uri, reqmajor, reqminor = peg.Match(peg.Request_Line, firstline);
--print("--",method, uri,version)

	if (not method)  then
		return nil, "no Http method found"
	end

--print("WebRequest.Parse() - 3.0");
	local req = WebRequest(method, uri, nil, nil)
	req.FirstLine = firstline
	req.Version = version
	req.DataStream = stream;


--print("WebRequest.Parse() - 6.0");

	local lastline, err = req:ReadHeaders(stream);

	return req
end


return WebRequest;
