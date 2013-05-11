
local SCManager = require("SCManager");
local JSON = require("dkjson");




local query = function(params)
	if not params or not params.source then
		return false, "source not specified";
	end

	local nextRecord = params.source;
	local filter = params.filter;
	local projection = params.projection;


	local function closure()
		local record;

		if filter then
			while true do
				record = nextRecord();	
	
				if not record then
					return nil;
				end
				
				record = filter(self, record);

				if record then
					break;
				end
			end
		else
			record = nextRecord();
		end

		if not record then
			return nil;
		end

		if projection then
			return projection(self, record);
		end

		return record;
	end

	return closure;
end

local mgr, err = SCManager();

local res = {}

for record in query {
	source = mgr:services(), 
	
	projection = function(self, record)
		return {name=record.ServiceName, description=record.DisplayName, };
	end,

	filter = function(self, record)
		if record.Status.ServiceFlags > 0 then
			return record;
		end
	end
	} do

	table.insert(res, record);
end


local jsonstr = JSON.encode(res, {indent=true});

print(jsonstr);

