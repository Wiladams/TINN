
RunOnce = function(sink)
	print("comp_sourcecode, RunOnce...")
	for i = 1, 10 do
		sink:postMessage(i);
	end
	--sink:quit();
end


OnIdle = function(counter)
	print("comp_sourcecode, OnIdle(): ", counter)
	if sink ~= nil then 
		RunOnce(sink);

		sink = nil;
		exit();
	end
end



