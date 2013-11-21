-- cabinet.lua	
-- cabinet.dll	

local ffi = require("ffi");

local WTypes = require("WTypes");
local basetsd = require("basetsd")

DECLARE_HANDLE("COMPRESSOR_HANDLE");

ffi.cdef[[
typedef COMPRESSOR_HANDLE *PCOMPRESSOR_HANDLE;

typedef COMPRESSOR_HANDLE DECOMPRESSOR_HANDLE;
typedef COMPRESSOR_HANDLE *PDECOMPRESSOR_HANDLE;

static const int COMPRESS_ALGORITHM_INVALID     = 0;
static const int COMPRESS_ALGORITHM_NULL        = 1;
static const int COMPRESS_ALGORITHM_MSZIP       = 2;
static const int COMPRESS_ALGORITHM_XPRESS      = 3;
static const int COMPRESS_ALGORITHM_XPRESS_HUFF = 4;
static const int COMPRESS_ALGORITHM_LZMS        = 5;
static const int COMPRESS_ALGORITHM_MAX         = 6;

static const int COMPRESS_RAW            = (1 << 29);

typedef PVOID (*PFN_COMPRESS_ALLOCATE) (
    PVOID UserContext,
    SIZE_T Size
    );

typedef VOID (*PFN_COMPRESS_FREE) (
    PVOID UserContext,
    PVOID Memory
    );

typedef struct _COMPRESS_ALLOCATION_ROUTINES {
    PFN_COMPRESS_ALLOCATE Allocate;
    PFN_COMPRESS_FREE Free;
    PVOID UserContext;
} COMPRESS_ALLOCATION_ROUTINES, *PCOMPRESS_ALLOCATION_ROUTINES;

typedef enum {
    COMPRESS_INFORMATION_CLASS_INVALID = 0,
    COMPRESS_INFORMATION_CLASS_BLOCK_SIZE,
    COMPRESS_INFORMATION_CLASS_LEVEL
} COMPRESS_INFORMATION_CLASS;
]]

ffi.cdef[[
BOOL
CloseCompressor (
    COMPRESSOR_HANDLE CompressorHandle
    );

BOOL
CloseDecompressor (
    DECOMPRESSOR_HANDLE DecompressorHandle
    );

BOOL
Compress (
    COMPRESSOR_HANDLE CompressorHandle,
    PVOID UncompressedData,
    SIZE_T UncompressedDataSize,
    PVOID CompressedBuffer,
    SIZE_T CompressedBufferSize,
    PSIZE_T CompressedDataSize
    );

BOOL
CreateCompressor (
    DWORD Algorithm,
    PCOMPRESS_ALLOCATION_ROUTINES AllocationRoutines,
    PCOMPRESSOR_HANDLE CompressorHandle
    );

BOOL
CreateDecompressor (
    DWORD Algorithm,
    PCOMPRESS_ALLOCATION_ROUTINES AllocationRoutines,
    PDECOMPRESSOR_HANDLE DecompressorHandle
    );

BOOL
Decompress (
    DECOMPRESSOR_HANDLE DecompressorHandle,
    PVOID CompressedData,
    SIZE_T CompressedDataSize,
    PVOID UncompressedBuffer,
    SIZE_T UncompressedBufferSize,
    PSIZE_T UncompressedDataSize
    );
]]

ffi.cdef[[
BOOL
QueryCompressorInformation (
    COMPRESSOR_HANDLE CompressorHandle,
    COMPRESS_INFORMATION_CLASS CompressInformationClass,
    PVOID CompressInformation,
    SIZE_T CompressInformationSize
    );

BOOL
QueryDecompressorInformation (
    DECOMPRESSOR_HANDLE DecompressorHandle,
    COMPRESS_INFORMATION_CLASS CompressInformationClass,
    PVOID CompressInformation,
    SIZE_T CompressInformationSize
    );

BOOL
ResetCompressor (
    COMPRESSOR_HANDLE CompressorHandle
    );

BOOL
ResetDecompressor (
    DECOMPRESSOR_HANDLE DecompressorHandle
    );

BOOL
SetCompressorInformation (
    COMPRESSOR_HANDLE CompressorHandle,
    COMPRESS_INFORMATION_CLASS CompressInformationClass,
    PVOID CompressInformation,
    SIZE_T CompressInformationSize
    );

BOOL
SetDecompressorInformation (
    DECOMPRESSOR_HANDLE DecompressorHandle,
    COMPRESS_INFORMATION_CLASS CompressInformationClass,
    PVOID CompressInformation,
    SIZE_T CompressInformationSize
    );
]]

