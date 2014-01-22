local ffi = require("ffi")

local Application = require("Application")
local windns_ffi = require("windns_ffi")
local NativeSocket = require("NativeSocket")
local ws2_32 = require("ws2_32")
local Stopwatch = require("StopWatch")

local clock = Stopwatch();


-- DNS UDP port
local IPPORT_DNS = 53;

-- Construct DNS_TYPE_A request, send it to the specified DNS server, wait for the reply.
local function QueryDNS( strDnsServerIP, strToQuery, msTimeout)
    msTimeout = msTimeout or 60 * 1000  -- 1 minute

    -- Create UDP v4 socket for sending
    local socket, err = NativeSocket( AF_INET, SOCK_DGRAM, IPPROTO_UDP );
    if not socket then
        return false, err
    end

    -- Prepare the DNS request
    local dwBuffSize = ffi.new("DWORD[1]", 2048);
    local buff = ffi.new("uint8_t[2048]")

    local wType = ffi.C.DNS_TYPE_A;
    local wID = clock:GetCurrentTicks() % 65536;
        
    local res = windns_ffi.DnsWriteQuestionToBuffer_UTF8( ffi.cast("DNS_MESSAGE_BUFFER*",buff), dwBuffSize, ffi.cast("char *",strToQuery), wType, wID, true )


    if res == 0 then
        return false, "DnsWriteQuestionToBuffer_W failed."
    end

	-- No need to bind: http://stackoverflow.com/questions/1075399

    -- Send the request.
    local addrRemote = sockaddr_in(IPPORT_DNS, AF_INET);
    addrRemote.sin_addr.S_addr = ws2_32.inet_addr( strDnsServerIP );
    local iRes, err = socket:sendTo(addrRemote, ffi.sizeof(addrRemote), buff, dwBuffSize[0]);
    

    if (not iRes) then
        print("Error sending data: ", err)
        return false, err
    end

    local msSendTime = clock:Milliseconds();

    print( string.format("DNS query sent to %s, asking the IP of \"%s\".", strDnsServerIP, strToQuery ));

    -- Try to receive the results
    local RecvFromAddr = sockaddr_in();
    local RecvFromAddrSize = ffi.sizeof(RecvFromAddr);
    local cbReceived, err = socket:receiveFrom(RecvFromAddr, RecvFromAddrSize, buff, 2048);

    if not cbReceived then
        print("Error Receiving Data: ", err)
        return false, err;
    end

    if( 0 == cbReceived ) then
        return false, "Nothing received"
    end


    local ellapsed = clock:Milliseconds() - msSendTime;
    print(string.format("Received %i bytes (%d milliseconds passed)\n", cbReceived, ellapsed ));

    -- Parse the DNS response received with DNS API
    local pDnsResponseBuff = ffi.cast("DNS_MESSAGE_BUFFER*", buff);
    windns_ffi.DNS_BYTE_FLIP_HEADER_COUNTS ( pDnsResponseBuff.MessageHead );

    if pDnsResponseBuff.MessageHead.Xid ~= wID then        
        return false, "wrong transaction ID"
    end

    local pRecord = ffi.new("DNS_RECORD *[1]",nil);

    iRes = windns_ffi.DnsExtractRecordsFromMessage_W( pDnsResponseBuff, cbReceived, pRecord );
    

    -- Find the first "A" records
    pRecord = pRecord[0];
    local pRecordA = ffi.cast("DNS_RECORD *", pRecord);
    while( nil ~= pRecordA and ffi.C.DNS_TYPE_A ~= pRecordA.wType ) do
        --print("advancing")
        pRecordA = pRecordA.pNext;
    end
    
    if( nil == pRecordA ) then
        return false, "The DNS reply does not contain any 'A' records"
    end

    -- Print the record found, and the rest of 'A'-records as well    
    repeat
        local a = IN_ADDR();
        a.S_addr = pRecordA.Data.A.IpAddress

        print(string.format("\tIP: %s, TTL %d", a, pRecordA.dwTtl));

        -- Try to find the rest of the 'A'-records in the reply.
		repeat
            pRecordA = pRecordA.pNext;
        until (nil == pRecordA) or  (ffi.C.DNS_TYPE_A == pRecordA.wType)   
    until pRecordA == nil

    -- Free the resources
    if pRecord ~= nil then
        windns_ffi.DnsRecordListFree( pRecord, ffi.C.DnsFreeRecordList );
    end 

    return hr;
end

-- "8.8.8.8" is the public DNS server maintained by google inc.
local nameserver = "8.8.8.8"
--local testdomain = "www.nanotechstyles.com"
--local testdomain = "microsoft.com"
local testdomain = "google.com"

local function main()

	local success, err = QueryDNS( nameserver, testdomain );

    print("success: ", success, err)
end

run(main)
