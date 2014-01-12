
local ffi = require("ffi")

local WTypes = require("WTypes")
local dxgiformat = require("dxgitype")
local IUnknown = require("IUnknown")
local WinNT = require("WinNT")
local core_string = require("core_string_l1_1_0")




ffi.cdef[[
/* Forward Declarations */ 

typedef struct IDXGIObject IDXGIObject;
typedef struct IDXGIDeviceSubObject IDXGIDeviceSubObject;
typedef struct IDXGIResource IDXGIResource;
typedef struct IDXGIKeyedMutex IDXGIKeyedMutex;
typedef struct IDXGISurface IDXGISurface;
typedef struct IDXGISurface1 IDXGISurface1;
typedef struct IDXGIAdapter IDXGIAdapter;
typedef struct IDXGIOutput IDXGIOutput;
typedef struct IDXGISwapChain IDXGISwapChain;
typedef struct IDXGIFactory IDXGIFactory;
typedef struct IDXGIDevice IDXGIDevice;
typedef struct IDXGIFactory1 IDXGIFactory1;
typedef struct IDXGIAdapter1 IDXGIAdapter1;
typedef struct IDXGIDevice1 IDXGIDevice1;
]]






--[=[
-- These are included in dxgitype.lua

ffi.cdef[[
static const int DXGI_CPU_ACCESS_NONE = 0;

static const int DXGI_CPU_ACCESS_DYNAMIC    = 1;
static const int DXGI_CPU_ACCESS_READ_WRITE = 2;
static const int DXGI_CPU_ACCESS_SCRATCH    = 3;
static const int DXGI_CPU_ACCESS_FIELD      = 15;


ffi.cdef[[
static const int DXGI_USAGE_SHADER_INPUT    =          ( 1L << (0 + 4) );
static const int DXGI_USAGE_RENDER_TARGET_OUTPUT =    ( 1L << (1 + 4) );
static const int DXGI_USAGE_BACK_BUFFER          =    ( 1L << (2 + 4) );
static const int DXGI_USAGE_SHARED               =    ( 1L << (3 + 4) );
static const int DXGI_USAGE_READ_ONLY            =    ( 1L << (4 + 4) );
static const int DXGI_USAGE_DISCARD_ON_PRESENT   =    ( 1L << (5 + 4) );
static const int DXGI_USAGE_UNORDERED_ACCESS     =    ( 1L << (6 + 4) );
]]
--]=]

ffi.cdef[[
typedef UINT DXGI_USAGE;
]]

ffi.cdef[[
typedef struct DXGI_FRAME_STATISTICS
    {
    UINT PresentCount;
    UINT PresentRefreshCount;
    UINT SyncRefreshCount;
    LARGE_INTEGER SyncQPCTime;
    LARGE_INTEGER SyncGPUTime;
    } 	DXGI_FRAME_STATISTICS;

typedef struct DXGI_MAPPED_RECT
    {
    INT Pitch;
    BYTE *pBits;
    } 	DXGI_MAPPED_RECT;
]]


ffi.cdef[[
typedef struct DXGI_ADAPTER_DESC
    {
    WCHAR Description[ 128 ];
    UINT VendorId;
    UINT DeviceId;
    UINT SubSysId;
    UINT Revision;
    SIZE_T DedicatedVideoMemory;
    SIZE_T DedicatedSystemMemory;
    SIZE_T SharedSystemMemory;
    LUID AdapterLuid;
    } 	DXGI_ADAPTER_DESC;
]]
DXGI_ADAPTER_DESC = ffi.typeof("DXGI_ADAPTER_DESC")
DXGI_ADAPTER_DESC_mt = {
    __tostring = function(self)
        return ffi.string(core_string.toAnsi(self.Description))
    end,    
}
ffi.metatype(DXGI_ADAPTER_DESC, DXGI_ADAPTER_DESC_mt)



ffi.cdef[[
typedef struct DXGI_OUTPUT_DESC
    {
    WCHAR DeviceName[ 32 ];
    RECT DesktopCoordinates;
    BOOL AttachedToDesktop;
    DXGI_MODE_ROTATION Rotation;
    HMONITOR Monitor;
    } 	DXGI_OUTPUT_DESC;
]]
DXGI_OUTPUT_DESC = ffi.typeof("DXGI_OUTPUT_DESC")
DXGI_OUTPUT_DESC_mt = {
    __tostring = function(self)
        return ffi.string(core_string.toAnsi(self.DeviceName))
    end,

    __index = {
        Print = function(self)
            print("      Device Name: ", ffi.string(core_string.toAnsi(self.DeviceName)))
            print("   Desktop Coords: ", self.DesktopCoordinates)
            print("AttachedToDesktop: ", self.AttachedToDesktop)
            print("         Rotation: ", self.Rotation)
            print("          Monitor: ", self.Monitor)
        end,
    },
}
ffi.metatype(DXGI_OUTPUT_DESC, DXGI_OUTPUT_DESC_mt)


ffi.cdef[[
typedef struct DXGI_SHARED_RESOURCE
    {
    HANDLE Handle;
    } 	DXGI_SHARED_RESOURCE;

static const int	DXGI_RESOURCE_PRIORITY_MINIMUM	= 0x28000000;

static const int	DXGI_RESOURCE_PRIORITY_LOW	= 0x50000000;

static const int	DXGI_RESOURCE_PRIORITY_NORMAL	= 0x78000000;

static const int	DXGI_RESOURCE_PRIORITY_HIGH	= 0xa0000000;

static const int	DXGI_RESOURCE_PRIORITY_MAXIMUM	= 0xc8000000;
]]

ffi.cdef[[
typedef 
enum DXGI_RESIDENCY
    {	DXGI_RESIDENCY_FULLY_RESIDENT	= 1,
	DXGI_RESIDENCY_RESIDENT_IN_SHARED_MEMORY	= 2,
	DXGI_RESIDENCY_EVICTED_TO_DISK	= 3
    } 	DXGI_RESIDENCY;
]]

ffi.cdef[[
typedef struct DXGI_SURFACE_DESC
    {
    UINT Width;
    UINT Height;
    DXGI_FORMAT Format;
    DXGI_SAMPLE_DESC SampleDesc;
    } 	DXGI_SURFACE_DESC;
]]

ffi.cdef[[
typedef 
enum DXGI_SWAP_EFFECT
    {	DXGI_SWAP_EFFECT_DISCARD	= 0,
	DXGI_SWAP_EFFECT_SEQUENTIAL	= 1
    } 	DXGI_SWAP_EFFECT;

typedef 
enum DXGI_SWAP_CHAIN_FLAG
    {	DXGI_SWAP_CHAIN_FLAG_NONPREROTATED	= 1,
	DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH	= 2,
	DXGI_SWAP_CHAIN_FLAG_GDI_COMPATIBLE	= 4
    } 	DXGI_SWAP_CHAIN_FLAG;

typedef struct DXGI_SWAP_CHAIN_DESC
    {
    DXGI_MODE_DESC BufferDesc;
    DXGI_SAMPLE_DESC SampleDesc;
    DXGI_USAGE BufferUsage;
    UINT BufferCount;
    HWND OutputWindow;
    BOOL Windowed;
    DXGI_SWAP_EFFECT SwapEffect;
    UINT Flags;
    } 	DXGI_SWAP_CHAIN_DESC;
]]




IID_IDXGIObject = UUIDFromString("aec22fb8-76f3-4639-9be0-28eb43a67a2e")

ffi.cdef[[
    typedef struct IDXGIObjectVtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IDXGIObject * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
              void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IDXGIObject * This);
        
        ULONG ( __stdcall *Release )( 
            IDXGIObject * This);
        
        HRESULT ( __stdcall *SetPrivateData )( 
            IDXGIObject * This,
            /* [in] */ REFGUID Name,
            /* [in] */ UINT DataSize,
            /* [in] */ const void *pData);
        
        HRESULT ( __stdcall *SetPrivateDataInterface )( 
            IDXGIObject * This,
            /* [in] */ REFGUID Name,
            /* [in] */ const IUnknown *pUnknown);
        
        HRESULT ( __stdcall *GetPrivateData )( 
            IDXGIObject * This,
            /* [in] */ REFGUID Name,
            /* [out][in] */ UINT *pDataSize,
            /* [out] */ void *pData);
        
        HRESULT ( __stdcall *GetParent )( 
            IDXGIObject * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppParent);
        
            } IDXGIObjectVtbl;

    struct IDXGIObject
    {
        const struct IDXGIObjectVtbl *lpVtbl;
    };
]]
    

