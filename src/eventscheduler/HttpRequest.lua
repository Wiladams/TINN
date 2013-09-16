local ffi = require "ffi"
--local peg = require "peg_http"
local MemoryStream = require "MemoryStream"

local HttpMessage = require ("HttpMessage").HttpMessage;
local HttpMessage_t = require("HttpMessage").HttpMessage_t;


local HttpRequest_t = {}
local HttpRequest_mt = {
--[[
	__tostring = function(self)
		local mstream = MemoryStream(8192)
		self:Send(mstream)

		local str = mstream:ToString()

		return str
	end,
--]]
	__index = HttpRequest_t;
}


local HttpRequest = function(method, resource, headers, body)
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

	setmetatable(obj, HttpRequest_mt);

	obj:SetHeaders(headers);
	-- Set the body if it's there
	obj:SetBody(body);

	return obj;
end


function HttpRequest_t:SetBody(body)
	if not body then
		self.Body = nil
		return self;
	end

	len = #body

--print("--HttpRequest:SetBody()")
--print(body)

	self.Body = body
	self:AddHeader("Content-Length", len);
end



function HttpRequest_t:WritePreamble(stream)
--print("HttpRequest:WritePreamble()")
	if not self.Method or not self.Resource then
		return nil, "malformed http request"
	end

	local success, err

	-- Write request line
	local req_line = string.format("%s %s HTTP/%s", self.Method, self.Resource,self.Version);
	success, err = stream:WriteLine(req_line)
--print("-- HttpRequest:WritePreamble(), Line Success: ", success, err);
	if not success then
		return nil, err
	end

	-- Write Headers
	success, err = self:WriteHeaders(stream);
--print("-- HttpRequest:WritePreamble(), Headers Success: ", success, err);
	if not success then
		return nil, err
	end

	-- Write blank line
	success, err = stream:WriteLine()
--print("-- HttpRequest:WritePreamble(), Blank Success: ", success, err);

	return success, err
end


function HttpRequest_t:Send(stream)
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


local Parse = function(stream)
--print("HttpRequest.Parse() - 1.0");

	local firstline, err = stream:ReadLine(4096)

--print(string.format("HttpRequest.Parse() - 1.1: '%s', %s", tostring(firstline), tostring(err)));
--print("-- ISBLANK: ", firstline == "");

	if not firstline or firstline == "" then
		print("HttpRequest.Parse(), First Line: ", firstline, err)
		return nil, err
	end

--print("HttpRequest.Parse() - 2.0");

	-- For a request 
	local method, uri, version = firstline:match'^([^ ]+) ([^ ]+) HTTP/(%d+%.%d+)$'

	--local method, uri, reqmajor, reqminor
	--method, uri, reqmajor, reqminor = peg.Match(peg.Request_Line, firstline);
--print("--",method, uri,version)

	if (not method)  then
		return nil, "no Http method found"
	end

--print("HttpRequest.Parse() - 3.0");
	local req = HttpRequest(method, uri, nil, nil)
	req.FirstLine = firstline
	req.Version = version
	req.DataStream = stream;

--print("HttpRequest.Parse() - 6.0");

	local lastline, err = req:ReadHeaders(stream)

	return req
end


return {
	new = HttpRequest,
	Parse = Parse,
}

