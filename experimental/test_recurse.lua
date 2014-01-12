-- test_recurse.lua

local function looper(count)
print("looper: ", count)

	count = count - 1;
	if count < 1 then
		return
	end

	looper(count)
end

looper(5)

local looper2 = function(count)
print("looper2: ", count)

	count = count - 1;
	if count < 1 then
		return
	end

	looper2(count)
end

looper2(5)