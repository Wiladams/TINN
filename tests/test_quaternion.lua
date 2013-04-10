-- test_quaternion.lua
package.path = package.path..";../src/?.lua"

local matrix = require("math_matrix")
local quaternion = require("graphics.quaternion")

local vec3 = matrix.vec3;
local vec4 = matrix.vec4;

q1 = quaternion.fromAxisAngle(vec3(0,0,1), math.rad(90));

print(q1.w, q1.x, q1.y, q1.z);

print(math.sqrt(2)/2);

print("toMat4");

local m1 = q1:toMat4();
print(m1);

local xaxis = vec4(1,0,0,1);

local tformed = xaxis * m1;

print("TFORMED")
print(tformed);
