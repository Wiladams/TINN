local ffi = require "ffi"
local bit = require "bit"
local bor = bit.bor
local rshift = bit.rshift
local lshift = bit.lshift
local C = ffi.C


local stdlib = require("stdlib")
local malloc = stdlib.malloc;
local realloc = stdlib.realloc;
local free = stdlib.free;

-- round up to the nearest
-- power of 2
local roundup32 = function(x) 
	x = x - 1; 
	x = bor(x,rshift(x,1)); 
	x = bor(x,rshift(x,2)); 
	x = bor(x,rshift(x,4)); 
	x = bor(x,rshift(x,8)); 
	x = bor(x,rshift(x,16)); 
	x = x + 1;
	
	return x
end


local Vector_t = {}
local Vector_mt = {
	-- __index = Vector_t;

	__index = function(tbl, key)
		
		if type(key) == "number" then
			local data = rawget(tbl, "Data");
			return data[key];
		end
		
		return Vector_t[key]
	end,

}
			
local Vector = function(typename, capacity)

	capacity = capacity or 0

	local obj = {
		ElementTypeName = typename,
		ElementType = ffi.typeof(typename),
		n = 0,
		Capacity = capacity,
		Data = nil,
	}
	setmetatable(obj, Vector_mt);
	
	return obj
end

Vector_t.Free = function(self)
	if self.Data ~= nil then
		free(self.Data);
	end
end

-- Maximumm number of elements
Vector_t.Max = function(self)
	return self.Capacity;
end

-- Current number of elements in vector
Vector_t.Size = function(self)
	return self.n;
end

Vector_t.Realloc = function(self, nelems)
	if nelems == 0 then
		if self.Data ~= nil then
			free(self.Data)
			self.Data = nil
		end
		return nil
	end
	
	local newdata = malloc(ffi.sizeof(self.ElementType)* nelems);

	-- copy existing over to new one
	local maxCopy = math.min(nelems, self.n);
	ffi.copy(newdata, ffi.cast("const uint8_t *",self.Data), ffi.sizeof(self.ElementType) * maxCopy);
	local typeptr = self.ElementTypeName.." *";
	--print("Type PTR: ", typeptr);
	
	-- free old data
	free(self.Data);
	
	self.Data = ffi.cast(typeptr,newdata);	
end

-- access an element
-- perform bounds checking and resizing
Vector_t.a = function(v, i) 
	if v.Capacity <= i then						
		v.Capacity = i + 1; 
		v.n = i + 1;
		v.Capacity = roundup32(v.Capacity) 
		self:Realloc(v.Capacity) 
	else
		if v.n <= i then 
			v.n = i			
		end
	end
			
	return v.Data[i]
end	  

-- Access without bounds checking
Vector_t.Elements = function(self)
	local index = -1;
	
	local clojure = function()
		index = index + 1;
		if index < self.n then
			return self.Data[index];
		end
		
		return nil
	end
	
	return clojure
end

Vector_t.A = function(self, i)
	return self.Data[i];
end

Vector_t.Resize = function(self, s) 
	self.Capacity = s; 
	self:Realloc(self.Data, self.Capacity)
end
		
Vector_t.Copy = function(self, v0)
	-- If we're too small, then increase
	-- size to match
	if (self.Capacity < v0.n) then
		self:Resize(v0.n);
	end
			
	self.n = v0.n;									
	ffi.copy(self.Data, v0.Data, ffi.sizeof(self.Data[0]) * v0.n);		
end
		
-- pop, without bounds checking
Vector_t.Pop = function(self)
	self.n = self.n-1;
	return self.Data[self.n]
end

Vector_t.Push = function(v, x) 
	if (v.n == v.Capacity) then	
		if v.Capacity > 0 then
			v.Capacity = lshift(v.Capacity, 1)
		else
			v.Capacity = 2;
		end
		v:Realloc(v.Capacity);
	end															
			
	v.Data[v.n] = x;
	v.n = v.n + 1;
end
		
Vector_t.Pushp = function(v) 
	if (v.n == v.Capacity) then
		if v.Capacity > 0 then
			v.Capacity = lshift(v.Capacity, 1)
		else
			v.Capacity = 2
		end
		v:Realloc(v.Capacity)	
	end
				
	v.n = v.n + 1
	return v.Data + v.n-1
end

return Vector;

