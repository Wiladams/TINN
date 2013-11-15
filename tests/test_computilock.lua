
local IOProcessor = require("IOProcessor")
local SRWLock = require("SRWLock")

local Computicle = require("Computicle");
local Messenger = require("Messenger");


local lock = SRWLock();


local comp1 = Computicle:create([[
	print("Lock First - BEGIN")
	print(lock:lock());

	print("Lock First - begin waiting")
	wait(3000)

	print("Lock First - done waiting")

	lock:release();

	print("Lock First - END")
	exit()
]]);



local comp2 = Computicle:create([[
	print("Lock Second - BEGIN")
	print(lock:lock())
	print("Lock Second - END")

	exit();
]]);



print("Finish: ", comp1:waitForFinish());
print("Finish: ", comp2:waitForFinish());


