

OnExit = function(msg)
	print("comp_sinkcode, EXIT");
end


OnMessage = function(msg)
	local Message = msg.Message;

	print(msg.Message*10);
end
