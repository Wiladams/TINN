
local makeGlobal = function(thing, name)
	if name and thing then
		_G[name] = thing;
	elseif type(thing) == "table" then
		for k,v in pairs(thing) do 
			_G[k]=v 
		end
	end
	
	return true;
end


return {
	makeGlobal = makeGlobal;
}