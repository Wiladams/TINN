local ffi = require("ffi")

local arch = {}

function arch.stringToPointer(str)
	local num = tonumber(str);
	if not num then
		return nil, "invalid number";
	end

	return ffi.cast("void *", ffi.cast("intptr_t", num));
end


-- This helper routine will take a pointer
-- to cdata, and return a string that contains
-- the memory address
-- tonumber(ffi.cast('intptr_t', ffi.cast('void *', ptr)))
function arch.pointerToString(instance)
	if ffi.abi("64bit") then
		return string.format("0x%016x", tonumber(ffi.cast("int64_t", ffi.cast("void *", instance))))
	elseif ffi.abi("32bit") then
		return string.format("0x%08x", tonumber(ffi.cast("int32_t", ffi.cast("void *", instance))))
	end

	return nil;
end

function arch.fieldAddress(astruct, fieldname)
	local structtype = ffi.typeof(astruct);
	local offset = ffi.offsetof(structtype, fieldname);
	local structptr = ffi.cast("uint8_t *", astruct); 
	
	return structptr + offset;
end

return arch;
