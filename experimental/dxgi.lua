local ffi = require("ffi")
local dxgi_ffi = require("dxgi_ffi")
local core_string = require("core_string_l1_1_0")


local IDXGIFactory1 = {}
setmetatable(IDXGIFactory1, {
    __call = function(self, ...)
        return self:create(...)
    end,
})

local IDXGIFactory1_mt = {
    __index = IDXGIFactory1,
}

IDXGIFactory1.init = function(self, objhandle)
    local obj = {
        Handle = objhandle,
    }
    setmetatable(obj, IDXGIFactory1_mt)

    return obj;
end 

IDXGIFactory1.create = function(self)
    local ppFactory = ffi.new("IDXGIFactory1 *[1]")
    local hr = dxgi_ffi.CreateDXGIFactory1(IID_IDXGIFactory1, ffi.cast("void *",ppFactory));

    if hr ~= 0 then
        return nil, hr
    end

    return self:init(ppFactory[0])
end

IDXGIFactory1.QueryInterface= function(self,riid,ppvObject)	
    local hr = self.Handle.lpVtbl.QueryInterface(self.Handle,riid,ppvObject)
    if hr ~= 0 then
        return nil;
    end

    return ppvObject[0];
end

IDXGIFactory1.AddRef= function(self)	
    self.Handle.lpVtbl.AddRef(self.Handle)
end

IDXGIFactory1.Release= function(self)	
    self.Handle.lpVtbl.Release(self.Handle)
end

IDXGIFactory1.SetPrivateData= function(self,Name,DataSize,pData)	
    self.Handle.lpVtbl.SetPrivateData(self.Handle,Name,DataSize,pData)
end

IDXGIFactory1.SetPrivateDataInterface= function(self,Name,pUnknown)	
    self.Handle.lpVtbl.SetPrivateDataInterface(self.Handle,Name,pUnknown) 
end

IDXGIFactory1.GetPrivateData= function(self,Name,pDataSize,pData)	
    self.Handle.lpVtbl.GetPrivateData(self.Handle,Name,pDataSize,pData) 
end

IDXGIFactory1.GetParent= function(self,riid,ppParent)	
    self.Handle.lpVtbl.GetParent(self.Handle,riid,ppParent)
end

IDXGIFactory1.EnumAdapters= function(self,Adapter,ppAdapter)	
    self.Handle.lpVtbl.EnumAdapters(self.Handle,Adapter,ppAdapter) 
end

IDXGIFactory1.MakeWindowAssociation= function(self,WindowHandle,Flags)	
    self.Handle.lpVtbl.MakeWindowAssociation(self.Handle,WindowHandle,Flags) 
end

IDXGIFactory1.GetWindowAssociation= function(self,pWindowHandle)	
    self.Handle.lpVtbl.GetWindowAssociation(self.Handle,pWindowHandle)
end

IDXGIFactory1.CreateSwapChain= function(self,pDevice,pDesc,ppSwapChain)	
    self.Handle.lpVtbl.CreateSwapChain(self.Handle,pDevice,pDesc,ppSwapChain) 
end

IDXGIFactory1.CreateSoftwareAdapter= function(self,Module,ppAdapter)	
    self.Handle.lpVtbl.CreateSoftwareAdapter(self.Handle,Module,ppAdapter)
end

--[[
HRESULT EnumAdapters1(
  [in]   UINT Adapter,
  [out]  IDXGIAdapter1 **ppAdapter
);
--]]



IDXGIFactory1.Adapters= function(self,Adapter,ppAdapter)	
    local idx = 0;
    local ppAdapter = ffi.new("IDXGIAdapter1 *[1]")
    local listOfAdapters = {}

    -- First, get the list stuffed into a table
    while true do
        local hr = self.Handle.lpVtbl.EnumAdapters1(self.Handle,idx,ppAdapter)
        if hr ~= 0 then
            break
        end
        local adapter = ppAdapter[0];
        listOfAdapters[idx+1] = adapter;
        idx = idx + 1;
    end

    -- Create an iterator which will feed the adapters out
    idx = 0;
    local closure = function()
        idx = idx + 1;
        if idx > #listOfAdapters then
            return nil
        end
        return listOfAdapters[idx]
    end

    return closure
