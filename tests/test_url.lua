local URL = require("url");

function printURL(urltable)
	print("==================================")
	for name, value in pairs(urltable) do
		print(name, value)
	end
end

printURL(URL.parse("//www.bing.com/", {port="80", path="/", scheme="http"}));

printURL(URL.parse("file://www.bing.com/favicon.ico"));

printURL(URL.parse("http://appgateway.cloudapp.net/resources?file=favicon.ico"));

printURL(URL.parse("ssh://wiladams:PassingWording@appgateway.cloudapp.net:80/resources?file=favicon.ico"));
