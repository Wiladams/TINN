local ffi = require("ffi")
local WTypes = require("WTypes")


-- Forward Declarations
ffi.cdef [[
typedef struct IDispatch IDispatch;
typedef struct IPropertyBag IPropertyBag;
typedef struct IRecordInfo IRecordInfo;
typedef struct ITypeComp ITypeComp;
typedef struct ITypeInfo ITypeInfo;
typedef struct ITypeLib ITypeLib;

]]

ffi.cdef[[
typedef struct tagSAFEARRAYBOUND
{
    ULONG cElements;
    LONG lLbound;
} 	SAFEARRAYBOUND;

typedef struct tagSAFEARRAYBOUND *LPSAFEARRAYBOUND;

typedef struct tagSAFEARRAY
    {
    USHORT cDims;
    USHORT fFeatures;
    ULONG cbElements;
    ULONG cLocks;
    PVOID pvData;
    SAFEARRAYBOUND rgsabound[ 1 ];
    } 	SAFEARRAY;

typedef SAFEARRAY *LPSAFEARRAY;

]]

ffi.cdef[[
static const int	FADF_AUTO	=( 0x1 );

static const int	FADF_STATIC	=( 0x2 );

static const int	FADF_EMBEDDED	=( 0x4 );

static const int	FADF_FIXEDSIZE	=( 0x10 );

static const int	FADF_RECORD	=( 0x20 );

static const int	FADF_HAVEIID	=( 0x40 );

static const int	FADF_HAVEVARTYPE	=( 0x80 );

static const int	FADF_BSTR	=( 0x100 );

static const int	FADF_UNKNOWN	=( 0x200 );

static const int	FADF_DISPATCH	=( 0x400 );

static const int	FADF_VARIANT	=( 0x800 );

static const int	FADF_RESERVED	=( 0xf008 );


]]


ffi.cdef[[
typedef struct tagVARIANT VARIANT;

struct tagVARIANT
    {
    union 
        {
        struct __tagVARIANT
            {
            VARTYPE vt;
            WORD wReserved1;
            WORD wReserved2;
            WORD wReserved3;
            union 
                {
                LONGLONG llVal;
                LONG lVal;
                BYTE bVal;
                SHORT iVal;
                FLOAT fltVal;
                DOUBLE dblVal;
                VARIANT_BOOL boolVal;
                _VARIANT_BOOL boola;
                SCODE scode;
                CY cyVal;
                DATE date;
                BSTR bstrVal;
                IUnknown *punkVal;
                IDispatch *pdispVal;
                SAFEARRAY *parray;
                BYTE *pbVal;
                SHORT *piVal;
                LONG *plVal;
                LONGLONG *pllVal;
                FLOAT *pfltVal;
                DOUBLE *pdblVal;
                VARIANT_BOOL *pboolVal;
                _VARIANT_BOOL *pbool;
                SCODE *pscode;
                CY *pcyVal;
                DATE *pdate;
                BSTR *pbstrVal;
                IUnknown **ppunkVal;
                IDispatch **ppdispVal;
                SAFEARRAY **pparray;
                VARIANT *pvarVal;
                PVOID byref;
                CHAR cVal;
                USHORT uiVal;
                ULONG ulVal;
                ULONGLONG ullVal;
                INT intVal;
                UINT uintVal;
                DECIMAL *pdecVal;
                CHAR *pcVal;
                USHORT *puiVal;
                ULONG *pulVal;
                ULONGLONG *pullVal;
                INT *pintVal;
                UINT *puintVal;
                struct __tagBRECORD
                    {
                    PVOID pvRecord;
                    IRecordInfo *pRecInfo;
                    } 	;
                } 	;
            } 	;
        DECIMAL decVal;
        } 	;
    } ;
typedef VARIANT *LPVARIANT;

typedef VARIANT VARIANTARG;

typedef VARIANT *LPVARIANTARG;

]]


