
local makeGlobal = function(thing, name)
	if type(thing) == "table" then
		for k,v in pairs(example) 
			do _G[k]=v 
		end
	elseif thing and name then
		_G[name] = thing;
	end
	
	return true;
end


return {
	makeGlobal = makeGlobal;
}