-- test_SToken.lua

local SToken = require("SToken");

local testVector = "this is a long string with a lot of words in it."

local beginning, ending = testVector:find("this");
local len = ending - beginning + 1;

print(beginning, ending, len);

local tok1 = SToken(testVector, beginning-1, len);
local tok2 = SToken(testVector, beginning-1, len);

local beg2, end2 = testVector:find("words");
local len2 = end2-beg2+1
local tok3 = SToken(testVector, beg2-1, len2);

print("Token: ", tok1);
print("Token Length: ", #tok1);
print("Tok1 == Tok2: ", tok1 == tok2);

print("Token3: ", tok3);
print("Token 3 Len: ", #tok3);
print("tok1 == tok3: ", tok1 == tok3);