ffi.cdef[[
typedef LONG DISPID;

typedef DISPID MEMBERID;

typedef DWORD HREFTYPE;

typedef enum tagTYPEKIND
{	
	TKIND_ENUM	= 0,
	TKIND_RECORD	= ( TKIND_ENUM + 1 ) ,
	TKIND_MODULE	= ( TKIND_RECORD + 1 ) ,
	TKIND_INTERFACE	= ( TKIND_MODULE + 1 ) ,
	TKIND_DISPATCH	= ( TKIND_INTERFACE + 1 ) ,
	TKIND_COCLASS	= ( TKIND_DISPATCH + 1 ) ,
	TKIND_ALIAS	= ( TKIND_COCLASS + 1 ) ,
	TKIND_UNION	= ( TKIND_ALIAS + 1 ) ,
	TKIND_MAX	= ( TKIND_UNION + 1 ) 
} 	TYPEKIND;

typedef struct tagTYPEDESC
    {
    union 
        {
        struct tagTYPEDESC *lptdesc;
        struct tagARRAYDESC *lpadesc;
        HREFTYPE hreftype;
         /* Empty union arm */ 
        } 	;
    VARTYPE vt;
} 	TYPEDESC;

typedef struct tagARRAYDESC
    {
    TYPEDESC tdescElem;
    USHORT cDims;
    SAFEARRAYBOUND rgbounds[ 1 ];
    } 	ARRAYDESC;

typedef struct tagPARAMDESCEX
    {
    ULONG cBytes;
    VARIANTARG varDefaultValue;
    } 	PARAMDESCEX;

typedef struct tagPARAMDESCEX *LPPARAMDESCEX;

typedef struct tagPARAMDESC
    {
    LPPARAMDESCEX pparamdescex;
    USHORT wParamFlags;
    } 	PARAMDESC;

typedef struct tagPARAMDESC *LPPARAMDESC;

static const int	PARAMFLAG_NONE	=( 0 );

static const int	PARAMFLAG_FIN	=( 0x1 );

static const int	PARAMFLAG_FOUT	=( 0x2 );

static const int	PARAMFLAG_FLCID	=( 0x4 );

static const int	PARAMFLAG_FRETVAL	=( 0x8 );

static const int	PARAMFLAG_FOPT	=( 0x10 );

static const int	PARAMFLAG_FHASDEFAULT	=( 0x20 );

static const int	PARAMFLAG_FHASCUSTDATA	=( 0x40 );

]]

ffi.cdef[[
typedef struct tagIDLDESC
    {
    ULONG_PTR dwReserved;
    USHORT wIDLFlags;
    } 	IDLDESC;

typedef struct tagIDLDESC *LPIDLDESC;

static const int	IDLFLAG_NONE	= PARAMFLAG_NONE;
static const int	IDLFLAG_FIN	= PARAMFLAG_FIN;
static const int	IDLFLAG_FOUT	= PARAMFLAG_FOUT;
static const int	IDLFLAG_FLCID	= PARAMFLAG_FLCID;
static const int	IDLFLAG_FRETVAL	= PARAMFLAG_FRETVAL;
]]

ffi.cdef[[
typedef struct tagELEMDESC {
    TYPEDESC tdesc;             /* the type of the element */
    union {
        IDLDESC idldesc;        /* info for remoting the element */
        PARAMDESC paramdesc;    /* info about the parameter */
    } ;
} ELEMDESC, * LPELEMDESC;
]]

ffi.cdef[[
typedef struct tagTYPEATTR
{
    GUID guid;
    LCID lcid;
    DWORD dwReserved;
    MEMBERID memidConstructor;
    MEMBERID memidDestructor;
    LPOLESTR lpstrSchema;
    ULONG cbSizeInstance;
    TYPEKIND typekind;
    WORD cFuncs;
    WORD cVars;
    WORD cImplTypes;
    WORD cbSizeVft;
    WORD cbAlignment;
    WORD wTypeFlags;
    WORD wMajorVerNum;
    WORD wMinorVerNum;
    TYPEDESC tdescAlias;
    IDLDESC idldescType;
    } 	TYPEATTR;

typedef struct tagTYPEATTR *LPTYPEATTR;
]]

ffi.cdef[[
typedef struct tagDISPPARAMS
    {
    VARIANTARG *rgvarg;
    DISPID *rgdispidNamedArgs;
    UINT cArgs;
    UINT cNamedArgs;
    } 	DISPPARAMS;
]]

