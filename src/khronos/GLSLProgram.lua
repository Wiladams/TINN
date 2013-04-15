local ffi = require "ffi"

ffi.cdef[[
typedef struct glsl_shader_t
{
	int ID;
	bool Owner;
}glsl_shader_t;
]]

GLSLShader = ffi.typeof("glsl_shader_t");
GLSLShader_mt = {
	__index = {
		CreateFromText = function(self, text, stype)
			local src_array = ffi.new("char*[1]", ffi.cast("char *",text));
			local lpSuccess = ffi.new("int[1]");

			self.ID = ogm.glCreateShader(stype);
			self.Owner = true;
			ogm.glShaderSource(self.ID, 1, src_array, nil);
			self:Compile();

			return self;
		end,

		CreateFromFile = function(self, fname, stype)
			local fp = io.open(fname, "r");
			local src_buf = fp:read("*all");

			self:CreateFromText(src_buf, stype)

			fp:close();

			return shader;
		end,

		Compile = function(self)
			ogm.glCompileShader(self.ID);
		end,

		GetValue = function(self, nameenum)
			local lpParams = ffi.new("int[1]");

			ogm.glGetShaderiv(self.ID, nameenum, lpParams)
			return lpParams[0];
		end,

		GetShaderType = function(self)
			return self:GetValue(GL_SHADER_TYPE);
		end,

		GetDeleteStatus = function(self)
			return self:GetValue(GL_DELETE_STATUS);
		end,

		GetCompileStatus = function(self)
			return self:GetValue(GL_COMPILE_STATUS);
		end,

		GetInfoLogLength = function(self)
			return self:GetValue(GL_INFO_LOG_LENGTH);
		end,

		GetSourceLength = function(self)
			return self:GetValue(GL_SHADER_SOURCE_LENGTH);
		end,

		GetSource = function(self)
			local bufSize = self:GetSourceLength();
			local source = Array1D(bufSize+1, "char")
			local lpLength = ffi.new("int[1]");

			ogm.glGetShaderSource(self.ID, bufSize, lpLength, source)

			return ffi.string(source);
		end,

		GetInfoLog = function(self)
			local bufSize = self:GetInfoLogLength();
			local log = Array1D(bufSize+1, "char")
			local lpLength = ffi.new("int[1]");

			ogm.glGetShaderInfoLog(self.ID, bufSize, lpLength, log)

			return ffi.string(log);
		end,
	},
}
GLSLShader = ffi.metatype("glsl_shader_t", GLSLShader_mt);








GPUProgram = {}
GPUProgram_mt = {}

function GPUProgram.new(fragtext, vertext)
	local self = {}

	self.ID = ogm.glCreateProgram();

	if fragtext ~= nil then
		self.FragmentShader = GLSLShader():CreateFromText(fragtext, GL_FRAGMENT_SHADER);
		GPUProgram.AttachShader(self, self.FragmentShader);
	end

	if vertext ~= nil then
		self.VertexShader = GLSLShader():CreateFromText(vertext, GL_VERTEX_SHADER);
		GPUProgram.AttachShader(self, self.VertexShader);
	end

	GPUProgram.Link(self)

	setmetatable(self, GPUProgram_mt)

	return self
end

function GPUProgram:AttachShader(shader)
	ogm.glAttachShader(self.ID, shader.ID);
end

function GPUProgram:Link()
	ogm.glLinkProgram(self.ID);

	local lpLinked = ffi.new("int[1]");
	ogm.glGetProgramiv(self.ID, GL_LINK_STATUS, lpLinked);
	self.LinkStatus = lpLinked[0];

	if(0 == linked) then
		print("shader linking failed");
	end
end

function GPUProgram:Validate()
	ogm.glValidateProgram(self.ID);
end


function GPUProgram:Use()
	ogm.glUseProgram(self.ID);
end

local function get_ProgramValue(programid, nameenum)
	local lpParams = ffi.new("int[1]");

	ogm.glGetProgramiv(programid, nameenum, lpParams)

	return lpParams[0];
end

function GPUProgram:GetDeleteStatus()
	return get_ProgramValue(self.ID, GL_DELETE_STATUS);
end

function GPUProgram:GetLinkStatus()
	return get_ProgramValue(self.ID, GL_LINK_STATUS);
end

function GPUProgram:GetValidateStatus()
	return get_ProgramValue(self.ID, GL_VALIDATE_STATUS);
end

function GPUProgram:GetInfoLogLength()
	return get_ProgramValue(self.ID, GL_INFO_LOG_LENGTH);
end

function GPUProgram:GetAttachedShaderCount()
	return get_ProgramValue(self.ID, GL_ATTACHED_SHADERS);
end

function GPUProgram:GetActiveAttributeCount()
	return get_ProgramValue(self.ID, GL_ACTIVE_ATTRIBUTES);
end

function GPUProgram:GetActiveAttributeMaxLength()
	return get_ProgramValue(self.ID, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH);
