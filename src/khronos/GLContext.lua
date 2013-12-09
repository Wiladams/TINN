

local bit = require("bit");
local bor = bit.bor;

local User32 = require("User32");
local GDI32 = require("GDI32");
local WindowKind = require("WindowKind");

local OglMan = require("OglMan");



local CHECKGL = function(str)
	local err = glGetError();
	if (err ~= 0) then
		io.write(string.format("GL Error: 0x%x  For: %s\n", err, str));
		assert(err == 0);
	end
end

--local dummyWinKind = WindowKind:create("dummyclass");

local CreateGLContext = function(hWnd, majorversion, minorversion, multisamplemode)

	local err = 0;

	-- Create a throw away window so an initial GL
	-- context can be created
	local dummyname = "dummyclass";
	local dummywindowatom = User32.RegisterWindowClass(dummyname);
	local dummyWindow = User32.CreateWindowHandle(dummyname, dummyname, 1, 1);
	local dummydc = User32.GetDC(dummyWindow);

	-- Start off with an initial pixel description to get
	-- things started.
	-- This will be close to what we want as we'll use it later
	-- with SetPixelFormat, even though it will have no effect on
	-- the outcome there.
    local pfd = ffi.new("PIXELFORMATDESCRIPTOR");
    pfd.nSize = ffi.sizeof(pfd);
    pfd.nVersion = 1;
    pfd.dwFlags = bor(GDI32.FFI.PFD_DRAW_TO_WINDOW, GDI32.FFI.PFD_SUPPORT_OPENGL, GDI32.FFI.PFD_DOUBLEBUFFER);
    pfd.iPixelType = GDI32.FFI.PFD_TYPE_RGBA;
    pfd.cColorBits = 32;
    pfd.cDepthBits = 24;
    pfd.cStencilBits = 8;
    pfd.iLayerType = GDI32.FFI.PFD_MAIN_PLANE;

    local pixelFormat = GDI32.Lib.ChoosePixelFormat(dummydc, pfd);
	assert(pixelFormat ~= 0, "pixel format not chosen");

	-- Now we set the pixel format on the window so we can create
	-- the wglcontext.
    local bResult = GDI32.Lib.SetPixelFormat(dummydc, pixelFormat, pfd);
	assert(bResult~=0, "could not setpixelformat");

	-- Now create the dummy context
	local dummyRC = OglMan.Lib.wglCreateContext(dummydc);
    OglMan.Lib.wglMakeCurrent(dummydc, dummyRC);

	-- Now that we have an active glContext, we can
	-- initialize a couple of function pointers we'll need
	--local wglChoosePixelFormatARB = (PFNWGLCHOOSEPIXELFORMATARBPROC)wglGetProcAddress("wglChoosePixelFormatARB");
	--assert(wglChoosePixelFormatARB != NULL);

	--wglCreateContextAttribsARB = (PFNWGLCREATECONTEXTATTRIBSARBPROC)wglGetProcAddress("wglCreateContextAttribsARB");
	--assert(wglCreateContextAttribsARB != NULL);


	-- Using the wglChoosePixelFormatARB extension function,
	-- we'll try to get a more advanced pixel format
	local pnFormats= ffi.new("int[1]",0);
	local pPixelFormat = ffi.new("int[1]", pixelFormat);

	local err = 0;

	if multisamplemode > 1 then
	
		local pixelAttribs = ffi.new("int[32]",{
			WGL_SUPPORT_OPENGL_ARB, GL_TRUE,
			WGL_DRAW_TO_WINDOW_ARB, GL_TRUE,
			WGL_ACCELERATION_ARB, WGL_FULL_ACCELERATION_ARB,
			WGL_DOUBLE_BUFFER_ARB, GL_TRUE,

			WGL_PIXEL_TYPE_ARB, WGL_TYPE_RGBA_ARB,
			WGL_RED_BITS_ARB, 8,
			WGL_GREEN_BITS_ARB, 8,
			WGL_BLUE_BITS_ARB, 8,
			WGL_ALPHA_BITS_ARB, 8,
			WGL_DEPTH_BITS_ARB, 24,
			WGL_STENCIL_BITS_ARB, 8,

			WGL_SAMPLE_BUFFERS_ARB, GL_TRUE,
			WGL_SAMPLES_ARB, multisamplemode,

			0,0});

		err = OglMan.wglChoosePixelFormatARB(dummydc, pixelAttribs, NULL, 1, pPixelFormat, pnFormats);
		CHECKGL("wglChoosePixelFormatARB");
	else 
		local pixelAttribs = ffi.new("int[32]",{
			WGL_SUPPORT_OPENGL_ARB, GL_TRUE,
			WGL_DRAW_TO_WINDOW_ARB, GL_TRUE,
			WGL_ACCELERATION_ARB, WGL_FULL_ACCELERATION_ARB,
			WGL_DOUBLE_BUFFER_ARB, GL_TRUE,

			WGL_PIXEL_TYPE_ARB, WGL_TYPE_RGBA_ARB,
			WGL_RED_BITS_ARB, 8,
			WGL_GREEN_BITS_ARB, 8,
			WGL_BLUE_BITS_ARB, 8,
			WGL_ALPHA_BITS_ARB, 8,
			WGL_DEPTH_BITS_ARB, 24,
			WGL_STENCIL_BITS_ARB, 8,

			WGL_SAMPLE_BUFFERS_ARB, GL_FALSE,
			0,0});

		err = OglMan.wglChoosePixelFormatARB(dummydc, pixelAttribs, nil, 1, pPixelFormat, pnFormats);
		CHECKGL("wglChoosePixelFormatARB");
	end

	-- At this point, we have the wgl function pointers that we need,
	-- and we've already used the dummy dc to select a pixel format,
	-- so we can destroy the dummy window now.
	User32.Lib.DestroyWindow(dummyWindow);

	-- Now, we want to get the DC of the real window
	-- and set the pixel format on that.
	local hDC = User32.Lib.GetDC(hWnd);
	err = GDI32.Lib.SetPixelFormat(hDC, pixelFormat, pfd);

