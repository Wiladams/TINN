-- From WinUser.h

local ffi = require("ffi")
local WTypes = require("WTypes")

--[[
/*
 * Gesture defines and functions
 */
--]]

--[[
/*
 * Gesture information handle
 */
 --]]
DECLARE_HANDLE("HGESTUREINFO");

ffi.cdef[[
/*
 * Gesture flags - GESTUREINFO.dwFlags
 */
static const int GF_BEGIN                       = 0x00000001;
static const int GF_INERTIA                     = 0x00000002;
static const int GF_END                         = 0x00000004;
]]

ffi.cdef[[
/*
 * Gesture IDs
 */
static const int GID_BEGIN                      = 1;
static const int GID_END                        = 2;
static const int GID_ZOOM                       = 3;
static const int GID_PAN                        = 4;
static const int GID_ROTATE                     = 5;
static const int GID_TWOFINGERTAP               = 6;
static const int GID_PRESSANDTAP                = 7;
static const int GID_ROLLOVER                   = GID_PRESSANDTAP;
]]

ffi.cdef[[
/*
 * Gesture information structure
 *   - Pass the HGESTUREINFO received in the WM_GESTURE message lParam into the
 *     GetGestureInfo function to retrieve this information.
 *   - If cbExtraArgs is non-zero, pass the HGESTUREINFO received in the WM_GESTURE
 *     message lParam into the GetGestureExtraArgs function to retrieve extended
 *     argument information.
 */
typedef struct tagGESTUREINFO {
    UINT cbSize;                    // size, in bytes, of this structure (including variable length Args field)
    DWORD dwFlags;                  // see GF_* flags
    DWORD dwID;                     // gesture ID, see GID_* defines
    HWND hwndTarget;                // handle to window targeted by this gesture
    POINTS ptsLocation;             // current location of this gesture
    DWORD dwInstanceID;             // internally used
    DWORD dwSequenceID;             // internally used
    ULONGLONG ullArguments;         // arguments for gestures whose arguments fit in 8 BYTES
    UINT cbExtraArgs;               // size, in bytes, of extra arguments, if any, that accompany this gesture
} GESTUREINFO, *PGESTUREINFO;
typedef GESTUREINFO const * PCGESTUREINFO;
]]

ffi.cdef[[
/*
 * Gesture notification structure
 *   - The WM_GESTURENOTIFY message lParam contains a pointer to this structure.
 *   - The WM_GESTURENOTIFY message notifies a window that gesture recognition is
 *     in progress and a gesture will be generated if one is recognized under the
 *     current gesture settings.
 */
typedef struct tagGESTURENOTIFYSTRUCT {
    UINT cbSize;                    // size, in bytes, of this structure
    DWORD dwFlags;                  // unused
    HWND hwndTarget;                // handle to window targeted by the gesture
    POINTS ptsLocation;             // starting location
    DWORD dwInstanceID;             // internally used
} GESTURENOTIFYSTRUCT, *PGESTURENOTIFYSTRUCT;
]]

--[[
/*
 * Gesture argument helpers
 *   - Angle should be a double in the range of -2pi to +2pi
 *   - Argument should be an unsigned 16-bit value
 */
 --]]
local function GID_ROTATE_ANGLE_TO_ARGUMENT(_arg_)     
    return math.floor((((_arg_ + 2.0 * 3.14159265) / (4.0 * 3.14159265)) * 65535.0))
end 

local function GID_ROTATE_ANGLE_FROM_ARGUMENT(_arg_)   
    return ((_arg_ / 65535.0) * 4.0 * 3.14159265) - 2.0 * 3.14159265;
end

ffi.cdef[[
/*
 * Gesture information retrieval
 *   - HGESTUREINFO is received by a window in the lParam of a WM_GESTURE message.
 */
BOOL
GetGestureInfo(
    HGESTUREINFO hGestureInfo,
    PGESTUREINFO pGestureInfo);

/*
 * Gesture extra arguments retrieval
 *   - HGESTUREINFO is received by a window in the lParam of a WM_GESTURE message.
 *   - Size, in bytes, of the extra argument data is available in the cbExtraArgs
 *     field of the GESTUREINFO structure retrieved using the GetGestureInfo function.
 */
BOOL
GetGestureExtraArgs(
    HGESTUREINFO hGestureInfo,
    UINT cbExtraArgs,
    PBYTE pExtraArgs);

/*
 * Gesture information handle management
 *   - If an application processes the WM_GESTURE message, then once it is done
 *     with the associated HGESTUREINFO, the application is responsible for
 *     closing the handle using this function. Failure to do so may result in
 *     process memory leaks.
 *   - If the message is instead passed to DefWindowProc, or is forwarded using
 *     one of the PostMessage or SendMessage class of API functions, the handle
 *     is transfered with the message and need not be closed by the application.
 */
BOOL CloseGestureInfoHandle(HGESTUREINFO hGestureInfo);
]]