-- fci.h
ffi.cdef[[
typedef struct {
    int     erfOper;            // FCI/FDI error code -- see FDIERROR_XXX
                                //  and FCIERR_XXX equates for details.

    int     erfType;            // Optional error value filled in by FCI/FDI.
                                // For FCI, this is usually the C run-time
                                // *errno* value.

    BOOL    fError;             // TRUE => error present
} ERF;      /* erf */
typedef ERF *PERF;  /* perf */

// BUGBUG - Should honor unsigned ?
static const int CB_MAX_CHUNK           = 32768; // U
static const int CB_MAX_DISK       = 0x7fffffff; //L
static const int CB_MAX_FILENAME           = 256;
static const int CB_MAX_CABINET_NAME       = 256;
static const int CB_MAX_CAB_PATH           = 256;
static const int CB_MAX_DISK_NAME          = 256;

typedef unsigned short TCOMP; /* tcomp */

static const int tcompMASK_TYPE         = 0x000F;  // Mask for compression type
static const int tcompTYPE_NONE         = 0x0000;  // No compression
static const int tcompTYPE_MSZIP        = 0x0001;  // MSZIP
static const int tcompTYPE_QUANTUM      = 0x0002;  // Quantum
static const int tcompTYPE_LZX          = 0x0003;  // LZX
static const int tcompBAD               = 0x000F;  // Unspecified compression type

static const int tcompMASK_LZX_WINDOW   = 0x1F00;  // Mask for LZX Compression Memory
static const int tcompLZX_WINDOW_LO     = 0x0F00;  // Lowest LZX Memory (15)
static const int tcompLZX_WINDOW_HI     = 0x1500;  // Highest LZX Memory (21)
static const int tcompSHIFT_LZX_WINDOW       = 8;  // Amount to shift over to get int

static const int tcompMASK_QUANTUM_LEVEL =0x00F0;  // Mask for Quantum Compression Level
static const int tcompQUANTUM_LEVEL_LO   =0x0010;  // Lowest Quantum Level (1)
static const int tcompQUANTUM_LEVEL_HI   =0x0070;  // Highest Quantum Level (7)
static const int tcompSHIFT_QUANTUM_LEVEL    = 4;  // Amount to shift over to get int

static const int tcompMASK_QUANTUM_MEM  = 0x1F00;  // Mask for Quantum Compression Memory
static const int tcompQUANTUM_MEM_LO    = 0x0A00;  // Lowest Quantum Memory (10)
static const int tcompQUANTUM_MEM_HI    = 0x1500;  // Highest Quantum Memory (21)
static const int tcompSHIFT_QUANTUM_MEM      = 8;  // Amount to shift over to get int

static const int tcompMASK_RESERVED     = 0xE000;  // Reserved bits (high 3 bits)

]]

--[[
#define CompressionTypeFromTCOMP(tc) \
            ((tc) & tcompMASK_TYPE)

#define CompressionLevelFromTCOMP(tc) \
            (((tc) & tcompMASK_QUANTUM_LEVEL) >> tcompSHIFT_QUANTUM_LEVEL)

#define CompressionMemoryFromTCOMP(tc) \
            (((tc) & tcompMASK_QUANTUM_MEM) >> tcompSHIFT_QUANTUM_MEM)

#define TCOMPfromTypeLevelMemory(t,l,m)           \
            (((m) << tcompSHIFT_QUANTUM_MEM  ) |  \
             ((l) << tcompSHIFT_QUANTUM_LEVEL) |  \
             ( t                             ))

#define LZXCompressionWindowFromTCOMP(tc) \
            (((tc) & tcompMASK_LZX_WINDOW) >> tcompSHIFT_LZX_WINDOW)

#define TCOMPfromLZXWindow(w)      \
            (((w) << tcompSHIFT_LZX_WINDOW ) |  \
             ( tcompTYPE_LZX ))

--]]

if _WIN64 then
--#include <pshpack4.h>
end