--[[
#define IDXGIObject_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IDXGIObject_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IDXGIObject_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IDXGIObject_SetPrivateData(This,Name,DataSize,pData)	\
    ( (This)->lpVtbl -> SetPrivateData(This,Name,DataSize,pData) ) 

#define IDXGIObject_SetPrivateDataInterface(This,Name,pUnknown)	\
    ( (This)->lpVtbl -> SetPrivateDataInterface(This,Name,pUnknown) ) 

#define IDXGIObject_GetPrivateData(This,Name,pDataSize,pData)	\
    ( (This)->lpVtbl -> GetPrivateData(This,Name,pDataSize,pData) ) 

#define IDXGIObject_GetParent(This,riid,ppParent)	\
    ( (This)->lpVtbl -> GetParent(This,riid,ppParent) ) 
--]]




IID_IDXGIDeviceSubObject = UUIDFromString("3d3e0379-f9de-4d58-bb6c-18d62992f1a6")

ffi.cdef[[
    typedef struct IDXGIDeviceSubObjectVtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IDXGIDeviceSubObject * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
              void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IDXGIDeviceSubObject * This);
        
        ULONG ( __stdcall *Release )( 
            IDXGIDeviceSubObject * This);
        
        HRESULT ( __stdcall *SetPrivateData )( 
            IDXGIDeviceSubObject * This,
            /* [in] */ REFGUID Name,
            /* [in] */ UINT DataSize,
            /* [in] */ const void *pData);
        
        HRESULT ( __stdcall *SetPrivateDataInterface )( 
            IDXGIDeviceSubObject * This,
            /* [in] */ REFGUID Name,
            /* [in] */ const IUnknown *pUnknown);
        
        HRESULT ( __stdcall *GetPrivateData )( 
            IDXGIDeviceSubObject * This,
            /* [in] */ REFGUID Name,
            /* [out][in] */ UINT *pDataSize,
            /* [out] */ void *pData);
        
        HRESULT ( __stdcall *GetParent )( 
            IDXGIDeviceSubObject * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppParent);
        
        HRESULT ( __stdcall *GetDevice )( 
            IDXGIDeviceSubObject * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppDevice);
        
            } IDXGIDeviceSubObjectVtbl;

    struct IDXGIDeviceSubObject
    {
        const struct IDXGIDeviceSubObjectVtbl *lpVtbl;
    };
]]
    


--[[
#define IDXGIDeviceSubObject_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IDXGIDeviceSubObject_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IDXGIDeviceSubObject_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IDXGIDeviceSubObject_SetPrivateData(This,Name,DataSize,pData)	\
    ( (This)->lpVtbl -> SetPrivateData(This,Name,DataSize,pData) ) 

#define IDXGIDeviceSubObject_SetPrivateDataInterface(This,Name,pUnknown)	\
    ( (This)->lpVtbl -> SetPrivateDataInterface(This,Name,pUnknown) ) 

#define IDXGIDeviceSubObject_GetPrivateData(This,Name,pDataSize,pData)	\
    ( (This)->lpVtbl -> GetPrivateData(This,Name,pDataSize,pData) ) 

#define IDXGIDeviceSubObject_GetParent(This,riid,ppParent)	\
    ( (This)->lpVtbl -> GetParent(This,riid,ppParent) ) 


#define IDXGIDeviceSubObject_GetDevice(This,riid,ppDevice)	\
    ( (This)->lpVtbl -> GetDevice(This,riid,ppDevice) ) 
--]]


IID_IDXGIResource = UUIDFromString("035f3ab4-482e-4e50-b41f-8a7f8bd8960b")
 
ffi.cdef[[
    typedef struct IDXGIResourceVtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IDXGIResource * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
              void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IDXGIResource * This);
        
        ULONG ( __stdcall *Release )( 
            IDXGIResource * This);
        
        HRESULT ( __stdcall *SetPrivateData )( 
            IDXGIResource * This,
            /* [in] */ REFGUID Name,
            /* [in] */ UINT DataSize,
            /* [in] */ const void *pData);
        
        HRESULT ( __stdcall *SetPrivateDataInterface )( 
            IDXGIResource * This,
            /* [in] */ REFGUID Name,
            /* [in] */ const IUnknown *pUnknown);
        
        HRESULT ( __stdcall *GetPrivateData )( 
            IDXGIResource * This,
            /* [in] */ REFGUID Name,
            /* [out][in] */ UINT *pDataSize,
            /* [out] */ void *pData);
        
        HRESULT ( __stdcall *GetParent )( 
            IDXGIResource * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppParent);
        
        HRESULT ( __stdcall *GetDevice )( 
            IDXGIResource * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppDevice);
        
        HRESULT ( __stdcall *GetSharedHandle )( 
            IDXGIResource * This,
            /* [out] */ HANDLE *pSharedHandle);
        
        HRESULT ( __stdcall *GetUsage )( 
            IDXGIResource * This,
            /* [out] */ DXGI_USAGE *pUsage);
        
        HRESULT ( __stdcall *SetEvictionPriority )( 
            IDXGIResource * This,
            /* [in] */ UINT EvictionPriority);
        
        HRESULT ( __stdcall *GetEvictionPriority )( 
            IDXGIResource * This,
            /* [retval][out] */ UINT *pEvictionPriority);
        
            } IDXGIResourceVtbl;

    struct IDXGIResource
    {
        const struct IDXGIResourceVtbl *lpVtbl;
    };
]]
    

--[[
#define IDXGIResource_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IDXGIResource_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IDXGIResource_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IDXGIResource_SetPrivateData(This,Name,DataSize,pData)	\
    ( (This)->lpVtbl -> SetPrivateData(This,Name,DataSize,pData) ) 

#define IDXGIResource_SetPrivateDataInterface(This,Name,pUnknown)	\
    ( (This)->lpVtbl -> SetPrivateDataInterface(This,Name,pUnknown) ) 

#define IDXGIResource_GetPrivateData(This,Name,pDataSize,pData)	\
    ( (This)->lpVtbl -> GetPrivateData(This,Name,pDataSize,pData) ) 

#define IDXGIResource_GetParent(This,riid,ppParent)	\
    ( (This)->lpVtbl -> GetParent(This,riid,ppParent) ) 


#define IDXGIResource_GetDevice(This,riid,ppDevice)	\
    ( (This)->lpVtbl -> GetDevice(This,riid,ppDevice) ) 


#define IDXGIResource_GetSharedHandle(This,pSharedHandle)	\
    ( (This)->lpVtbl -> GetSharedHandle(This,pSharedHandle) ) 

#define IDXGIResource_GetUsage(This,pUsage)	\
    ( (This)->lpVtbl -> GetUsage(This,pUsage) ) 

#define IDXGIResource_SetEvictionPriority(This,EvictionPriority)	\
    ( (This)->lpVtbl -> SetEvictionPriority(This,EvictionPriority) ) 

#define IDXGIResource_GetEvictionPriority(This,pEvictionPriority)	\
    ( (This)->lpVtbl -> GetEvictionPriority(This,pEvictionPriority) ) 
--]]




