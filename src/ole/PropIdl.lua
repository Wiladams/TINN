-- MSCOM.lua
local ffi = require("ffi")

local WTypes = require("WTypes")
local core_string = require("core_string_l1_1_0");

local IUnknown = require("IUnknown")
local OaIdl = require("OaIdl")
local ObjIdl = require("ObjIdl")

-- Forward Declarations
ffi.cdef[[
typedef struct IPropertyStorage IPropertyStorage;
typedef struct IEnumSTATPROPSTG IEnumSTATPROPSTG;

]]




ffi.cdef[[
typedef struct tagPROPSPEC
    {
    ULONG ulKind;
    union 
        {
        PROPID propid;
        LPOLESTR lpwstr;
         /* Empty union arm */ 
        }   ;
    }   PROPSPEC;

typedef struct tagSTATPROPSTG
    {
    LPOLESTR lpwstrName;
    PROPID propid;
    VARTYPE vt;
    }   STATPROPSTG;
]]

ffi.cdef[[
typedef struct tagVersionedStream
    {
    GUID guidVersion;
    IStream *pStream;
    }   VERSIONEDSTREAM;

typedef struct tagVersionedStream *LPVERSIONEDSTREAM;
]]

ffi.cdef[[
typedef struct tagPROPVARIANT PROPVARIANT;

typedef struct tagCAC
    {
    ULONG cElems;
    CHAR *pElems;
    }   CAC;

typedef struct tagCAUB
    {
    ULONG cElems;
    UCHAR *pElems;
    }   CAUB;

typedef struct tagCAI
    {
    ULONG cElems;
    SHORT *pElems;
    }   CAI;

typedef struct tagCAUI
    {
    ULONG cElems;
    USHORT *pElems;
    }   CAUI;

typedef struct tagCAL
    {
    ULONG cElems;
    LONG *pElems;
    }   CAL;

typedef struct tagCAUL
    {
    ULONG cElems;
    ULONG *pElems;
    }   CAUL;

typedef struct tagCAFLT
    {
    ULONG cElems;
    FLOAT *pElems;
    }   CAFLT;

typedef struct tagCADBL
    {
    ULONG cElems;
    DOUBLE *pElems;
    }   CADBL;

typedef struct tagCACY
    {
    ULONG cElems;
    CY *pElems;
    }   CACY;

typedef struct tagCADATE
    {
    ULONG cElems;
    DATE *pElems;
    }   CADATE;

typedef struct tagCABSTR
    {
    ULONG cElems;
    BSTR *pElems;
    }   CABSTR;

typedef struct tagCABSTRBLOB
    {
    ULONG cElems;
    BSTRBLOB *pElems;
    }   CABSTRBLOB;

typedef struct tagCABOOL
    {
    ULONG cElems;
    VARIANT_BOOL *pElems;
    }   CABOOL;

typedef struct tagCASCODE
    {
    ULONG cElems;
    SCODE *pElems;
    }   CASCODE;

typedef struct tagCAPROPVARIANT
    {
    ULONG cElems;
    PROPVARIANT *pElems;
    }   CAPROPVARIANT;

typedef struct tagCAH
    {
    ULONG cElems;
    LARGE_INTEGER *pElems;
    }   CAH;

typedef struct tagCAUH
    {
    ULONG cElems;
    ULARGE_INTEGER *pElems;
    }   CAUH;

typedef struct tagCALPSTR
    {
    ULONG cElems;
    LPSTR *pElems;
    }   CALPSTR;

typedef struct tagCALPWSTR
    {
    ULONG cElems;
    LPWSTR *pElems;
    }   CALPWSTR;

typedef struct tagCAFILETIME
    {
    ULONG cElems;
    FILETIME *pElems;
    }   CAFILETIME;

typedef struct tagCACLIPDATA
    {
    ULONG cElems;
    CLIPDATA *pElems;
    }   CACLIPDATA;

typedef struct tagCACLSID
    {
    ULONG cElems;
    CLSID *pElems;
    }   CACLSID;
]]

ffi.cdef[[
// This is the standard C layout of the structure.
typedef WORD PROPVAR_PAD1;
typedef WORD PROPVAR_PAD2;
typedef WORD PROPVAR_PAD3;
]]

