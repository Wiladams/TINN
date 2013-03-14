
local HttpStatus = require ("httpstatus");

local test_mixed_status=function()
local statii = {
	"200",
	"100",
	304,
	404,
	"500"
	};

	-- print out som\
	for _,status in ipairs(statii) do
		print(status, HttpStatus.GetPhrase(status));
	end
end

local test_all_status = function()
	for status,v in pairs(HttpStatus.codes) do
		print(status, HttpStatus.GetPhrase(status));
	end
end

test_mixed_status();
--test_all_status();
