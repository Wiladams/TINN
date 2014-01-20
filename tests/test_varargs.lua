-- test_varargs.lua

local function func2(...)
	while true do
		print("func2: ", ...)
		coroutine.yield(...);
	end
end

local crt2 = coroutine.create(func2)

local function func1(...)
	while true do
		local res = {pcall(coroutine.resume, crt2, ...)}
		local pcallres = table.remove(res, 1)
		local corres = table.remove(res, 1)
		
		print("func1: ", unpack(res))

		coroutine.yield(unpack(res))
	end
end


local args = {"a", "b", 1, 2, 3}
local crt1 = coroutine.create(func1)

while true do
	args = {coroutine.resume(crt1, unpack(args))}
end