ffi.cdef[[
/***    FCIERROR - Error codes returned in erf.erfOper field
 *
 */
typedef enum {
FCIERR_NONE,                // No error

FCIERR_OPEN_SRC,            // Failure opening file to be stored in cabinet

FCIERR_READ_SRC,            // Failure reading file to be stored in cabinet

FCIERR_ALLOC_FAIL,          // Out of memory in FCI

FCIERR_TEMP_FILE,           // Could not create a temporary file

FCIERR_BAD_COMPR_TYPE,      // Unknown compression type

FCIERR_CAB_FILE,            // Could not create cabinet file

FCIERR_USER_ABORT,          // Client requested abort

FCIERR_MCI_FAIL,            // Failure compressing data

FCIERR_CAB_FORMAT_LIMIT     // Data-size or file-count exceeded CAB format limits

} FCIERROR;
]]

ffi.cdef[[
static const int _A_NAME_IS_UTF = 0x80;
static const int _A_EXEC        = 0x40;

typedef void * HFCI;
]]

ffi.cdef[[
/***    CCAB - Current Cabinet
 *
 *  This structure is used for passing in the cabinet parameters to FCI,
 *  and is passed back on certain FCI callbacks to provide cabinet
 *  information to the client.
 */
typedef struct {
// longs first
    ULONG  cb;                  // size available for cabinet on this media
    ULONG  cbFolderThresh;      // Thresshold for forcing a new Folder

// then ints
    UINT   cbReserveCFHeader;   // Space to reserve in CFHEADER
    UINT   cbReserveCFFolder;   // Space to reserve in CFFOLDER
    UINT   cbReserveCFData;     // Space to reserve in CFDATA
    int    iCab;                // sequential numbers for cabinets
    int    iDisk;               // Disk number
//#ifndef REMOVE_CHICAGO_M6_HACK
    int    fFailOnIncompressible; // TRUE => Fail if a block is incompressible
//#endif

//  then shorts
    USHORT setID;               // Cabinet set ID

// then chars
    char   szDisk[CB_MAX_DISK_NAME];    // current disk name
    char   szCab[CB_MAX_CABINET_NAME];  // current cabinet name
    char   szCabPath[CB_MAX_CAB_PATH];  // path for creating cabinet
} CCAB; /* ccab */
typedef CCAB *PCCAB; /* pccab */
]]

ffi.cdef[[
//** Memory functions for FCI
typedef void * (*PFNFCIALLOC)(ULONG cb); /* pfna */

typedef void (*PFNFCIFREE)(void *memory); /* pfnf */


//** File I/O functions for FCI
typedef INT_PTR (*PFNFCIOPEN) (LPSTR pszFile, int oflag, int pmode, int *err, void *pv);
typedef UINT (*PFNFCIREAD) (INT_PTR hf, void *memory, UINT cb, int *err, void *pv);
typedef UINT (*PFNFCIWRITE)(INT_PTR hf, void *memory, UINT cb, int *err, void *pv);
typedef int  (*PFNFCICLOSE)(INT_PTR hf, int *err, void *pv);
typedef long (*PFNFCISEEK) (INT_PTR hf, long dist, int seektype, int *err, void *pv);
typedef int  (*PFNFCIDELETE) (LPSTR pszFile, int *err, void *pv);
]]

--[[
#define FNFCIALLOC(fn) void HUGE * FAR DIAMONDAPI fn(ULONG cb)
#define FNFCIFREE(fn) void FAR DIAMONDAPI fn(void HUGE *memory)

#define FNFCIOPEN(fn) INT_PTR FAR DIAMONDAPI fn(_In_ LPSTR pszFile, int oflag, int pmode, int FAR *err, void FAR *pv)
#define FNFCIREAD(fn) UINT FAR DIAMONDAPI fn(INT_PTR hf, void FAR *memory, UINT cb, int FAR *err, void FAR *pv)
#define FNFCIWRITE(fn) UINT FAR DIAMONDAPI fn(INT_PTR hf, void FAR *memory, UINT cb, int FAR *err, void FAR *pv)
#define FNFCICLOSE(fn) int FAR DIAMONDAPI fn(INT_PTR hf, int FAR *err, void FAR *pv)
#define FNFCISEEK(fn) long FAR DIAMONDAPI fn(INT_PTR hf, long dist, int seektype, int FAR *err, void FAR *pv)
#define FNFCIDELETE(fn) int FAR DIAMONDAPI fn(_In_ LPSTR pszFile, int FAR *err, void FAR *pv)
--]]

