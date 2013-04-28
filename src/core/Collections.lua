--[[
	Collections.lua

	This file contains a few collection classes that are
	useful for many things.  The most basic object is the
	simple list.

	From the list is implemented a queue
--]]

-- The basic list type
-- This will be used to implement queues and other things
local List = {}
local List_mt = {
	__index = List;
}

function List.new(params)
	local obj = params or {first=0, last=-1}

	setmetatable(obj, List_mt)

	return obj
end


function List:PushLeft (value)
	local first = self.first - 1
	self.first = first
	self[first] = value
end

function List:PushRight(value)
	local last = self.last + 1
	self.last = last
	self[last] = value
end

function List:PopLeft()
	local first = self.first

	if first > self.last then
		return nil, "list is empty"
	end
	local value = self[first]
	self[first] = nil        -- to allow garbage collection
	self.first = first + 1

	return value
end

function List:PopRight()
	local last = self.last
	if self.first > last then
		return nil, "list is empty"
	end
	local value = self[last]
	self[last] = nil         -- to allow garbage collection
	self.last = last - 1

	return value
end



local Queue = {}
local Queue_mt = {
	__index = Queue;
}

function Queue.new(name)
	local obj = {first=1, last=0, name=name}

	setmetatable(obj, Queue_mt);

	return obj
end

function Queue:Enqueue(value)
	--self.MyList:PushRight(value)
	local last = self.last + 1
	self.last = last
	self[last] = value

	return value
end

function Queue:Dequeue(value)
	-- return self.MyList:PopLeft()
	local first = self.first

	if first > self.last then
		return nil, "list is empty"
	end
	
	local value = self[first]
	self[first] = nil        -- to allow garbage collection
	self.first = first + 1

	return value	
end

function Queue:Len()
	return self.last - self.first+1
end

function Queue:Entries(func, param)
	local starting = self.first-1;
	local len = self:Len();

	local closure = function()
		starting = starting + 1;
		return self[starting];
	end

	return closure;
end


return {
	List = List;
	Queue = Queue;
}
