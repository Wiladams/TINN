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

quaternion_t = {}
quaternion_mt = {
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


quaternion_t.new = function(x, y, z, w)
	local obj = {
		x=x; 
		y=y; 
		z=z; 
		w=w;
		};
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

-- Converting quaternion to matrix4x4
quaternion_t.toMat4 = function(q)
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

--[[
	local function quat_to_mat4_s(q)
		local lensq = q:dot(q);
		if (lensq~=0) then
			return 2/lensq;
		end 

		return 0;
	end

	local function quat_to_mat4_xyzs(q, s)
		return {q.x*s,q.y*s, q.z*s};
	end

	local function quat_to_mat4_X(xyzs, x) 
		return xyzs*x;
	end

	local function _quat_xyzsw(xyzs, w)
		return  xyzs*w;
	end

	local function _quat_XYZ(xyzs, q)
		return {
			quat_to_mat4_X(xyzs, q.x),
			quat_to_mat4_X(xyzs, q.y),
			quat_to_mat4_X(xyzs,q.z)
		};
 	end

	local function _quat_to_mat4(xyzsw, XYZ) 
		local m4 = mat4();
		-- set each of these as a column
		m4:setColumn(0,{(1.0-(ZYZ[2][2]+ZYZ[3][3])),  (ZYZ[1][2]-xyzsw[2]), (ZYZ[1][3]+xyzsw[1]), 0});
		m4:setColumn(1,{(ZYZ[1][2]+xyzsw[2]), (1-(ZYZ[1][1]+ZYZ[3][3])), (ZYZ[2][3]-xyzsw[0]), 0});
		m4:setColumn(2,{(ZYZ[1][3]-xyzsw[1]), (ZYZ[2][3]+xyzsw[0]), (1.0-(ZYZ[1][1]+ZYZ[2][2])), 0}); 
		m4:setColumn(3,{0,  0, 0, 1});
	end


	return _quat_to_mat4(
	_quat_xyzsw(quat_to_mat4_xyzs(q, quat_to_mat4_s(q)),q.w), 
	_quat_XYZ(quat_to_mat4_xyzs(q, quat_to_mat4_s(q)), q));
--]]
end

quaternion_t.identity = quaternion_t.new(0,0,0,1);

--[[
	Function: quat

	Description: Create a quaternion which represents a rotation
	around a specified axis by a given angle.

	Parameters
		axis - vec3
		angle - The amount of rotation in degrees
--]]
quaternion_t.fromAxisAngle = function(axis, angle)
	local _quat = function(a, s, c) 	
		return quaternion_t.new(a[0]*s, a[1]*s, a[2]*s,c);
	end
	
	return _quat(axis:normal(), 
		sin(angle/2), 
		cos(angle/2));
end

return quaternion_t;
