local httpheaders = {
	-- Request headers
	["Accept"] = {request=true};
	["Accept-Charset"] = {request=true};
	["Accept-Encoding"] = {request=true};
	["Accept-Language"] = {request=true};
	["Accept-Datetime"] = {request=true};
	["Authorization"] = {request=true};
	["Pragma"] = {request=true, response=true};
	["Cookie"] = {request=true};
	["Content-MD5"] = {request=true};
	["Expect"] = {request=true};
	["From"] = {request=true};
	["Host"] = {request=true};
	["If-Match"] = {request=true};
	["If-Modified-Since"] = {request=true};
	["If-None-Match"] = {request=true};
	["If-Range"] = {request=true};
	["If-Unmodified-Since"] = {request=true};
	["Max-Forwards"] = {request=true};
	["Proxy-Authorization"] = {request=true};
	["Range"] = {request=true};
	["Referer"] = {request=true};
	["TE"] = {request=true};
	["Upgrade"] = {request=true};
	["User-Agent"] = {request=true};
	["Warning"] = {request=true};



	-- Non-standard request headers
	["X-Requested-With"] = {request=true};
	["X-Do-Not-Track"] = {request=true};
	["DNT"] = {request=true};
	["X-Forwarded-For"] = {request=true};
	["X-ATT-DeviceId"] = {request=true};
	["X-Wap-Profile"] = {request=true};

	-- Response Headers
	["Accept-Ranges"] = {response=true};
	["Age"] = {response=true};
	["Allow"] = {response=true};
	["Content-Encoding"] = {response=true};
	["Connection-Language"] = {response=true};
	["Content-Location"] = {response=true};
	["Content-Disposition"] = {response=true};
	["Content-Range"] = {response=true};
	["ETag"] = {response=true};
	["Expires"] = {response=true};
	["Last-Modified"] = {response=true};
	["Link"] = {response=true};
	["Location"] = {response=true};
	["P3P"] = {response=true};
	["Proxy-Authenticate"] = {response=true};
	["Refresh"] = {response=true};
	["Retry-After"] = {response=true};
	["Server"] = {response=true};
	["Set-Cookie"] = {response=true};
	["Strict-Transport-Security"] = {response=true};
	["Trailer"] = {response=true};
	["Transfer-Encoding"] = {response=true};
	["Vary"] = {response=true};
	["Warning"] = {response=true};
	["WWW-Authenticate"] = {response=true};

	-- Request and Response headers
	["Cache-Control"] = {request=true, response=true};
	["Connection"] = {request=true, response=true};
	["Content-Length"] = {request=true, response=true};
	["Content-Type"] = {request=true, response=true};
	["Date"] = {request=true, response=true};
	["Via"] = {request=true, response=true};

};

return httpheaders;
