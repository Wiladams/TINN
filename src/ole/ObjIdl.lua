-- ObjIdl.lua
local ffi = require("ffi")
local WTypes = require("WTypes")


-- Forward Declarations
ffi.cdef[[
typedef struct IEnumSTATSTG IEnumSTATSTG;
typedef struct IStream IStream;
typedef struct IStorage IStorage;
]]

ffi.cdef[[
typedef IStream *LPSTREAM;

typedef struct tagSTATSTG
    {
    LPOLESTR pwcsName;
    DWORD type;
    ULARGE_INTEGER cbSize;
    FILETIME mtime;
    FILETIME ctime;
    FILETIME atime;
    DWORD grfMode;
    DWORD grfLocksSupported;
    CLSID clsid;
    DWORD grfStateBits;
    DWORD reserved;
    } 	STATSTG;

typedef enum tagSTGTY
    {	STGTY_STORAGE	= 1,
	STGTY_STREAM	= 2,
	STGTY_LOCKBYTES	= 3,
	STGTY_PROPERTY	= 4
    } 	STGTY;

typedef enum tagSTREAM_SEEK
    {	STREAM_SEEK_SET	= 0,
	STREAM_SEEK_CUR	= 1,
	STREAM_SEEK_END	= 2
    } 	STREAM_SEEK;

typedef enum tagLOCKTYPE
    {	LOCK_WRITE	= 1,
	LOCK_EXCLUSIVE	= 2,
	LOCK_ONLYONCE	= 4
    } 	LOCKTYPE;

]]

ffi.cdef[[
    typedef struct IStreamVtbl
    {
        
        HRESULT ( __stdcall *QueryInterface )( 
            IStream * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
             void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IStream * This);
        
        ULONG ( __stdcall *Release )( 
            IStream * This);
        
        /* [local] */ HRESULT ( __stdcall *Read )( 
            IStream * This,
            /* [annotation] */ 
            void *pv,
            /* [in] */ ULONG cb,
            /* [annotation] */ 
            ULONG *pcbRead);
        
        /* [local] */ HRESULT ( __stdcall *Write )( 
            IStream * This,
            /* [annotation] */ 
            const void *pv,
            /* [in] */ ULONG cb,
            /* [annotation] */ 
            ULONG *pcbWritten);
        
        /* [local] */ HRESULT ( __stdcall *Seek )( 
            IStream * This,
            /* [in] */ LARGE_INTEGER dlibMove,
            /* [in] */ DWORD dwOrigin,
            /* [annotation] */ 
            ULARGE_INTEGER *plibNewPosition);
        
        HRESULT ( __stdcall *SetSize )( 
            IStream * This,
            /* [in] */ ULARGE_INTEGER libNewSize);
        
        /* [local] */ HRESULT ( __stdcall *CopyTo )( 
            IStream * This,
            /* [unique][in] */ IStream *pstm,
            /* [in] */ ULARGE_INTEGER cb,
            /* [annotation] */ 
            ULARGE_INTEGER *pcbRead,
            /* [annotation] */ 
            ULARGE_INTEGER *pcbWritten);
        
        HRESULT ( __stdcall *Commit )( 
            IStream * This,
            /* [in] */ DWORD grfCommitFlags);
        
        HRESULT ( __stdcall *Revert )( 
            IStream * This);
        
        HRESULT ( __stdcall *LockRegion )( 
            IStream * This,
            /* [in] */ ULARGE_INTEGER libOffset,
            /* [in] */ ULARGE_INTEGER cb,
            /* [in] */ DWORD dwLockType);
        
        HRESULT ( __stdcall *UnlockRegion )( 
            IStream * This,
            /* [in] */ ULARGE_INTEGER libOffset,
            /* [in] */ ULARGE_INTEGER cb,
            /* [in] */ DWORD dwLockType);
        
        HRESULT ( __stdcall *Stat )( 
            IStream * This,
            /* [out] */ STATSTG *pstatstg,
            /* [in] */ DWORD grfStatFlag);
        
        HRESULT ( __stdcall *Clone )( 
            IStream * This,
            /* [out] */ IStream **ppstm);
        
     } IStreamVtbl;

    struct IStream
    {
        const struct IStreamVtbl *lpVtbl;
    };
]]

