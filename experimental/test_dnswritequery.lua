-- http://const.me/articles/ms-dns-api/

local ffi = require("ffi")
local core_string = require("core_string_l1_1_0")
local windns_ffi = require("windns_ffi")
local Stopwatch = require("StopWatch")
local Heap = require("Heap")

local clock = Stopwatch();

local procHeap = Heap:create(4096)

local pDnsBuff = "8.8.8.8";
local strName = procHeap:alloc(512);
ffi.cast("wchar_t *",strName)[255] = 0;

--local strName = core_string.toUnicode("nanotechstyles.com")
--local strNameA = core_string.toAnsi(strName)

print("pDnsBuff: ", pDnsBuff)
print("strName: ", strName)
print("strNameA: ", strNameA)


-- Prepare the DNS request
--local buff = ffi.new("uint8_t[2048]")
local buff = procHeap:alloc(2048);

print("buff: ", buff)

--local pDnsBuff = ffi.cast("DNS_MESSAGE_BUFFER*",buff);
--local pdwBuffSize = ffi.new("DWORD[1]", 2048);
--local pDnsBuff = ffi.new("DNS_MESSAGE_BUFFER")
local pdwBuffSize = ffi.new("DWORD[1]", 2048)

local wType = ffi.C.DNS_TYPE_A;
--local wID = clock:GetCurrentTicks() % 65536;
local wID = 100;

print("QueryDNS, 3.0: ", pDnsBuff, pdwBuffSize[0], wType, wID)

print("DnsWriteQuestionToBuffer_W: ", windns_ffi.DnsWriteQuestionToBuffer_W)
local res = windns_ffi.DnsWriteQuestionToBuffer_W( ffi.cast("DNS_MESSAGE_BUFFER*",buff), pdwBuffSize, ffi.cast("wchar_t *",strName), wType, wID, 1 );
--local res = windns_ffi.DnsWriteQuestionToBuffer_UTF8( pDnsBuff, dwBuffSize, ffi.cast("char *",strToQuery), wType, wID, true )

print("Result: ", buff, res)
