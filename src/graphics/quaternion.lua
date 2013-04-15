--=======================================
--		QUATERNION
--
-- As a data structure, the quaternion is represented as:
-- 	x, y, z, w
--=======================================

local cos = math.cos;
local sin = math.sin;
local sqrt = math.sqrt;
local math_matrix = require("math_matrix");
local mat4 = math_matrix.mat4;



local quaternion_t = {}

setmetatable(quaternion_t, {
	__call = function(self, ...)
		return quaternion_t.new(...);
	end,
	})

local quaternion_mt = {
	__index = quaternion_t;

	-- Basic quaternion arithmetic
	__add = function(q1, q2)
		if tonumber(q2) then
			return quaternion_t.new(q1.x, q1.y, q1.z, q1.w+tonumber(q2));
		end

		return quaternion_t.new(q1.x+q2.x, q1.y+q2.y, q1.z+q2.z, q1.w+q2.w);
	end,

	__sub = function(q1, q2)
		-- quat - s;
		if tonumber(q2) then
			return quaternion_t.new(q1.x, q1.y, q1.z, q1.w-tonumber(q2));
		end
		
		if tonumber(q1) then
			return quaternion_t.new(-q2.x, -q2.y, -q2.z, tonumber(q1)-q2.w);
		end

		return quaternion_t.new(q1.x-q2.x, q1.y-q2.y, q1.z-q2.z, q1.w-q2.w);
	end,

	__unm = function(q1)
		return quaternion_t.new(-q1.x, -q1.y,-q1.z,-q1.w);
	end,

	-- Multiply two quaternions
	__mul = function(a, r)
		if tonumber(a) then
			a,r = r,a;
		end

		if tonumber(r) then
			local s = tonumber(r);
			return quaternion_t.new(a.x*s, a.y*s,a.z*s,a.w*s);
		end

		return quaternion_t.new(
			a.y*r.z - a.z*r.y + r.w*a.x + a.w*r.x,
			a.z*r.x - a.x*r.z + r.w*a.y + a.w*r.y,
			a.x*r.y - a.y*r.x + r.w*a.z + a.w*r.z,
			a.w*r.w - a.x*r.x - a.y*r.y - a.z*r.z
		);
	end,

	__div = function(q1, s)
		return q1 * (1/s);
	end,

}


--[[
	Construct a Quaternion
	method 1:
	  quaternion(x,y,z,w)

	method 2:
	  quaternion(axis, angle)

	method 3:
	  quaternion(quaternion)
--]]
quaternion_t.new = function(...)
	local nargs = select('#', ...)
	
	local obj = {}
	if nargs == 4 then
		obj.x=select(1,...); 
		obj.y=select(2,...); 
		obj.z=select(3,...); 
		obj.w=select(4,...);
	elseif nargs == 2 then
		local axis = select(1,...);
		local angle = select(2,...);
		local a = axis:normal();
		local s = sin(angle/2);
		local c = cos(angle/2);

		obj.x = a[0]*s;
		obj.y = a[1]*s;
		obj.z = a[2]*s;
		obj.w = c;
	end
	setmetatable(obj, quaternion_mt);

	return  obj;
end

quaternion_t.dot = function(q1, q2)
	return q1.x*q2.x+q1.y*q2.y+q1.z*q2.z+ q1.w*q2.w;
end

quaternion_t.length = function(q)
	return sqrt(q.x*q.x+q.y*q.y+q.z*q.z+q.w*q.w);
end

quaternion_t.normalize = function(q)
	return q/q:length();
end

quaternion_t.conj = function(q)
	 return quaternion_t.new(-q.x, -q.y, -q.z, q.w);
end

quaternion_t.distance = function(q1, q2)
	return (q1-q2):normalize();
end

quaternion_t.slerp = function(p, q, t, theta)
	return (sin((1-t)*theta)*p + sin(t*theta)*q)/sin(theta);
end

-- Converting quaternion to matrix4x4
quaternion_t.toMat4 = function(q)
	-- This conversion could be multiplied out in long
	-- form, but, assuming we have fast matrix multiply
	-- just use that instead for simplicity
	m1 = mat4({
		{ q.w, -q.z,  q.y, q.x},
		{ q.z,  q.w, -q.x, q.y},
		{-q.y,  q.x,  q.w, q.z},
		{-q.x, -q.y, -q.z, q.w}
		});
	m2 = mat4({
		{q.w, -q.z, q.y -q.x},
		{q.z, q.w, -q.x, -q.y},
		{-q.y, q.x, q.w, -q.z},
		{q.x, q.y, q.z, q.w}
		});

	return m1 * m2;
end

quaternion_t.identity = quaternion_t.new(0,0,0,1);


return quaternion_t;