ffi.cdef[[
typedef struct tagEXCEPINFO {
    WORD  wCode;
    WORD  wReserved;
    BSTR  bstrSource;
    BSTR  bstrDescription;
    BSTR  bstrHelpFile;
    DWORD dwHelpContext;
    PVOID pvReserved;
    HRESULT (__stdcall *pfnDeferredFillIn)(struct tagEXCEPINFO *);
    SCODE scode;
} EXCEPINFO, * LPEXCEPINFO;

typedef /* [v1_enum] */ 
enum tagCALLCONV
    {	CC_FASTCALL	= 0,
	CC_CDECL	= 1,
	CC_MSCPASCAL	= ( CC_CDECL + 1 ) ,
	CC_PASCAL	= CC_MSCPASCAL,
	CC_MACPASCAL	= ( CC_PASCAL + 1 ) ,
	CC_STDCALL	= ( CC_MACPASCAL + 1 ) ,
	CC_FPFASTCALL	= ( CC_STDCALL + 1 ) ,
	CC_SYSCALL	= ( CC_FPFASTCALL + 1 ) ,
	CC_MPWCDECL	= ( CC_SYSCALL + 1 ) ,
	CC_MPWPASCAL	= ( CC_MPWCDECL + 1 ) ,
	CC_MAX	= ( CC_MPWPASCAL + 1 ) 
    } 	CALLCONV;

typedef /* [v1_enum] */ 
enum tagFUNCKIND
    {	FUNC_VIRTUAL	= 0,
	FUNC_PUREVIRTUAL	= ( FUNC_VIRTUAL + 1 ) ,
	FUNC_NONVIRTUAL	= ( FUNC_PUREVIRTUAL + 1 ) ,
	FUNC_STATIC	= ( FUNC_NONVIRTUAL + 1 ) ,
	FUNC_DISPATCH	= ( FUNC_STATIC + 1 ) 
    } 	FUNCKIND;

typedef /* [v1_enum] */ 
enum tagINVOKEKIND
    {	INVOKE_FUNC	= 1,
	INVOKE_PROPERTYGET	= 2,
	INVOKE_PROPERTYPUT	= 4,
	INVOKE_PROPERTYPUTREF	= 8
    } 	INVOKEKIND;

typedef struct tagFUNCDESC
    {
    MEMBERID memid;
    SCODE *lprgscode;
    ELEMDESC *lprgelemdescParam;
    FUNCKIND funckind;
    INVOKEKIND invkind;
    CALLCONV callconv;
    SHORT cParams;
    SHORT cParamsOpt;
    SHORT oVft;
    SHORT cScodes;
    ELEMDESC elemdescFunc;
    WORD wFuncFlags;
    } 	FUNCDESC;

typedef struct tagFUNCDESC *LPFUNCDESC;

typedef /* [v1_enum] */ 
enum tagVARKIND
    {	VAR_PERINSTANCE	= 0,
	VAR_STATIC	= ( VAR_PERINSTANCE + 1 ) ,
	VAR_CONST	= ( VAR_STATIC + 1 ) ,
	VAR_DISPATCH	= ( VAR_CONST + 1 ) 
    } 	VARKIND;

static const int	IMPLTYPEFLAG_FDEFAULT	= 0x1;
static const int	IMPLTYPEFLAG_FSOURCE	= 0x2;
static const int	IMPLTYPEFLAG_FRESTRICTED	= 0x4;
static const int	IMPLTYPEFLAG_FDEFAULTVTABLE	= 0x8;

typedef struct tagVARDESC
    {
    MEMBERID memid;
    LPOLESTR lpstrSchema;
    union 
        {
        ULONG oInst;
        VARIANT *lpvarValue;
        } ;
    ELEMDESC elemdescVar;
    WORD wVarFlags;
    VARKIND varkind;
    } 	VARDESC;

typedef struct tagVARDESC *LPVARDESC;

]]


ffi.cdef[[
typedef /* [unique] */  ITypeComp *LPTYPECOMP;

typedef enum tagDESCKIND
    {	DESCKIND_NONE	= 0,
	DESCKIND_FUNCDESC	= ( DESCKIND_NONE + 1 ) ,
	DESCKIND_VARDESC	= ( DESCKIND_FUNCDESC + 1 ) ,
	DESCKIND_TYPECOMP	= ( DESCKIND_VARDESC + 1 ) ,
	DESCKIND_IMPLICITAPPOBJ	= ( DESCKIND_TYPECOMP + 1 ) ,
	DESCKIND_MAX	= ( DESCKIND_IMPLICITAPPOBJ + 1 ) 
} 	DESCKIND;

typedef union tagBINDPTR
    {
    FUNCDESC *lpfuncdesc;
    VARDESC *lpvardesc;
    ITypeComp *lptcomp;
    } 	BINDPTR;

typedef union tagBINDPTR *LPBINDPTR;

    typedef struct ITypeCompVtbl
    {
        
        HRESULT ( __stdcall *QueryInterface )( 
            ITypeComp * This,
            /* [in] */ REFIID riid,
            void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            ITypeComp * This);
        
        ULONG ( __stdcall *Release )( 
            ITypeComp * This);
        
        HRESULT ( __stdcall *Bind )( 
            ITypeComp * This,
            LPOLESTR szName,
            /* [in] */ ULONG lHashVal,
            /* [in] */ WORD wFlags,
            /* [out] */ ITypeInfo **ppTInfo,
            /* [out] */ DESCKIND *pDescKind,
            /* [out] */ BINDPTR *pBindPtr);
        
        HRESULT ( __stdcall *BindType )( 
            ITypeComp * This,
            LPOLESTR szName,
            /* [in] */ ULONG lHashVal,
            /* [out] */ ITypeInfo **ppTInfo,
            /* [out] */ ITypeComp **ppTComp);
        
    } ITypeCompVtbl;

    struct ITypeComp
    {
        const struct ITypeCompVtbl *lpVtbl;
    };

]]

