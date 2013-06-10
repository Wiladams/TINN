local ffi = require "ffi"
local bit = require("bit");
local band = bit.band;

local heap_ffi = require ("Heap_ffi");

local core_process = require("core_processthreads_l1_1_1");
local errorhandling = require("core_errorhandling_l1_1_1");





ffi.cdef[[
typedef struct {
	void *	Data;
	int32_t	Size;
	HANDLE	HeapHandle;
	DWORD	owningthread;
	bool	OwnAllocation;
} HeapBlob;
]]



--[[
	A HeapBlob is a chunk of memory that is allocated
	from a Heap.  The HeapBlob contains the pointer to
	the data that was allocated, as well as the size of
	the data.  It also contains a pointer back to the heap
	that was used to allocate the data in the first place.

	Given the amount of overhead associated with each blob,
	this construct is most useful when allocated large amounts
	of data, not small chunks.

	Given that it is a metatype, the objects can call the
	proper heap deallocation routine when they go out of scope
	and are about to be garbage collected.  This is a nice
	convenience, and makes heap allocation as seamless and
	painless as using ffi.new()
--]]
HeapBlob = ffi.typeof("HeapBlob");
HeapBlob_mt = {
	__gc = function(self)
		if self.HeapHandle == nil or self.owningthread == 0 then return nil end

		if self.owningthread == core_process.GetCurrentThreadId() then
			local res = heap_ffi.HeapFree(self.HeapHandle, 0, self.Data)
		end
	end,

	__index = {
		GetSize = function(self, flags)
			flags = flags or 0

			if self.HeapHandle == nil then 
				return false, "Blob has no handle"; 
			end

			local result = heap_ffi.HeapSize(self.HeapHandle, flags, self.Data)

			return result
		end,

		isValid = function(self, flags)
			flags = flags or 0

			if self.HeapHandle == nil then 
				return false,  "Blob has no handle";
			end

			local isValid = heap_ffi.HeapValidate(self.HeapHandle, flags, self.Data);

			return isValid
		end,

		reaAlloc = function(self, nbytes, flags)
			flags = flags or 0

			if self.Heap == nil then return false end

			local ptr = heap_ffi.HeapReAlloc(self.HeapHandle, flags, self.Data, nbytes)

			if ptr == nil then return false end

			self.Data = ptr;
			self.Size = nbytes;

			return true
		end,

	}
}
HeapBlob = ffi.metatype(HeapBlob, HeapBlob_mt);





ffi.cdef[[
typedef struct {
	HANDLE	Handle;
	bool	OwnAllocation;
	DWORD	Owningthread;
} HeapHandle;
]]
local HeapHandle = ffi.typeof("HeapHandle");
local HeapHandle_mt = {
	__gc = function(self)
		if self.Handle == nil or self.Owningthread == 0 then return false end

		if self.Owningthread == core_process.GetCurrentThreadId() then
			local status = heap_ffi.HeapDestroy(self.Handle);
		end
	end,

	__index = {

	},

}

local Heap = {}
setmetatable(Heap, {
	__call = function(self, ...)
		return Heap:new(...);
	end,


	__index = {

		create = function(self, initialSize, maxSize, options)
			local initialSize = initialSize or 0
			local maxSize = maxSize or 0
			local options = options or 0

			-- Try to allocate the heap as specified
			local rawhandle = heap_ffi.HeapCreate(options, initialSize, maxSize)

			-- If the allocation fails
			-- just return nil
			if rawhandle == nil then
				return false, "could not create heap"
			end

			local aheap = Heap(rawhandle, true, core_process.GetCurrentThreadId());

			return aheap
		end,

		getProcessHeap = function()
			local rawhandle = heap_ffi.GetProcessHeap()

			-- If we couldn't get the handle to the process
			-- heap, then just return nil
			if rawhandle == nil then
				return nil
			end

			local aheap = Heap(rawhandle)

			return aheap;
		end,
	},
});

local Heap_mt = {
	__index = Heap;
}


