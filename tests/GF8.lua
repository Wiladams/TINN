-- GF8.lua

local ffi = require("ffi");
local bit = require("bit");
local band = bit.band;
local bor = bit.bor;
local bxor = bit.bxor;
local lshift = bit.lshift;
local rshift = bit.rshift;

local MAXBYTE = 0xff;

ffi.cdef[[
typedef struct {
    int32_t i;
} GF8;

]]

local gf_log = ffi.new("uint8_t[?]",MAXBYTE + 1);
local gf_exp = ffi.new("uint8_t[?]",(MAXBYTE + 1) * 2);
local inverse = ffi.new("uint8_t[?]", MAXBYTE + 1);


local GF8 = ffi.typeof("GF8");
local GF8_mt = {
    __new = function(ct, i)
        if i < 0 or i > MAXBYTE then
            return nil;
        end

        return ffi.new(ct, band(i,0xff));
    end,

    __index = {
        isEmpty = function(self)
            return self.i == -1;
        end,

    },

    __eq = function(self, other)
        return self.i == other.i;
    end,

    __add = function(self, other)
        return GF8(bxor(self.i, other.i));
    end,

    -- subtraction is the same as addition!
    __sub = function(self, other)
        return GF8(bxor(self.i, other.i));
    end,

    __mul = function(self, other)
        if (self.i == 0 or other.i == 0) then 
            return GF8(0);
        end
        -- BUGBUG, check for valid value

        return GF8(gf_exp[gf_log[self.i] + gf_log[other.i] ]);
    end,

    __div = function(self, other)
        if (other.i == 0) then
            --throw new DivideByZeroException();
            return nil, "divide by zero";
        end

        if self.i == 0 then
            return GF8(0);
        end

        return GF8(gf_exp[gf_log[self.i] + gf_log[inverse[other.i] ] ]);
    end,

    __pow = function(self, exponent)
        if (self.i == 0) then
            return GF8(0);
        end

        if (exponent == 0) then
            return GF8(1);
        end

        local ret = GF8(self.i);
        local i = 1
        while  i < exponent-1 do
            ret = ret * self
            i = i + 1;
        end

        return GF8(ret.i);
    end,

    __tostring = function(self)
        if self.i == -1 then
            return "empty"
        end

        return tostring(self.i);
    end,
}
ffi.metatype(GF8, GF8_mt);

local classInitialize = function()
    --GF8.empty = new GF8(0);
    --empty.i = -1;

    local primitive_polynomial = 285;

    local mask = 1;
    gf_exp[8] = 0;

    local i = 0; 
    while (i < MAXBYTE) do
    
        gf_exp[i] = band(mask, 0xff);
        gf_log[mask] = i;

        mask = lshift(mask,1);
        if (band(mask, 256) ~= 0) then
            mask = bxor(mask, primitive_polynomial);
        end
        i = i + 1;
    end

    -- set the extended gf_exp values for fast multiply
    local i = 0;
    while (i < MAXBYTE ) do
        gf_exp[i + MAXBYTE] = gf_exp[i];
        i = i + 1;
    end

    inverse[0] = 0;
    inverse[1] = 1;

    local i = 2; 
    while (i <= MAXBYTE) do
        inverse[i] = gf_exp[MAXBYTE - gf_log[i]];
        i = i + 1;
    end
end

classInitialize();


--[=[
    public struct GF8
    {
        public static byte Modnn(Int32 x)
        {
            while (x >= byte.MaxValue)
            {
                x -= byte.MaxValue;
                x = (byte)((x >> 8) + (x & byte.MaxValue));
            }
            return (byte)x;
        }
    }
--]=]


return GF8;
