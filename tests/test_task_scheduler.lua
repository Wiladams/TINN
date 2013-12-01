require ("IOProcessor");

local test_sleep = function(interval)
	while true do
		sleep(interval);
		print(string.format("interval: %d - %d ", interval, IOProcessor.Clock:Milliseconds()));
	end
end

local function main()
	spawn(test_sleep, 500);
	spawn(test_sleep, 3000);
end


run(main)