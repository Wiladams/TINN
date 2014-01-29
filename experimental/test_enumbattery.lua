-- test_enumbattery.lua
local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor;
local band = bit.band;
local bnot = bit.bnot;

local devguid = require("devguid")
local WinBase = require("WinBase")
local errorhandling = require("core_errorhandling_l1_1_1");
local SetupApi = require("SetupApi")
local WinError = require("win_error")
local Device = require("Device")
local Application = require("Application")
local arch = require("arch")
local WinIoCtl = require("WinIoCtl")
local DeviceRecordSet = require("DeviceRecordSet")



ffi.cdef[[
typedef enum {
    BatteryInformation,
    BatteryGranularityInformation,
    BatteryTemperature,
    BatteryEstimatedTime,
    BatteryDeviceName,
    BatteryManufactureDate,
    BatteryManufactureName,
    BatteryUniqueID,
    BatterySerialNumber
} BATTERY_QUERY_INFORMATION_LEVEL;

typedef struct _BATTERY_QUERY_INFORMATION {
    ULONG                           BatteryTag;
    BATTERY_QUERY_INFORMATION_LEVEL InformationLevel;
    ULONG                           AtRate;
} BATTERY_QUERY_INFORMATION, *PBATTERY_QUERY_INFORMATION;

typedef struct _BATTERY_INFORMATION {
    ULONG       Capabilities;
    UCHAR       Technology;
    UCHAR       Reserved[3];
    UCHAR       Chemistry[4];
    ULONG       DesignedCapacity;
    ULONG       FullChargedCapacity;
    ULONG       DefaultAlert1;
    ULONG       DefaultAlert2;
    ULONG       CriticalBias;
    ULONG       CycleCount;
} BATTERY_INFORMATION, *PBATTERY_INFORMATION;

// BATTERY_INFORMATION.*Capacity constants
static const int BATTERY_UNKNOWN_CAPACITY = 0xFFFFFFFF;
static const int UNKNOWN_CAPACITY         = BATTERY_UNKNOWN_CAPACITY;

// BATTERY_INFORMATION.Capabilities flags
static const int BATTERY_SYSTEM_BATTERY              = 0x80000000;
static const int BATTERY_CAPACITY_RELATIVE           = 0x40000000;
static const int BATTERY_IS_SHORT_TERM               = 0x20000000;
static const int BATTERY_SEALED                      = 0x10000000;
static const int BATTERY_SET_CHARGE_SUPPORTED        = 0x00000001;
static const int BATTERY_SET_DISCHARGE_SUPPORTED     = 0x00000002;
static const int BATTERY_SET_CHARGINGSOURCE_SUPPORTED= 0x00000004;

]]

local IOCTL_BATTERY_QUERY_TAG = WinIoCtl.CTL_CODE(FILE_DEVICE_BATTERY, 0x10, METHOD_BUFFERED, FILE_READ_ACCESS)
local IOCTL_BATTERY_QUERY_INFORMATION = WinIoCtl.CTL_CODE(FILE_DEVICE_BATTERY, 0x11, METHOD_BUFFERED, FILE_READ_ACCESS)