ffi.cdef[[
struct tagPROPVARIANT {
  union {
struct tag_inner_PROPVARIANT
    {
    VARTYPE vt;
    PROPVAR_PAD1 wReserved1;
    PROPVAR_PAD2 wReserved2;
    PROPVAR_PAD3 wReserved3;
    union 
        {
         /* Empty union arm */ 
        CHAR cVal;
        UCHAR bVal;
        SHORT iVal;
        USHORT uiVal;
        LONG lVal;
        ULONG ulVal;
        INT intVal;
        UINT uintVal;
        LARGE_INTEGER hVal;
        ULARGE_INTEGER uhVal;
        FLOAT fltVal;
        DOUBLE dblVal;
        VARIANT_BOOL boolVal;
        _VARIANT_BOOL boola;
        SCODE scode;
        CY cyVal;
        DATE date;
        FILETIME filetime;
        CLSID *puuid;
        CLIPDATA *pclipdata;
        BSTR bstrVal;
        BSTRBLOB bstrblobVal;
        BLOB blob;
        LPSTR pszVal;
        LPWSTR pwszVal;
        IUnknown *punkVal;
        IDispatch *pdispVal;
        IStream *pStream;
        IStorage *pStorage;
        LPVERSIONEDSTREAM pVersionedStream;
        LPSAFEARRAY parray;
        CAC cac;
        CAUB caub;
        CAI cai;
        CAUI caui;
        CAL cal;
        CAUL caul;
        CAH cah;
        CAUH cauh;
        CAFLT caflt;
        CADBL cadbl;
        CABOOL cabool;
        CASCODE cascode;
        CACY cacy;
        CADATE cadate;
        CAFILETIME cafiletime;
        CACLSID cauuid;
        CACLIPDATA caclipdata;
        CABSTR cabstr;
        CABSTRBLOB cabstrblob;
        CALPSTR calpstr;
        CALPWSTR calpwstr;
        CAPROPVARIANT capropvar;
        CHAR *pcVal;
        UCHAR *pbVal;
        SHORT *piVal;
        USHORT *puiVal;
        LONG *plVal;
        ULONG *pulVal;
        INT *pintVal;
        UINT *puintVal;
        FLOAT *pfltVal;
        DOUBLE *pdblVal;
        VARIANT_BOOL *pboolVal;
        DECIMAL *pdecVal;
        SCODE *pscode;
        CY *pcyVal;
        DATE *pdate;
        BSTR *pbstrVal;
        IUnknown **ppunkVal;
        IDispatch **ppdispVal;
        LPSAFEARRAY *pparray;
        PROPVARIANT *pvarVal;
        }   ;
    } ;
    DECIMAL decVal;
  };
};

typedef struct tagPROPVARIANT * LPPROPVARIANT;
typedef const PROPVARIANT *     REFPROPVARIANT;

]]



local PROPVARIANT = ffi.typeof("PROPVARIANT")
local PROPVARIANT_mt = {
    __tostring = function(self)
        if self.vt == ffi.C.VT_BLOB then
            return tostring(self.blob)
        elseif self.vt == ffi.C.VT_BOOL then
            return not (self.boolVal == 0);
        elseif self.vt == ffi.C.VT_CLSID then
            return tostring(ffi.cast("CLSID *", self.puuid))
        elseif self.vt == ffi.C.VT_LPWSTR then
            return core_string.toAnsi(self.pwszVal)
        elseif self.vt == ffi.C.VT_UI4 then
            return tonumber(self.uintVal)
        end

        return tostring(self.pcVal)
    end,
}
ffi.metatype(PROPVARIANT, PROPVARIANT_mt)


