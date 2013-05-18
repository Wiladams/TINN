
local ffi = require("ffi");
local WinError = require("win_error");
local core_string = require("core_string_l1_1_0");
local httpapi = require("httpapi");


local HttpRequestQueue = {}
setmetatable(HttpRequestQueue, {
	__call = function(self, ...)
		return HttpRequestQueue:new(...);
	end,
});

local HttpRequestQueue_mt = {
	__index = HttpRequestQueue;
}

HttpRequestQueue.new = function(self, name)
	local pName;
	if name then
		pName = core_string.toUnicode(name);
	end
	local pSecurityAttributes = nil;
	local Flags = 0;
	local pReqQueueHandle = ffi.new("HANDLE[1]");

	local version = ffi.new("HTTPAPI_VERSION", 2, 0);

	local status = httpapi.HttpCreateRequestQueue(
		version,
		pName,
		pSecurityAttributes,
		Flags,
		pReqQueueHandle);

	if status ~= NO_ERROR then
		return false, tostring(status);
	end

	local obj = {
		Handle = pReqQueueHandle[0];
	}
	setmetatable(obj, HttpRequestQueue_mt);

	return obj;
end

HttpRequestQueue.receiveRequest = function(self, pRequestBuffer, RequestBufferLength)
	pRequestBuffer = pRequestBuffer or ffi.new("HTTP_REQUEST");
	RequestBufferLength = RequestBufferLength or ffi.sizeof(pRequestBuffer);
	local RequestId = 0;
	local Flags = 0;
	local pBytesReceived = ffi.new("ULONG[1]");
	local pOverlapped = nil;

	local status = httpapi.HttpReceiveHttpRequest(
    	self.Handle,
     	RequestId,
    	Flags,
    	pRequestBuffer,
    	RequestBufferLength,
    	pBytesReceived ,
    	pOverlapped);

	print("receiveRequest: ", status);

	return true;
end

--[[

--]]
HttpServerSession = {}
setmetatable(HttpServerSession, {
	__call = function(self, ...)
		return HttpServerSession:new(...);
	end,

	__index = HttpServerSession_t,
});

HttpServerSession_mt = {
	__index = HttpServerSession;
}

HttpServerSession.new = function(self, ...)
	-- Create a server session
	local version = ffi.new("HTTPAPI_VERSION", 2, 0);
	local pServerSessionId = ffi.new("HTTP_SERVER_SESSION_ID[1]");
	local Reserved = 0;

	local status = httpapi.HttpCreateServerSession(version, pServerSessionId, Reserved);

	if status ~= NO_ERROR then
		return false, tostring(status);
	end

	local obj = {
		Handle = pServerSessionId[0];
	}
	setmetatable(obj, HttpServerSession_mt);

	return obj;
end

HttpServerSession.createUrlGroup = function(self)
	return HttpUrlGroup(self.Handle);
end

HttpServerSession.createRequestQueue = function(self, name)
	return HttpRequestQueue(name);
end



--[[
	HttpUrlGroup
--]]
HttpUrlGroup = {}
setmetatable(HttpUrlGroup, {
	__call = function(self, ...)
		return HttpUrlGroup:new(...);
	end,

});

HttpUrlGroup_mt = {
	__index = HttpUrlGroup,
}
HttpUrlGroup.new = function(self, ServerSessionId)
	-- Create a request queue
	local pUrlGroupId = ffi.new("HTTP_URL_GROUP_ID[1]");
	local Reserved = 0;
	local status = httpapi.HttpCreateUrlGroup(ServerSessionId, pUrlGroupId, Reserved);
	
	if status ~= NO_ERROR then
		return false, tostring(status);
	end
	

	local obj = {
		Handle = pUrlGroupId[0];
	}
	setmetatable(obj, HttpUrlGroup_mt);

	return obj;
end

HttpUrlGroup.addUrl = function(self, url)
	local pFullyQualifiedUrl = core_string.toUnicode(url);
	local UrlContext = 0;
	local Reserved = 0;

	local status = httpapi.HttpAddUrlToUrlGroup(self.Handle, pFullyQualifiedUrl, UrlContext, Reserved);

	if status ~= NO_ERROR then
		return false, tostring(status);
	end

	return true;
end




--[[
	Test Cases
--]]
local session = HttpServerSession();

-- create a server session
assert(session);

-- create a url group
local urlGroup = session:createUrlGroup();
assert(urlGroup);

-- Add a URL to watch
print(urlGroup:addUrl("http://localhost:8080/system"));

-- create a request queue
local requestQueue = session:createRequestQueue();

assert(requestQueue, "request queue not created");

--for k,v in pairs(requestQueue) do
--	print(k,v);
--end
--print("metatable: ", getmetatable(requestQueue) == HttpRequestQueue_mt);

requestQueue:receiveRequest();