IID_IDXGIKeyedMutex = UUIDFromString("9d8e1289-d7b3-465f-8126-250e349af85d")

ffi.cdef[[

    typedef struct IDXGIKeyedMutexVtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IDXGIKeyedMutex * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
              void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IDXGIKeyedMutex * This);
        
        ULONG ( __stdcall *Release )( 
            IDXGIKeyedMutex * This);
        
        HRESULT ( __stdcall *SetPrivateData )( 
            IDXGIKeyedMutex * This,
            /* [in] */ REFGUID Name,
            /* [in] */ UINT DataSize,
            /* [in] */ const void *pData);
        
        HRESULT ( __stdcall *SetPrivateDataInterface )( 
            IDXGIKeyedMutex * This,
            /* [in] */ REFGUID Name,
            /* [in] */ const IUnknown *pUnknown);
        
        HRESULT ( __stdcall *GetPrivateData )( 
            IDXGIKeyedMutex * This,
            /* [in] */ REFGUID Name,
            /* [out][in] */ UINT *pDataSize,
            /* [out] */ void *pData);
        
        HRESULT ( __stdcall *GetParent )( 
            IDXGIKeyedMutex * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppParent);
        
        HRESULT ( __stdcall *GetDevice )( 
            IDXGIKeyedMutex * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppDevice);
        
        HRESULT ( __stdcall *AcquireSync )( 
            IDXGIKeyedMutex * This,
            /* [in] */ UINT64 Key,
            /* [in] */ DWORD dwMilliseconds);
        
        HRESULT ( __stdcall *ReleaseSync )( 
            IDXGIKeyedMutex * This,
            /* [in] */ UINT64 Key);
        
            } IDXGIKeyedMutexVtbl;

    struct IDXGIKeyedMutex
    {
        const struct IDXGIKeyedMutexVtbl *lpVtbl;
    };
]]
    

--[[

#define IDXGIKeyedMutex_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IDXGIKeyedMutex_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IDXGIKeyedMutex_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IDXGIKeyedMutex_SetPrivateData(This,Name,DataSize,pData)	\
    ( (This)->lpVtbl -> SetPrivateData(This,Name,DataSize,pData) ) 

#define IDXGIKeyedMutex_SetPrivateDataInterface(This,Name,pUnknown)	\
    ( (This)->lpVtbl -> SetPrivateDataInterface(This,Name,pUnknown) ) 

#define IDXGIKeyedMutex_GetPrivateData(This,Name,pDataSize,pData)	\
    ( (This)->lpVtbl -> GetPrivateData(This,Name,pDataSize,pData) ) 

#define IDXGIKeyedMutex_GetParent(This,riid,ppParent)	\
    ( (This)->lpVtbl -> GetParent(This,riid,ppParent) ) 


#define IDXGIKeyedMutex_GetDevice(This,riid,ppDevice)	\
    ( (This)->lpVtbl -> GetDevice(This,riid,ppDevice) ) 


#define IDXGIKeyedMutex_AcquireSync(This,Key,dwMilliseconds)	\
    ( (This)->lpVtbl -> AcquireSync(This,Key,dwMilliseconds) ) 

#define IDXGIKeyedMutex_ReleaseSync(This,Key)	\
    ( (This)->lpVtbl -> ReleaseSync(This,Key) ) 
--]]



ffi.cdef[[
static const int	DXGI_MAP_READ	= 1UL;
static const int	DXGI_MAP_WRITE	= 2UL;
static const int	DXGI_MAP_DISCARD	= 4UL;
]]




IID_IDXGISurface = UUIDFromString("cafcb56c-6ac3-4889-bf47-9e23bbd260ec")

ffi.cdef[[
    typedef struct IDXGISurfaceVtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IDXGISurface * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
              void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IDXGISurface * This);
        
        ULONG ( __stdcall *Release )( 
            IDXGISurface * This);
        
        HRESULT ( __stdcall *SetPrivateData )( 
            IDXGISurface * This,
            /* [in] */ REFGUID Name,
            /* [in] */ UINT DataSize,
            /* [in] */ const void *pData);
        
        HRESULT ( __stdcall *SetPrivateDataInterface )( 
            IDXGISurface * This,
            /* [in] */ REFGUID Name,
            /* [in] */ const IUnknown *pUnknown);
        
        HRESULT ( __stdcall *GetPrivateData )( 
            IDXGISurface * This,
            /* [in] */ REFGUID Name,
            /* [out][in] */ UINT *pDataSize,
            /* [out] */ void *pData);
        
        HRESULT ( __stdcall *GetParent )( 
            IDXGISurface * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppParent);
        
        HRESULT ( __stdcall *GetDevice )( 
            IDXGISurface * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppDevice);
        
        HRESULT ( __stdcall *GetDesc )( 
            IDXGISurface * This,
            /* [out] */ DXGI_SURFACE_DESC *pDesc);
        
        HRESULT ( __stdcall *Map )( 
            IDXGISurface * This,
            /* [out] */ DXGI_MAPPED_RECT *pLockedRect,
            /* [in] */ UINT MapFlags);
        
        HRESULT ( __stdcall *Unmap )( 
            IDXGISurface * This);
        
            } IDXGISurfaceVtbl;

    struct IDXGISurface
    {
        const struct IDXGISurfaceVtbl *lpVtbl;
    };
]]
    


--[[
#define IDXGISurface_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IDXGISurface_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IDXGISurface_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IDXGISurface_SetPrivateData(This,Name,DataSize,pData)	\
    ( (This)->lpVtbl -> SetPrivateData(This,Name,DataSize,pData) ) 

#define IDXGISurface_SetPrivateDataInterface(This,Name,pUnknown)	\
    ( (This)->lpVtbl -> SetPrivateDataInterface(This,Name,pUnknown) ) 

#define IDXGISurface_GetPrivateData(This,Name,pDataSize,pData)	\
    ( (This)->lpVtbl -> GetPrivateData(This,Name,pDataSize,pData) ) 

#define IDXGISurface_GetParent(This,riid,ppParent)	\
    ( (This)->lpVtbl -> GetParent(This,riid,ppParent) ) 


#define IDXGISurface_GetDevice(This,riid,ppDevice)	\
    ( (This)->lpVtbl -> GetDevice(This,riid,ppDevice) ) 


#define IDXGISurface_GetDesc(This,pDesc)	\
    ( (This)->lpVtbl -> GetDesc(This,pDesc) ) 

#define IDXGISurface_Map(This,pLockedRect,MapFlags)	\
    ( (This)->lpVtbl -> Map(This,pLockedRect,MapFlags) ) 

#define IDXGISurface_Unmap(This)	\
    ( (This)->lpVtbl -> Unmap(This) ) 
--]]





IID_IDXGISurface1 = UUIDFromString("4AE63092-6327-4c1b-80AE-BFE12EA32B86")


