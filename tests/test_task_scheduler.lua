require ("IOProcessor");

local test_wait = function(interval)
	while true do
		wait(interval);
		print(string.format("interval: %d - %d ", interval, IOProcessor.Clock:Milliseconds()));
	end
end

local function main()
	spawn(test_wait, 500);
	spawn(test_wait, 3000);
end


run(main)