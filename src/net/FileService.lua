
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

	if not resourceBody then
--print("NO RESPONSE BODY: ", filename, mimetype)
		-- send back an error response
		local respHeader = {
			["Connection"] = "Keep-Alive",
			["Content-Length"]="0",
		};
		response:writeHead("404", respHeader);
		response:writeEnd();
		return false
	end

--print("== FileService.SENDING ==");
--print("FILE: ", filename, mimetype);
--print(resourceBody);

	local headers = {
		["Connection"] = "Keep-Alive",
		["Content-Type"] = mimetype;
	}

	response:writeHead(200, headers);
	response:writeEnd(resourceBody);
end

local function SendStaticContent(request, response, basename)
--print("SendStaticContent: ", request.Resource);
	basename = basename or "static";
	local rootdir = '/'..basename;

	local starting, ending = request.Resource:find(rootdir);
		
	local resource = request.Resource:sub(ending+1);

	-- BUGBUG
	-- need to scrub for '../'
	local filename = basename..'/'..resource;

	SendFile(filename, response);
end

return {
	loadResource = loadResource,
	SendStaticContent = SendStaticContent,
	SendFile = SendFile,
}