local Battery = {}
setmetatable(Battery, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local Battery_mt = {
	__index = Battery
}

function Battery.init(self, rawhandle)
	local obj = {
		Device = Device:init(rawhandle),
	}
end

function Battery.create(self, batteryname)
	return self:init(rawhandle)
end

function Battery.names(self)
    local dwResult = ffi.C.GBS_ONBATTERY;

    local drs = DeviceRecordSet(bor(ffi.C.DIGCF_PRESENT, ffi.C.DIGCF_DEVICEINTERFACE), GUID_DEVCLASS_BATTERY);
    hdev = drs:getNativeHandle();

    -- Limit search to 100 batteries max
    for idev = 0, 99 do
		did = ffi.new("SP_DEVICE_INTERFACE_DATA");
		did.cbSize = ffi.sizeof(did);

		local res = SetupApi.SetupDiEnumDeviceInterfaces(hdev,
			nil,
			GUID_DEVCLASS_BATTERY,
			idev,
			did)

		if res ~= 0 then
			local cbRequired = ffi.new("DWORD[1]");

			-- figure out how much space is needed
			local res = SetupApi.SetupDiGetDeviceInterfaceDetail(hdev,
				did,
				nil,
				0,
				cbRequired,
				nil);

			local err = errorhandling.GetLastError()

			if err ~= ERROR_INSUFFICIENT_BUFFER then
				print("ERROR, after first InterfaceDetail: ", err)
				break;
			end

print("REQUIRED: ", cbRequired[0])
			local pdidd = WinBase.LocalAlloc(ffi.C.LPTR, 1024)
			local cbSize = ffi.sizeof("SP_DEVICE_INTERFACE_DETAIL_DATA_A");
			print("cbSize: ", cbSize);

 			local didd = ffi.cast("PSP_DEVICE_INTERFACE_DETAIL_DATA_A", pdidd)
 			didd.cbSize = cbSize;


            -- call again now that we have the right sized buffer
			local res = SetupApi.SetupDiGetDeviceInterfaceDetail(hdev,
				did,
				didd,
				264,
				nil,
				nil);

			if res == 0 then
				local err = errorhandling.GetLastError();
				print("ERROR, after second InterfaceDetail: ", err)
				break;
			end

			-- enumerate battery information
			print("BATTERY: ", ffi.string(didd.DevicePath))
			hBattery, err = Device(ffi.string(didd.DevicePath))
			if not hBattery then
				print("Battery Device creation ERROR: ", err)
				break;
			end

			-- Ask the battery for its tag.
			local bqi = ffi.new("BATTERY_QUERY_INFORMATION");

			local dwWait = ffi.new("DWORD[1]", 0);

			local dwOut, err = hBattery:control(IOCTL_BATTERY_QUERY_TAG,
        dwWait,
        ffi.sizeof("DWORD"),
        arch.fieldAddress(bqi, "BatteryTag"),
        ffi.sizeof("ULONG")); 

      if not dwOut then
        print("dwOut, err: ", dwOut, err)
        break;
      end

      -- We have the tag, so now other things can be asked for
      local bi = ffi.new("BATTERY_INFORMATION");
      bqi.InformationLevel = ffi.C.BatteryInformation;

      local dwOut, err = hBattery:control(IOCTL_BATTERY_QUERY_INFORMATION,
        bqi,
        ffi.sizeof(bqi),
        bi,
        ffi.sizeof(bi))

      -- Only non-UPS system batteries count
      print("Caps: ", bi.Capabilities, band(bi.Capabilities, ffi.C.BATTERY_SYSTEM_BATTERY))

      if (band(bi.Capabilities, ffi.C.BATTERY_SYSTEM_BATTERY) ~= 0 ) then
        print("System BATTERY")

--[[
          --if ( band(bi.Capabilities & BATTERY_IS_SHORT_TERM) == 0) then
          --{
          --             dwResult |= GBS_HASBATTERY;
          --}

        -- Query the battery status.
        BATTERY_WAIT_STATUS bws = {0};
        bws.BatteryTag = bqi.BatteryTag;

        BATTERY_STATUS bs;
        if (DeviceIoControl(hBattery,
                                          IOCTL_BATTERY_QUERY_STATUS,
                                          &bws,
                                          sizeof(bws),
                                          &bs,
                                          sizeof(bs),
                                          &dwOut,
                                          NULL))
        {
                        if (bs.PowerState & BATTERY_POWER_ON_LINE)
                         {
                          dwResult &= ~GBS_ONBATTERY;
                         }
        }
--]]
      end
		end
  end
end

--[[
local function GetBatteryState()
 
  -- Returned value includes GBS_HASBATTERY if the system has a 
  -- non-UPS battery, and GBS_ONBATTERY if the system is running on 
  -- a battery.
  --
  -- dwResult & GBS_ONBATTERY means we have not yet found AC power.
  -- dwResult & GBS_HASBATTERY means we have found a non-UPS battery.

  local dwResult = ffi.C.GBS_ONBATTERY;

  -- IOCTL_BATTERY_QUERY_INFORMATION,
  -- enumerate the batteries and ask each one for information.

  local hdev = SetupDiGetClassDevs(GUID_DEVCLASS_BATTERY, 
        0, 
        0, 
        bor(ffi.C.DIGCF_PRESENT, ffi.C.DIGCF_DEVICEINTERFACE));
  
  if (INVALID_HANDLE_VALUE ~= hdev) then
   
    -- Limit search to 100 batteries max
    for idev = 0, 99 do
     {
      SP_DEVICE_INTERFACE_DATA did = {0};
      did.cbSize = sizeof(did);

      if (SetupDiEnumDeviceInterfaces(hdev,
                                      0,
                                      &GUID_DEVCLASS_BATTERY,
                                      idev,
                                      &did))
       {
        DWORD cbRequired = 0;

        SetupDiGetDeviceInterfaceDetail(hdev,
                                        &did,
                                        0,
                                        0,
                                        &cbRequired,
                                        0);
        if (ERROR_INSUFFICIENT_BUFFER == GetLastError())
         {
          PSP_DEVICE_INTERFACE_DETAIL_DATA pdidd =
            (PSP_DEVICE_INTERFACE_DETAIL_DATA)LocalAlloc(LPTR,
                                                         cbRequired);
          if (pdidd)
           {
            pdidd->cbSize = sizeof(*pdidd);
            if (SetupDiGetDeviceInterfaceDetail(hdev,
                                                &did,
                                                pdidd,
                                                cbRequired,
                                                &cbRequired,
                                                0))
             {
              -- Enumerated a battery.  Ask it for information.
              HANDLE hBattery = 
                      CreateFile(pdidd->DevicePath,
                                 GENERIC_READ | GENERIC_WRITE,
                                 FILE_SHARE_READ | FILE_SHARE_WRITE,
                                 NULL,
                                 OPEN_EXISTING,
                                 FILE_ATTRIBUTE_NORMAL,
                                 NULL);
              if (INVALID_HANDLE_VALUE != hBattery)
               {
                -- Ask the battery for its tag.
                BATTERY_QUERY_INFORMATION bqi = {0};

                DWORD dwWait = 0;
                DWORD dwOut;

                if (DeviceIoControl(hBattery,
                                    IOCTL_BATTERY_QUERY_TAG,
                                    &dwWait,
                                    sizeof(dwWait),
                                    &bqi.BatteryTag,
                                    sizeof(bqi.BatteryTag),
                                    &dwOut,
                                    NULL)
                    && bqi.BatteryTag)
                 {
                  -- With the tag, you can query the battery info.
                  BATTERY_INFORMATION bi = {0};
                  bqi.InformationLevel = BatteryInformation;

                  if (DeviceIoControl(hBattery,
                                      IOCTL_BATTERY_QUERY_INFORMATION,
                                      &bqi,
                                      sizeof(bqi),
                                      &bi,
                                      sizeof(bi),
                                      &dwOut,
                                      NULL))
                   {
                    -- Only non-UPS system batteries count
                    if (bi.Capabilities & BATTERY_SYSTEM_BATTERY)
                     {
                      if (!(bi.Capabilities & BATTERY_IS_SHORT_TERM))
                       {
                        dwResult |= GBS_HASBATTERY;
                       }

                      -- Query the battery status.
                      BATTERY_WAIT_STATUS bws = {0};
                      bws.BatteryTag = bqi.BatteryTag;

                      BATTERY_STATUS bs;
                      if (DeviceIoControl(hBattery,
                                          IOCTL_BATTERY_QUERY_STATUS,
                                          &bws,
                                          sizeof(bws),
                                          &bs,
                                          sizeof(bs),
                                          &dwOut,
                                          NULL))
                       {
                        if (bs.PowerState & BATTERY_POWER_ON_LINE)
                         {
                          dwResult &= ~GBS_ONBATTERY;
                         }
                       }
                     }
                   }
                 }
                CloseHandle(hBattery);
               }
             }
            LocalFree(pdidd);
           }
         }
       }
        elseif (ERROR_NO_MORE_ITEMS == errorhandling.GetLastError()) then
         
          break;  -- Enumeration failed - perhaps we're out of items
         end
     }
    SetupDiDestroyDeviceInfoList(hdev);
   }

  --  Final cleanup:  If we didn't find a battery, then presume that we
  --  are on AC power.

  if (0 == band(dwResult,  ffi.C.GBS_HASBATTERY)) then
    dwResult = band(dwResult, bnot(ffi.C.GBS_ONBATTERY);
  end

  return dwResult;
end
--]]

local function main()
	Battery:names();
end

run(main)