ffi.cdef[[
typedef BOOL (*PFNFCIGETNEXTCABINET)(PCCAB  pccab,
                                                ULONG  cbPrevCab,
                                                void *pv); /* pfnfcignc */
typedef int (*PFNFCIFILEPLACED)(PCCAB pccab,
                                           LPSTR pszFile,
                                           long  cbFile,
                                           BOOL  fContinuation,
                                           void *pv); /* pfnfcifp */

typedef INT_PTR (*PFNFCIGETOPENINFO)(LPSTR pszName,
                                                USHORT *pdate,
                                                USHORT *ptime,
                                                USHORT *pattribs,
                                                int *err,
                                                void *pv); /* pfnfcigoi */

static const int statusFile     = 0;   // Add File to Folder callback
static const int statusFolder   = 1;   // Add Folder to Cabinet callback
static const int statusCabinet  = 2;   // Write out a completed cabinet callback

typedef long (*PFNFCISTATUS)(UINT   typeStatus,
                                        ULONG  cb1,
                                        ULONG  cb2,
                                        void *pv); /* pfnfcis */

typedef BOOL (*PFNFCIGETTEMPFILE)(char *pszTempName,
                                             int   cbTempName,
                                             void *pv); /* pfnfcigtf */

]]


ffi.cdef[[
typedef void *HFDI; /* hfdi */
]]




ffi.cdef[[
typedef enum {
    FDIERROR_NONE,

    FDIERROR_CABINET_NOT_FOUND,

    FDIERROR_NOT_A_CABINET,

    FDIERROR_UNKNOWN_CABINET_VERSION,

    FDIERROR_CORRUPT_CABINET,

    FDIERROR_ALLOC_FAIL,

    FDIERROR_BAD_COMPR_TYPE,

    FDIERROR_MDI_FAIL,

    FDIERROR_TARGET_FILE,

    FDIERROR_RESERVE_MISMATCH,

    FDIERROR_WRONG_CABINET,

    FDIERROR_USER_ABORT,

    FDIERROR_EOF,

} FDIERROR;
]]



ffi.cdef[[
/***    FDICABINETINFO - Information about a cabinet
 *
 */
typedef struct {
    long        cbCabinet;              // Total length of cabinet file
    USHORT      cFolders;               // Count of folders in cabinet
    USHORT      cFiles;                 // Count of files in cabinet
    USHORT      setID;                  // Cabinet set ID
    USHORT      iCabinet;               // Cabinet number in set (0 based)
    BOOL        fReserve;               // TRUE => RESERVE present in cabinet
    BOOL        hasprev;                // TRUE => Cabinet is chained prev
    BOOL        hasnext;                // TRUE => Cabinet is chained next
} FDICABINETINFO; /* fdici */
typedef FDICABINETINFO  *PFDICABINETINFO; /* pfdici */


/***    FDIDECRYPTTYPE - PFNFDIDECRYPT command types
 *
 */
typedef enum {
    fdidtNEW_CABINET,                   // New cabinet
    fdidtNEW_FOLDER,                    // New folder
    fdidtDECRYPT,                       // Decrypt a data block
} FDIDECRYPTTYPE; /* fdidt */


/***    FDIDECRYPT - Data for PFNFDIDECRYPT function
 *
 */
typedef struct {
    FDIDECRYPTTYPE    fdidt;            // Command type (selects union below)
    void          *pvUser;           // Decryption context
    union {
        struct {                        // fdidtNEW_CABINET
            void  *pHeaderReserve;   // RESERVE section from CFHEADER
            USHORT    cbHeaderReserve;  // Size of pHeaderReserve
            USHORT    setID;            // Cabinet set ID
            int       iCabinet;         // Cabinet number in set (0 based)
        } cabinet;

        struct {                        // fdidtNEW_FOLDER
            void  *pFolderReserve;   // RESERVE section from CFFOLDER
            USHORT    cbFolderReserve;  // Size of pFolderReserve
            USHORT    iFolder;          // Folder number in cabinet (0 based)
        } folder;

        struct {                        // fdidtDECRYPT
            void  *pDataReserve;     // RESERVE section from CFDATA
            USHORT    cbDataReserve;    // Size of pDataReserve
            void  *pbData;           // Data buffer
            USHORT    cbData;           // Size of data buffer
            BOOL      fSplit;           // TRUE if this is a split data block
            USHORT    cbPartial;        // 0 if this is not a split block, or
                                        //  the first piece of a split block;
                                        // Greater than 0 if this is the
                                        //  second piece of a split block.
        } decrypt;
    };
} FDIDECRYPT; /* fdid */
typedef FDIDECRYPT  *PFDIDECRYPT; /* pfdid */
]]


