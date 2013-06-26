-- test_GF8.lua

local GF8 = require("GF8");

g1 = GF8(1);
g2 = GF8(2);

g3 = g1 + g2;

print("g1: ", g1);
print("g2: ", g2);
print("g3: ", g3);

g4 = GF8(4);
g5 = GF8(5);

print("g4, g5, g4+g5", g4, g5, g4+g5);

print("g8: ", GF8(8));

print("g9: ", GF8(9));

print("g1^0: ", g1^0);
print("g2^1: ", g2^1);
print("g2^2: ", g2^2);