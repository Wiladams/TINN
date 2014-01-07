
local ffi = require("ffi")
local bit = require("bit")
local band = bit.band;
local bor = bit.bor;
local rshift = bit.rshift;
local lshift = bit.lshift;

NO_ERROR		= 0;

ERROR_SUCCESS	= 0;

ERROR_INVALID_FUNCTION          = 1;    

ERROR_FILE_NOT_FOUND            = 2;

ERROR_ACCESS_DENIED             = 5;

ERROR_INVALID_HANDLE            = 6;

ERROR_INVALID_DATA              = 13;

ERROR_HANDLE_EOF                = 38;

ERROR_NOT_SUPPORTED             = 50;

ERROR_NETNAME_DELETED           = 64;

ERROR_INVALID_PARAMETER         = 87;

ERROR_INSUFFICIENT_BUFFER       = 122;

ERROR_INVALID_NAME              = 123;

ERROR_ALREADY_EXISTS    		= 183;

ERROR_ENVVAR_NOT_FOUND          = 203;

ERROR_MORE_DATA                 = 234;

WAIT_TIMEOUT                    = 258;

ERROR_OPERATION_ABORTED			= 995;

ERROR_NOACCESS                  = 998;

ERROR_INVALID_SERVICE_CONTROL   = 1052;

ERROR_CONNECTION_INVALID        = 1229;

ERROR_PRIVILEGE_NOT_HELD        = 1314;

ERROR_LOGON_FAILURE             = 1326;

ERROR_LOGON_TYPE_NOT_GRANTED    = 1385;


ffi.cdef[[
static const int FACILITY_WIN32  = 7;
]]

local function __HRESULT_FROM_WIN32(x) 
  if x <= 0 then
    return x
  end

  return bor(band(x, 0x0000FFFF), bor(lshift(ffi.C.FACILITY_WIN32, 16), 0x80000000))
end

function HRESULT_CODE(hr)
	return band(hr, 0xFFFF)
end

function HRESULT_FACILITY(hr)
	return band(rshift(hr, 16), 0x1fff)
end

function HRESULT_SEVERITY(hr)
	return band(rshift(hr, 31), 0x1)
end

function HRESULT_PARTS(hr)
	return HRESULT_SEVERITY(hr), HRESULT_FACILITY(hr), HRESULT_CODE(hr)
end

function FAILED(hr)
	return HRESULT_SEVERITY(hr) ~= 0;
end

return {
	__HRESULT_FROM_WIN32 = __HRESULT_FROM_WIN32,
}