ffi.cdef[[
    typedef struct IDXGISurface1Vtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IDXGISurface1 * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
              void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IDXGISurface1 * This);
        
        ULONG ( __stdcall *Release )( 
            IDXGISurface1 * This);
        
        HRESULT ( __stdcall *SetPrivateData )( 
            IDXGISurface1 * This,
            /* [in] */ REFGUID Name,
            /* [in] */ UINT DataSize,
            /* [in] */ const void *pData);
        
        HRESULT ( __stdcall *SetPrivateDataInterface )( 
            IDXGISurface1 * This,
            /* [in] */ REFGUID Name,
            /* [in] */ const IUnknown *pUnknown);
        
        HRESULT ( __stdcall *GetPrivateData )( 
            IDXGISurface1 * This,
            /* [in] */ REFGUID Name,
            /* [out][in] */ UINT *pDataSize,
            /* [out] */ void *pData);
        
        HRESULT ( __stdcall *GetParent )( 
            IDXGISurface1 * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppParent);
        
        HRESULT ( __stdcall *GetDevice )( 
            IDXGISurface1 * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppDevice);
        
        HRESULT ( __stdcall *GetDesc )( 
            IDXGISurface1 * This,
            /* [out] */ DXGI_SURFACE_DESC *pDesc);
        
        HRESULT ( __stdcall *Map )( 
            IDXGISurface1 * This,
            /* [out] */ DXGI_MAPPED_RECT *pLockedRect,
            /* [in] */ UINT MapFlags);
        
        HRESULT ( __stdcall *Unmap )( 
            IDXGISurface1 * This);
        
        HRESULT ( __stdcall *GetDC )( 
            IDXGISurface1 * This,
            /* [in] */ BOOL Discard,
            /* [out] */ HDC *phdc);
        
        HRESULT ( __stdcall *ReleaseDC )( 
            IDXGISurface1 * This,
            /* [in] */ RECT *pDirtyRect);
        
            } IDXGISurface1Vtbl;

    struct IDXGISurface1
    {
        const struct IDXGISurface1Vtbl *lpVtbl;
    };
]]
    

--[[
#define IDXGISurface1_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IDXGISurface1_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IDXGISurface1_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IDXGISurface1_SetPrivateData(This,Name,DataSize,pData)	\
    ( (This)->lpVtbl -> SetPrivateData(This,Name,DataSize,pData) ) 

#define IDXGISurface1_SetPrivateDataInterface(This,Name,pUnknown)	\
    ( (This)->lpVtbl -> SetPrivateDataInterface(This,Name,pUnknown) ) 

#define IDXGISurface1_GetPrivateData(This,Name,pDataSize,pData)	\
    ( (This)->lpVtbl -> GetPrivateData(This,Name,pDataSize,pData) ) 

#define IDXGISurface1_GetParent(This,riid,ppParent)	\
    ( (This)->lpVtbl -> GetParent(This,riid,ppParent) ) 


#define IDXGISurface1_GetDevice(This,riid,ppDevice)	\
    ( (This)->lpVtbl -> GetDevice(This,riid,ppDevice) ) 


#define IDXGISurface1_GetDesc(This,pDesc)	\
    ( (This)->lpVtbl -> GetDesc(This,pDesc) ) 

#define IDXGISurface1_Map(This,pLockedRect,MapFlags)	\
    ( (This)->lpVtbl -> Map(This,pLockedRect,MapFlags) ) 

#define IDXGISurface1_Unmap(This)	\
    ( (This)->lpVtbl -> Unmap(This) ) 


#define IDXGISurface1_GetDC(This,Discard,phdc)	\
    ( (This)->lpVtbl -> GetDC(This,Discard,phdc) ) 

#define IDXGISurface1_ReleaseDC(This,pDirtyRect)	\
    ( (This)->lpVtbl -> ReleaseDC(This,pDirtyRect) ) 
--]]






IID_IDXGIAdapter = UUIDFromString("2411e7e1-12ac-4ccf-bd14-9798e8534dc0")


ffi.cdef[[
    typedef struct IDXGIAdapterVtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IDXGIAdapter * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
              void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IDXGIAdapter * This);
        
        ULONG ( __stdcall *Release )( 
            IDXGIAdapter * This);
        
        HRESULT ( __stdcall *SetPrivateData )( 
            IDXGIAdapter * This,
            /* [in] */ REFGUID Name,
            /* [in] */ UINT DataSize,
            /* [in] */ const void *pData);
        
        HRESULT ( __stdcall *SetPrivateDataInterface )( 
            IDXGIAdapter * This,
            /* [in] */ REFGUID Name,
            /* [in] */ const IUnknown *pUnknown);
        
        HRESULT ( __stdcall *GetPrivateData )( 
            IDXGIAdapter * This,
            /* [in] */ REFGUID Name,
            /* [out][in] */ UINT *pDataSize,
            /* [out] */ void *pData);
        
        HRESULT ( __stdcall *GetParent )( 
            IDXGIAdapter * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppParent);
        
        HRESULT ( __stdcall *EnumOutputs )( 
            IDXGIAdapter * This,
            /* [in] */ UINT Output,
            /* [out][in] */ IDXGIOutput **ppOutput);
        
        HRESULT ( __stdcall *GetDesc )( 
            IDXGIAdapter * This,
            /* [out] */ DXGI_ADAPTER_DESC *pDesc);
        
        HRESULT ( __stdcall *CheckInterfaceSupport )( 
            IDXGIAdapter * This,
            /* [in] */ REFGUID InterfaceName,
            /* [out] */ LARGE_INTEGER *pUMDVersion);
        
            } IDXGIAdapterVtbl;

    struct IDXGIAdapter
    {
        const struct IDXGIAdapterVtbl *lpVtbl;
    };
]]
    


--[[
#define IDXGIAdapter_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IDXGIAdapter_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IDXGIAdapter_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IDXGIAdapter_SetPrivateData(This,Name,DataSize,pData)	\
    ( (This)->lpVtbl -> SetPrivateData(This,Name,DataSize,pData) ) 

#define IDXGIAdapter_SetPrivateDataInterface(This,Name,pUnknown)	\
    ( (This)->lpVtbl -> SetPrivateDataInterface(This,Name,pUnknown) ) 

#define IDXGIAdapter_GetPrivateData(This,Name,pDataSize,pData)	\
    ( (This)->lpVtbl -> GetPrivateData(This,Name,pDataSize,pData) ) 

#define IDXGIAdapter_GetParent(This,riid,ppParent)	\
    ( (This)->lpVtbl -> GetParent(This,riid,ppParent) ) 


#define IDXGIAdapter_EnumOutputs(This,Output,ppOutput)	\
    ( (This)->lpVtbl -> EnumOutputs(This,Output,ppOutput) ) 

#define IDXGIAdapter_GetDesc(This,pDesc)	\
    ( (This)->lpVtbl -> GetDesc(This,pDesc) ) 

#define IDXGIAdapter_CheckInterfaceSupport(This,InterfaceName,pUMDVersion)	\
    ( (This)->lpVtbl -> CheckInterfaceSupport(This,InterfaceName,pUMDVersion) ) 
--]]

ffi.cdef[[
static const int	DXGI_ENUM_MODES_INTERLACED	= 1UL;

static const int	DXGI_ENUM_MODES_SCALING	= 2UL;
]]




IID_IDXGIOutput = UUIDFromString("ae02eedb-c735-4690-8d52-5a8dc20213aa")

