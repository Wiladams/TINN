local ffi = require("ffi")

local Application = require("Application")
local windns_ffi = require("windns_ffi")
local NativeSocket = require("NativeSocket")
local ws2_32 = require("ws2_32")
local Stopwatch = require("StopWatch")
local core_string = require("core_string_l1_1_0")
local L = core_string.toUnicode

local clock = Stopwatch();

--[[
// Call FormatMessageW, put the result into CString
CStringW ErrMsgW(HRESULT hr)
{
    LPVOID lpMsgBuf;
    FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL, hr, 0, (LPTSTR) &lpMsgBuf, 0, NULL);
    CStringW res(static_cast<const wchar_t*>(lpMsgBuf));
    LocalFree(lpMsgBuf);
    return res;
}
--]]

--[[
// Wrap GetLastError() in HRESULT
inline HRESULT GetLastHr()  { return HRESULT_FROM_WIN32( GetLastError() ); }

// Wrap WSAGetLastError() in HRESULT
inline HRESULT GetLastWsa() { return HRESULT_FROM_WIN32( WSAGetLastError() ); }
--]]


-- DNS UDP port
local IPPORT_DNS = 53;

-- Construct DNS_TYPE_A request, send it to the specified DNS server, wait for the reply.
local function QueryDNS( strDnsServerIP, strToQuery, msTimeout)
    msTimeout = msTimeout or 60000  -- 1 minutes
print("QueryDNS, 1.0")
    -- Create UDP v4 socket for sending
    local socket, err = NativeSocket( AF_INET, SOCK_DGRAM, IPPROTO_UDP );
    if not socket then
        return false, err
    end

print("QueryDNS, 2.0")

    -- Prepare the DNS request
    local buff = ffi.new("uint8_t[2048]")

    local pDnsBuff = ffi.cast("DNS_MESSAGE_BUFFER*",buff);
    local dwBuffSize = ffi.new("DWORD[1]", 2048);

    --local strName = ffi.new("wchar_t[256]");
    --wcsncpy( strName, strToQuery, 256 );
    --strName[255] = 0;
    local strName = core_string.toUnicode(strToQuery)
    local wType = ffi.C.DNS_TYPE_A;
    local wID = clock:GetCurrentTicks() % 65536;
print("QueryDNS, 3.0: ", strToQuery, wType, wID)
        
    --local res = windns_ffi.DnsWriteQuestionToBuffer_W( pDnsBuff, dwBuffSize, strName, wType, wID, 1 )
    local res = windns_ffi.DnsWriteQuestionToBuffer_UTF8( pDnsBuff, dwBuffSize, ffi.cast("char *",strToQuery), wType, wID, true )

print("QueryDNS, 4.0: ", buff)

    if res == 0 then
        return false, "DnsWriteQuestionToBuffer_W failed."
    end

	-- No need to bind: http://stackoverflow.com/questions/1075399

    -- Send the request.
    local addrRemote = sockaddr_in(IPPORT_DNS, AF_INET);
    addrRemote.sin_addr.S_addr = ws2_32.inet_addr( strDnsServerIP );
    local iRes = socket:sendTo(buff, dwBuffSize, 0, addrRemote, ffi.sizeof( addrRemote ) );
    if( iRes ~= dwBuffSize ) then
--[[
        if( SOCKET_ERROR == iRes )
                hr = GetLastWsa();
        else
                hr = HRESULT_FROM_WIN32( RPC_S_SEND_INCOMPLETE );   // =Some data remains to be sent in the request buffer
--]]        
        return false, "sendto() failed."
    end

    local msSendTime = clock:Milliseconds();

    print( string.format("DNS query sent to %s, asking the IP of \"%S\".\n", strDnsServerIP, strName ));

    -- Try to receive the results
    local RecvFromAddr = sockaddr_in();
    local RecvFromAddrSize = ffi.new("int[1]", ffi.sizeof( RecvFromAddr ));
    local cbReceived, err = socket:receiveFrom(buff, 2048, 0, RecvFromAddr, RecvFromAddrSize );

    if not cbReceived then
        print("Error Receiving Data: ", err)
        return false;
    end

    if( 0 == cbReceived ) then
        return false, "Nothing received"
    end

--[[
        if( RecvFromAddr.sin_addr.S_un.S_addr !=  addrRemote.sin_addr.S_un.S_addr ||
                RecvFromAddr.sin_port != addrRemote.sin_port )
        {
            // TODO: retry receiving instead of just failing
            hr = E_FAIL;
            printf( "The response is from some other host.\n" );
            break;
        }
--]]

    local ellapsed = clock:Milliseconds() - msSendTime;
    print(string.format("Received %i bytes (%d seconds passed)\n", cbReceived, ellapsed ));

    -- Parse the DNS response received with DNS API
    local pDnsResponseBuff = ffi.cast("DNS_MESSAGE_BUFFER*", buff);
    windns_ffi.DNS_BYTE_FLIP_HEADER_COUNTS ( pDnsResponseBuff.MessageHead );

    if pDnsResponseBuff.MessageHead.Xid ~= wID then        
        return false, "wrong transaction ID"
    end

    local pRecord = ffi.new("DNS_RECORD *[1]",nil);

    iRes = windns_ffi.DnsExtractRecordsFromMessage_W( pDnsResponseBuff, cbReceived, pRecord );
    
--[[
    hr = HRESULT_FROM_WIN32(iRes);
        if( FAILED(hr) )
        {
            // The DNS response may contain an error code instead of the requested data, e.g. "DNS server failure"
            printf( "DnsExtractRecordsFromMessage returned an error code %i, which means\n", iRes );
            break;
        }
--]]

    -- Find the first "A" records
    pRecord = pRecord[0];
    local pRecordA = ffi.cast("DNS_RECORD *", pRecord);
    while( nil ~= pRecordA and ffi.C.DNS_TYPE_A ~= pRecordA.wType ) do
        pRecordA = pRecordA.pNext;
    end
    
    if( nil == pRecordA ) then
        return false, "The DNS reply does not contain any 'A' records"
    end

    -- Print the record found, and the rest of 'A'-records as well
    print( "Got the reply:" );
--[[
        do
        {
            const BYTE* a = (const BYTE*)(&pRecordA->Data.A.IpAddress);

            printf( "\tIP %i.%i.%i.%i, TTL %i.\n",
                int( a[0] ), int( a[1] ), int( a[2] ), int( a[3] ),
                int( pRecordA->dwTtl ) );

            // Try to find the rest of the 'A'-records in the reply.
			do
            {
                pRecordA = pRecordA->pNext;
            }
            while( NULL != pRecordA && DNS_TYPE_A != pRecordA->wType );
        }
        while( NULL != pRecordA );
--]]

    -- Free the resources
    if nil ~= pRecord then
        windns_ffi.DnsRecordListFree( pRecord, DnsFreeRecordList );
    end 

    return hr;
end

-- "8.8.8.8" is the public DNS server maintained by google inc.
local nameserver = "8.8.8.8"

-- "nanotechstyles.com" is the domain name owned by the author of this code
local testdomain = "nanotechstyles.com"

local function main()

	local success, err = QueryDNS( nameserver, testdomain );

    print("success: ", success, err)

    --printf( "%S\n", LPCTSTR( ErrMsgW( hr ) ) );

    --printf( "Press a key to continue.\n" );
    --_getch();

    return 0;
end

run(main)
