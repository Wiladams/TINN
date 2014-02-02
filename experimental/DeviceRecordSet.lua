local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor;
local band = bit.band;

local core_string = require("core_string_l1_1_0")
local errorhandling = require("core_errorhandling_l1_1_1");
local SetupApi = require("SetupApi")
local WinNT = require("WinNT")
local iterators = require("iterators")
local WinError = require("win_error")
local WinBase = require("WinBase")


local DeviceRecordSet = {}
setmetatable(DeviceRecordSet, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local DeviceRecordSet_mt = {
	__index = DeviceRecordSet,
}


function DeviceRecordSet.init(self, rawhandle)
	local obj = {
		Handle = rawhandle,
	}
	setmetatable(obj, DeviceRecordSet_mt)

	return obj;
end

function DeviceRecordSet.create(self, Flags, ClassGuid)
	Flags = Flags or bor(ffi.C.DIGCF_PRESENT, ffi.C.DIGCF_ALLCLASSES)

	local rawhandle = SetupApi.SetupDiGetClassDevs(
		ClassGuid, 
        nil, 
        nil, 
        Flags);

	if rawhandle == nil then
		return nil, errorhandling.GetLastError();
	end

	return self:init(rawhandle)
end

function DeviceRecordSet.getNativeHandle(self)
	return self.Handle;
end

function DeviceRecordSet.getRegistryValue(self, key, idx)
	idx = idx or 0;

	local did = ffi.new("SP_DEVINFO_DATA")
	did.cbSize = ffi.sizeof("SP_DEVINFO_DATA");

--print("HANDLE: ", self.Handle)
	local res = SetupApi.SetupDiEnumDeviceInfo(self.Handle,idx,did)

	if res == 0 then
		local err = errorhandling.GetLastError()
		--print("after SetupDiEnumDeviceInfo, ERROR: ", err)
		return nil, err;
	end

	local regDataType = ffi.new("DWORD[1]")
	local pbuffersize = ffi.new("DWORD[1]",260);
	local buffer = ffi.new("char[260]")

	local res = SetupApi.SetupDiGetDeviceRegistryProperty(
            self:getNativeHandle(),
            did,
			key,
			regDataType,
            buffer,
            pbuffersize[0],
            pbuffersize);

	if res == 0 then
		local err = errorhandling.GetLastError();
		--print("after GetDeviceRegistryProperty, ERROR: ", err)
		return nil, err;
	end

	--print("TYPE: ", regDataType[0])
	if (regDataType[0] == ffi.C.REG_SZ) then
		return ffi.string(buffer, pbuffersize[0]-1)
	elseif regDataType[0] == ffi.C.REG_MULTI_SZ then
		local res = {}
		for _,name in iterators.mstrziter{data=buffer, datalength=pbuffersize[0]} do
			table.insert(res, name)
		end
		return res;
	elseif regDataType[0] == ffi.C.REG_DWORD_LITTLE_ENDIAN then
		return ffi.cast("DWORD *", buffer)[0]
	end

	return nil;
end


function DeviceRecordSet.devices(self, fields)
	fields = fields or {
		{ffi.C.SPDRP_DEVICEDESC, "description"},
		{ffi.C.SPDRP_MFG, "manufacturer"},
		{ffi.C.SPDRP_DEVTYPE, "devicetype"},
		{ffi.C.SPDRP_CLASS, "class"},
		{ffi.C.SPDRP_ENUMERATOR_NAME, "enumerator"},
		{ffi.C.SPDRP_FRIENDLYNAME, "friendlyname"},
		{ffi.C.SPDRP_LOCATION_INFORMATION , "locationinfo"},
		{ffi.C.SPDRP_LOCATION_PATHS, "locationpaths"},
		{ffi.C.SPDRP_PHYSICAL_DEVICE_OBJECT_NAME, "objectname"},
		{ffi.C.SPDRP_SERVICE, "service"},
	}

	local function closure(fields, idx)
		local res = {}

		local count = 0;
		for _it, field in ipairs(fields) do
			local value, err = self:getRegistryValue(field[1], idx)
			if value then
				count = count + 1;
				res[field[2]] = value;
			end
		end

		if count == 0 then
			return nil;
		end
				
		return idx+1, res;
	end

	return closure, fields, 0
end

function DeviceRecordSet.interfaces(self, classguid)
--rint("did.cbSize: ", did.cbSize)

	local function closure(params, idx)
		local did = ffi.new("SP_DEVICE_INTERFACE_DATA");
		did.cbSize = ffi.sizeof(did);

		local res = SetupApi.SetupDiEnumDeviceInterfaces(self:getNativeHandle(),
			nil,
			params.classguid,
			idx,
			did)

		if res == 0 then
			local err = errorhandling.GetLastError();
			--print("ERROR, after EnumDeviceInterfaces: ", err)
			return nil;
		end
		
		-- figure out how much space is needed
		-- to get the interface detail
		local cbRequired = ffi.new("DWORD[1]");
		local res = SetupApi.SetupDiGetDeviceInterfaceDetail(self:getNativeHandle(),
			did,
			nil,
			0,
			cbRequired,
			nil);


		-- if the error is anything but insufficient buffer
		-- then return nil
		local err = errorhandling.GetLastError()

		if err ~= ERROR_INSUFFICIENT_BUFFER then
			print("ERROR, after first InterfaceDetail: ", err)
			return nil;
		end
		
		-- allocate a buffer to hold the detail
		local pdidd = WinBase.LocalAlloc(ffi.C.LPTR, 1024)
		local cbSize = ffi.sizeof("SP_DEVICE_INTERFACE_DETAIL_DATA_A");

 		local didd = ffi.cast("PSP_DEVICE_INTERFACE_DETAIL_DATA_A", pdidd)
 		didd.cbSize = cbSize;

        -- call again now that we have the right sized buffer
		local res = SetupApi.SetupDiGetDeviceInterfaceDetail(self:getNativeHandle(),
			did,
			didd,
			264,
			nil,
			nil);

		if res == 0 then
			local err = errorhandling.GetLastError();
			print("ERROR, after second InterfaceDetail: ", err)
			return nil;
		end

		local devicePath = ffi.string(didd.DevicePath)

		-- cleanup
		WinBase.LocalFree(pdidd)

		return idx+1, devicePath
	end

	return closure, {classguid = classguid}, 0
end

return DeviceRecordSet