end

function GPUProgram:GetActiveUniformCount()
	return get_ProgramValue(self.ID, GL_ACTIVE_UNIFORMS);
end

function GPUProgram:GetActiveUniformMaxLength()
	return get_ProgramValue(self.ID, GL_ACTIVE_UNIFORM_MAX_LENGTH);
end

function GPUProgram:GetInfoLog()
	local bufSize = self:GetInfoLogLength();
	local buff = ffi.new("char[?]", bufSize+1)
	local lpLength = ffi.new("int[1]");

	ogm.glGetProgramInfoLog(self.ID, bufSize, lpLength, buff)

	return ffi.string(buff);
end


function GPUProgram:Print()
	print("==== GLSL Program ====")
	print(string.format("Delete Status: 0x%x", self:GetDeleteStatus()))
	print(string.format("Link Status: 0x%x", self:GetLinkStatus()))
	print(string.format("Validate Status: 0x%x", self:GetValidateStatus()))

	print(string.format("Log Length: 0x%x", self:GetInfoLogLength()))
	print(string.format("Attached Shaders: 0x%x", self:GetAttachedShaderCount()))
	print(string.format("Active Attributes: 0x%x", self:GetActiveAttributeCount()))
	print(string.format("Active Max Length: 0x%x", self:GetActiveAttributeMaxLength()))
	print(string.format("Active Uniforms: 0x%x", self:GetActiveUniformCount()))
	print(string.format("Active Uniform Length: 0x%x", self:GetActiveUniformMaxLength()))

	print("==== LOG ====");
	print(self:GetInfoLog());
end


function GetUniform(self, name)
	local loc = ogm.glGetUniformLocation(self.ID, name);

--print("GetUniform: ", name, loc);

	local lpsize = ffi.new("int[1]");
	local lputype = ffi.new("int[1]");
	local buff = Array1D(256, "char");
	local bufflen = 255;
	local lplength = ffi.new("int[1]");

	ogm.glGetActiveUniform (self.ID, loc, bufflen, lplength, lpsize, lputype, buff);
	local size = lpsize[0];
	local utype = lputype[0];
	local namelen = lplength[0];
	local iname = ffi.string(buff);
--[[
	print("==========");
	print("Name: ", name);
	print("Location: ", loc);
	print(string.format("Type: 0x%x", utype));
	print("Size: ", size);
	print("IName: ", ffi.string(buff), namelen);
--]]
	return loc, utype, size;
end

-- This table of properties helps in the
-- process of retrieving and setting uniform
-- values of a shader
local uniformprops = {}
uniformprops[GL_FLOAT]		= {1, "float", ogm.glGetUniformfv, ogm.glUniform1fv, 1, "float[1]"};
uniformprops[GL_FLOAT_VEC2]	= {2, "float", ogm.glGetUniformfv, ogm.glUniform2fv, 1, "float[2]"};
uniformprops[GL_FLOAT_VEC3]	= {3, "float", ogm.glGetUniformfv, ogm.glUniform3fv, 1, "float[3]"};
uniformprops[GL_FLOAT_VEC4]	= {4, "float", ogm.glGetUniformfv, ogm.glUniform4fv, 1, "float[4]"};

uniformprops[GL_DOUBLE]		= {1, "double", ogm.glGetUniformdv, ogm.glUniform1dv, 1, "double[1]"};
uniformprops[GL_DOUBLE_VEC2]	= {2, "double", ogm.glGetUniformdv, ogm.glUniform2dv, 1, "double[2]"};
uniformprops[GL_DOUBLE_VEC3]	= {3, "double", ogm.glGetUniformdv, ogm.glUniform3dv, 1, "double[3]"};
uniformprops[GL_DOUBLE_VEC4]	= {4, "double", ogm.glGetUniformdv, ogm.glUniform4dv, 1, "double[4]"};

uniformprops[GL_INT]		= {1, "int", ogm.glGetUniformiv, ogm.glUniform1iv, 1, "int[1]"};
uniformprops[GL_INT_VEC2]	= {2, "int", ogm.glGetUniformiv, ogm.glUniform2iv, 1, "int[2]"};
uniformprops[GL_INT_VEC3]	= {3, "int", ogm.glGetUniformiv, ogm.glUniform3iv, 1, "int[3]"};
uniformprops[GL_INT_VEC4]	= {4, "int", ogm.glGetUniformiv, ogm.glUniform4iv, 1, "int[4]"};

uniformprops[GL_BOOL]		= {1, "int", ogm.glGetUniformiv, ogm.glUniform1iv, 1, "int[1]"};
uniformprops[GL_BOOL_VEC2]	= {2, "int", ogm.glGetUniformiv, ogm.glUniform2iv, 1, "int[2]"};
uniformprops[GL_BOOL_VEC3]	= {3, "int", ogm.glGetUniformiv, ogm.glUniform3iv, 1, "int[3]"};
uniformprops[GL_BOOL_VEC4]	= {4, "int", ogm.glGetUniformiv, ogm.glUniform4iv, 1, "int[4]"};