ffi.cdef[[
    typedef struct IDXGIOutputVtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IDXGIOutput * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
              void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IDXGIOutput * This);
        
        ULONG ( __stdcall *Release )( 
            IDXGIOutput * This);
        
        HRESULT ( __stdcall *SetPrivateData )( 
            IDXGIOutput * This,
            /* [in] */ REFGUID Name,
            /* [in] */ UINT DataSize,
            /* [in] */ const void *pData);
        
        HRESULT ( __stdcall *SetPrivateDataInterface )( 
            IDXGIOutput * This,
            /* [in] */ REFGUID Name,
            /* [in] */ const IUnknown *pUnknown);
        
        HRESULT ( __stdcall *GetPrivateData )( 
            IDXGIOutput * This,
            /* [in] */ REFGUID Name,
            /* [out][in] */ UINT *pDataSize,
            /* [out] */ void *pData);
        
        HRESULT ( __stdcall *GetParent )( 
            IDXGIOutput * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppParent);
        
        HRESULT ( __stdcall *GetDesc )( 
            IDXGIOutput * This,
            /* [out] */ DXGI_OUTPUT_DESC *pDesc);
        
        HRESULT ( __stdcall *GetDisplayModeList )( 
            IDXGIOutput * This,
            /* [in] */ DXGI_FORMAT EnumFormat,
            /* [in] */ UINT Flags,
            /* [out][in] */ UINT *pNumModes,
            /* [out] */ DXGI_MODE_DESC *pDesc);
        
        HRESULT ( __stdcall *FindClosestMatchingMode )( 
            IDXGIOutput * This,
            /* [in] */ const DXGI_MODE_DESC *pModeToMatch,
            /* [out] */ DXGI_MODE_DESC *pClosestMatch,
            /* [in] */ IUnknown *pConcernedDevice);
        
        HRESULT ( __stdcall *WaitForVBlank )( 
            IDXGIOutput * This);
        
        HRESULT ( __stdcall *TakeOwnership )( 
            IDXGIOutput * This,
            /* [in] */ IUnknown *pDevice,
            BOOL Exclusive);
        
        void ( __stdcall *ReleaseOwnership )( 
            IDXGIOutput * This);
        
        HRESULT ( __stdcall *GetGammaControlCapabilities )( 
            IDXGIOutput * This,
            /* [out] */ DXGI_GAMMA_CONTROL_CAPABILITIES *pGammaCaps);
        
        HRESULT ( __stdcall *SetGammaControl )( 
            IDXGIOutput * This,
            /* [in] */ const DXGI_GAMMA_CONTROL *pArray);
        
        HRESULT ( __stdcall *GetGammaControl )( 
            IDXGIOutput * This,
            /* [out] */ DXGI_GAMMA_CONTROL *pArray);
        
        HRESULT ( __stdcall *SetDisplaySurface )( 
            IDXGIOutput * This,
            /* [in] */ IDXGISurface *pScanoutSurface);
        
        HRESULT ( __stdcall *GetDisplaySurfaceData )( 
            IDXGIOutput * This,
            /* [in] */ IDXGISurface *pDestination);
        
        HRESULT ( __stdcall *GetFrameStatistics )( 
            IDXGIOutput * This,
            /* [out] */ DXGI_FRAME_STATISTICS *pStats);
        
            } IDXGIOutputVtbl;

    struct IDXGIOutput
    {
        const struct IDXGIOutputVtbl *lpVtbl;
    };
]]
    






ffi.cdef[[

static const int DXGI_MAX_SWAP_CHAIN_BUFFERS    = 16;
static const int DXGI_PRESENT_TEST              = 0x00000001;
static const int DXGI_PRESENT_DO_NOT_SEQUENCE   = 0x00000002;
static const int DXGI_PRESENT_RESTART           = 0x00000004;
]]



IID_IDXGISwapChain = UUIDFromString("310d36a0-d2e7-4c0a-aa04-6a9d23b8886a")

ffi.cdef[[
    typedef struct IDXGISwapChainVtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IDXGISwapChain * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
              void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IDXGISwapChain * This);
        
        ULONG ( __stdcall *Release )( 
            IDXGISwapChain * This);
        
        HRESULT ( __stdcall *SetPrivateData )( 
            IDXGISwapChain * This,
            /* [in] */ REFGUID Name,
            /* [in] */ UINT DataSize,
            /* [in] */ const void *pData);
        
        HRESULT ( __stdcall *SetPrivateDataInterface )( 
            IDXGISwapChain * This,
            /* [in] */ REFGUID Name,
            /* [in] */ const IUnknown *pUnknown);
        
        HRESULT ( __stdcall *GetPrivateData )( 
            IDXGISwapChain * This,
            /* [in] */ REFGUID Name,
            /* [out][in] */ UINT *pDataSize,
            /* [out] */ void *pData);
        
        HRESULT ( __stdcall *GetParent )( 
            IDXGISwapChain * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppParent);
        
        HRESULT ( __stdcall *GetDevice )( 
            IDXGISwapChain * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppDevice);
        
        HRESULT ( __stdcall *Present )( 
            IDXGISwapChain * This,
            /* [in] */ UINT SyncInterval,
            /* [in] */ UINT Flags);
        
        HRESULT ( __stdcall *GetBuffer )( 
            IDXGISwapChain * This,
            /* [in] */ UINT Buffer,
            /* [in] */ REFIID riid,
            /* [out][in] */ void **ppSurface);
        
        HRESULT ( __stdcall *SetFullscreenState )( 
            IDXGISwapChain * This,
            /* [in] */ BOOL Fullscreen,
            /* [in] */ IDXGIOutput *pTarget);
        
        HRESULT ( __stdcall *GetFullscreenState )( 
            IDXGISwapChain * This,
            /* [out] */ BOOL *pFullscreen,
            /* [out] */ IDXGIOutput **ppTarget);
        
        HRESULT ( __stdcall *GetDesc )( 
            IDXGISwapChain * This,
            /* [out] */ DXGI_SWAP_CHAIN_DESC *pDesc);
        
        HRESULT ( __stdcall *ResizeBuffers )( 
            IDXGISwapChain * This,
            /* [in] */ UINT BufferCount,
            /* [in] */ UINT Width,
            /* [in] */ UINT Height,
            /* [in] */ DXGI_FORMAT NewFormat,
            /* [in] */ UINT SwapChainFlags);
        
        HRESULT ( __stdcall *ResizeTarget )( 
            IDXGISwapChain * This,
            /* [in] */ const DXGI_MODE_DESC *pNewTargetParameters);
        
        HRESULT ( __stdcall *GetContainingOutput )( 
            IDXGISwapChain * This,
            IDXGIOutput **ppOutput);
        
        HRESULT ( __stdcall *GetFrameStatistics )( 
            IDXGISwapChain * This,
            /* [out] */ DXGI_FRAME_STATISTICS *pStats);
        
        HRESULT ( __stdcall *GetLastPresentCount )( 
            IDXGISwapChain * This,
            /* [out] */ UINT *pLastPresentCount);
        
            } IDXGISwapChainVtbl;

    struct IDXGISwapChain
    {
        const struct IDXGISwapChainVtbl *lpVtbl;
    };
]]
    


--[[
#define IDXGISwapChain_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IDXGISwapChain_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IDXGISwapChain_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IDXGISwapChain_SetPrivateData(This,Name,DataSize,pData)	\
    ( (This)->lpVtbl -> SetPrivateData(This,Name,DataSize,pData) ) 

#define IDXGISwapChain_SetPrivateDataInterface(This,Name,pUnknown)	\
    ( (This)->lpVtbl -> SetPrivateDataInterface(This,Name,pUnknown) ) 

#define IDXGISwapChain_GetPrivateData(This,Name,pDataSize,pData)	\
    ( (This)->lpVtbl -> GetPrivateData(This,Name,pDataSize,pData) ) 

#define IDXGISwapChain_GetParent(This,riid,ppParent)	\
    ( (This)->lpVtbl -> GetParent(This,riid,ppParent) ) 


#define IDXGISwapChain_GetDevice(This,riid,ppDevice)	\
    ( (This)->lpVtbl -> GetDevice(This,riid,ppDevice) ) 


#define IDXGISwapChain_Present(This,SyncInterval,Flags)	\
    ( (This)->lpVtbl -> Present(This,SyncInterval,Flags) ) 

#define IDXGISwapChain_GetBuffer(This,Buffer,riid,ppSurface)	\
    ( (This)->lpVtbl -> GetBuffer(This,Buffer,riid,ppSurface) ) 

#define IDXGISwapChain_SetFullscreenState(This,Fullscreen,pTarget)	\
    ( (This)->lpVtbl -> SetFullscreenState(This,Fullscreen,pTarget) ) 

#define IDXGISwapChain_GetFullscreenState(This,pFullscreen,ppTarget)	\
    ( (This)->lpVtbl -> GetFullscreenState(This,pFullscreen,ppTarget) ) 

#define IDXGISwapChain_GetDesc(This,pDesc)	\
    ( (This)->lpVtbl -> GetDesc(This,pDesc) ) 

#define IDXGISwapChain_ResizeBuffers(This,BufferCount,Width,Height,NewFormat,SwapChainFlags)	\
    ( (This)->lpVtbl -> ResizeBuffers(This,BufferCount,Width,Height,NewFormat,SwapChainFlags) ) 

#define IDXGISwapChain_ResizeTarget(This,pNewTargetParameters)	\
    ( (This)->lpVtbl -> ResizeTarget(This,pNewTargetParameters) ) 

#define IDXGISwapChain_GetContainingOutput(This,ppOutput)	\
    ( (This)->lpVtbl -> GetContainingOutput(This,ppOutput) ) 

#define IDXGISwapChain_GetFrameStatistics(This,pStats)	\
    ( (This)->lpVtbl -> GetFrameStatistics(This,pStats) ) 

#define IDXGISwapChain_GetLastPresentCount(This,pLastPresentCount)	\
    ( (This)->lpVtbl -> GetLastPresentCount(This,pLastPresentCount) ) 
--]]