--[[
#define IStream_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IStream_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IStream_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IStream_Read(This,pv,cb,pcbRead)	\
    ( (This)->lpVtbl -> Read(This,pv,cb,pcbRead) ) 

#define IStream_Write(This,pv,cb,pcbWritten)	\
    ( (This)->lpVtbl -> Write(This,pv,cb,pcbWritten) ) 


#define IStream_Seek(This,dlibMove,dwOrigin,plibNewPosition)	\
    ( (This)->lpVtbl -> Seek(This,dlibMove,dwOrigin,plibNewPosition) ) 

#define IStream_SetSize(This,libNewSize)	\
    ( (This)->lpVtbl -> SetSize(This,libNewSize) ) 

#define IStream_CopyTo(This,pstm,cb,pcbRead,pcbWritten)	\
    ( (This)->lpVtbl -> CopyTo(This,pstm,cb,pcbRead,pcbWritten) ) 

#define IStream_Commit(This,grfCommitFlags)	\
    ( (This)->lpVtbl -> Commit(This,grfCommitFlags) ) 

#define IStream_Revert(This)	\
    ( (This)->lpVtbl -> Revert(This) ) 

#define IStream_LockRegion(This,libOffset,cb,dwLockType)	\
    ( (This)->lpVtbl -> LockRegion(This,libOffset,cb,dwLockType) ) 

#define IStream_UnlockRegion(This,libOffset,cb,dwLockType)	\
    ( (This)->lpVtbl -> UnlockRegion(This,libOffset,cb,dwLockType) ) 

#define IStream_Stat(This,pstatstg,grfStatFlag)	\
    ( (This)->lpVtbl -> Stat(This,pstatstg,grfStatFlag) ) 

#define IStream_Clone(This,ppstm)	\
    ( (This)->lpVtbl -> Clone(This,ppstm) ) 

--]]

ffi.cdef[[
typedef IEnumSTATSTG *LPENUMSTATSTG;

    typedef struct IEnumSTATSTGVtbl
    {
        
        HRESULT ( __stdcall *QueryInterface )( 
            IEnumSTATSTG * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IEnumSTATSTG * This);
        
        ULONG ( __stdcall *Release )( 
            IEnumSTATSTG * This);
        
        /* [local] */ HRESULT ( __stdcall *Next )( 
            IEnumSTATSTG * This,
            /* [in] */ ULONG celt,
            /* [annotation] */ 
            STATSTG *rgelt,
            /* [annotation] */ 
            ULONG *pceltFetched);
        
        HRESULT ( __stdcall *Skip )( 
            IEnumSTATSTG * This,
            /* [in] */ ULONG celt);
        
        HRESULT ( __stdcall *Reset )( 
            IEnumSTATSTG * This);
        
        HRESULT ( __stdcall *Clone )( 
            IEnumSTATSTG * This,
            IEnumSTATSTG **ppenum);
        
    } IEnumSTATSTGVtbl;

    struct IEnumSTATSTG
    {
        const struct IEnumSTATSTGVtbl *lpVtbl;
    };

]]
--[[
#define IEnumSTATSTG_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IEnumSTATSTG_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IEnumSTATSTG_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IEnumSTATSTG_Next(This,celt,rgelt,pceltFetched)	\
    ( (This)->lpVtbl -> Next(This,celt,rgelt,pceltFetched) ) 

#define IEnumSTATSTG_Skip(This,celt)	\
    ( (This)->lpVtbl -> Skip(This,celt) ) 

#define IEnumSTATSTG_Reset(This)	\
    ( (This)->lpVtbl -> Reset(This) ) 

#define IEnumSTATSTG_Clone(This,ppenum)	\
    ( (This)->lpVtbl -> Clone(This,ppenum) ) 

--]]