--[[
#define ITypeComp_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define ITypeComp_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define ITypeComp_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define ITypeComp_Bind(This,szName,lHashVal,wFlags,ppTInfo,pDescKind,pBindPtr)	\
    ( (This)->lpVtbl -> Bind(This,szName,lHashVal,wFlags,ppTInfo,pDescKind,pBindPtr) ) 

#define ITypeComp_BindType(This,szName,lHashVal,ppTInfo,ppTComp)	\
    ( (This)->lpVtbl -> BindType(This,szName,lHashVal,ppTInfo,ppTComp) ) 

--]]
ffi.cdef[[
typedef struct ITypeInfo ITypeInfo;
typedef ITypeInfo *LPTYPEINFO;

    typedef struct ITypeInfoVtbl
    {
        
        HRESULT ( __stdcall *QueryInterface )( 
             ITypeInfo * This,
            /* [in] */  REFIID riid,
              void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
             ITypeInfo * This);
        
        ULONG ( __stdcall *Release )( 
             ITypeInfo * This);
        
        /* [local] */ HRESULT ( __stdcall *GetTypeAttr )( 
            ITypeInfo * This,
            /* [out] */ TYPEATTR **ppTypeAttr);
        
        HRESULT ( __stdcall *GetTypeComp )( 
             ITypeInfo * This,
            /* [out] */ ITypeComp **ppTComp);
        
        /* [local] */ HRESULT ( __stdcall *GetFuncDesc )( 
            ITypeInfo * This,
            /* [in] */ UINT index,
            /* [out] */ FUNCDESC **ppFuncDesc);
        
        /* [local] */ HRESULT ( __stdcall *GetVarDesc )( 
            ITypeInfo * This,
            /* [in] */ UINT index,
            /* [out] */ VARDESC **ppVarDesc);
        
        /* [local] */ HRESULT ( __stdcall *GetNames )( 
            ITypeInfo * This,
            MEMBERID memid,
            BSTR *rgBstrNames,
            UINT cMaxNames,
            UINT *pcNames);
        
        HRESULT ( __stdcall *GetRefTypeOfImplType )( 
             ITypeInfo * This,
            /* [in] */ UINT index,
            /* [out] */ HREFTYPE *pRefType);
        
        HRESULT ( __stdcall *GetImplTypeFlags )( 
             ITypeInfo * This,
            /* [in] */ UINT index,
            /* [out] */ INT *pImplTypeFlags);
        
        HRESULT ( __stdcall *GetIDsOfNames )( 
            ITypeInfo * This,
            /* [annotation][size_is][in] */ 
            LPOLESTR *rgszNames,
            /* [in] */ UINT cNames,
            MEMBERID *pMemId);
        
        HRESULT ( __stdcall *Invoke )( 
            ITypeInfo * This,
            /* [in] */ PVOID pvInstance,
            /* [in] */ MEMBERID memid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS *pDispParams,
            /* [out] */ VARIANT *pVarResult,
            /* [out] */ EXCEPINFO *pExcepInfo,
            /* [out] */ UINT *puArgErr);
        
        /* [local] */ HRESULT ( __stdcall *GetDocumentation )( 
            ITypeInfo * This,
            /* [in] */ MEMBERID memid,
            /* [out] */ BSTR *pBstrName,
            /* [out] */ BSTR *pBstrDocString,
            /* [out] */ DWORD *pdwHelpContext,
            /* [out] */ BSTR *pBstrHelpFile);
        
        /* [local] */ HRESULT ( __stdcall *GetDllEntry )( 
            ITypeInfo * This,
            /* [in] */ MEMBERID memid,
            /* [in] */ INVOKEKIND invKind,
            /* [out] */ BSTR *pBstrDllName,
            /* [out] */ BSTR *pBstrName,
            /* [out] */ WORD *pwOrdinal);
        
        HRESULT ( __stdcall *GetRefTypeInfo )( 
             ITypeInfo * This,
            /* [in] */ HREFTYPE hRefType,
            /* [out] */ ITypeInfo **ppTInfo);
        
        /* [local] */ HRESULT ( __stdcall *AddressOfMember )( 
            ITypeInfo * This,
            /* [in] */ MEMBERID memid,
            /* [in] */ INVOKEKIND invKind,
            /* [out] */ PVOID *ppv);
        
        /* [local] */ HRESULT ( __stdcall *CreateInstance )( 
            ITypeInfo * This,
            /* [in] */ IUnknown *pUnkOuter,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ PVOID *ppvObj);
        
        HRESULT ( __stdcall *GetMops )( 
             ITypeInfo * This,
            /* [in] */ MEMBERID memid,
            /* [out] */ BSTR *pBstrMops);
        
        /* [local] */ HRESULT ( __stdcall *GetContainingTypeLib )( 
            ITypeInfo * This,
            /* [out] */ ITypeLib **ppTLib,
            /* [out] */ UINT *pIndex);
        
        /* [local] */ void ( __stdcall *ReleaseTypeAttr )( 
            ITypeInfo * This,
            /* [in] */ TYPEATTR *pTypeAttr);
        
        /* [local] */ void ( __stdcall *ReleaseFuncDesc )( 
            ITypeInfo * This,
            /* [in] */ FUNCDESC *pFuncDesc);
        
        /* [local] */ void ( __stdcall *ReleaseVarDesc )( 
            ITypeInfo * This,
            /* [in] */ VARDESC *pVarDesc);
        
    } ITypeInfoVtbl;

    struct ITypeInfo
    {
        const struct ITypeInfoVtbl *lpVtbl;
    };

]]

