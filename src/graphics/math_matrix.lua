-- math_matrix.lua

--[[
	The math_matrix represents a minimal set of routines
	to support both vector and matrix types, and operations
	between them.

	The make_matrix_kind() creates types of matrices and vectors
	with given sizes, dimensions and element types.

	The operations available here may not be the fastest implementations 
	available, but they are verified to be correct and stable for many 
	common cases.

	In addition to core operations, there are some convenience operators
	as well.
--]]

local ffi = require "ffi"

local pow = math.pow;
local sqrt = math.sqrt;

-- The catalog of matrix kinds
-- Each time a kind is created, it is stored
-- in this table, according to type
local matrix_kinds = {}

local swizzlemap = {
		x = 0;
		y = 1;
		z = 2;
		w = 3;

		r = 0;
		g = 1;
		b = 2;
		a = 3;

		s = 0;
		t = 1;
		p = 2;
		q = 3;
}

local swizzlit = function(val)
	local offset = 0;
	local closure = function()
		offset = offset + 1
		if offset > #val then
			return nil
		end

		return swizzlemap[val:sub(offset,offset)];
	end

	return closure;
end


local function make_matrix_kind(ct, rows, columns)
--print("make_matrix_kind: ", ct, rows, columns);

	rows = rows or 1;
	columns = columns or 1;

	local typemoniker = string.format("%s:[%d,%d]", tostring(ct), rows, columns);

