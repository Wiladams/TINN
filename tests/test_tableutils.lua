-- test_tableutils.lua
local tabutils = require("tabutils");



tab = {};
tabutils.binsert(tab, 7);
tabutils.binsert(tab, 3);
tabutils.binsert(tab, 9);
tabutils.binsert(tab, 1);
tabutils.binsert(tab, 2);


for k,v in pairs(tab) do
	print(k,v);
end