--[[
#define ITypeInfo_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define ITypeInfo_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define ITypeInfo_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define ITypeInfo_GetTypeAttr(This,ppTypeAttr)	\
    ( (This)->lpVtbl -> GetTypeAttr(This,ppTypeAttr) ) 

#define ITypeInfo_GetTypeComp(This,ppTComp)	\
    ( (This)->lpVtbl -> GetTypeComp(This,ppTComp) ) 

#define ITypeInfo_GetFuncDesc(This,index,ppFuncDesc)	\
    ( (This)->lpVtbl -> GetFuncDesc(This,index,ppFuncDesc) ) 

#define ITypeInfo_GetVarDesc(This,index,ppVarDesc)	\
    ( (This)->lpVtbl -> GetVarDesc(This,index,ppVarDesc) ) 

#define ITypeInfo_GetNames(This,memid,rgBstrNames,cMaxNames,pcNames)	\
    ( (This)->lpVtbl -> GetNames(This,memid,rgBstrNames,cMaxNames,pcNames) ) 

#define ITypeInfo_GetRefTypeOfImplType(This,index,pRefType)	\
    ( (This)->lpVtbl -> GetRefTypeOfImplType(This,index,pRefType) ) 

#define ITypeInfo_GetImplTypeFlags(This,index,pImplTypeFlags)	\
    ( (This)->lpVtbl -> GetImplTypeFlags(This,index,pImplTypeFlags) ) 

#define ITypeInfo_GetIDsOfNames(This,rgszNames,cNames,pMemId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,rgszNames,cNames,pMemId) ) 

#define ITypeInfo_Invoke(This,pvInstance,memid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,pvInstance,memid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 

#define ITypeInfo_GetDocumentation(This,memid,pBstrName,pBstrDocString,pdwHelpContext,pBstrHelpFile)	\
    ( (This)->lpVtbl -> GetDocumentation(This,memid,pBstrName,pBstrDocString,pdwHelpContext,pBstrHelpFile) ) 

#define ITypeInfo_GetDllEntry(This,memid,invKind,pBstrDllName,pBstrName,pwOrdinal)	\
    ( (This)->lpVtbl -> GetDllEntry(This,memid,invKind,pBstrDllName,pBstrName,pwOrdinal) ) 

#define ITypeInfo_GetRefTypeInfo(This,hRefType,ppTInfo)	\
    ( (This)->lpVtbl -> GetRefTypeInfo(This,hRefType,ppTInfo) ) 

#define ITypeInfo_AddressOfMember(This,memid,invKind,ppv)	\
    ( (This)->lpVtbl -> AddressOfMember(This,memid,invKind,ppv) ) 

#define ITypeInfo_CreateInstance(This,pUnkOuter,riid,ppvObj)	\
    ( (This)->lpVtbl -> CreateInstance(This,pUnkOuter,riid,ppvObj) ) 

#define ITypeInfo_GetMops(This,memid,pBstrMops)	\
    ( (This)->lpVtbl -> GetMops(This,memid,pBstrMops) ) 

#define ITypeInfo_GetContainingTypeLib(This,ppTLib,pIndex)	\
    ( (This)->lpVtbl -> GetContainingTypeLib(This,ppTLib,pIndex) ) 

#define ITypeInfo_ReleaseTypeAttr(This,pTypeAttr)	\
    ( (This)->lpVtbl -> ReleaseTypeAttr(This,pTypeAttr) ) 

#define ITypeInfo_ReleaseFuncDesc(This,pFuncDesc)	\
    ( (This)->lpVtbl -> ReleaseFuncDesc(This,pFuncDesc) ) 

#define ITypeInfo_ReleaseVarDesc(This,pVarDesc)	\
    ( (This)->lpVtbl -> ReleaseVarDesc(This,pVarDesc) ) 

--]]



