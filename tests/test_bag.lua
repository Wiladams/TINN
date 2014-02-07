--[[
	Testing the Bag
--]]
local Collections = require("Collections")

local names = {
	alpha = "alpha-value";
	beta = "beta-value";
	gamma = "gamma-value";
}

local bg = Collections.Bag();

for k,v in pairs(names) do
	print("adding: ", k, v)
	bg[k] = v;
end;

print("Count after add: ", #bg)


bg["gamma"] = nil;

print("Count, after 1 remove: ", #bg)

print("beta: ", bg["beta"])

-- iterate over items
print("== pairs ==")
for k,v in pairs(bg) do
	print(k,v)
end
