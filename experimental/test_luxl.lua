-- test_luxl.lua
local ffi = require("ffi");
local luxl = require("luxl");
local stringzutils = require("stringzutils");

local case1 = [[
<start>
	<first/>
	<second>with text</second>
</start>
]]

local case2 = [[<cfg  version = "2" >

<ident >Test Name< /ident>
<descr>A test xml data file with annoying spaces everywhere</descr>
< params>
  <board width="10" height="20"/>
  <size>20</size >
</params>

</cfg >
]]

local EventNames = {
	[luxl.EVENT_START] = "EVENT_START"; 	 -- Start tag
	[luxl.EVENT_END] = "EVENT_END";       -- End tag
	[luxl.EVENT_TEXT] = "EVENT_TEXT";      -- Text
	[luxl.EVENT_ATTR_NAME] = "EVENT_ATTR_NAME"; -- Attribute name
	[luxl.EVENT_ATTR_VAL] = "EVENT_ATTR_VAL";  -- Attribute value
	[luxl.EVENT_END_DOC] = "EVENT_END_DOC";   -- End of document
	[luxl.EVENT_MARK] = "EVENT_MARK";      -- Internal only; notes position in buffer
	[luxl.EVENT_NONE] = "EVENT_NONE";      -- Internal only; should never see this event
}


local getEventInfo = function(buff, event, offset, size)
	return EventNames[event]..' '..ffi.string(ffi.cast("char *",buff)+offset, size);
end

local test_sample = function(sample)
	local p1 = luxl(sample, #sample);

	for _it, event, offset, size in p1:lexemes() do
		--print(event, offset, size);
		print(getEventInfo(sample, event, offset, size));
	end
end


test_sample(case1);
--test_sample(case2);

