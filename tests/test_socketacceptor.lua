-- test_socketacceptor.lua

local Computicle = require("Computicle");

local acceptsink = Computicle:create([[require("AcceptHandler")]])

local comp = Computicle:create([[require("SocketAcceptor")]], {sink1=acceptsink:getStoned()});

comp:waitForFinish();