--print("TYPE: ", typemoniker);

	if matrix_kinds[typemoniker] then
		return matrix_kinds[typemoniker];
	end

	local nelems = rows*columns;
	
	local ptrType = ffi.typeof("$ *", ct);
	local constptrType = ffi.typeof("const $ *", ct);

	local mat_kind = ffi.typeof("struct {$ data[$];}", ct, nelems);
	local mat_kind_ptr = ffi.typeof("$ *", mat_kind);
	
	local column_kind = nil;
	local column_kind_ptr = nil;
	if columns > 1 then
		column_kind = make_matrix_kind(ct, rows, 1);
		column_kind_ptr = ffi.typeof("$ *", column_kind);
	end


	local dot = function(a,b, nelems)
		local dotprod = 0;
		for i=0,nelems-1 do
			dotprod = dotprod + a[i]*b[i];
		end
		return dotprod;
	end

	local mat_t = {
		asElementPointer = function(self)
			return ffi.cast(ptrType,self);
		end,

		asConstPointer = function(self)
			return ffi.cast(constptrType, self);
		end,

		elements = function(self)
			local idx = -1;

			local closure = function()
				idx = idx + 1;
				if idx >= nelems then
					return nil
				end
				return self.data[idx]
			end

			return closure;
		end,

		elementType = function(self)
			return ct
		end,

		rows = function(self)
			return rows;
		end,

		columns = function(self)
			return columns;
		end,


		-- Element Accessors
		get = function(self, row, col)
			return self.data[(col * rows) + row];
		end,

		set = function(self, row, col, val)
			self.data[(col * rows) + row] = val;
			return self;
		end,

		setDiagonalValue = function(self, val)
			local maxelem = math.min(rows, columns);

			for elem=0,maxelem-1 do
				self:set(elem,elem,val);
			end
			return self;
		end,

		setColumn = function(self, col, val)
				local maxelems = math.min(rows, #val)
				for row=0,maxelems-1 do
					if type(val) == "table" then
						self:set(row,col,val[row+1]);
					else
						self:set(row,col,val[row]);
					end
				end
			
			return self;
		end,

		-- setRow
		-- Sets the values of a matrix row.
		-- 
		-- Parameters
		-- row - the row in question, starting at 0
		-- val - either a table or any object that is
		--       array indexable
		--
		setRow = function(self, row, val)
			local maxelems = math.min(columns, #val)
			for col=0,maxelems-1 do
				if type(val) == "table" then
					self:set(row,col,val[col+1]);
				else
					self:set(row,col,val[col]);
				end
			end

			return self;
		end,

		-- Given a symbolic index such as '.rgb'
		-- return an instance of a matrix containing
		-- the specified fields.
		swizzleout = function(self, val)
			-- construct a row matrix based on our type
			local kind = make_matrix_kind(ct, 1, #val);
			-- fill it with swizzled values
			local res = kind();
			local offset = 0;
			for idx in swizzlit(val) do
				res:set(0,offset, self.data[idx]);
				offset = offset + 1;
			end
			return res;
		end,

		transpose = function(self)
			local reskind = make_matrix_kind(ct, columns, rows);
			local res = reskind();

			for col=0,columns-1 do
				res:setRow(col, self[col])
			end

			return res;
		end,

		--[[
			Arithmetic operators
		--]]
		addSelf = function(self, other)
			if type(other) == "cdata" then
				for i=0,nelems-1 do 
					self.data[i] = self.data[i] + other.data[i];
				end
			elseif type(other)  == "number" then
				for i=0,nelems-1 do 
					self.data[i] = self.data[i] + other;
				end
			end

			return self; 
		end,


		divSelf = function(self, other)

			if type(other) == "cdata" then
				for i=0,nelems-1 do 
					self.data[i] = self.data[i] / other.data[i];
				end
			elseif tonumber(other) then
				local anum = tonumber(other)
				for i=0,nelems-1 do 
					self.data[i] = self.data[i] / anum;
				end
			end

			return self; 
		end,

		subSelf = function(self, other)
			if type(other) == "cdata" then
				for i=0,nelems-1 do 
					self.data[i] = self.data[i] - other.data[i];
				end
			elseif type(other)  == "number" then
				for i=0,nelems-1 do 
					self.data[i] = self.data[i] - other;
				end
			end

			return self; 
		end,

		sum = function(self)
			local res = 0;
			for i=0,nelems do
				res = res + self.data[i];
			end

			return res;
		end,

		negateSelf = function(self)
			for i=0,nelems-1 do
				self.data[i] = -self.data[i];
			end
			return self;
		end,


		--[[
			Linear Algebra
		--]]
		-- The adjoint is derived from the minors()
		-- then transposed
		adjoint = function(self)
			return self:minors():transpose()
		end,

		angleBetween = function(self,rhs)
			return math.acos(self:dot(rhs));
		end,

		cofactor = function(self, row, column)
			if columns < 2 or rows < 2 then
				return false, "too small"
			end

			local reskind = make_matrix_kind(ct, rows - 1, columns-1)
			local res = reskind();

			local rowoffset = 0;
			local coloffset = 0;

--print("cofactor: ", res:rows(), res:columns());

			for rowidx =0,rows-2 do
				if rowoffset == row then
					rowoffset = rowoffset + 1;
				end

				local coloffset = 0;
				for colidx=0,columns-2 do
					if coloffset == column then
						coloffset = coloffset + 1;
					end
					
					res:set(rowidx, colidx, self:get(rowoffset, coloffset));

					coloffset = coloffset + 1;
				end
				rowoffset = rowoffset + 1;
			end

			return res
		end,
		
		cofactors = function(self)
			local mom = self:adjoint();
			
			-- apply checkerboard pattern of negation
			for i=0,nelems-1 do
				mom.data[i] = mom.data[i]* pow(-1, i);
			end

			return mom;
		end;

		-- Retrieve the matrix that is 2 orders smaller
		-- than the current matrix
		centerfactor = function(self)
			-- This will only work if order is
			-- 4 or greater
			if rows < 4 or columns < 4 then
				return false, "order is too small"
			end

			local reskind = make_matrix_kind(ct, rows-2, columns-2);
			local res = reskind();

			for row = 1, rows-2 do
				for column = 1, columns-2 do
					res:set(row-1, column-1, self:get(row, column));
				end
			end

			return res;
		end,

		cross = function(self, other)
			local reskind = make_matrix_kind(ct, 1, 3);
			local res = reskind();
			local vptr = other:asConstPointer();


			res.data[0] = self.data[1]*vptr[2] - vptr[1]*self.data[2];
			res.data[1] = -self.data[0]*vptr[2] + vptr[0]*self.data[2];
			res.data[2] = self.data[0]*vptr[1] - vptr[0]*self.data[1];

			return res;
		end,

		determinant = function(self)
			-- For cases smaller than 4
			-- use straight forward methods
			if rows == 1 and columns == 1 then
				return self.data[0]
			end

			if rows == 2 and columns == 2 then
				return self:get(0,0)*self:get(1,1) - self:get(0,1)*self:get(1,0);
			end

			if rows == 3 and columns == 3 then
				return self:get(0,0)*self:get(1,1)*self:get(2,2) +
				self:get(0,1)*self:get(1,2)*self:get(2,0) +
				self:get(0,2)*self:get(1,0)*self:get(2,1) -
				self:get(2,0)*self:get(1,1)*self:get(0,2) -
				self:get(2,1)*self:get(1,2)*self:get(0,0) -
				self:get(2,2)*self:get(1,0)*self:get(0,1);
			end

			-- Using the generalized formula
			local det = 0;
			for col=0,columns-1 do
				det = det + pow(-1,col)*self:get(0,col)*self:cofactor(0,col):determinant();
			end

			return det;
		end,

		dot = function(self, other)
			return dot(self, other, nelems)
		end,

		-- The matrix of determinants for each cofactor of the matrix
		minors = function(self)
			local mom = mat_kind();
			for row=0,rows-1 do
				for col=0,columns-1 do
					mom:set(row,col,self:cofactor(row,col):determinant());
				end
			end

			return mom;
		end,

		-- inverse * self == identity
		inverse = function(self)
			local det = self:determinant();
			if det == 0 then
				return false, "determinant == 0"
			end

			-- minors put determinant of cofactor into each element position
			-- adjoint transposes the minors
			-- cofactors apply checkerboard of negation to matrix
			-- multiply by inverse of determinant
			return self:cofactors() * tonumber(1/det);
		end,

		length = function(self)
			return sqrt(dot(self, self, nelems));
		end,

		lengthSquared = function(self)
			return dot(self, self, nelems);
		end,

		normal = function(self)
			local scalar = 1/self:length();
			return self * scalar;
		end,


		mul = function(self, other)
			-- check for case: number * Matrix
			-- swap if necessary
			if tonumber(self) then
				self, other = other, self
			end

			if type(other) == "number" then
				local res = mat_kind();
				-- If it's just a number, then do an element
				-- by element multiplication
				for i=0,nelems-1 do 
					res.data[i] = self.data[i] * other;
				end
				return res;
			end

			local newkind = make_matrix_kind(ct, rows, other:columns());
			local res = newkind();

			-- do matrix to matrix multiplication
			for row=0,self:rows()-1 do
				for col=0,other:columns()-1 do
					-- calculate a dot product between each
					-- row of self and column of other
					-- don't use the 'dot()' function here as it would need
					-- a contiguous array for each row, which would require
					-- a copy
					local dotprod = 0;
					for k=0,self:columns()-1 do
						dotprod = dotprod + self:get(row,k)*other:get(k,col);
					end
					res:set(row,col, dotprod);
				end
			end

			return res; 
		end,


		["tostring"] = function(self)
			local res = {};
			for row=0,rows-1 do
				for col=0,columns-1 do
					table.insert(res,self:get(row, col));
					if col < columns-1 then
						table.insert(res, ", ");
					end
				end
				table.insert(res,"\n");
			end
			return table.concat(res);
		end,
	}

	local mat_mt = {
		__len = function(self) return nelems; end;

		__new = function(ct, ...)
			local nargs = select("#",...);

			-- default constructor
			if nargs < 1 then
				return ffi.new(ct);
			end

			-- copy constructor
			if type(select(1,...)) == "cdata" and ffi.typeof(select(1,...)) == mat_kind then
				return ffi.new(ct, ...);
			end

			-- constructor with single number
			-- set the diagonal
			if type(select(1,...)) == "number" then
				local obj = ffi.new(ct);
				if nargs == 1 then
					obj:setDiagonalValue(select(1,...));
				else
					for i=1,nargs do
						obj.data[i-1] = select(i,...);
					end
				end
				return obj;
			end

			-- construction based on a table of tables
			if type(select(1,...)) == "table" then
				local obj = ffi.new(ct);
				for row,value in ipairs(select(1,...)) do
					obj:setRow(row-1,value);
				end
				return obj;
			end

			return false, "unknown construction pattern";
		end;

		__add = function(self, other) return mat_kind(self):addSelf(other); end;
		__sub = function(self, other) return mat_kind(self):subSelf(other); end;
		__div = function(self, other) return mat_kind(self):divSelf(other); end;
		__unm = function(self) return mat_kind(self):negateSelf(); end;

		-- this one does an algebraic mulitplication, NOT a member-wise
		-- component multiplication
		__mul = function(self, other) return mat_t.mul(self, other); end;

		__tostring = function(self) return mat_t.tostring(self); end;

		__index = function(self, key)
			--print("INDEX: ", key, rows, columns);
			
			if type(key) == "number" then
				-- If this matrix is representing a columnar
				-- or row vector, then just return a standard
				-- value from the array.
				if rows==1 or columns == 1 then
					return self.data[key];
				end

				-- Return a pointer to the specified column
				return ffi.cast(column_kind_ptr, self:asElementPointer() + key*rows)[0];
				--return self:asElementPointer() + key*rows;
			elseif  key =="metatable" then
				-- if the user is asking for the metatable
				return mat_t;
			elseif mat_t[key] then
				-- user is calling a function
				return mat_t[key];
			elseif type(key) == "string" then
				return self:swizzleout(key);
			end
		end;

		__newindex = function(self, key, value)
			if type(key) == "number" then
				-- If this matrix is representing a columnar
				-- or row vector, then just return a standard
				-- value from the array.
				if rows==1 or columns == 1 then
					self.data[key] = value;
				end
			end
			return self;
		end;
	}
	
	-- Save the fact that we've created the type so that
	-- we can return that same type next time it is asked for
	matrix_kinds[typemoniker] = mat_kind;

	return ffi.metatype(mat_kind, mat_mt);
end


return {
	make_matrix_kind = make_matrix_kind;
	

	mat2 = make_matrix_kind(ffi.typeof("double"), 2,2);
	mat3 = make_matrix_kind(ffi.typeof("double"), 3,3);
	mat4 = make_matrix_kind(ffi.typeof("double"), 4,4);

	vec2 = make_matrix_kind(ffi.typeof("float"), 1, 2);
	vec3 = make_matrix_kind(ffi.typeof("float"), 1, 3);
	vec4 = make_matrix_kind(ffi.typeof("float"), 1, 4);

	swizzlit = swizzlit;

	PlaneNormal = function(p1, p2, p3)
		local v1 = p2 - p1;
		local v2 = p3 - p1;

		return v1:cross(v2):normal();
	end;
}