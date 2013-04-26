-- test_DbgHelp.lua


local ffi = require("ffi");

local dbg = require("dbghelp_ffi")


local test_Demangle = function(MangledNames)
	local UnDecoratedLength = 255;
	local UnDecoratedName = ffi.new("char[?]", UnDecoratedLength);
	
	for _,name in ipairs(MangledNames) do
		local result = dbg.Lib.UnDecorateSymbolName(name,UnDecoratedName, UnDecoratedLength,0);
		
		if result > 0 then
			print(string.format('{mangled="%s", demangled="%s"},', name, ffi.string(UnDecoratedName, result)));
		else
			print(string.format'{mangled="%s"},', name);
		end
	end
end


local manglednames = {
    "??0Foo@Leap@@QAE@ABV01@@Z",
    "??0Foo@Leap@@QAE@H@Z",
    "??0Foo@Leap@@QAE@XZ",
    "??0FooBase@Leap@@QAE@ABV01@@Z",
    "??0FooBase@Leap@@QAE@XZ",
    "??1Foo@Leap@@UAE@XZ",
    "??1FooBase@Leap@@UAE@XZ",
    "??4Foo@Leap@@QAEAAV01@ABV01@@Z",
    "??4FooBase@Leap@@QAEAAV01@ABV01@@Z",
    "??_7Foo@Leap@@6B@",
    "??_7FooBase@Leap@@6B@",
    "?get@Foo@Leap@@QAEHXZ",
}

test_Demangle(manglednames);
