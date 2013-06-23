local Computicle = require("Computicle");


local setNumbers = function()
	comp.lowValue = 100;
	comp.highValue = 200;

	comp:exec([[print(" Low: ", lowValue)]]);
	comp:exec([[print("High: ", highValue)]])
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


local function main()
	-- start by saying hello
	comp:exec([[print("hello, injector")]]);

	setNumbers();
	--setTable();

	SELFICLE:quit();
end


-- wait for it all to actually go through
comp:waitForFinish();

local comp = Computicle:loadAndRun("comp_msgpump");

