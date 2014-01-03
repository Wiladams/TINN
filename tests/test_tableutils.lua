-- test_tableutils.lua
local tabutils = require("tabutils");



local tab = {};
tabutils.binsert(tab, 7);
tabutils.binsert(tab, 3);
tabutils.binsert(tab, 9);
tabutils.binsert(tab, 1);
tabutils.binsert(tab, 2);

print("== Dictionary ==")
for k,v in pairs(tab) do
	print(k,v);
end
print("----------------")


print("Size: ", #tab)
local nEntries = #tab
for i=1,nEntries do
	table.remove(tab, 1);
end

print("Entries After Remove: ", #tab)