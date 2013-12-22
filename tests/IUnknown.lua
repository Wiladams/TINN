local ffi = require("ffi")
local WTypes = require("WTypes")

--[[
#define STDMETHODCALLTYPE       __stdcall
#define STDMETHODVCALLTYPE      __cdecl

#define STDMETHOD(method)       HRESULT (STDMETHODCALLTYPE * method)
#define STDMETHOD_(type,method) type (STDMETHODCALLTYPE * method)
--]]

ffi.cdef[[
struct IUnknown IUnknown;

typedef struct IUnknownVtbl
{
        //BEGIN_INTERFACE
        
        HRESULT ( __stdcall *QueryInterface )(struct IUnknown * This, REFIID riid, void **ppvObject);
        ULONG (__stdcall *AddRef)(struct IUnknown * This);
        ULONG (__stdcall *Release)(struct IUnknown * This);
        
        //END_INTERFACE
} IUnknownVtbl;

struct IUnknown
{
	const struct IUnknownVtbl *lpVtbl;
};
]]
