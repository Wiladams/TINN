-- test_query.lua
--

local JSON = require("dkjson");
local Query = require("Query");
local irecords = Query.irecords


local records = {
	{name = "William", address="1313 Mockingbird Lane", occupation = "eng"},
	{name = "Daughter", address="university", occupation="student"},
	{name = "Wife", address="home", occupation="changer"},
}

local test_iterator = function()
	for record in irecords(records) do
		print(record);
	end
end

local test_query = function()
	local source = irecords(records);

	local res = {}

	for record in Query.query {
		source = source, 
	
		projection = function(self, record)
			return {name=record.name, address=record.address, };
		end,

		filter = function(self, record)
			if record.occupation == "eng" then
				return record;
			end
		end
		} do

		table.insert(res, record);
	end


	local jsonstr = JSON.encode(res, {indent=true});

	print(jsonstr);
end

test_iterator();
test_query();