end

IDXGIFactory1.IsCurrent= function(self)	
    local res = self.Handle.lpVtbl.IsCurrent(self.Handle)
    
    if res == 0 then return false end

    return true;
end



--[[
    IDXGIAdapter1

    An adapter that may be returned from the Factory enumeration
    of Adapters()
--]]
local IDXGIAdapter1 = ffi.typeof("IDXGIAdapter1")
local IDXGIAdapter1_mt = {
    __tostring = function(self)
        return tostring(self:GetDescription())
    end,

    __index = {
        GetDescription = function(self)
            local pDesc = ffi.new("DXGI_ADAPTER_DESC1")
            self.lpVtbl.GetDesc1(self,pDesc)
            return pDesc;
        end, 

        Outputs = function(self)
            local idx = 0;
            local ppOutput = ffi.new("IDXGIOutput *[1]")
            local listOfOutputs = {}

            -- First, get the list stuffed into a table
            while true do
                local hr = self.lpVtbl.EnumOutputs(self,idx,ppOutput)
                if hr ~= 0 then
                    break
                end
                local output = ppOutput[0];
                listOfOutputs[idx+1] = output;
                idx = idx + 1;
            end

            -- Create an iterator which will feed the adapters out
            idx = 0;
            local closure = function()
                idx = idx + 1;
                if idx > #listOfOutputs then
                return nil
            end
            return listOfOutputs[idx]
    end

    return closure
            end,

        Print = function(self)
            local desc = self:GetDescription()
            print("Description: ", ffi.string(core_string.toAnsi(desc.Description)))
            print("Video Memory: ", desc.DedicatedVideoMemory)
            print("System Memory: ", desc.DedicatedSystemMemory)
            print("Shared Memory: ", desc.SharedSystemMemory)
        end,
    },
}
ffi.metatype(IDXGIAdapter1, IDXGIAdapter1_mt)

--[[
#define IDXGIAdapter1_QueryInterface(This,riid,ppvObject)   \
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IDXGIAdapter1_AddRef(This)  \
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IDXGIAdapter1_Release(This) \
    ( (This)->lpVtbl -> Release(This) ) 


#define IDXGIAdapter1_SetPrivateData(This,Name,DataSize,pData)  \
    ( (This)->lpVtbl -> SetPrivateData(This,Name,DataSize,pData) ) 

#define IDXGIAdapter1_SetPrivateDataInterface(This,Name,pUnknown)   \
    ( (This)->lpVtbl -> SetPrivateDataInterface(This,Name,pUnknown) ) 

#define IDXGIAdapter1_GetPrivateData(This,Name,pDataSize,pData) \
    ( (This)->lpVtbl -> GetPrivateData(This,Name,pDataSize,pData) ) 

#define IDXGIAdapter1_GetParent(This,riid,ppParent) \
    ( (This)->lpVtbl -> GetParent(This,riid,ppParent) ) 


#define IDXGIAdapter1_EnumOutputs(This,Output,ppOutput) \
    ( (This)->lpVtbl -> EnumOutputs(This,Output,ppOutput) ) 


#define IDXGIAdapter1_CheckInterfaceSupport(This,InterfaceName,pUMDVersion) \
    ( (This)->lpVtbl -> CheckInterfaceSupport(This,InterfaceName,pUMDVersion) ) 


--]]