ffi.cdef[[
// Reserved global Property IDs
static const int PID_DICTIONARY  = 0;

static const int PID_CODEPAGE    = 0x1;

static const int PID_FIRST_USABLE    = 0x2;

static const int PID_FIRST_NAME_DEFAULT  = 0xfff;

static const int PID_LOCALE  = 0x80000000;

static const int PID_MODIFY_TIME = 0x80000001;

static const int PID_SECURITY    = 0x80000002;

static const int PID_BEHAVIOR    = 0x80000003;

static const int PID_ILLEGAL = 0xffffffff;

// Range which is read-only to downlevel implementations
static const int PID_MIN_READONLY    = 0x80000000;

static const int PID_MAX_READONLY    = 0xbfffffff;

// Property IDs for the DiscardableInformation Property Set

static const int PIDDI_THUMBNAIL          = 0x00000002L; // VT_BLOB

// Property IDs for the SummaryInformation Property Set

static const int PIDSI_TITLE               = 0x00000002L;  // VT_LPSTR
static const int PIDSI_SUBJECT             = 0x00000003L;  // VT_LPSTR
static const int PIDSI_AUTHOR              = 0x00000004L;  // VT_LPSTR
static const int PIDSI_KEYWORDS            = 0x00000005L;  // VT_LPSTR
static const int PIDSI_COMMENTS            = 0x00000006L;  // VT_LPSTR
static const int PIDSI_TEMPLATE            = 0x00000007L;  // VT_LPSTR
static const int PIDSI_LASTAUTHOR          = 0x00000008L;  // VT_LPSTR
static const int PIDSI_REVNUMBER           = 0x00000009L;  // VT_LPSTR
static const int PIDSI_EDITTIME            = 0x0000000aL;  // VT_FILETIME (UTC)
static const int PIDSI_LASTPRINTED         = 0x0000000bL;  // VT_FILETIME (UTC)
static const int PIDSI_CREATE_DTM          = 0x0000000cL;  // VT_FILETIME (UTC)
static const int PIDSI_LASTSAVE_DTM        = 0x0000000dL;  // VT_FILETIME (UTC)
static const int PIDSI_PAGECOUNT           = 0x0000000eL;  // VT_I4
static const int PIDSI_WORDCOUNT           = 0x0000000fL;  // VT_I4
static const int PIDSI_CHARCOUNT           = 0x00000010L;  // VT_I4
static const int PIDSI_THUMBNAIL           = 0x00000011L;  // VT_CF
static const int PIDSI_APPNAME             = 0x00000012L;  // VT_LPSTR
static const int PIDSI_DOC_SECURITY        = 0x00000013L;  // VT_I4

// Property IDs for the DocSummaryInformation Property Set

static const int PIDDSI_CATEGORY          = 0x00000002; // VT_LPSTR
static const int PIDDSI_PRESFORMAT        = 0x00000003; // VT_LPSTR
static const int PIDDSI_BYTECOUNT         = 0x00000004; // VT_I4
static const int PIDDSI_LINECOUNT         = 0x00000005; // VT_I4
static const int PIDDSI_PARCOUNT          = 0x00000006; // VT_I4
static const int PIDDSI_SLIDECOUNT        = 0x00000007; // VT_I4
static const int PIDDSI_NOTECOUNT         = 0x00000008; // VT_I4
static const int PIDDSI_HIDDENCOUNT       = 0x00000009; // VT_I4
static const int PIDDSI_MMCLIPCOUNT       = 0x0000000A; // VT_I4
static const int PIDDSI_SCALE             = 0x0000000B; // VT_BOOL
static const int PIDDSI_HEADINGPAIR       = 0x0000000C; // VT_VARIANT | VT_VECTOR
static const int PIDDSI_DOCPARTS          = 0x0000000D; // VT_LPSTR | VT_VECTOR
static const int PIDDSI_MANAGER           = 0x0000000E; // VT_LPSTR
static const int PIDDSI_COMPANY           = 0x0000000F; // VT_LPSTR
static const int PIDDSI_LINKSDIRTY        = 0x00000010; // VT_BOOL


//  FMTID_MediaFileSummaryInfo - Property IDs

static const int PIDMSI_EDITOR                   = 0x00000002L;  // VT_LPWSTR
static const int PIDMSI_SUPPLIER                 = 0x00000003L;  // VT_LPWSTR
static const int PIDMSI_SOURCE                   = 0x00000004L;  // VT_LPWSTR
static const int PIDMSI_SEQUENCE_NO              = 0x00000005L;  // VT_LPWSTR
static const int PIDMSI_PROJECT                  = 0x00000006L;  // VT_LPWSTR
static const int PIDMSI_STATUS                   = 0x00000007L;  // VT_UI4
static const int PIDMSI_OWNER                    = 0x00000008L;  // VT_LPWSTR
static const int PIDMSI_RATING                   = 0x00000009L;  // VT_LPWSTR
static const int PIDMSI_PRODUCTION               = 0x0000000AL;  // VT_FILETIME (UTC)
static const int PIDMSI_COPYRIGHT                = 0x0000000BL;  // VT_LPWSTR
]]


