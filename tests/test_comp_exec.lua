local Computicle = require("Computicle");

-- The following runs a primary application loop
comp = Computicle:load("comp_msgpump");


-- Functions to be injected into computicle
comp.OnIdle = function(count)
  print("IDLE", count)
end

comp.hello = function()
  print("Hello, Injector!");
end



-- Functions to be executed locally
printNumbers = function()
  comp:exec([[print(" Low: ", lowValue);]]);
  comp:exec([[print("High: ", highValue);]]);
end


setNumbers = function()
  comp.lowValue = 100;
  comp.highValue = 200;
end




local setTable = function()

	comp.contacts = {
		{first = "William", last = "Adams", phone = "(111) 555-1212"},
		{first = "Bill", last = "Gates", phone = "(111) 123-4567"},
	}


comp:exec([=[
print("== CONTACTS ==")

-- turn contacts back into a Lua table
local JSON = require("dkjson");

local contable = JSON.decode(contacts);


for _, person in ipairs(contable) do
	--print(person);
	print("== PERSON ==");
	for k,v in pairs(person) do
		print(k,v);
	end
end

]=]);
end



-- set timeout interval for idling
comp.gIdleTimeout = 1000;


function main()
print("MAIN");

	comp:exec([[hello()]]);

	setNumbers();
	printNumbers();


	setTable();

	-- Wait for finish, or 5 seconds
	print(comp:waitForFinish(5000));
	
	-- send a quit message
	comp:quit();

	-- and wait again to see how it returns from finish
	-- this time
	print(comp:waitForFinish(1000));
end

main();

