-- test_MMDevice.lua
local ffi = require("ffi")
local MMDevice_ffi = require("MMDevice_ffi")
local ObjBase = require("ObjBase")
local win_error = require("win_error")
local core_string = require("core_string_l1_1_0");

local CO_E_FIRST       = 0x800401F0;
local CO_E_LAST        = 0x800401FF;
--#define CO_S_FIRST        0x000401F0L
--#define CO_S_LAST         0x000401FFL

-- COM MUST be initialized before anything 
-- else can be done.
local hr = ObjBase.CoInitialize(nil)

--print("CoInitialize: ", HRESULT_PARTS(hr))


DEFINE_PROPERTYKEY("PKEY_Device_FriendlyName",           0xa45c254e, 0xdf1c, 0x4efd, 0x80, 0x20, 0x67, 0xd1, 0x46, 0xa8, 0x50, 0xe0, 14);
DEFINE_PROPERTYKEY("PKEY_DeviceInterface_FriendlyName",  0x026e516e, 0xb814, 0x414b, 0x83, 0xcd, 0x85, 0x6d, 0x6f, 0xef, 0x48, 0x22, 2); -- DEVPROP_TYPE_STRING

--print("PKEY_DeviceInterface_FriendlyName: ", tostring(PKEY_DeviceInterface_FriendlyName.fmtid), PKEY_DeviceInterface_FriendlyName.pid)

--if PKEY_Device_FriendlyName then
--return true
--end

-- Create an instance of the enumeration interface
local pEnumerator = ffi.new("IMMDeviceEnumerator *[1]")

local hr = ObjBase.CoCreateInstance(MMDevice_ffi.CLSID_MMDeviceEnumerator, 
	nil,
    CLSCTX_INPROC_SERVER, 
    MMDevice_ffi.IID_IMMDeviceEnumerator,
    ffi.cast("void**",pEnumerator));

--print(string.format("CoCreateInstance: 0x%4x", hr))
--print(HRESULT_PARTS(hr))

--pEnumerator = pEnumerator[0];
--print("pEnumerator: ", pEnumerator[0])
local ppDevices = ffi.new("IMMDeviceCollection *[1]")

--[[
print("About To EnumAudioEndpoints")
print("        pEnumerator: ", pEnumerator[0])
print("               eAll: ", ffi.C.eAll)
print("DEVICE_STATE_ACTIVE: ", ffi.C.DEVICE_STATE_ACTIVE)
print("          ppDevices: ", ppDevices)
--]]

hr = pEnumerator[0].EnumAudioEndpoints(pEnumerator[0], ffi.C.eAll, ffi.C.DEVICE_STATE_ACTIVE, ppDevices)

--print("EnumAudioEndpoints: ", HRESULT_PARTS(hr))

if hr ~= 0 then
	return false, hr
end 
ppDevices = ppDevices[0]

-- get the count of devices
local pcDevices = ffi.new("UINT[1]")
hr = ppDevices:GetCount(pcDevices)

--print("GetCount: ", HRESULT_PARTS(hr))
--print("Count of devices: ", pcDevices[0])

local deviceCount = pcDevices[0];
local ppDevice = ffi.new("IMMDevice * [1]")
for i=0,deviceCount-1 do
	local hr = ppDevices:Item(i, ppDevice)
	--print("Item: ", ppDevice[0], HRESULT_PARTS(hr))

	if hr == 0 then
		pEndPoint = ppDevice[0]
		local ppstrId = ffi.new("PWSTR [1]")
		hr = pEndPoint:GetId(ppstrId)
		local deviceID = core_string.toAnsi(ppstrId[0])
		--print("Device ID: ", deviceID)

		-- open property store
		local pProps = ffi.new("IPropertyStore * [1]");
		hr = pEndPoint:OpenPropertyStore(ffi.C.STGM_READ, pProps);
		--print("Open Property Store: ", HRESULT_PARTS(hr))

		if hr ~= 0 then
			break
		end

		local pStore = pProps[0];
		-- How many properties
		local cProps = ffi.new("DWORD[1]")
		hr = pStore.lpVtbl.GetCount(pStore,cProps);
		--print("PropertyStore:GetCount: ", cProps[0])

		-- for each of the properties, get the key 
		-- then the value
		local propVar = ffi.new("PROPVARIANT");
		hr = pStore.lpVtbl.GetValue(pStore, PKEY_Device_FriendlyName, propVar);
		local value = core_string.toAnsi(propVar.pwszVal)
		print("Value: ", value)

--[[
		for i=0, cProps[0]-1 do
			local pkey = ffi.new("PROPERTYKEY")
			hr = pStore.lpVtbl.GetAt(pStore, i, pkey)
			--print("GetAt: ", i, hr, pkey.fmtid)

			local propVar = ffi.new("PROPVARIANT");
			hr = pStore.lpVtbl.GetValue(pStore, pkey, propVar);

		--print(string.format("GetValue: %d %d 0x%x", HRESULT_PARTS(hr)))
		--print("Value TYPE: ", propVar.vt)

			if propVar.vt == ffi.C.VT_LPWSTR then
				local value = core_string.toAnsi(propVar.pwszVal)
				print("Value: ", value)
			end
		end
--]]
	end
end