--print("SetPixelFormat, RETURNED: %d", err);


	-- And finally, create a context of the specific
	-- version we're looking for
	-- The ctxAttribs define what attributes we want to have
	-- on the context itself.
	local ctxAttribs = ffi.new("int[32]", {
		WGL_CONTEXT_MAJOR_VERSION_ARB, majorversion,
		WGL_CONTEXT_MINOR_VERSION_ARB, minorversion,
		WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB,
		0,0
		});

	local hRC = nil;
	if OglMan.wglCreateContextAttribsARB then
    	hRC = OglMan.wglCreateContextAttribsARB(ffi.cast("void *", hDC), nil, ctxAttribs);
		CHECKGL("wglCreateContextAttribsARB");

		if hRC == nil then
			hRC = OglMan.Lib.wglCreateContext(hDC);
		end
	else
		hRC = OglMan.Lib.wglCreateContext(hDC);
	end

-- print(string.format("hRC: 0x%x", hRC));

	if hRC == nil then
		return false
	end

	return hRC;
end


local GLContext = {}
setmetatable(GLContext, {
	__call = function(self, ...)
		return self:create(...);
	end,
})
local GLContext_mt = {
	__index = GLContext;
}

GLContext.init = function(self, hRC)
	local obj = {
		Handle = hRC;
	}
	setmetatable(obj, GLContext_mt);

	return obj
end


GLContext.create = function(self, hWnd, majorversion, minorversion, multisamplemode)
	if not hWnd then
		return nil, "must specify a window handle"
	end

	majorversion = majorversion or 3;
	minorversion = minorversion or 2;
	multisamplemode = multisamplemode or 0

	local hRC, err = CreateGLContext(hWnd, majorversion, minorversion, multisamplemode)

	if not hRC then
		return false, err
	end

	return self:init(hRC);
end

GLContext.MakeCurrent = function(self, hDC)
	OglMan.Lib.wglMakeCurrent(hDC, self.Handle)
end

return GLContext;
