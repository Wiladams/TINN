local URL = require("url");

function printURL(urltable)
	print("==================================")
	for name, value in pairs(urltable) do
		print(name, value)
	end
end

local test_parse = function()
	printURL(URL.parse("//www.bing.com/", {port="80", path="/", scheme="http"}));

	printURL(URL.parse("file://www.bing.com/favicon.ico"));

	printURL(URL.parse("http://appgateway.cloudapp.net/resources?file=favicon.ico"));

	printURL(URL.parse("ssh://wiladams:PassingWording@appgateway.cloudapp.net:80/resources?file=favicon.ico"));
end

local test_path = function()
	local parts = URL.parse("http://localhost:8080/files/tools/TINN/tinn.exe");
	printURL(parts);

	local segments = URL.parse_path(parts.path)

	print("== SEGMENTS ==")
	for _, item in ipairs(segments) do
		print(item);
	end
	print("--------------");

	table.remove(segments, 1);
	local path = URL.build_path(segments, false);
	print("PATH UNSAFE: ", path);

	path = URL.build_path(segments, true);
	print("PATH SAFE: ", path);

end

local test_escape = function()
	local aurl = "https://localhost:8080/files/tools/TINN Directory/tinn.exe";

	local fixed = URL.escape(aurl);

	print("fixed: ", fixed);
end


--test_path();
test_escape();