local ffi = require "ffi"



gl   = ffi.load( "opengl32" );

require "WTypes"

ffi.cdef[[
typedef unsigned int GLenum;
typedef unsigned char GLboolean;
typedef unsigned int GLbitfield;
typedef signed char GLbyte;
typedef int GLint;
typedef int GLsizei;
typedef unsigned char GLubyte;
typedef char GLchar;
typedef char GLcharARB;
typedef short GLshort;
typedef unsigned short GLushort;
typedef unsigned int GLuint;
typedef int64_t GLint64;
typedef uint64_t GLuint64;
typedef int64_t GLint64EXT;
typedef uint64_t GLuint64EXT;

typedef unsigned short GLhalfNV;

typedef float GLfloat;
typedef float GLclampf;

typedef double GLdouble;
typedef double GLclampd;

typedef void GLvoid;
typedef long GLintptr;
typedef long GLsizeiptr;
typedef void *GLhandleARB;
typedef long GLintptrARB;
typedef long GLsizeiptrARB;
typedef unsigned short GLhalfARB;
typedef unsigned short GLhalf;
]]


require "gl"
require "glext"
require "wglext"



function GetFunctionProtoName(fname)
	local upname = fname:upper();
	local protoname = string.format("PFN%sPROC", upname);

	return protoname;
end

function CastFunctionPointer(fname, funcptr)
	local protoname = GetFunctionProtoName(fname);
	local castfunc = ffi.cast(protoname, funcptr);

	return castfunc;
end

function GetWglFunction(fname)
	local funcptr = gl.wglGetProcAddress(fname);

	if funcptr == nil then
		return nil
	end

	local castfunc = CastFunctionPointer(fname, funcptr);

	return castfunc;
end




local OglMan={
	Lib = gl;
}
OglMan_mt = {
	__index = function(tbl, key)
		local funcptr = GetWglFunction(key)

		-- Set the function into the table of
		-- known functions, so next time around,
		-- it this code will not need to execute
		rawset(tbl, key, funcptr)

		return funcptr;
	end,

--[[
	__newindex = function(tbl, idx, value)
		if idx == "Execute" then
			rawset(tbl, idx, value)
		end
	end,
--]]
}

setmetatable(OglMan, OglMan_mt)



--[[
	Convenience aliases
--]]


glAlphaFunc = gl.glAlphaFunc;

glBegin = gl.glBegin;

glBlendFunc = gl.glBlendFunc;

glClear = gl.glClear;

glClearColor = gl.glClearColor;

function glClearDepth (depth)
	gl.glClearDepth(depth);
end

function glColor(...)
local arg={...};
	if #arg == 3 then
		gl.glColor3d(arg[1], arg[2], arg[3]);
	elseif #arg == 4 then
		gl.glColor4d(arg[1], arg[2], arg[3], arg[4]);
	elseif #arg == 2 then
		gl.glColor4d(arg[1], arg[1], arg[1], arg[2]);
	elseif #arg == 1 then
		if type(arg[1] == "number") then
			gl.glColor3d(arg[1], arg[1], arg[1]);
		elseif type(arg[1]) == "table" then
			if #arg[1] == 3 then
				gl.glColor3d(arg[1], arg[2], arg[3]);
			elseif #arg[1] == 4 then
				gl.glColor4d(arg[1], arg[2], arg[3], arg[4]);
			end
		end
	end
end

glColor3f = gl.glColor3f;
glColor4f = gl.glColor4f;

glColorMaterial = gl.glColorMaterial;

glCullFace = gl.glCullFace;

glDeleteLists = gl.glDeleteLists;

glDepthFunc = gl.glDepthFunc;

glDepthRange = gl.glDepthRange;

glDisable = gl.glDisable;
glEnable = gl.glEnable;

glDrawPixels = gl.glDrawPixels;

glEnd = gl.glEnd;
glEndList = gl.glEndList;

glFinish = gl.glFinish;
glFlush = gl.glFlush;

glGenLists = gl.glGenLists;

glGetError = gl.glGetError;
glHint = gl.glHint;
glLineWidth = gl.glLineWidth;

glLoadIdentity = gl.glLoadIdentity;
glMatrixMode = gl.glMatrixMode;
glPopMatrix = gl.glPopMatrix;
glPushMatrix = gl.glPushMatrix;

glOrtho = gl.glOrtho;
glFrustum = gl.glFrustum;

glPixelStorei = gl.glPixelStorei;

glPointSize = gl.glPointSize;

glPolygonMode = gl.glPolygonMode;




function glRasterPos(x, y)
	gl.glRasterPos2d(x, y);
end

glRasterPos2i = gl.glRasterPos2i;


function glRotate(angle, x, y, z)
	gl.glRotated(angle, x, y, z);
end

glRotatef = gl.glRotatef;


function glScale(x, y, z)
	gl.glScaled (x, y, z);
end

glScalef = gl.glScalef;

glShadeModel = gl.glShadeModel;


function glTexCoord(s, t, r, q)
	gl.glTexCoord2d(s, t);
end

glTexCoord2f = glTexCoord;
glTexCoord2d = gl.glTexCoord2d;


function glTranslate(x, y, z)
	gl.glTranslated(x, y, z);
end

glTranslatef = gl.glTranslatef;


function glVertex(...)
local arg={...};
	if #arg == 3 then
		gl.glVertex3d(arg[1], arg[2], arg[3]);
	elseif #arg == 4 then
		gl.glVertex4d(arg[1], arg[2], arg[3], arg[4]);
	elseif #arg == 1 then
		if type(arg[1]) == "table" then
			if #arg[1] == 3 then
				gl.glVertex3d(arg[1], arg[2], arg[3]);
			elseif #arg[1] == 4 then
				gl.glVertex4d(arg[1], arg[2], arg[3], arg[4]);
			end
		end
	end
end

glVertex2f = gl.glVertex2f;
glVertex3f = gl.glVertex3f;
glVertex4f = gl.glVertex4f;

glVertex2d = gl.glVertex2d;

glViewport = gl.glViewport;




return OglMan;
