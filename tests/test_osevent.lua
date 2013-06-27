-- test_osevent.lua
-- Demonstrate how synchronization can occur across
-- computicles, using event objects.

local Computicle = require("Computicle");
local OSEvent = require("OSEvent");

local initialState = false;
local ev1, err = OSEvent:create(initialState);

print("EVENT: ", ev1, err);


local eventResetTmpl = [[
local ffi = require("ffi");
local OSEvent = require("OSEvent");

local eventHandle = ffi.cast("HANDLE", _params.event);
local event = OSEvent:init(eventHandle);

event:set();
]];

local comp = Computicle:create(eventResetTmpl, {event = ev1:getNativeHandle()});

print(string.format("0x%x",ev1:await()));

