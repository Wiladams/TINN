-- test_functor.lua

local functorFactor = function(params)
	local functor = {
		Params = params;
	}

	setmetatable(functor, {
		__call = function(...)
			print(functor.Params);
		end,
		})

	return functor
end


local f1 = functorFactor("words to say", func);

f1();

f1.Params = "new words to say"

f1();

f1.Params = nil;
print("-----")
f1();
