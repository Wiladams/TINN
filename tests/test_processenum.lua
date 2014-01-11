

local OSProcess = require("OSProcess");
local Query = require("Query")

local function test_query()
	local res = {};
		
	for record in Query.query {
		source = OSProcess:processes(), 

		filter = filterfunc,
		} do
		--print("query: ", record)
		table.insert(res, record);
	end
end

local function test_processes()
	for proc in OSProcess:processes() do
		print(proc:getImageName());
	end
end

local function test_processids()
	for id in OSProcess:processIds() do 
		print("ID: ", id)
		--local proc, err = OSProcess:open(id);
		--if proc then
		--	print(proc:getImageName());
		--else
		--	print("ERROR, proc: ", proc, err)
		--end
	end
end

test_query();
--test_processids();
test_processes();