ffi.cdef[[
static const int DXGI_MWA_NO_WINDOW_CHANGES    =  ( 1 << 0 );
static const int DXGI_MWA_NO_ALT_ENTER         =  ( 1 << 1 );
static const int DXGI_MWA_NO_PRINT_SCREEN      =  ( 1 << 2 );
static const int DXGI_MWA_VALID                =  ( 0x7 );
]]



IID_IDXGIFactory = UUIDFromString("7b7166ec-21c7-44ae-b21a-c9ae321ae369")


ffi.cdef[[
    typedef struct IDXGIFactoryVtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IDXGIFactory * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
              void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IDXGIFactory * This);
        
        ULONG ( __stdcall *Release )( 
            IDXGIFactory * This);
        
        HRESULT ( __stdcall *SetPrivateData )( 
            IDXGIFactory * This,
            /* [in] */ REFGUID Name,
            /* [in] */ UINT DataSize,
            /* [in] */ const void *pData);
        
        HRESULT ( __stdcall *SetPrivateDataInterface )( 
            IDXGIFactory * This,
            /* [in] */ REFGUID Name,
            /* [in] */ const IUnknown *pUnknown);
        
        HRESULT ( __stdcall *GetPrivateData )( 
            IDXGIFactory * This,
            /* [in] */ REFGUID Name,
            /* [out][in] */ UINT *pDataSize,
            /* [out] */ void *pData);
        
        HRESULT ( __stdcall *GetParent )( 
            IDXGIFactory * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppParent);
        
        HRESULT ( __stdcall *EnumAdapters )( 
            IDXGIFactory * This,
            /* [in] */ UINT Adapter,
            /* [out] */ IDXGIAdapter **ppAdapter);
        
        HRESULT ( __stdcall *MakeWindowAssociation )( 
            IDXGIFactory * This,
            HWND WindowHandle,
            UINT Flags);
        
        HRESULT ( __stdcall *GetWindowAssociation )( 
            IDXGIFactory * This,
            HWND *pWindowHandle);
        
        HRESULT ( __stdcall *CreateSwapChain )( 
            IDXGIFactory * This,
            IUnknown *pDevice,
            DXGI_SWAP_CHAIN_DESC *pDesc,
            IDXGISwapChain **ppSwapChain);
        
        HRESULT ( __stdcall *CreateSoftwareAdapter )( 
            IDXGIFactory * This,
            /* [in] */ HMODULE Module,
            /* [out] */ IDXGIAdapter **ppAdapter);
        
            } IDXGIFactoryVtbl;

    struct IDXGIFactory
    {
        const struct IDXGIFactoryVtbl *lpVtbl;
    };
]]
    

--[[
#define IDXGIFactory_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IDXGIFactory_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IDXGIFactory_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IDXGIFactory_SetPrivateData(This,Name,DataSize,pData)	\
    ( (This)->lpVtbl -> SetPrivateData(This,Name,DataSize,pData) ) 

#define IDXGIFactory_SetPrivateDataInterface(This,Name,pUnknown)	\
    ( (This)->lpVtbl -> SetPrivateDataInterface(This,Name,pUnknown) ) 

#define IDXGIFactory_GetPrivateData(This,Name,pDataSize,pData)	\
    ( (This)->lpVtbl -> GetPrivateData(This,Name,pDataSize,pData) ) 

#define IDXGIFactory_GetParent(This,riid,ppParent)	\
    ( (This)->lpVtbl -> GetParent(This,riid,ppParent) ) 


#define IDXGIFactory_EnumAdapters(This,Adapter,ppAdapter)	\
    ( (This)->lpVtbl -> EnumAdapters(This,Adapter,ppAdapter) ) 

#define IDXGIFactory_MakeWindowAssociation(This,WindowHandle,Flags)	\
    ( (This)->lpVtbl -> MakeWindowAssociation(This,WindowHandle,Flags) ) 

#define IDXGIFactory_GetWindowAssociation(This,pWindowHandle)	\
    ( (This)->lpVtbl -> GetWindowAssociation(This,pWindowHandle) ) 

#define IDXGIFactory_CreateSwapChain(This,pDevice,pDesc,ppSwapChain)	\
    ( (This)->lpVtbl -> CreateSwapChain(This,pDevice,pDesc,ppSwapChain) ) 

#define IDXGIFactory_CreateSoftwareAdapter(This,Module,ppAdapter)	\
    ( (This)->lpVtbl -> CreateSoftwareAdapter(This,Module,ppAdapter) ) 
--]]

ffi.cdef[[
HRESULT CreateDXGIFactory(REFIID riid, void **ppFactory);
HRESULT CreateDXGIFactory1(REFIID riid, void **ppFactory);
]]



IID_IDXGIDevice = UUIDFromString("54ec77fa-1377-44e6-8c32-88fd5f44c84c")


ffi.cdef[[
    typedef struct IDXGIDeviceVtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IDXGIDevice * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
              void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IDXGIDevice * This);
        
        ULONG ( __stdcall *Release )( 
            IDXGIDevice * This);
        
        HRESULT ( __stdcall *SetPrivateData )( 
            IDXGIDevice * This,
            /* [in] */ REFGUID Name,
            /* [in] */ UINT DataSize,
            /* [in] */ const void *pData);
        
        HRESULT ( __stdcall *SetPrivateDataInterface )( 
            IDXGIDevice * This,
            /* [in] */ REFGUID Name,
            /* [in] */ const IUnknown *pUnknown);
        
        HRESULT ( __stdcall *GetPrivateData )( 
            IDXGIDevice * This,
            /* [in] */ REFGUID Name,
            /* [out][in] */ UINT *pDataSize,
            /* [out] */ void *pData);
        
        HRESULT ( __stdcall *GetParent )( 
            IDXGIDevice * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppParent);
        
        HRESULT ( __stdcall *GetAdapter )( 
            IDXGIDevice * This,
            /* [out] */ IDXGIAdapter **pAdapter);
        
        HRESULT ( __stdcall *CreateSurface )( 
            IDXGIDevice * This,
            /* [in] */ const DXGI_SURFACE_DESC *pDesc,
            /* [in] */ UINT NumSurfaces,
            /* [in] */ DXGI_USAGE Usage,
            /* [in] */ const DXGI_SHARED_RESOURCE *pSharedResource,
            /* [out] */ IDXGISurface **ppSurface);
        
        HRESULT ( __stdcall *QueryResourceResidency )( 
            IDXGIDevice * This,
            /* [size_is][in] */ IUnknown *const *ppResources,
            /* [size_is][out] */ DXGI_RESIDENCY *pResidencyStatus,
            /* [in] */ UINT NumResources);
        
        HRESULT ( __stdcall *SetGPUThreadPriority )( 
            IDXGIDevice * This,
            /* [in] */ INT Priority);
        
        HRESULT ( __stdcall *GetGPUThreadPriority )( 
            IDXGIDevice * This,
            /* [retval][out] */ INT *pPriority);
        
            } IDXGIDeviceVtbl;

    struct IDXGIDevice
    {
        const struct IDXGIDeviceVtbl *lpVtbl;
    };
]]
    

