--[[
   table.bininsert( table, value [, comp] )
   
   Inserts a given value through BinaryInsert into the table sorted by [, comp].
   
   If 'comp' is given, then it must be a function that receives
   two table elements, and returns true when the first is less
   than the second, e.g. comp = function(a, b) return a > b end,
   will give a sorted table, with the biggest value on position 1.
   [, comp] behaves as in table.sort(table, value [, comp])
   returns the index where 'value' was inserted
]]--

local floor = math.floor;
local insert = table.insert;

-- Avoid heap allocs for performance
local fcomp_default = function( a,b ) 
   return a < b 
end

local function binsert(t, value, fcomp)
   -- Initialise compare function
   local fcomp = fcomp or fcomp_default
   
   --  Initialise numbers
   local iStart = 1;
   local iEnd = #t;
   local iMid = 1;
   local iState = 0;
   
   -- Get insert position
   while iStart <= iEnd do
      -- calculate middle
      iMid = floor( (iStart+iEnd)/2 );
      
      -- compare
      if fcomp( value,t[iMid] ) then
            iEnd = iMid - 1;
            iState = 0;
      else
            iStart = iMid + 1;
            iState = 1;
      end
   end
   
   insert( t,(iMid+iState),value );
   return (iMid+iState);
end


return {
   binsert = binsert,
}