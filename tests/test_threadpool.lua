-- test_threadpool.lua
local ffi = require("ffi")

local Threadpool = require("Threadpool")
local core_synch = require("core_synch_l1_2_0");
local stdlib = require("stdlib")

local malloc = stdlib.malloc
local free = stdlib.free


jit.off(somework)
local function somework(Instance, Context, Work)
	local ctxt = ffi.cast("int *", Context)

	--print("Instance: ", Instance)
	--print("Context: ", Context)
	print("Somework Work: ", ctxt[0])
end

ffi.cdef[[
typedef struct {
	int value;
} boxedint
]]
boxedint = ffi.typeof("boxedint")

boxedint_mt = {
	__new = function(ct, value)
		local abox = malloc(ffi.sizeof("boxedint"))
		abox = ffi.cast("boxedint *", abox)
		abox.value = value;
		return abox;
	end,

	__newindex = function(self, key, value)
		print("key, value: ", key, value)
	end,

	__gc = function(self)
		free(self)
	end,
}
ffi.metatype(boxedint, boxedint_mt)



local tp1 = Threadpool();

local int17 = boxedint(17);

local testSchedule = function()
	int17.value = 17;

	print("int17: ", int17.value)

	local task1 = tp1:scheduleTask(somework, {int17})
	--local task2 = tp1:scheduleTask(somework)
	--local task3 = tp1:scheduleTask(somework)
	--local task4 = tp1:scheduleTask(somework)


	-- do something to sleep the current thread
	task1:waitForFinish();
	--task2:waitForFinish();
	--task3:waitForFinish();
	--task4:waitForFinish();
	--core_synch.SleepEx(10 * 1000, true);
end


local testTask = function()
	local task = tp1:createTask(somework)

	print(task)
end

--testTask();
testSchedule();
