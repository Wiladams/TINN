-- d2dBaseTypes.lua

local ffi = require("ffi")



if not D3DCOLORVALUE_DEFINED then
ffi.cdef[[
//+-----------------------------------------------------------------------------
//
//  Struct:
//      D3DCOLORVALUE
//
//------------------------------------------------------------------------------
typedef struct D3DCOLORVALUE
{
    FLOAT r;
    FLOAT g;
    FLOAT b;
    FLOAT a;

} D3DCOLORVALUE;
]]
D3DCOLORVALUE = ffi.typeof("D3DCOLORVALUE")
D3DCOLORVALUE_DEFINED = true;
end

ffi.cdef[[
//+-----------------------------------------------------------------------------
//
//  Struct:
//      D2D_POINT_2U
//
//------------------------------------------------------------------------------
typedef struct D2D_POINT_2U
{
    UINT32 x;
    UINT32 y;
} D2D_POINT_2U;


//+-----------------------------------------------------------------------------
//
//  Struct:
//      D2D_POINT_2F
//
//------------------------------------------------------------------------------
typedef struct D2D_POINT_2F
{
    FLOAT x;
    FLOAT y;
} D2D_POINT_2F;


//+-----------------------------------------------------------------------------
//
//  Struct:
//      D2D_RECT_F
//
//------------------------------------------------------------------------------
typedef struct D2D_RECT_F
{
    FLOAT left;
    FLOAT top;
    FLOAT right;
    FLOAT bottom;
} D2D_RECT_F;


//+-----------------------------------------------------------------------------
//
//  Struct:
//      D2D_RECT_U
//
//------------------------------------------------------------------------------
typedef struct D2D_RECT_U
{
    UINT32 left;
    UINT32 top;
    UINT32 right;
    UINT32 bottom;
} D2D_RECT_U;


//+-----------------------------------------------------------------------------
//
//  Struct:
//      D2D_SIZE_F
//
//------------------------------------------------------------------------------
typedef struct D2D_SIZE_F
{
    FLOAT width;
    FLOAT height;
} D2D_SIZE_F;


//+-----------------------------------------------------------------------------
//
//  Struct:
//      D2D_SIZE_U
//
//------------------------------------------------------------------------------
typedef struct D2D_SIZE_U
{
    UINT32 width;
    UINT32 height;
} D2D_SIZE_U;

typedef D3DCOLORVALUE D2D_COLOR_F;

//+-----------------------------------------------------------------------------
//
//  Struct:
//      D2D_MATRIX_3X2_F
//
//------------------------------------------------------------------------------
typedef struct D2D_MATRIX_3X2_F
{
    FLOAT _11;
    FLOAT _12;
    FLOAT _21;
    FLOAT _22;
    FLOAT _31;
    FLOAT _32;
} D2D_MATRIX_3X2_F;
]]