ffi.cdef[[
//** Memory functions for FDI
typedef void * (*PFNALLOC)(ULONG cb); /* pfna */
typedef void (*PFNFREE)(void  *pv); /* pfnf */
]]

local FNALLOC = function(fn, cb) 
	return fn(cb);
end

local FNFREE = function(fn, pv) 
	return  fn(pv);
end

ffi.cdef[[
//** File I/O functions for FDI
typedef INT_PTR (*PFNOPEN) (LPSTR pszFile, int oflag, int pmode);
typedef UINT (*PFNREAD) (INT_PTR hf, void *pv, UINT cb);
typedef UINT (*PFNWRITE)(INT_PTR hf, void *pv, UINT cb);
typedef int  (*PFNCLOSE)(INT_PTR hf);
typedef long (*PFNSEEK) (INT_PTR hf, long dist, int seektype);
]]

--[[
#define FNOPEN(fn) INT_PTR   fn(_In_ LPSTR pszFile, int oflag, int pmode)
#define FNREAD(fn) UINT   fn(_In_ INT_PTR hf, _Out_writes_bytes_(cb) void  *pv, UINT cb)
#define FNWRITE(fn) UINT   fn(_In_ INT_PTR hf, _In_reads_bytes_(cb) void  *pv, UINT cb)
#define FNCLOSE(fn) int   fn(_In_ INT_PTR hf)
#define FNSEEK(fn) long   fn(_In_ INT_PTR hf, long dist, int seektype)
--]]

ffi.cdef[[
typedef int (  *PFNFDIDECRYPT)(PFDIDECRYPT pfdid); /* pfnfdid */


typedef struct {
// long fields
    long      cb;
    char  *psz1;
    char  *psz2;
    char  *psz3;                     // Points to a 256 character buffer
    void  *pv;                       // Value for client

// int fields
    INT_PTR   hf;

// short fields
    USHORT    date;
    USHORT    time;
    USHORT    attribs;

    USHORT    setID;                    // Cabinet set ID
    USHORT    iCabinet;                 // Cabinet number (0-based)
    USHORT    iFolder;                  // Folder number (0-based)

    FDIERROR  fdie;
} FDINOTIFICATION,  *PFDINOTIFICATION;  /* fdin, pfdin */

typedef enum {
    fdintCABINET_INFO,              // General information about cabinet
    fdintPARTIAL_FILE,              // First file in cabinet is continuation
    fdintCOPY_FILE,                 // File to be copied
    fdintCLOSE_FILE_INFO,           // close the file, set relevant info
    fdintNEXT_CABINET,              // File continued to next cabinet
    fdintENUMERATE,                 // Enumeration status
} FDINOTIFICATIONTYPE; /* fdint */

typedef INT_PTR (  *PFNFDINOTIFY)(FDINOTIFICATIONTYPE fdint, PFDINOTIFICATION    pfdin); /* pfnfdin */
]]

--#define FNFDIDECRYPT(fn) int   fn(PFDIDECRYPT pfdid)
--#define FNFDINOTIFY(fn) INT_PTR   fn(FDINOTIFICATIONTYPE fdint, PFDINOTIFICATION    pfdin)

if _WIN64 then
--#pragma pack (1)
end

ffi.cdef[[
/** FDISPILLFILE - Pass as pszFile on PFNOPEN to create spill file
 *
 *  ach    - A two byte string to signal to PFNOPEN that a spill file is
 *           requested.  Value is '*','\0'.
 *  cbFile - Required spill file size, in bytes.
 */
typedef struct {
    char    ach[2];                 // Set to { '*', '\0' }
    long    cbFile;                 // Required spill file size
} FDISPILLFILE; /* fdisf */
typedef FDISPILLFILE *PFDISPILLFILE; /* pfdisf */
]]



if _WIN64 then
--#pragma pack ()
end

