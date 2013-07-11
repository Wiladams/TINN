-- test_comp_netstream.lua
Computicle = require("Computicle");

local comp = Computicle:createFromFile("comp_getbing.lua");

comp:waitForFinish();