--[[
#define IDXGIDevice_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IDXGIDevice_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IDXGIDevice_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IDXGIDevice_SetPrivateData(This,Name,DataSize,pData)	\
    ( (This)->lpVtbl -> SetPrivateData(This,Name,DataSize,pData) ) 

#define IDXGIDevice_SetPrivateDataInterface(This,Name,pUnknown)	\
    ( (This)->lpVtbl -> SetPrivateDataInterface(This,Name,pUnknown) ) 

#define IDXGIDevice_GetPrivateData(This,Name,pDataSize,pData)	\
    ( (This)->lpVtbl -> GetPrivateData(This,Name,pDataSize,pData) ) 

#define IDXGIDevice_GetParent(This,riid,ppParent)	\
    ( (This)->lpVtbl -> GetParent(This,riid,ppParent) ) 


#define IDXGIDevice_GetAdapter(This,pAdapter)	\
    ( (This)->lpVtbl -> GetAdapter(This,pAdapter) ) 

#define IDXGIDevice_CreateSurface(This,pDesc,NumSurfaces,Usage,pSharedResource,ppSurface)	\
    ( (This)->lpVtbl -> CreateSurface(This,pDesc,NumSurfaces,Usage,pSharedResource,ppSurface) ) 

#define IDXGIDevice_QueryResourceResidency(This,ppResources,pResidencyStatus,NumResources)	\
    ( (This)->lpVtbl -> QueryResourceResidency(This,ppResources,pResidencyStatus,NumResources) ) 

#define IDXGIDevice_SetGPUThreadPriority(This,Priority)	\
    ( (This)->lpVtbl -> SetGPUThreadPriority(This,Priority) ) 

#define IDXGIDevice_GetGPUThreadPriority(This,pPriority)	\
    ( (This)->lpVtbl -> GetGPUThreadPriority(This,pPriority) ) 
--]]




ffi.cdef[[
typedef 
enum DXGI_ADAPTER_FLAG
    {	DXGI_ADAPTER_FLAG_NONE	= 0,
	DXGI_ADAPTER_FLAG_REMOTE	= 1,
	DXGI_ADAPTER_FLAG_FORCE_DWORD	= 0xffffffff
    } 	DXGI_ADAPTER_FLAG;

typedef struct DXGI_ADAPTER_DESC1
    {
    WCHAR Description[ 128 ];
    UINT VendorId;
    UINT DeviceId;
    UINT SubSysId;
    UINT Revision;
    SIZE_T DedicatedVideoMemory;
    SIZE_T DedicatedSystemMemory;
    SIZE_T SharedSystemMemory;
    LUID AdapterLuid;
    UINT Flags;
    } 	DXGI_ADAPTER_DESC1;
]]
DXGI_ADAPTER_DESC1 = ffi.typeof("DXGI_ADAPTER_DESC1")
DXGI_ADAPTER_DESC1_mt = {
    __tostring = function(self)
        return ffi.string(core_string.toAnsi(self.Description))
    end,    
}
ffi.metatype(DXGI_ADAPTER_DESC1, DXGI_ADAPTER_DESC1_mt)


ffi.cdef[[
typedef struct DXGI_DISPLAY_COLOR_SPACE
    {
    FLOAT PrimaryCoordinates[ 8 ][ 2 ];
    FLOAT WhitePoints[ 16 ][ 2 ];
    } 	DXGI_DISPLAY_COLOR_SPACE;
]]



IID_IDXGIFactory1 = UUIDFromString("770aae78-f26f-4dba-a829-253c83d1b387")


ffi.cdef[[
    typedef struct IDXGIFactory1Vtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IDXGIFactory1 * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
              void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IDXGIFactory1 * This);
        
        ULONG ( __stdcall *Release )( 
            IDXGIFactory1 * This);
        
        HRESULT ( __stdcall *SetPrivateData )( 
            IDXGIFactory1 * This,
            /* [in] */ REFGUID Name,
            /* [in] */ UINT DataSize,
            /* [in] */ const void *pData);
        
        HRESULT ( __stdcall *SetPrivateDataInterface )( 
            IDXGIFactory1 * This,
            /* [in] */ REFGUID Name,
            /* [in] */ const IUnknown *pUnknown);
        
        HRESULT ( __stdcall *GetPrivateData )( 
            IDXGIFactory1 * This,
            /* [in] */ REFGUID Name,
            /* [out][in] */ UINT *pDataSize,
            /* [out] */ void *pData);
        
        HRESULT ( __stdcall *GetParent )( 
            IDXGIFactory1 * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppParent);
        
        HRESULT ( __stdcall *EnumAdapters )( 
            IDXGIFactory1 * This,
            /* [in] */ UINT Adapter,
            /* [out] */ IDXGIAdapter **ppAdapter);
        
        HRESULT ( __stdcall *MakeWindowAssociation )( 
            IDXGIFactory1 * This,
            HWND WindowHandle,
            UINT Flags);
        
        HRESULT ( __stdcall *GetWindowAssociation )( 
            IDXGIFactory1 * This,
            HWND *pWindowHandle);
        
        HRESULT ( __stdcall *CreateSwapChain )( 
            IDXGIFactory1 * This,
            IUnknown *pDevice,
            DXGI_SWAP_CHAIN_DESC *pDesc,
            IDXGISwapChain **ppSwapChain);
        
        HRESULT ( __stdcall *CreateSoftwareAdapter )( 
            IDXGIFactory1 * This,
            /* [in] */ HMODULE Module,
            /* [out] */ IDXGIAdapter **ppAdapter);
        
        HRESULT ( __stdcall *EnumAdapters1 )( 
            IDXGIFactory1 * This,
            /* [in] */ UINT Adapter,
            /* [out] */ IDXGIAdapter1 **ppAdapter);
        
        BOOL ( __stdcall *IsCurrent )( 
            IDXGIFactory1 * This);
        
            } IDXGIFactory1Vtbl;

    struct IDXGIFactory1
    {
        const struct IDXGIFactory1Vtbl *lpVtbl;
    };
]]



IID_IDXGIAdapter1 = UUIDFromString("29038f61-3839-4626-91fd-086879011a05")


ffi.cdef[[
    typedef struct IDXGIAdapter1Vtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IDXGIAdapter1 * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
              void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IDXGIAdapter1 * This);
        
        ULONG ( __stdcall *Release )( 
            IDXGIAdapter1 * This);
        
        HRESULT ( __stdcall *SetPrivateData )( 
            IDXGIAdapter1 * This,
            /* [in] */ REFGUID Name,
            /* [in] */ UINT DataSize,
            /* [in] */ const void *pData);
        
        HRESULT ( __stdcall *SetPrivateDataInterface )( 
            IDXGIAdapter1 * This,
            /* [in] */ REFGUID Name,
            /* [in] */ const IUnknown *pUnknown);
        
        HRESULT ( __stdcall *GetPrivateData )( 
            IDXGIAdapter1 * This,
            /* [in] */ REFGUID Name,
            /* [out][in] */ UINT *pDataSize,
            /* [out] */ void *pData);
        
        HRESULT ( __stdcall *GetParent )( 
            IDXGIAdapter1 * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppParent);
        
        HRESULT ( __stdcall *EnumOutputs )( 
            IDXGIAdapter1 * This,
            /* [in] */ UINT Output,
            /* [out][in] */ IDXGIOutput **ppOutput);
        
        HRESULT ( __stdcall *GetDesc )( 
            IDXGIAdapter1 * This,
            /* [out] */ DXGI_ADAPTER_DESC *pDesc);
        
        HRESULT ( __stdcall *CheckInterfaceSupport )( 
            IDXGIAdapter1 * This,
            /* [in] */ REFGUID InterfaceName,
            /* [out] */ LARGE_INTEGER *pUMDVersion);
        
        HRESULT ( __stdcall *GetDesc1 )( 
            IDXGIAdapter1 * This,
            /* [out] */ DXGI_ADAPTER_DESC1 *pDesc);
        
            } IDXGIAdapter1Vtbl;

    struct IDXGIAdapter1
    {
        const struct IDXGIAdapter1Vtbl *lpVtbl;
    };
]]
    

