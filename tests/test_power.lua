local ffi = require("ffi");
local kernel32 = require("win_kernel32");
local k32Lib = kernel32.Lib;
local Lib = ffi.load("PowrProf");

require("power_base_l1_1_0");

local SYSTEM_POWER_CAPABILITIES = ffi.typeof("SYSTEM_POWER_CAPABILITIES");
local BATTERY_REPORTING_SCALE = ffi.typeof("BATTERY_REPORTING_SCALE");

local GetPwrCapabilities = function()
	powerinfo = SYSTEM_POWER_CAPABILITIES();
	local res = Lib.GetPwrCapabilities(powerinfo);
	if res == 0 then
		return false, k32Lib.GetLastError();
	end

	return powerinfo;
end

local SystemPowerCapabilities = {}
local SystemPowerCapabilities_mt = {
	__index = SystemPowerCapabilities,

	__tostring = function(self)
		local res = {}
		for k,v in pairs(self) do 
			table.insert(res, string.format("%s = %s\n", k, tostring(v)));
		end
		return table.concat(res);
	end,
}

SystemPowerCapabilities.new = function(data)
	local obj = {
		PowerButtonPresent = pwrinfo.PowerButtonPresent > 0;
		SleepButtonPresent = pwrinfo.SleepButtonPresent > 0;
		LidPresent = pwrinfo.LidPresent > 0;
		SystemS1 = pwrinfo.SystemS1 > 0;
		SystemS2 = pwrinfo.SystemS2 > 0;
		SystemS3 = pwrinfo.SystemS3 > 0;
		SystemS4 = pwrinfo.SystemS4 > 0;	-- hibernate
		SystemS5 = pwrinfo.SystemS5 > 0;	-- off
		HiberFilePresent = pwrinfo.HiberFilePresent > 0;
		FullWake = pwrinfo.FullWake > 0;
		VideoDimPresent = pwrinfo.VideoDimPresent > 0;
		ApmPresent = pwrinfo.ApmPresent > 0;
		UpsPresent = pwrinfo.UpsPresent > 0;

		-- Processors
		ThermalControl = pwrinfo.ThermalControl > 0;
		ProcessorThrottle = pwrinfo.ProcessorThrottle > 0;
		ProcessorMinThrottle = pwrinfo.ProcessorMinThrottle;
		ProcessorMaxThrottle = pwrinfo.ProcessorMaxThrottle;
		FastSystemS4 = pwrinfo.FastSystemS4;

		-- Disk
		DiskSpinDown = pwrinfo.DiskSpinDown > 0;

		-- SystemBattery
		SystemBatteriesPresent = pwrinfo.SystemBatteriesPresent > 0;
		BatteriesAreShortTerm = pwrinfo.BatteriesAreShortTerm > 0;
		BatteryScale = {
			BATTERY_REPORTING_SCALE(pwrinfo.BatteryScale[0]),
			BATTERY_REPORTING_SCALE(pwrinfo.BatteryScale[1]),
			BATTERY_REPORTING_SCALE(pwrinfo.BatteryScale[2]),			
		},

		AcOnLineWake = tonumber(pwrinfo.AcOnLineWake);
		SoftLidWake = tonumber(pwrinfo.SoftLidWake);
		RtcWake = tonumber(pwrinfo.RtcWake);
		MinDeviceWakeState = tonumber(pwrinfo.MinDeviceWakeState);
		DefaultLowLatencyWake = tonumber(pwrinfo.DefaultLowLatencyWake);
	}
	setmetatable(obj, SystemPowerCapabilities_mt);

	return obj;
end


pwrinfo = GetPwrCapabilities();
pwrinfo = SystemPowerCapabilities.new(pwrinfo);

print(pwrinfo);