uniformprops[GL_FLOAT_MAT2]	= {4, "float", ogm.glGetUniformfv, ogm.glUniformMatrix2fv, 1, "float[4]"};
uniformprops[GL_FLOAT_MAT3]	= {9, "float", ogm.glGetUniformfv, ogm.glUniformMatrix3fv, 1, "float[9]"};
uniformprops[GL_FLOAT_MAT4]	= {16, "float", ogm.glGetUniformfv, ogm.glUniformMatrix4fv, 1, "float[16]"};

uniformprops[GL_SAMPLER_1D]		= {1, "int", ogm.glGetUniformiv, ogm.glUniform1iv, 1, "int[1]"};
uniformprops[GL_SAMPLER_1D_SHADOW]		= {1, "int", ogm.glGetUniformiv, ogm.glUniform1iv, 1, "int[1]"};
uniformprops[GL_SAMPLER_2D]	= {1, "int", ogm.glGetUniformiv, ogm.glUniform1iv, 1, "int[1]"};
uniformprops[GL_SAMPLER_2D_SHADOW]	= {1, "int", ogm.glGetUniformiv, ogm.glUniform1iv, 1, "int[1]"};
uniformprops[GL_SAMPLER_3D]	= {1, "int", ogm.glGetUniformiv, ogm.glUniform1iv, 1, "int[1]"};
uniformprops[GL_SAMPLER_CUBE]	= {1, "int", ogm.glGetUniformiv, ogm.glUniform1iv, 1, "int[1]"};


function GetUniformValue(self, name)
	local loc, utype, size = GetUniform(self, name);

	if loc == nil then return nil end;

	local uprops = uniformprops[utype];
--[[
	print("================")
	print("GPUProgram:GetUniformValue")
	print("Name: ", name);
	print("Loc: ", loc);
	print("Size: ", size);
	print("----");
--]]
	local ncomps = uprops[1]
	local basetype = uprops[2]
	local getfunc = uprops[3]
	local narrelem = uprops[5];
	local typedecl = uprops[6];
--	print(ncomps, basetype, typedecl);

	-- Create a buffer of the appropriate size
	-- to hold the results
	local buff = ffi.new(typedecl);

	-- Call the getter to get the value
	getfunc(self.ID, loc, buff);

	return buff, ncomps;
end


function SetUniformValue(self, name, value)
	local loc, utype, size = GetUniform(self, name);

	if loc == nil then return nil end;

	local uprops = uniformprops[utype];
--[[
	print("================")
	print("GPUProgram:GetUniformValue")
	print("Name: ", name);
	print("Loc: ", loc);
	print("Size: ", size);
	print("----");
--]]
	local ncomps = uprops[1]
	local basetype = uprops[2]
	local setfunc = uprops[4]
	local narrelem = uprops[5];
	local typedecl = uprops[6];
	--print(ncomps, basetype, typedecl);

	-- Create a buffer of the appropriate size
	-- to hold the results
	local buff = ffi.new(typedecl);

	-- copy value into buffer
	if ncomps == 1 then
		buff[0] = value
	else
		for i=0,ncomps-1 do
			buff[i] = value[i];
		end
	end

	-- Call the setter to get the value
	setfunc(loc, narrelem, buff);
end



function glsl_get(self, key)
	-- First, try the object itself as it might
	-- be a simple field access
	local field = rawget(self,key)
	if field ~= nil then
--		print("returning self field: ", field)
		return field
	end

	-- Next, try the class table, as it might be a
	-- function for the class
	field = rawget(GPUProgram,key)
	if field ~= nil then
--		print("returning glsl field: ", field)
		return field
	end

	-- Last, do whatever magic to return a value
	-- or nil

	local value, ncomps =  GetUniformValue(self, key)

	if ncomps == 1 then
		return value[0];
	end

	return value
end

function glsl_set(self, key, value)
	-- See if the field exists in the table
	local field = rawget(self,key)
	if field ~= nil then
		rawset(self, key, value)
	end

	-- Otherwise, try to set the value
	-- in the shader
	SetUniformValue(self, key, value)
end

GPUProgram_mt.__index = glsl_get

GPUProgram_mt.__newindex = glsl_set


function GLSLProgram(fragtext, vertext)
	local prog = GPUProgram.new(fragtext, vertext)

	return prog
end

function CreateGLSLProgramFromFiles(fragname, vertname)
	local fragtext = nil;
	local verttext = nil;
	local fp = nil;

	if fragname then
		fp = io.open(fragname, "r");
		fragtext = fp:read("*all");
		--print(fragtext);
		fp:close();
	end

	if vertname then
		fp = io.open(vertname, "r");
		verttext = fp:read("*all");
		fp:close();
	end

	local prog = GLSLProgram(fragtext, verttext);

	return prog;
end


return GLSLProgram
