

local OSProcess = require("OSProcess");

for id in OSProcess:processIds() do 
	local proc, err = OSProcess:open(id);
	if proc then
		print(proc:getImageName());
	end
end
