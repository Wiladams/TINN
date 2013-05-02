-- shell.lua
local langutils = require("langutils");

include = function(name)
	local module = require(name);

	if module then
		langutils.makeGlobal(module, name);
	end
end

import = function(name)
--print("Importing: ", name);
	local module = require(name);
--print("Module: ", module);

	if module then
		langutils.makeGlobal(module);
	end
end



import 'twitshl.ver';
import 'datetime';
import "Heap";
import "processenvironment";
import 'SysInfo';
