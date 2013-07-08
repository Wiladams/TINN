

OnMessage = function(msg)
	local Message = msg.Message;
--print("comp_splittercode, OnMessage(): ", Message);

	if sink1 then
		sink1:receiveMessage(Message);
	end	

	if sink2 then
		sink2:receiveMessage(Message);
	end
end