local IDXGIOutput = ffi.typeof("IDXGIOutput")
local IDXGIOutput_mt = {
    __tostring = function(self)
        local desc = self:GetDescription();
        return tostring(desc)
    end,

    __index = {
        GetDescription = function(self)
            local pDesc = ffi.new("DXGI_OUTPUT_DESC")
            self.lpVtbl.GetDesc(self,pDesc)
            return pDesc;
        end,

        GetDisplayModes = function(self, EnumFormat, Flags)
            EnumFormat = EnumFormat or ffi.C.DXGI_FORMAT_R8G8B8A8_UNORM;
            Flags = Flags or 0;

            local Flags = 0;
            local pNumModes = ffi.new("UINT[1]");
            local pDesc = nil;

            -- First find out how many modes there are
            local hr = self.lpVtbl.GetDisplayModeList(self,EnumFormat,Flags,pNumModes,pDesc) 

            if hr~= 0 then
                return nil, hr
            end

            -- now that we know how many there are, call allocate an array
            -- to hold the values, and call again.
            pDesc = ffi.new("DXGI_MODE_DESC[?]",pNumModes[0])
            local hr = self.lpVtbl.GetDisplayModeList(self,EnumFormat,Flags,pNumModes,pDesc) 

            if hr~= 0 then
                return nil, hr
            end

            return pDesc, pNumModes[0];
        end,

        WaitForVBlank = function(self)
            return self.lpVtbl.WaitForVBlank(self)
        end,
    },
}
ffi.metatype(IDXGIOutput, IDXGIOutput_mt)


--[[
#define IDXGIOutput_QueryInterface(This,riid,ppvObject) \
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IDXGIOutput_AddRef(This)    \
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IDXGIOutput_Release(This)   \
    ( (This)->lpVtbl -> Release(This) ) 


#define IDXGIOutput_SetPrivateData(This,Name,DataSize,pData)    \
    ( (This)->lpVtbl -> SetPrivateData(This,Name,DataSize,pData) ) 

#define IDXGIOutput_SetPrivateDataInterface(This,Name,pUnknown) \
    ( (This)->lpVtbl -> SetPrivateDataInterface(This,Name,pUnknown) ) 

#define IDXGIOutput_GetPrivateData(This,Name,pDataSize,pData)   \
    ( (This)->lpVtbl -> GetPrivateData(This,Name,pDataSize,pData) ) 

#define IDXGIOutput_GetParent(This,riid,ppParent)   \
    ( (This)->lpVtbl -> GetParent(This,riid,ppParent) ) 




#define IDXGIOutput_FindClosestMatchingMode(This,pModeToMatch,pClosestMatch,pConcernedDevice)   \
    ( (This)->lpVtbl -> FindClosestMatchingMode(This,pModeToMatch,pClosestMatch,pConcernedDevice) ) 


#define IDXGIOutput_TakeOwnership(This,pDevice,Exclusive)   \
    ( (This)->lpVtbl -> TakeOwnership(This,pDevice,Exclusive) ) 

#define IDXGIOutput_ReleaseOwnership(This)  \
    ( (This)->lpVtbl -> ReleaseOwnership(This) ) 

#define IDXGIOutput_GetGammaControlCapabilities(This,pGammaCaps)    \
    ( (This)->lpVtbl -> GetGammaControlCapabilities(This,pGammaCaps) ) 

#define IDXGIOutput_SetGammaControl(This,pArray)    \
    ( (This)->lpVtbl -> SetGammaControl(This,pArray) ) 

#define IDXGIOutput_GetGammaControl(This,pArray)    \
    ( (This)->lpVtbl -> GetGammaControl(This,pArray) ) 

#define IDXGIOutput_SetDisplaySurface(This,pScanoutSurface) \
    ( (This)->lpVtbl -> SetDisplaySurface(This,pScanoutSurface) ) 

#define IDXGIOutput_GetDisplaySurfaceData(This,pDestination)    \
    ( (This)->lpVtbl -> GetDisplaySurfaceData(This,pDestination) ) 

#define IDXGIOutput_GetFrameStatistics(This,pStats) \
    ( (This)->lpVtbl -> GetFrameStatistics(This,pStats) ) 
--]]


return {
    IDXGIAdapter1 = IDXGIAdapter1,
    IDXGIFactory1 = IDXGIFactory1,
    IDXGIOutput = IDXGIOutput,
}