ffi.cdef[[    
static const int PRSPEC_INVALID = ( 0xffffffff );

static const int PRSPEC_LPWSTR  = ( 0 );

static const int PRSPEC_PROPID  = ( 1 );


]]

ffi.cdef[[
    typedef struct IEnumSTATPROPSTGVtbl
    {
        
        HRESULT ( __stdcall *QueryInterface )( 
            IEnumSTATPROPSTG * This,
            REFIID riid,
            void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IEnumSTATPROPSTG * This);
        
        ULONG ( __stdcall *Release )( 
            IEnumSTATPROPSTG * This);
        
        HRESULT ( __stdcall *Next )( 
            IEnumSTATPROPSTG * This,
            ULONG celt,
            STATPROPSTG *rgelt,
            ULONG *pceltFetched);
        
        HRESULT ( __stdcall *Skip )( 
            IEnumSTATPROPSTG * This,
            ULONG celt);
        
        HRESULT ( __stdcall *Reset )( 
            IEnumSTATPROPSTG * This);
        
        HRESULT ( __stdcall *Clone )( 
            IEnumSTATPROPSTG * This,
            IEnumSTATPROPSTG **ppenum);
        
    } IEnumSTATPROPSTGVtbl;

    struct IEnumSTATPROPSTG
    {
        const struct IEnumSTATPROPSTGVtbl *lpVtbl;
    };
]]

ffi.cdef[[
typedef struct tagSTATPROPSETSTG
    {
    FMTID fmtid;
    CLSID clsid;
    DWORD grfFlags;
    FILETIME mtime;
    FILETIME ctime;
    FILETIME atime;
    DWORD dwOSVersion;
    }   STATPROPSETSTG;
]]

ffi.cdef[[
    typedef struct IPropertyStorageVtbl
    {
        
        HRESULT ( __stdcall *QueryInterface )( 
            IPropertyStorage * This,
            /* [in] */ REFIID riid,
              void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IPropertyStorage * This);
        
        ULONG ( __stdcall *Release )( 
            IPropertyStorage * This);
        
        HRESULT ( __stdcall *ReadMultiple )( 
            IPropertyStorage * This,
            /* [in] */ ULONG cpspec,
            /* [size_is][in] */ const PROPSPEC rgpspec[  ],
            /* [size_is][out] */ PROPVARIANT rgpropvar[  ]);
        
        HRESULT ( __stdcall *WriteMultiple )( 
            IPropertyStorage * This,
            /* [in] */ ULONG cpspec,
            /* [size_is][in] */ const PROPSPEC rgpspec[  ],
            /* [size_is][in] */ const PROPVARIANT rgpropvar[  ],
            /* [in] */ PROPID propidNameFirst);
        
        HRESULT ( __stdcall *DeleteMultiple )( 
            IPropertyStorage * This,
            /* [in] */ ULONG cpspec,
            /* [size_is][in] */ const PROPSPEC rgpspec[  ]);
        
        HRESULT ( __stdcall *ReadPropertyNames )( 
            IPropertyStorage * This,
            /* [in] */ ULONG cpropid,
            /* [size_is][in] */ const PROPID rgpropid[  ],
            /* [size_is][out] */ LPOLESTR rglpwstrName[  ]);
        
        HRESULT ( __stdcall *WritePropertyNames )( 
            IPropertyStorage * This,
            /* [in] */ ULONG cpropid,
            /* [size_is][in] */ const PROPID rgpropid[  ],
            /* [size_is][in] */ const LPOLESTR rglpwstrName[  ]);
        
        HRESULT ( __stdcall *DeletePropertyNames )( 
            IPropertyStorage * This,
            /* [in] */ ULONG cpropid,
            /* [size_is][in] */ const PROPID rgpropid[  ]);
        
        HRESULT ( __stdcall *Commit )( 
            IPropertyStorage * This,
            /* [in] */ DWORD grfCommitFlags);
        
        HRESULT ( __stdcall *Revert )( 
            IPropertyStorage * This);
        
        HRESULT ( __stdcall *Enum )( 
            IPropertyStorage * This,
            /* [out] */ IEnumSTATPROPSTG **ppenum);
        
        HRESULT ( __stdcall *SetTimes )( 
            IPropertyStorage * This,
            /* [in] */ const FILETIME *pctime,
            /* [in] */ const FILETIME *patime,
            /* [in] */ const FILETIME *pmtime);
        
        HRESULT ( __stdcall *SetClass )( 
            IPropertyStorage * This,
            /* [in] */ REFCLSID clsid);
        
        HRESULT ( __stdcall *Stat )( 
            IPropertyStorage * This,
            /* [out] */ STATPROPSETSTG *pstatpsstg);
        
    } IPropertyStorageVtbl;

    struct IPropertyStorage
    {
        const struct IPropertyStorageVtbl *lpVtbl;
    };
]]
    


