local ffi = require "ffi"


local Heap_ffi = require ("Heap_ffi");

local kernel32 = ffi.load("kernel32")






ffi.cdef[[
typedef struct {
	HANDLE	Handle;
	int		Options;
	size_t	InitialSize;
	size_t	MaximumSize;
	DWORD	owningthread;
} HEAP;

typedef struct {
	void *	Data;
	int32_t	Size;
	HANDLE	HeapHandle;
	DWORD	owningthread;
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

		if self.owningthread == kernel32.GetCurrentThreadId() then
			local res = kernel32.HeapFree(self.HeapHandle, 0, self.Data)
		end
	end,

	__index = {
		GetSize = function(self, flags)
			flags = flags or 0

			if self.HeapHandle == nil then 
				return false, "Blob has no handle"; 
			end

			local result = kernel32.HeapSize(self.HeapHandle, flags, self.Data)

			return result
		end,

		isValid = function(self, flags)
			flags = flags or 0

			if self.HeapHandle == nil then 
				return false,  "Blob has no handle";
			end

			local isValid = kernel32.HeapValidate(self.HeapHandle, flags, self.Data);

			return isValid
		end,

		reaAlloc = function(self, nbytes, flags)
			flags = flags or 0

			if self.Heap == nil then return false end

			local ptr = kernel32.HeapReAlloc(self.HeapHandle, flags, self.Data, nbytes)

			if ptr == nil then return false end

			self.Data = ptr;
			self.Size = nbytes;

			return true
		end,

	}
}
HeapBlob = ffi.metatype(HeapBlob, HeapBlob_mt);




Heap = ffi.typeof("HEAP")
Heap_mt = {
	__gc = function(self)
		if self.Handle == nil or self.owningthread == 0 then return nil end

		if self.owningthread == kernel32.GetCurrentThreadId() then
			local success = kernel32.HeapDestroy(self.Handle) ~= 0
		end
	end,

	__index = {
		Alloc = function(self, nbytes, flags)
			flags = flags or 0
			nbytes = nbytes or 1

			local ptr = kernel32.HeapAlloc(self.Handle, flags, nbytes)

			return ptr;
		end,

		AllocBlob = function(self, nbytes, flags)
			flags = flags or 0
			nbytes = nbytes or 1

			local ptr = kernel32.HeapAlloc(self.Handle, flags, nbytes)

			-- If the allocation failed, then just return
			if ptr == nil then
				return nil
			end

			-- Create a blob object, and return that to the
			-- caller.
			local blob = HeapBlob(ptr, nbytes, self.Handle, kernel32.GetCurrentThreadId())

			return blob
		end,

		Compact = function(self, flags)
			flags = flags or 0
			local size = kernel32.HeapCompact(self.Handle, flags)
			return size
		end,

		Lock = function(self)
			local success = kernel32.HeapLock(self.Handle) ~= 0
			return success
		end,

		Unlock = function(self)
			local success = kernel32.HeapUnlock(self.Handle) ~= 0
			return success
		end,

		StartHeapWalk = function(self)
			local heapEntry = ffi.new("PROCESS_HEAP_ENTRY")
			local pheapEntry = ffi.new("PROCESS_HEAP_ENTRY[1]", heapEntry)
			local success = kernel32.HeapWalk(self.Handle, pheapEntry) ~= 0
			--heapEntry = pheapEntry[0]

			return heapEntry, success
		end,

		ContinueHeapWalk = function(self, heapEntry)
			pheapEntry = ffi.new("PROCESS_HEAP_ENTRY[1]", heapEntry)
			local success = kernel32.HeapWalk(self.Handle, pheapEntry) ~= 0
			heapEntry = pheapEntry[0]

			return heapEntry, success
		end,

		IsValid = function(self, flags)
			flags = flags or 0

			local isValid = kernel32.HeapValidate(self.Handle, flags, nil)

			return isValid
		end,


	},
}
Heap = ffi.metatype("HEAP", Heap_mt)



local function HeapCreate(initialSize, maxSize, options)
	initialSize = initialSize or 0
	maxSize = maxSize or 0
	options = options or 0

	-- Try to allocate the heap as specified
	local handle = kernel32.HeapCreate(options, initialSize, maxSize)

	-- If the allocation fails
	-- just return nil
	if handle == nil then
		return false, "could not create heap"
	end

	local aheap = Heap(handle, options, initialSize, maxSize)

	return aheap
end

local function GetProcessHeap()
	local handle = kernel32.GetProcessHeap()

		-- If the allocation fails
	-- just return nil
	if handle == nil then
		return nil
	end

	local aheap = Heap(handle)

	return aheap
end




return {
	-- Function calls
	GetProcessHeap = GetProcessHeap,
	HeapCreate = HeapCreate,

	-- Classes
	Heap = Heap,
	HeapBlob = HeapBlob,


}