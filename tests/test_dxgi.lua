-- test_dxgi.lua

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
		print("Output: ", output)
	end
end