ffi.cdef[[
static const int     cpuUNKNOWN       =  (-1);    /* FDI does detection */
static const int     cpu80286         =  (0);     /* '286 opcodes only */
static const int     cpu80386         =  (1);     /* '386 opcodes used */
]]

ffi.cdef[[

BOOL FCIAddFile(HFCI                        hfci,
                           LPSTR                       pszSourceFile,
                           LPSTR                       pszFileName,
                           BOOL                             fExecute,
                           PFNFCIGETNEXTCABINET  pfnfcignc,
                           PFNFCISTATUS          pfnfcis,
                           PFNFCIGETOPENINFO     pfnfcigoi,
                           TCOMP                            typeCompress
                          );

HFCI FCICreate(      PERF               perf,
                          PFNFCIFILEPLACED   pfnfcifp,
                          PFNFCIALLOC        pfna,
                          PFNFCIFREE         pfnf,
                          PFNFCIOPEN         pfnopen,
                          PFNFCIREAD         pfnread,
                          PFNFCIWRITE        pfnwrite,
                          PFNFCICLOSE        pfnclose,
                          PFNFCISEEK         pfnseek,
                          PFNFCIDELETE       pfndelete,
                          PFNFCIGETTEMPFILE  pfnfcigtf,
                                PCCAB              pccab,
                          void             *pv
                         );

BOOL FCIDestroy (HFCI hfci);

BOOL FCIFlushCabinet(HFCI                       hfci,
                                BOOL                            fGetNextCab,
                                PFNFCIGETNEXTCABINET pfnfcignc,
                                PFNFCISTATUS         pfnfcis
                               );

BOOL FCIFlushFolder(HFCI                        hfci,
                               PFNFCIGETNEXTCABINET  pfnfcignc,
                               PFNFCISTATUS          pfnfcis
                              );
]]

-- fdi.h
ffi.cdef[[
BOOL  FDICopy(HFDI                   hfdi,
                            LPSTR                  pszCabinet,
                            LPSTR                  pszCabPath,
                            int                         flags,
                            PFNFDINOTIFY     pfnfdin,
                            PFNFDIDECRYPT    pfnfdid,
                            void            *pvUser);

HFDI  FDICreate(PFNALLOC pfnalloc,
                              PFNFREE  pfnfree,
                              PFNOPEN  pfnopen,
                              PFNREAD  pfnread,
                              PFNWRITE pfnwrite,
                              PFNCLOSE pfnclose,
                              PFNSEEK  pfnseek,
                              int                 cpuType,
                                 PERF     perf);

BOOL  FDIDestroy(HFDI hfdi);


BOOL  FDIIsCabinet( HFDI             hfdi,
                                  INT_PTR          hf,
                                 PFDICABINETINFO  pfdici);


BOOL  FDITruncateCabinet(HFDI    hfdi,
                                       LPSTR   pszCabinetName,
                                       USHORT       iFolderToDelete);


]]



local Lib = ffi.load("cabinet");

if not Lib then
	return false;
end

-- windows 8 only
return {

CloseCompressor = Lib.CloseCompressor,
CloseDecompressor = Lib.CloseDecompressor,
Compress = Lib.Compress,
CreateCompressor = Lib.CreateCompressor,
CreateDecompressor = Lib.CreateDecompressor,
Decompress = Lib.Decompress,
--DeleteExtractedFiles
--Extract
FCIAddFile = Lib.FCIAddFile,
FCICreate = Lib.FCICreate,
FCIDestroy = Lib.FCIDestroy,
FCIFlushCabinet = Lib.FCIFlushCabinet,
FCIFlushFolder = Lib.FCIFlushFolder,
FDICopy = Lib.FDICopy,
FDICreate = Lib.FDICreate,
FDIDestroy = Lib.FDIDestroy,
FDIIsCabinet = Lib.FDIIsCabinet,
FDITruncateCabinet = Lib.FDITruncateCabinet,
QueryCompressorInformation = Lib.QueryCompressorInformation,
QueryDecompressorInformation = Lib.QueryDecompressorInformation,
ResetCompressor = Lib.ResetCompressor,
ResetDecompressor = Lib.ResetDecompressor,
SetCompressorInformation = Lib.SetCompressorInformation,
SetDecompressorInformation = Lib.SetDecompressorInformation,
}
