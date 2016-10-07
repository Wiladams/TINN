
local function importGlobal(thing, name, tbl)
	tbl = tbl or _G;

	if name and thing then
		tbl[name] = thing;
	elseif type(thing) == "table" then
		for k,v in pairs(thing) do 
			--if type(v) == "table" then
			--	makeGlobal(v, k);
			--else
				tbl[k]=v
			--end 
		end
	end
	
	return true;
end

return {
	importGlobal = importGlobal;
}