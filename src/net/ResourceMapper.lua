
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
	ShortestPrefixMatch = ShortestPrefixMatch,
	LongestPrefixMatch = LongestPrefixMatch,	
}
setmetatable(ResourceMapper, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local ResourceMapper_mt = {
	__index = ResourceMapper;
}

ResourceMapper.init = function(self, urlmap)
	local obj = {
		UrlMap = urlmap;
	};
	setmetatable(obj, ResourceMapper_mt);

	return obj;
end

ResourceMapper.create = function(self, ...)
	return self:init(...);
end


ResourceMapper.getHandler = function(self, request)
--print("ResourceMapper:findHandler(): ", request.Resource);

	local funcs = LongestPrefixMatch(request.Resource, self.UrlMap)
	local method;

	if funcs then
		method = funcs[request.Method]
		if not method then
			-- If we didn't have a method specific function
			-- then look for the default function
			method = funcs["_DEFAULT"]
		end
	end

	return method;
end

return ResourceMapper;
