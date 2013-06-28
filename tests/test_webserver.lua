local Computicle = require("Computicle");

local acceptor = Computicle:load("comp_socketacceptor");
--local requesthandler = Computicle:load("comp_webserver");
--acceptor.sink1 = requesthandler;

acceptor:waitForFinish();