ffi.cdef[[
typedef IStorage *LPSTORAGE;

typedef struct tagRemSNB
    {
    unsigned long ulCntStr;
    unsigned long ulCntChar;
    OLECHAR rgString[ 1 ];
    } 	RemSNB;

typedef RemSNB *wireSNB;

typedef LPOLESTR *SNB;

    typedef struct IStorageVtbl
    {
        
        HRESULT ( __stdcall *QueryInterface )( 
            IStorage * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
             void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IStorage * This);
        
        ULONG ( __stdcall *Release )( 
            IStorage * This);
        
        HRESULT ( __stdcall *CreateStream )( 
            IStorage * This,
            /* [string][in] */ const OLECHAR *pwcsName,
            /* [in] */ DWORD grfMode,
            /* [in] */ DWORD reserved1,
            /* [in] */ DWORD reserved2,
            /* [out] */ IStream **ppstm);
        
        /* [local] */ HRESULT ( __stdcall *OpenStream )( 
            IStorage * This,
            /* [string][in] */ const OLECHAR *pwcsName,
            /* [unique][in] */ void *reserved1,
            /* [in] */ DWORD grfMode,
            /* [in] */ DWORD reserved2,
            /* [out] */ IStream **ppstm);
        
        HRESULT ( __stdcall *CreateStorage )( 
            IStorage * This,
            /* [string][in] */ const OLECHAR *pwcsName,
            /* [in] */ DWORD grfMode,
            /* [in] */ DWORD reserved1,
            /* [in] */ DWORD reserved2,
            /* [out] */ IStorage **ppstg);
        
        HRESULT ( __stdcall *OpenStorage )( 
            IStorage * This,
            /* [string][unique][in] */ const OLECHAR *pwcsName,
            /* [unique][in] */ IStorage *pstgPriority,
            /* [in] */ DWORD grfMode,
            /* [unique][in] */  SNB snbExclude,
            /* [in] */ DWORD reserved,
            /* [out] */ IStorage **ppstg);
        
        /* [local] */ HRESULT ( __stdcall *CopyTo )( 
            IStorage * This,
            /* [in] */ DWORD ciidExclude,
            /* [size_is][unique][in] */ const IID *rgiidExclude,
            /* [annotation][unique][in] */ 
             SNB snbExclude,
            /* [unique][in] */ IStorage *pstgDest);
        
        HRESULT ( __stdcall *MoveElementTo )( 
            IStorage * This,
            /* [string][in] */ const OLECHAR *pwcsName,
            /* [unique][in] */ IStorage *pstgDest,
            /* [string][in] */ const OLECHAR *pwcsNewName,
            /* [in] */ DWORD grfFlags);
        
        HRESULT ( __stdcall *Commit )( 
            IStorage * This,
            /* [in] */ DWORD grfCommitFlags);
        
        HRESULT ( __stdcall *Revert )( 
            IStorage * This);
        
        /* [local] */ HRESULT ( __stdcall *EnumElements )( 
            IStorage * This,
            /* [in] */ DWORD reserved1,
            /* [size_is][unique][in] */ void *reserved2,
            /* [in] */ DWORD reserved3,
            /* [out] */ IEnumSTATSTG **ppenum);
        
        HRESULT ( __stdcall *DestroyElement )( 
            IStorage * This,
            /* [string][in] */ const OLECHAR *pwcsName);
        
        HRESULT ( __stdcall *RenameElement )( 
            IStorage * This,
            /* [string][in] */ const OLECHAR *pwcsOldName,
            /* [string][in] */ const OLECHAR *pwcsNewName);
        
        HRESULT ( __stdcall *SetElementTimes )( 
            IStorage * This,
            /* [string][unique][in] */ const OLECHAR *pwcsName,
            /* [unique][in] */ const FILETIME *pctime,
            /* [unique][in] */ const FILETIME *patime,
            /* [unique][in] */ const FILETIME *pmtime);
        
        HRESULT ( __stdcall *SetClass )( 
            IStorage * This,
            /* [in] */ REFCLSID clsid);
        
        HRESULT ( __stdcall *SetStateBits )( 
            IStorage * This,
            /* [in] */ DWORD grfStateBits,
            /* [in] */ DWORD grfMask);
        
        HRESULT ( __stdcall *Stat )( 
            IStorage * This,
            STATSTG *pstatstg,
            DWORD grfStatFlag);
        
    } IStorageVtbl;

    struct IStorage
    {
        const struct IStorageVtbl *lpVtbl;
    };

]]

