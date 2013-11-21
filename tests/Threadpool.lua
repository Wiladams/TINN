local ffi = require("ffi")

local core_threadpool = require("core_threadpool_l1_2_0")
local errorhandling = require("core_errorhandling_l1_1_1");


--[[
	Threadpool Work Handle Type
--]]
ffi.cdef[[
typedef struct {
	PTP_WORK Handle;	
} ThreadpoolWorkHandle_t;
]]

local ThreadpoolWorkHandle_t = ffi.typeof("ThreadpoolWorkHandle_t")
local ThreadpoolWorkHandle_mt = {
	__gc = function(self)
		--print("GC: ThreadpoolWorkHandle")
	end,

	__tostring = function(self)
		return tostring(self.Handle)
	end,
}
ffi.metatype(ThreadpoolWorkHandle_t, ThreadpoolWorkHandle_mt)



ThreadpoolWork = {}
setmetatable(ThreadpoolWork, {
	__call = function(self, ...)
		return self:create(...)
	end,
})
ThreadpoolWork_mt = {
	__index = ThreadpoolWork;

	__tostring = function(self)
		return tostring(self.Handle.Handle)
	end,
}


ThreadpoolWork.init = function(self, rawhandle)
	local obj = {
		Handle = ThreadpoolWorkHandle_t(rawhandle)
	}
	setmetatable(obj, ThreadpoolWork_mt)

	return obj;
end

ThreadpoolWork.create = function(self, pfnwk, pv, pcbe)
	local rawhandle = core_threadpool.CreateThreadpoolWork(pfnwk, pv, pcbe);

    return self:init(rawhandle)
end

ThreadpoolWork.getNativeHandle = function(self)
	return self.Handle.Handle;
end

ThreadpoolWork.waitForFinish = function(self, cancelPending)
	cancelPending = cancelPending or false;
	core_threadpool.WaitForThreadpoolWorkCallbacks(self:getNativeHandle(), cancelPending)
end



--[[
	Threadpool Handle type
--]]
ffi.cdef[[
typedef struct {
	PTP_POOL Handle;
} ThreadpoolHandle_t;
]]

local ThreadpoolHandle_t = ffi.typeof("ThreadpoolHandle_t")
local ThreadpoolHandle_mt = {
	__gc = function(self)
		--print("GC: ThreadpoolHandle_t")
		core_threadpool.CloseThreadpool(self.Handle)
	end,
}

ffi.metatype(ThreadpoolHandle_t, ThreadpoolHandle_mt)



local Threadpool = {
	DefaultMinThreads = 2;
	DefaultMaxThreads = 4;
}
setmetatable(Threadpool, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local Threadpool_mt = {
	__index = Threadpool,
}

Threadpool.init = function(self, rawhandle)

	local obj = {
		Environment = core_threadpool.TP_CALLBACK_ENVIRON();
		Handle = ThreadpoolHandle_t(rawhandle);
	}
    
	-- SetThreadpoolCallbackPool
    obj.Environment.Pool = rawhandle;

	setmetatable(obj, Threadpool_mt);

	return obj;
end


Threadpool.create = function(self, maxthreads, minthreads)
	maxthreads = maxthreads or Threadpool.DefaultMaxThreads;
	minthreads = minthreads or Threadpool.DefaultMinThreads;

	local rawhandle = core_threadpool.CreateThreadpool(nil)

	if rawhandle == nil then
		return nil, errorhandling.GetLastError();
	end

	core_threadpool.SetThreadpoolThreadMaximum(rawhandle, maxthreads);
	core_threadpool.SetThreadpoolThreadMinimum(rawhandle, minthreads);

	return self:init(rawhandle)
end

Threadpool.createTask = function(self, pfnwk, pv)
	local task, err = ThreadpoolWork(pfnwk, pv, self.Environment)
	
	--print("ThreadpoolWork: ", tostring(task))
	
	return task, err;
end

Threadpool.scheduleTask = function(self, pfnwk, pv)
	local task, err = self:createTask(pfnwk, pv)
	local res = core_threadpool.SubmitThreadpoolWork(task:getNativeHandle())

	return task;
end

return Threadpool