ffi.cdef[[
typedef IDispatch *LPDISPATCH;

static const int	DISPID_UNKNOWN	= -1;
static const int	DISPID_VALUE	= 0;
static const int	DISPID_PROPERTYPUT	= -3;
static const int	DISPID_NEWENUM	= -4;
static const int	DISPID_EVALUATE	= -5;
static const int	DISPID_CONSTRUCTOR	= -6;
static const int	DISPID_DESTRUCTOR	= -7;
static const int	DISPID_COLLECT	= -8;
]]

ffi.cdef[[
    typedef struct IDispatchVtbl
    {
        
        HRESULT ( __stdcall *QueryInterface )( 
            IDispatch * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
             void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IDispatch * This);
        
        ULONG ( __stdcall *Release )( 
            IDispatch * This);
        
        HRESULT ( __stdcall *GetTypeInfoCount )( 
            IDispatch * This,
            /* [out] */  UINT *pctinfo);
        
        HRESULT ( __stdcall *GetTypeInfo )( 
            IDispatch * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( __stdcall *GetIDsOfNames )( 
            IDispatch * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( __stdcall *Invoke )( 
            IDispatch * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS *pDispParams,
            /* [out] */ VARIANT *pVarResult,
            /* [out] */ EXCEPINFO *pExcepInfo,
            /* [out] */ UINT *puArgErr);
        
    } IDispatchVtbl;

    struct IDispatch
    {
        const struct IDispatchVtbl *lpVtbl;
    };
]]

--[[
#define IDispatch_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IDispatch_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IDispatch_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IDispatch_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define IDispatch_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define IDispatch_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define IDispatch_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 
--]]

ffi.cdef[[
typedef IRecordInfo *LPRECORDINFO;

    typedef struct IRecordInfoVtbl
    {
        
        HRESULT ( __stdcall *QueryInterface )( 
            IRecordInfo * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
             void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IRecordInfo * This);
        
        ULONG ( __stdcall *Release )( 
            IRecordInfo * This);
        
        HRESULT ( __stdcall *RecordInit )( 
            IRecordInfo * This,
            /* [out] */ PVOID pvNew);
        
        HRESULT ( __stdcall *RecordClear )( 
            IRecordInfo * This,
            /* [in] */ PVOID pvExisting);
        
        HRESULT ( __stdcall *RecordCopy )( 
            IRecordInfo * This,
            /* [in] */ PVOID pvExisting,
            /* [out] */ PVOID pvNew);
        
        HRESULT ( __stdcall *GetGuid )( 
            IRecordInfo * This,
            /* [out] */ GUID *pguid);
        
        HRESULT ( __stdcall *GetName )( 
            IRecordInfo * This,
            /* [out] */ BSTR *pbstrName);
        
        HRESULT ( __stdcall *GetSize )( 
            IRecordInfo * This,
            /* [out] */ ULONG *pcbSize);
        
        HRESULT ( __stdcall *GetTypeInfo )( 
            IRecordInfo * This,
            /* [out] */ ITypeInfo **ppTypeInfo);
        
        HRESULT ( __stdcall *GetField )( 
            IRecordInfo * This,
            /* [in] */ PVOID pvData,
            /* [in] */ LPCOLESTR szFieldName,
            /* [out] */ VARIANT *pvarField);
        
        HRESULT ( __stdcall *GetFieldNoCopy )( 
            IRecordInfo * This,
            /* [in] */ PVOID pvData,
            /* [in] */ LPCOLESTR szFieldName,
            /* [out] */ VARIANT *pvarField,
            /* [out] */ PVOID *ppvDataCArray);
        
        HRESULT ( __stdcall *PutField )( 
            IRecordInfo * This,
            /* [in] */ ULONG wFlags,
            /* [out][in] */ PVOID pvData,
            /* [in] */ LPCOLESTR szFieldName,
            /* [in] */ VARIANT *pvarField);
        
        HRESULT ( __stdcall *PutFieldNoCopy )( 
            IRecordInfo * This,
            /* [in] */ ULONG wFlags,
            /* [out][in] */ PVOID pvData,
            /* [in] */ LPCOLESTR szFieldName,
            /* [in] */ VARIANT *pvarField);
        
        HRESULT ( __stdcall *GetFieldNames )( 
            IRecordInfo * This,
            /* [out][in] */ ULONG *pcNames,
            /* [length_is][size_is][out] */ BSTR *rgBstrNames);
        
        BOOL ( __stdcall *IsMatchingType )( 
            IRecordInfo * This,
            /* [in] */ IRecordInfo *pRecordInfo);
        
        PVOID ( __stdcall *RecordCreate )( 
            IRecordInfo * This);
        
        HRESULT ( __stdcall *RecordCreateCopy )( 
            IRecordInfo * This,
            /* [in] */ PVOID pvSource,
            /* [out] */ PVOID *ppvDest);
        
        HRESULT ( __stdcall *RecordDestroy )( 
            IRecordInfo * This,
            /* [in] */ PVOID pvRecord);
        
    } IRecordInfoVtbl;

    struct IRecordInfo
    {
        const struct IRecordInfoVtbl *lpVtbl;
    };

]]

--[[
#define IRecordInfo_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IRecordInfo_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IRecordInfo_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IRecordInfo_RecordInit(This,pvNew)	\
    ( (This)->lpVtbl -> RecordInit(This,pvNew) ) 

#define IRecordInfo_RecordClear(This,pvExisting)	\
    ( (This)->lpVtbl -> RecordClear(This,pvExisting) ) 

#define IRecordInfo_RecordCopy(This,pvExisting,pvNew)	\
    ( (This)->lpVtbl -> RecordCopy(This,pvExisting,pvNew) ) 

#define IRecordInfo_GetGuid(This,pguid)	\
    ( (This)->lpVtbl -> GetGuid(This,pguid) ) 

#define IRecordInfo_GetName(This,pbstrName)	\
    ( (This)->lpVtbl -> GetName(This,pbstrName) ) 

#define IRecordInfo_GetSize(This,pcbSize)	\
    ( (This)->lpVtbl -> GetSize(This,pcbSize) ) 

#define IRecordInfo_GetTypeInfo(This,ppTypeInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,ppTypeInfo) ) 

#define IRecordInfo_GetField(This,pvData,szFieldName,pvarField)	\
    ( (This)->lpVtbl -> GetField(This,pvData,szFieldName,pvarField) ) 

#define IRecordInfo_GetFieldNoCopy(This,pvData,szFieldName,pvarField,ppvDataCArray)	\
    ( (This)->lpVtbl -> GetFieldNoCopy(This,pvData,szFieldName,pvarField,ppvDataCArray) ) 

#define IRecordInfo_PutField(This,wFlags,pvData,szFieldName,pvarField)	\
    ( (This)->lpVtbl -> PutField(This,wFlags,pvData,szFieldName,pvarField) ) 

#define IRecordInfo_PutFieldNoCopy(This,wFlags,pvData,szFieldName,pvarField)	\
    ( (This)->lpVtbl -> PutFieldNoCopy(This,wFlags,pvData,szFieldName,pvarField) ) 

#define IRecordInfo_GetFieldNames(This,pcNames,rgBstrNames)	\
    ( (This)->lpVtbl -> GetFieldNames(This,pcNames,rgBstrNames) ) 

#define IRecordInfo_IsMatchingType(This,pRecordInfo)	\
    ( (This)->lpVtbl -> IsMatchingType(This,pRecordInfo) ) 

#define IRecordInfo_RecordCreate(This)	\
    ( (This)->lpVtbl -> RecordCreate(This) ) 

#define IRecordInfo_RecordCreateCopy(This,pvSource,ppvDest)	\
    ( (This)->lpVtbl -> RecordCreateCopy(This,pvSource,ppvDest) ) 

#define IRecordInfo_RecordDestroy(This,pvRecord)	\
    ( (This)->lpVtbl -> RecordDestroy(This,pvRecord) ) 

--]]

ffi.cdef[[
typedef /* [v1_enum] */ 
enum tagSYSKIND
    {	SYS_WIN16	= 0,
	SYS_WIN32	= ( SYS_WIN16 + 1 ) ,
	SYS_MAC	= ( SYS_WIN32 + 1 ) ,
	SYS_WIN64	= ( SYS_MAC + 1 ) 
    } 	SYSKIND;

typedef enum tagLIBFLAGS
    {	LIBFLAG_FRESTRICTED	= 0x1,
	LIBFLAG_FCONTROL	= 0x2,
	LIBFLAG_FHIDDEN	= 0x4,
	LIBFLAG_FHASDISKIMAGE	= 0x8
    } 	LIBFLAGS;

typedef ITypeLib *LPTYPELIB;

typedef struct tagTLIBATTR
    {
    GUID guid;
    LCID lcid;
    SYSKIND syskind;
    WORD wMajorVerNum;
    WORD wMinorVerNum;
    WORD wLibFlags;
    } 	TLIBATTR;

typedef struct tagTLIBATTR *LPTLIBATTR;

    typedef struct ITypeLibVtbl
    {
        
        HRESULT ( __stdcall *QueryInterface )( 
            ITypeLib * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
             void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            ITypeLib * This);
        
        ULONG ( __stdcall *Release )( 
            ITypeLib * This);
        
        /* [local] */ UINT ( __stdcall *GetTypeInfoCount )( 
            ITypeLib * This);
        
        HRESULT ( __stdcall *GetTypeInfo )( 
            ITypeLib * This,
            /* [in] */ UINT index,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( __stdcall *GetTypeInfoType )( 
            ITypeLib * This,
            /* [in] */ UINT index,
            /* [out] */ TYPEKIND *pTKind);
        
        HRESULT ( __stdcall *GetTypeInfoOfGuid )( 
            ITypeLib * This,
            /* [in] */ REFGUID guid,
            /* [out] */ ITypeInfo **ppTinfo);
        
        /* [local] */ HRESULT ( __stdcall *GetLibAttr )( 
            ITypeLib * This,
            /* [out] */ TLIBATTR **ppTLibAttr);
        
        HRESULT ( __stdcall *GetTypeComp )( 
            ITypeLib * This,
            /* [out] */ ITypeComp **ppTComp);
        
        /* [local] */ HRESULT ( __stdcall *GetDocumentation )( 
            ITypeLib * This,
            /* [in] */ INT index,
            /* [out] */ BSTR *pBstrName,
            /* [out] */ BSTR *pBstrDocString,
            /* [out] */ DWORD *pdwHelpContext,
            /* [out] */ BSTR *pBstrHelpFile);
        
        /* [local] */ HRESULT ( __stdcall *IsName )( 
            ITypeLib * This,
            /* [annotation][out][in] */ 
             LPOLESTR szNameBuf,
            /* [in] */ ULONG lHashVal,
            /* [out] */ BOOL *pfName);
        
        /* [local] */ HRESULT ( __stdcall *FindName )( 
            ITypeLib * This,
            /* [annotation][out][in] */ 
            LPOLESTR szNameBuf,
            /* [in] */ ULONG lHashVal,
            /* [length_is][size_is][out] */ ITypeInfo **ppTInfo,
            /* [length_is][size_is][out] */ MEMBERID *rgMemId,
            /* [out][in] */ USHORT *pcFound);
        
        /* [local] */ void ( __stdcall *ReleaseTLibAttr )( 
            ITypeLib * This,
            /* [in] */ TLIBATTR *pTLibAttr);
        
    } ITypeLibVtbl;

    struct ITypeLib
    {
        const struct ITypeLibVtbl *lpVtbl;
    };
]]

--[[
#define ITypeLib_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define ITypeLib_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define ITypeLib_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define ITypeLib_GetTypeInfoCount(This)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This) ) 

#define ITypeLib_GetTypeInfo(This,index,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,index,ppTInfo) ) 

#define ITypeLib_GetTypeInfoType(This,index,pTKind)	\
    ( (This)->lpVtbl -> GetTypeInfoType(This,index,pTKind) ) 

#define ITypeLib_GetTypeInfoOfGuid(This,guid,ppTinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoOfGuid(This,guid,ppTinfo) ) 

#define ITypeLib_GetLibAttr(This,ppTLibAttr)	\
    ( (This)->lpVtbl -> GetLibAttr(This,ppTLibAttr) ) 

#define ITypeLib_GetTypeComp(This,ppTComp)	\
    ( (This)->lpVtbl -> GetTypeComp(This,ppTComp) ) 

#define ITypeLib_GetDocumentation(This,index,pBstrName,pBstrDocString,pdwHelpContext,pBstrHelpFile)	\
    ( (This)->lpVtbl -> GetDocumentation(This,index,pBstrName,pBstrDocString,pdwHelpContext,pBstrHelpFile) ) 

#define ITypeLib_IsName(This,szNameBuf,lHashVal,pfName)	\
    ( (This)->lpVtbl -> IsName(This,szNameBuf,lHashVal,pfName) ) 

#define ITypeLib_FindName(This,szNameBuf,lHashVal,ppTInfo,rgMemId,pcFound)	\
    ( (This)->lpVtbl -> FindName(This,szNameBuf,lHashVal,ppTInfo,rgMemId,pcFound) ) 

#define ITypeLib_ReleaseTLibAttr(This,pTLibAttr)	\
    ( (This)->lpVtbl -> ReleaseTLibAttr(This,pTLibAttr) ) 

--]]

return {
	IID_IDispatch 	= UUIDFromString("00020400-0000-0000-C000-000000000046");
	IID_IRecordInfo = UUIDFromString("0000002F-0000-0000-C000-000000000046");
	IID_ITypeComp   = UUIDFromString("00020403-0000-0000-C000-000000000046");
	IID_ITypeInfo 	= UUIDFromString("00020401-0000-0000-C000-000000000046");
	IID_ITypeLib    = UUIDFromString("00020402-0000-0000-C000-000000000046");
}