local langutils = require("langutils");

include = function(name)
	local mod = require(name);

	if mod then
		langutils.importGlobal(mod, name);
	end

	return mod;
end

use = function(name)
	local mod = require(name);

	if mod then
		langutils.importGlobal(mod);
	end

	return mod;
end