--[[
#define IDXGIAdapter1_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IDXGIAdapter1_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IDXGIAdapter1_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IDXGIAdapter1_SetPrivateData(This,Name,DataSize,pData)	\
    ( (This)->lpVtbl -> SetPrivateData(This,Name,DataSize,pData) ) 

#define IDXGIAdapter1_SetPrivateDataInterface(This,Name,pUnknown)	\
    ( (This)->lpVtbl -> SetPrivateDataInterface(This,Name,pUnknown) ) 

#define IDXGIAdapter1_GetPrivateData(This,Name,pDataSize,pData)	\
    ( (This)->lpVtbl -> GetPrivateData(This,Name,pDataSize,pData) ) 

#define IDXGIAdapter1_GetParent(This,riid,ppParent)	\
    ( (This)->lpVtbl -> GetParent(This,riid,ppParent) ) 


#define IDXGIAdapter1_EnumOutputs(This,Output,ppOutput)	\
    ( (This)->lpVtbl -> EnumOutputs(This,Output,ppOutput) ) 

#define IDXGIAdapter1_GetDesc(This,pDesc)	\
    ( (This)->lpVtbl -> GetDesc(This,pDesc) ) 

#define IDXGIAdapter1_CheckInterfaceSupport(This,InterfaceName,pUMDVersion)	\
    ( (This)->lpVtbl -> CheckInterfaceSupport(This,InterfaceName,pUMDVersion) ) 


#define IDXGIAdapter1_GetDesc1(This,pDesc)	\
    ( (This)->lpVtbl -> GetDesc1(This,pDesc) ) 
--]]




IID_IDXGIDevice1 = UUIDFromString("77db970f-6276-48ba-ba28-070143b4392c")


ffi.cdef[[
    typedef struct IDXGIDevice1Vtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IDXGIDevice1 * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
              void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IDXGIDevice1 * This);
        
        ULONG ( __stdcall *Release )( 
            IDXGIDevice1 * This);
        
        HRESULT ( __stdcall *SetPrivateData )( 
            IDXGIDevice1 * This,
            /* [in] */ REFGUID Name,
            /* [in] */ UINT DataSize,
            /* [in] */ const void *pData);
        
        HRESULT ( __stdcall *SetPrivateDataInterface )( 
            IDXGIDevice1 * This,
            /* [in] */ REFGUID Name,
            /* [in] */ const IUnknown *pUnknown);
        
        HRESULT ( __stdcall *GetPrivateData )( 
            IDXGIDevice1 * This,
            /* [in] */ REFGUID Name,
            /* [out][in] */ UINT *pDataSize,
            /* [out] */ void *pData);
        
        HRESULT ( __stdcall *GetParent )( 
            IDXGIDevice1 * This,
            /* [in] */ REFIID riid,
            /* [retval][out] */ void **ppParent);
        
        HRESULT ( __stdcall *GetAdapter )( 
            IDXGIDevice1 * This,
            /* [out] */ IDXGIAdapter **pAdapter);
        
        HRESULT ( __stdcall *CreateSurface )( 
            IDXGIDevice1 * This,
            /* [in] */ const DXGI_SURFACE_DESC *pDesc,
            /* [in] */ UINT NumSurfaces,
            /* [in] */ DXGI_USAGE Usage,
            /* [in] */ const DXGI_SHARED_RESOURCE *pSharedResource,
            /* [out] */ IDXGISurface **ppSurface);
        
        HRESULT ( __stdcall *QueryResourceResidency )( 
            IDXGIDevice1 * This,
            /* [size_is][in] */ IUnknown *const *ppResources,
            /* [size_is][out] */ DXGI_RESIDENCY *pResidencyStatus,
            /* [in] */ UINT NumResources);
        
        HRESULT ( __stdcall *SetGPUThreadPriority )( 
            IDXGIDevice1 * This,
            /* [in] */ INT Priority);
        
        HRESULT ( __stdcall *GetGPUThreadPriority )( 
            IDXGIDevice1 * This,
            /* [retval][out] */ INT *pPriority);
        
        HRESULT ( __stdcall *SetMaximumFrameLatency )( 
            IDXGIDevice1 * This,
            /* [in] */ UINT MaxLatency);
        
        HRESULT ( __stdcall *GetMaximumFrameLatency )( 
            IDXGIDevice1 * This,
            /* [out] */ UINT *pMaxLatency);
        
            } IDXGIDevice1Vtbl;

    struct IDXGIDevice1
    {
        const struct IDXGIDevice1Vtbl *lpVtbl;
    };
]]
    

--[[
#define IDXGIDevice1_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IDXGIDevice1_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IDXGIDevice1_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IDXGIDevice1_SetPrivateData(This,Name,DataSize,pData)	\
    ( (This)->lpVtbl -> SetPrivateData(This,Name,DataSize,pData) ) 

#define IDXGIDevice1_SetPrivateDataInterface(This,Name,pUnknown)	\
    ( (This)->lpVtbl -> SetPrivateDataInterface(This,Name,pUnknown) ) 

#define IDXGIDevice1_GetPrivateData(This,Name,pDataSize,pData)	\
    ( (This)->lpVtbl -> GetPrivateData(This,Name,pDataSize,pData) ) 

#define IDXGIDevice1_GetParent(This,riid,ppParent)	\
    ( (This)->lpVtbl -> GetParent(This,riid,ppParent) ) 


#define IDXGIDevice1_GetAdapter(This,pAdapter)	\
    ( (This)->lpVtbl -> GetAdapter(This,pAdapter) ) 

#define IDXGIDevice1_CreateSurface(This,pDesc,NumSurfaces,Usage,pSharedResource,ppSurface)	\
    ( (This)->lpVtbl -> CreateSurface(This,pDesc,NumSurfaces,Usage,pSharedResource,ppSurface) ) 

#define IDXGIDevice1_QueryResourceResidency(This,ppResources,pResidencyStatus,NumResources)	\
    ( (This)->lpVtbl -> QueryResourceResidency(This,ppResources,pResidencyStatus,NumResources) ) 

#define IDXGIDevice1_SetGPUThreadPriority(This,Priority)	\
    ( (This)->lpVtbl -> SetGPUThreadPriority(This,Priority) ) 

#define IDXGIDevice1_GetGPUThreadPriority(This,pPriority)	\
    ( (This)->lpVtbl -> GetGPUThreadPriority(This,pPriority) ) 


#define IDXGIDevice1_SetMaximumFrameLatency(This,MaxLatency)	\
    ( (This)->lpVtbl -> SetMaximumFrameLatency(This,MaxLatency) ) 

#define IDXGIDevice1_GetMaximumFrameLatency(This,pMaxLatency)	\
    ( (This)->lpVtbl -> GetMaximumFrameLatency(This,pMaxLatency) ) 
--]]

local Lib = ffi.load("DXGI")

return Lib