Heap.new = function(self, rawhandle, ownAllocation, owningThread)
	ownAllocation = ownAllocation or false;
	owningThread = owningThread or 0;

	if not rawhandle then
		return false, "now raw handle specified";
	end

	local obj = {
		Handle = HeapHandle(rawhandle, ownAllocation, owningThread);
	}

	setmetatable(obj, Heap_mt);
	return obj;
end

Heap.getNativeHandle = function(self)
	return self.Handle.Handle;
end

Heap.alloc = function(self, nbytes, flags)
	flags = flags or 0
	nbytes = nbytes or 1

	local ptr = heap_ffi.HeapAlloc(self:getNativeHandle(), flags, nbytes);

	return ptr;
end

Heap.allocBlob = function(self, nbytes, flags)
	local ptr, err = self:alloc(nbytes, flags);

	-- If the allocation failed, then just return
	if not ptr then
		return false;
	end

	-- Create a blob object, and return that to the
	-- caller.
	local blob = HeapBlob(ptr, nbytes, self:getNativeHandle(), core_process.GetCurrentThreadId())

	return blob
end

Heap.free = function(self, ptr, dwFlags)
	dwFlags = dwFlags or 0;
	local status = heap_ffi.HeapFree(self:getNativeHandle(), dwFlags, ptr);
	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return true;
end

Heap.compact = function(self, flags)
	flags = flags or 0
	local size = heap_ffi.HeapCompact(self:getNativeHandle(), flags)
	return size
end

Heap.lock = function(self)
	local status = heap_ffi.HeapLock(self:getNativeHandle());

	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return true
end

Heap.unlock = function(self)
	local status = heap_ffi.HeapUnlock(self:getNativeHandle());

	if status == 0 then
		return false, errorhandling.GetLastError();
	end

	return true
end

--[[
typedef struct _PROCESS_HEAP_ENTRY {
    PVOID lpData;
    DWORD cbData;
    BYTE cbOverhead;
    BYTE iRegionIndex;
    WORD wFlags;
    union {
        struct {
            HANDLE hMem;
            DWORD dwReserved[ 3 ];
        } Block;
        struct {
            DWORD dwCommittedSize;
            DWORD dwUnCommittedSize;
            LPVOID lpFirstBlock;
            LPVOID lpLastBlock;
        } Region;
    } DUMMYUNIONNAME;
} PROCESS_HEAP_ENTRY, *LPPROCESS_HEAP_ENTRY, *PPROCESS_HEAP_ENTRY;
--]]
Heap.entryList = function(self)
	local heapEntry = ffi.new("PROCESS_HEAP_ENTRY", heapEntry);

	local res = {};
	self:lock();

	local status = heap_ffi.HeapWalk(self:getNativeHandle(), heapEntry);

	while status ~= 0 do
		if band(heapEntry.wFlags, ffi.C.PROCESS_HEAP_ENTRY_BUSY) > 0 then
			-- Allocated block
			table.insert(res, {
						Kind = "allocated",
						Size = heapEntry.cbData,
						});
		elseif band(heapEntry.wFlags, ffi.C.PROCESS_HEAP_REGION) > 0 then
			table.insert(res, {
						Kind = "region",
						Committed = heapEntry.DUMMYUNIONNAME.Region.dwCommittedSize, 
						Free=heapEntry.DUMMYUNIONNAME.Region.dwUnCommittedSize});
		elseif band(heapEntry.wFlags, ffi.C.PROCESS_HEAP_UNCOMMITTED_RANGE) > 0 then
			table.insert(res, {
						Kind = "uncommitted",
						});
		else
			table.insert(res, {
						Kind = "block",
						}); 
		end
				
		status = heap_ffi.HeapWalk(self:getNativeHandle(), heapEntry);
	end

	self:unlock();

	return res;
end

Heap.isValid = function(self, flags)
	flags = flags or 0

	local isValid = heap_ffi.HeapValidate(self:getNativeHandle(), flags, nil);

	return isValid
end

return Heap;
