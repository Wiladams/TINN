
local mime = require "mime"

-- Load static content
local function loadResource(filename)
	-- determine the mimetype of the file
	-- try to load the file
	local fs = io.open(filename, "rb")
	
	if not fs then return nil end

	local fileData = fs:read("*a");
	fs:close();

	return fileData, mime.GetType(filename);
end

local function SendFile(filename, response)
	-- load the actual requested resource
	local resourceBody, mimetype = loadResource(filename);
print("SendFile(), FILE: ", filename, mimetype);

	if not resourceBody then
print("NO RESPONSE BODY")
		-- send back an error response
		response:writeHead("404", {["Content-Length"]="0"});
		response:writeEnd();
		return false, "Resource Not Found";
	end

print("== SENDING ==");
print(resourceBody);

	local headers = {
		["Content-Type"] = mimetype;
	}

	response:writeHead(200, headers);
	return response:writeEnd(resourceBody);
end

local function SendStaticContent(request, response, basename)
print("SendStaticContent: ", request.Resource);
	basename = basename or "static";
	local rootdir = '/'..basename;

	local starting, ending = request.Resource:find(rootdir);
		
	local resource = request.Resource:sub(ending+1);

	-- BUGBUG
	-- need to scrub for '../'
	local filename = basename..'/'..resource;

	return SendFile(filename, response);
end

return {
	loadResource = loadResource,
	SendStaticContent = SendStaticContent,
	SendFile = SendFile,
}