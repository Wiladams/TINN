
local makeGlobal = function(thing)
	if type(thing) == "table" then
		for k,v in pairs(example) 
			do _G[k]=v 
		end
	end
end


return {
	makeGlobal = makeGlobal;
}