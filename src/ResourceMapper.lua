
local ShortestPrefixMatch = function(resource, urlmap)
		local shortestMatch = nil
		for prefix,value in pairs(urlmap) do
			local start, finish = resource:find(prefix)
			if start and start == 1 then
				if not shortestMatch then
					shortestMatch = prefix
				else
					if #prefix < #shortestMatch then
						shortestMatch = prefix
					end
				end
			end
		end

		if shortestMatch then
			return urlmap[shortestMatch]
		end

		return nil
	end

local LongestPrefixMatch = function(resource, urlmap)
		local candidateMatch = nil
		for prefix,value in pairs(urlmap) do
			local start, finish = resource:find(prefix)
			if start and start == 1 then
				if not candidateMatch then
					candidateMatch = prefix
				else
					if #prefix > #candidateMatch then
						candidateMatch = prefix
					end
				end
			end
		end

		if candidateMatch then
			return urlmap[candidateMatch]
		end

		return nil
	end

local ResourceMapper = {
	FindHandler = function(request, urlmap)
--print("FindHandler: ", request.Resource);

		local funcs = LongestPrefixMatch(request.Resource, urlmap)
		if not funcs then
			--print("NO Functions found for resource")
			return nil
		end

		-- If we have a method specific function
		-- then return that
		local method = funcs[request.Method]

		--print("FindHandler: ", request.Resource, method);

		if method then
			return method
		end

		-- If we didn't have a method specific function
		-- then look for the default function
		method = funcs["_DEFAULT"]

		return method
	end;

	ShortestPrefixMatch = ShortestPrefixMatch,
	LongestPrefixMatch = LongestPrefixMatch,
}

return ResourceMapper;
