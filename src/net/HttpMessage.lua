
HttpMessage_t = {}
HttpMessage_mt = {
	__index = HttpMessage_t,
}

--[[
local HttpMessage = function(obj)
	obj = obj or {}

	obj.Headers = {}

	setmetatable(obj, HttpMessage_mt)

	return obj
end
--]]

HttpMessage_t.AppendHeader = function(self, name, value)
	local header = self.Headers[name];
	if not header or not value then
		return nil
	end

   	self.Headers[name] = self.Headers[name]..value;
end

HttpMessage_t.AddHeader = function(self, name, value)
	if not name then
		return nil
	end

	name = name:lower();

	local prevval = self.Headers[name]
	if prevval then
		value = prevval .. "," .. value
	end                        
	self.Headers [name] = value                        
end

 HttpMessage_t.CopyHeaders = function(self, headers, exclusions)
	if not headers then return nil end

	exclusions = exclusions or {}

	for name, value in pairs(headers) do
		if not exclusions[name] then
			self:AddHeader(name, value)
		end
	end
end

HttpMessage_t.SetHeaders = function(self, headers)
	if not headers then
		self.Headers = {}
		return
	end

	for name, value in pairs(headers) do
		self:AddHeader(name, value);
	end
end

HttpMessage_t.GetHeader = function(self, name)
	-- BUGBUG
	-- This should be a cases insensitive compare instead
	-- of doing a 'tolower'
	return self.Headers[name:lower()];
end

HttpMessage_t.ReadHeaders = function(self, stream)
	-- Read the headers
	-- and the expected blank line
	-- after them
	local headerline
	local err
    local prevname;

	while true do
		-- Read a line, terminated with crlf
		-- a 'nil' return would indicate either
		-- an error, or 'eof', so check the err
		headerline, err = stream:ReadLine(4096)
print("HttpMessage_t.ReadHeaders(), HEADERLINE: ", headerline, err)
		if not headerline then 
			return nil, err
		end

		if headerline == "" then
			return ""
		end


		-- parse the line to separate the name from the value
        local _,_, name, value = string.find (headerline, "^([^: ]+)%s*:%s*(.+)")

--print("HEADER: ", name, value)

        if name then
        	self:AddHeader(name, value)
        	prevname = name
        elseif prevname then
        	self:AppendHeader(prevname, value);
        end
	end

	return headerline, err
end

HttpMessage_t.WriteHeaders = function(self, stream)
	--print("HttpMessage_t.WriteHeaders() : ", self.Headers);

	if not self.Headers then
		return
	end

	local success, err

	for name,value in pairs(self.Headers) do
		--print("-- Header: ", name, value);
		--local hdr = string.format("%s: %s", value.name, value.value);
		local hdr = string.format("%s: %s", name, value);
		--print("-- Response Header: ", hdr);
		success, err = stream:WriteLine(hdr);

		if err then
			return nil, err
		end
	end

	return success, err
end


return {
	HttpMessage_t = HttpMessage_t,
}