ffi.cdef[[

/*
 * Gesture configuration structure
 *   - Used in SetGestureConfig and GetGestureConfig
 *   - Note that any setting not included in either GESTURECONFIG.dwWant or
 *     GESTURECONFIG.dwBlock will use the parent window's preferences or
 *     system defaults.
 */
typedef struct tagGESTURECONFIG {
    DWORD dwID;                     // gesture ID
    DWORD dwWant;                   // settings related to gesture ID that are to be turned on
    DWORD dwBlock;                  // settings related to gesture ID that are to be turned off
} GESTURECONFIG, *PGESTURECONFIG;

/*
 * Gesture configuration flags - GESTURECONFIG.dwWant or GESTURECONFIG.dwBlock
 */

/*
 * Common gesture configuration flags - set GESTURECONFIG.dwID to zero
 */
static const int GC_ALLGESTURES                             = 0x00000001;

/*
 * Zoom gesture configuration flags - set GESTURECONFIG.dwID to GID_ZOOM
 */
static const int GC_ZOOM                                    = 0x00000001;

/*
 * Pan gesture configuration flags - set GESTURECONFIG.dwID to GID_PAN
 */
static const int GC_PAN                                     = 0x00000001;
static const int GC_PAN_WITH_SINGLE_FINGER_VERTICALLY       = 0x00000002;
static const int GC_PAN_WITH_SINGLE_FINGER_HORIZONTALLY     = 0x00000004;
static const int GC_PAN_WITH_GUTTER                         = 0x00000008;
static const int GC_PAN_WITH_INERTIA                        = 0x00000010;

/*
 * Rotate gesture configuration flags - set GESTURECONFIG.dwID to GID_ROTATE
 */
static const int GC_ROTATE                                  = 0x00000001;

/*
 * Two finger tap gesture configuration flags - set GESTURECONFIG.dwID to GID_TWOFINGERTAP
 */
static const int GC_TWOFINGERTAP                            = 0x00000001;

/*
 * PressAndTap gesture configuration flags - set GESTURECONFIG.dwID to GID_PRESSANDTAP
 */
static const int GC_PRESSANDTAP                             = 0x00000001;
static const int GC_ROLLOVER                                = GC_PRESSANDTAP;

static const int GESTURECONFIGMAXCOUNT          = 256;             // Maximum number of gestures that can be included
                                                        // in a single call to SetGestureConfig / GetGestureConfig

BOOL
SetGestureConfig(
    HWND hwnd,                                     // window for which configuration is specified
    DWORD dwReserved,                              // reserved, must be 0
    UINT cIDs,                                     // count of GESTURECONFIG structures
    PGESTURECONFIG pGestureConfig,    // array of GESTURECONFIG structures, dwIDs will be processed in the
                                                        // order specified and repeated occurances will overwrite previous ones
    UINT cbSize);                                  // sizeof(GESTURECONFIG)


static const int GCF_INCLUDE_ANCESTORS          = 0x00000001;      // If specified, GetGestureConfig returns consolidated configuration
                                                        // for the specified window and it's parent window chain

BOOL
GetGestureConfig(
    HWND hwnd,                                     // window for which configuration is required
    DWORD dwReserved,                              // reserved, must be 0
    DWORD dwFlags,                                 // see GCF_* flags
    PUINT pcIDs,                                   // *pcIDs contains the size, in number of GESTURECONFIG structures,
                                                        // of the buffer pointed to by pGestureConfig
    PGESTURECONFIG pGestureConfig,
                                                        // pointer to buffer to receive the returned array of GESTURECONFIG structures
    UINT cbSize);                                  // sizeof(GESTURECONFIG)
]]

local Lib = ffi.load("user32")

local exports = {
    CloseGestureInfoHandle = Lib.CloseGestureInfoHandle,
    
    GetGestureConfig = Lib.GetGestureConfig,
    GetGestureExtraArgs = Lib.GetGestureExtraArgs,
    GetGestureInfo = Lib.GetGestureInfo,

    SetGestureConfig = Lib.SetGestureConfig,

    GID_ROTATE_ANGLE_TO_ARGUMENT = GID_ROTATE_ANGLE_TO_ARGUMENT,
    GID_ROTATE_ANGLE_FROM_ARGUMENT = GID_ROTATE_ANGLE_FROM_ARGUMENT,
}