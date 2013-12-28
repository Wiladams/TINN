-- test_dxgi.lua
local ffi = require("ffi")

local dxgi_ffi = require("dxgi_ffi")
local dxgi = require("dxgi")

local fac, err = dxgi.IDXGIFactory1()

print("Factory: ", fac, err)
print("Is Current: ", fac:IsCurrent())

for adapter in fac:Adapters() do
	print("======= Adapter ==========")
	print(adapter)
	print("---- Outputs ----")
	for output in adapter:Outputs() do
		output:GetDescription():Print();

		print("Output Modes")
--[[
	-- Valid under Mac Parallels
    DXGI_FORMAT_R8G8B8A8_UNORM              = 28,
    DXGI_FORMAT_R8G8B8A8_UNORM_SRGB         = 29,
    DXGI_FORMAT_B5G6R5_UNORM                = 85,
    DXGI_FORMAT_B8G8R8A8_UNORM              = 87,
    DXGI_FORMAT_B8G8R8A8_UNORM_SRGB         = 91,
--]]
		local modes, err = output:GetDisplayModes(ffi.C.DXGI_FORMAT_R8G8B8A8_UNORM);

		if modes then
			for i=0,err-1 do
				print("Mode: ", modes[i])
			end
		end
	end
end