--[[
#define IStorage_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IStorage_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IStorage_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IStorage_CreateStream(This,pwcsName,grfMode,reserved1,reserved2,ppstm)	\
    ( (This)->lpVtbl -> CreateStream(This,pwcsName,grfMode,reserved1,reserved2,ppstm) ) 

#define IStorage_OpenStream(This,pwcsName,reserved1,grfMode,reserved2,ppstm)	\
    ( (This)->lpVtbl -> OpenStream(This,pwcsName,reserved1,grfMode,reserved2,ppstm) ) 

#define IStorage_CreateStorage(This,pwcsName,grfMode,reserved1,reserved2,ppstg)	\
    ( (This)->lpVtbl -> CreateStorage(This,pwcsName,grfMode,reserved1,reserved2,ppstg) ) 

#define IStorage_OpenStorage(This,pwcsName,pstgPriority,grfMode,snbExclude,reserved,ppstg)	\
    ( (This)->lpVtbl -> OpenStorage(This,pwcsName,pstgPriority,grfMode,snbExclude,reserved,ppstg) ) 

#define IStorage_CopyTo(This,ciidExclude,rgiidExclude,snbExclude,pstgDest)	\
    ( (This)->lpVtbl -> CopyTo(This,ciidExclude,rgiidExclude,snbExclude,pstgDest) ) 

#define IStorage_MoveElementTo(This,pwcsName,pstgDest,pwcsNewName,grfFlags)	\
    ( (This)->lpVtbl -> MoveElementTo(This,pwcsName,pstgDest,pwcsNewName,grfFlags) ) 

#define IStorage_Commit(This,grfCommitFlags)	\
    ( (This)->lpVtbl -> Commit(This,grfCommitFlags) ) 

#define IStorage_Revert(This)	\
    ( (This)->lpVtbl -> Revert(This) ) 

#define IStorage_EnumElements(This,reserved1,reserved2,reserved3,ppenum)	\
    ( (This)->lpVtbl -> EnumElements(This,reserved1,reserved2,reserved3,ppenum) ) 

#define IStorage_DestroyElement(This,pwcsName)	\
    ( (This)->lpVtbl -> DestroyElement(This,pwcsName) ) 

#define IStorage_RenameElement(This,pwcsOldName,pwcsNewName)	\
    ( (This)->lpVtbl -> RenameElement(This,pwcsOldName,pwcsNewName) ) 

#define IStorage_SetElementTimes(This,pwcsName,pctime,patime,pmtime)	\
    ( (This)->lpVtbl -> SetElementTimes(This,pwcsName,pctime,patime,pmtime) ) 

#define IStorage_SetClass(This,clsid)	\
    ( (This)->lpVtbl -> SetClass(This,clsid) ) 

#define IStorage_SetStateBits(This,grfStateBits,grfMask)	\
    ( (This)->lpVtbl -> SetStateBits(This,grfStateBits,grfMask) ) 

#define IStorage_Stat(This,pstatstg,grfStatFlag)	\
    ( (This)->lpVtbl -> Stat(This,pstatstg,grfStatFlag) ) 


--]]


return {
	IID_IEnumSTATSTG 	= UUIDFromString("0000000d-0000-0000-C000-000000000046");
	IID_IStorage 		= UUIDFromString("0000000b-0000-0000-C000-000000000046");
	IID_IStream  		= UUIDFromString("0000000c-0000-0000-C000-000000000046");
}