local Computicle = require("Computicle");

--local comp = Computicle:create("print('Hello, World')");
local comp = Computicle:createFromFile("DaytimeClient.lua");

comp:waitForFinish();