--[[
#define IPropertyStorage_QueryInterface(This,riid,ppvObject)    \
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IPropertyStorage_AddRef(This)   \
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IPropertyStorage_Release(This)  \
    ( (This)->lpVtbl -> Release(This) ) 


#define IPropertyStorage_ReadMultiple(This,cpspec,rgpspec,rgpropvar)    \
    ( (This)->lpVtbl -> ReadMultiple(This,cpspec,rgpspec,rgpropvar) ) 

#define IPropertyStorage_WriteMultiple(This,cpspec,rgpspec,rgpropvar,propidNameFirst)   \
    ( (This)->lpVtbl -> WriteMultiple(This,cpspec,rgpspec,rgpropvar,propidNameFirst) ) 

#define IPropertyStorage_DeleteMultiple(This,cpspec,rgpspec)    \
    ( (This)->lpVtbl -> DeleteMultiple(This,cpspec,rgpspec) ) 

#define IPropertyStorage_ReadPropertyNames(This,cpropid,rgpropid,rglpwstrName)  \
    ( (This)->lpVtbl -> ReadPropertyNames(This,cpropid,rgpropid,rglpwstrName) ) 

#define IPropertyStorage_WritePropertyNames(This,cpropid,rgpropid,rglpwstrName) \
    ( (This)->lpVtbl -> WritePropertyNames(This,cpropid,rgpropid,rglpwstrName) ) 

#define IPropertyStorage_DeletePropertyNames(This,cpropid,rgpropid) \
    ( (This)->lpVtbl -> DeletePropertyNames(This,cpropid,rgpropid) ) 

#define IPropertyStorage_Commit(This,grfCommitFlags)    \
    ( (This)->lpVtbl -> Commit(This,grfCommitFlags) ) 

#define IPropertyStorage_Revert(This)   \
    ( (This)->lpVtbl -> Revert(This) ) 

#define IPropertyStorage_Enum(This,ppenum)  \
    ( (This)->lpVtbl -> Enum(This,ppenum) ) 

#define IPropertyStorage_SetTimes(This,pctime,patime,pmtime)    \
    ( (This)->lpVtbl -> SetTimes(This,pctime,patime,pmtime) ) 

#define IPropertyStorage_SetClass(This,clsid)   \
    ( (This)->lpVtbl -> SetClass(This,clsid) ) 

#define IPropertyStorage_Stat(This,pstatpsstg)  \
    ( (This)->lpVtbl -> Stat(This,pstatpsstg) ) 
--]]

return {
    IID_IPropertyStorage = UUIDFromString("00000138-0000-0000-C000-000000000046");
    IID_IEnumSTATPROPSTG = UUIDFromString("00000139-0000-0000-C000-000000000046");

    PROPVARIANT = PROPVARIANT,
}