-- Query.lua
--

--[[
	the query function receives its parameters as a single table
	params.source - The data source.  It should be an iterator that returns
	table values

	params.filter - a function, that receives a single table value as input
	and returns a single table value as output.  If the record is 'passed' then
	it is returned as the return value.  If the record does not meet the filter
	criteria, then 'nil' will be returned.

	params.projection - a function to morph a single entry.  It receives a single
	table value as input, and returns a single table value as output.

	The 'filter' and 'projection' functions are very similar, and in fact, the
	filter can also be used to transform the input.  They are kept separate 
	so that each can remain fairly simple in terms of their implementations.
--]]

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

local irecords = function(tbl)
	local i=0;

	local closure = function()
		i = i + 1;
		if i > #tbl then
			return nil;
		end

		return tbl[i];
	end

	return closure	
end

return {
	irecords = irecords,
	query = query,
}
