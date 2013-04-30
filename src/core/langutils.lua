
local makeGlobal = function(thing, name)
	if name and thing then
		_G[name] = thing;
	elseif type(thing) == "table" then
		for k,v in pairs(thing) do 
			--if type(v) == "table" then
			--	makeGlobal(v, k);
			--else
				_G[k]=v
			--end 
		end
	end
	
	return true;
end

return {
	makeGlobal = makeGlobal;
}