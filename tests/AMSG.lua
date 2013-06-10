local ffi = require("ffi");

require("WTypes");

ffi.cdef[[
	typedef struct {
    HWND hwnd;
    UINT message;
    WPARAM wParam;
    LPARAM lParam;
    DWORD time;
    POINT pt;
} AMSG, *PAMSG;
]]

return {
	AMSG = ffi.typeof("AMSG");
	
	print = function(msg)
		msg = ffi.cast("PAMSG", ffi.cast("void *",msg));

		print(string.format("== AMSG: %d", msg.message));
		--print("message: ", msg.message);
		--print("   time: ", msg.time);
	end,
}
