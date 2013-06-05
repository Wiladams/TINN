-- test_heap.lua

local Heap = require("Heap");

local h1 = Heap:create(4096);
local b1 = h1:alloc(10);
local b2 = h1:alloc(20);

local entries = h1:entryList();

print("Entries: ", #entries);

for _,entry in ipairs(entries) do
	print("======================")
	for k,v in pairs(entry) do
		print(k,v);
	end
end


local blob1 = h1:allocBlob(3600);

print(blob1);



