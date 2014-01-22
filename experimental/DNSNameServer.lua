local ffi = require("ffi")

local Application = require("Application")
local windns_ffi = require("windns_ffi")
local NativeSocket = require("NativeSocket")
local ws2_32 = require("ws2_32")
local Stopwatch = require("StopWatch")

local clock = Stopwatch();


-- DNS UDP port
local IPPORT_DNS = 53;

local DNSNameServer = {}
setmetatable(DNSNameServer, {
    __call = function(self, ...)
        return self:create(...)
    end,
})
local DNSNameServer_mt = {
    __index = DNSNameServer,
}

function DNSNameServer.init(self, serveraddress)
    local socket, err = NativeSocket( AF_INET, SOCK_DGRAM, IPPROTO_UDP );

    if not socket then
        return nil, err
    end

    local obj = {
        Socket = socket,
        ServerAddress = serveraddress,
    }
    setmetatable(obj, DNSNameServer_mt)

    return obj;
end

function DNSNameServer.create(self, servername)
    local remoteAddr = sockaddr_in(IPPORT_DNS, AF_INET);
    remoteAddr.sin_addr.S_addr = ws2_32.inet_addr( servername );

    return self:init(remoteAddr)
end

-- Construct DNS_TYPE_A request, send it to the specified DNS server, wait for the reply.
function DNSNameServer.Query(self, strToQuery, wType, msTimeout)
    wType = wType or ffi.C.DNS_TYPE_A
    msTimeout = msTimeout or 60 * 1000  -- 1 minute


    -- Prepare the DNS request
    local dwBuffSize = ffi.new("DWORD[1]", 2048);
    local buff = ffi.new("uint8_t[2048]")

    local wID = clock:GetCurrentTicks() % 65536;
        
    local res = windns_ffi.DnsWriteQuestionToBuffer_UTF8( ffi.cast("DNS_MESSAGE_BUFFER*",buff), dwBuffSize, ffi.cast("char *",strToQuery), wType, wID, true )

    if res == 0 then
        return false, "DnsWriteQuestionToBuffer_UTF8 failed."
    end

    -- Send the request.
    local iRes, err = self.Socket:sendTo(self.ServerAddress, ffi.sizeof(self.ServerAddress), buff, dwBuffSize[0]);
    

    if (not iRes) then
        print("Error sending data: ", err)
        return false, err
    end

    --local msSendTime = clock:Milliseconds();

    --print( string.format("DNS query sent, asking the IP of \"%s\".", strToQuery ));



    -- Try to receive the results
    local RecvFromAddr = sockaddr_in();
    local RecvFromAddrSize = ffi.sizeof(RecvFromAddr);
    local cbReceived, err = self.Socket:receiveFrom(RecvFromAddr, RecvFromAddrSize, buff, 2048);

    if not cbReceived then
        print("Error Receiving Data: ", err)
        return false, err;
    end

    if( 0 == cbReceived ) then
        return false, "Nothing received"
    end


    --local ellapsed = clock:Milliseconds() - msSendTime;
    --print(string.format("Received %i bytes (%d milliseconds passed)\n", cbReceived, ellapsed ));


    -- Parse the DNS response received with DNS API
    local pDnsResponseBuff = ffi.cast("DNS_MESSAGE_BUFFER*", buff);
    windns_ffi.DNS_BYTE_FLIP_HEADER_COUNTS ( pDnsResponseBuff.MessageHead );

    if pDnsResponseBuff.MessageHead.Xid ~= wID then        
        return false, "wrong transaction ID"
    end

    local pRecord = ffi.new("DNS_RECORD *[1]",nil);

    iRes = windns_ffi.DnsExtractRecordsFromMessage_W( pDnsResponseBuff, cbReceived, pRecord );
    
    pRecord = pRecord[0];
    local pRecordA = ffi.cast("DNS_RECORD *", pRecord);
    
    local function closure()
        if pRecordA == nil then
            return nil;
        end

        if pRecordA.wType == wType then
            local retVal = pRecordA
            pRecordA = pRecordA.pNext

            return retVal;
        end

        -- Find the next record of the specified type
        repeat
            pRecordA = pRecordA.pNext;
        until pRecordA == nil or pRecordA.wType == wType
    
        if pRecordA ~= nil then
            local retVal = pRecordA
            pRecordA = pRecordA.pNext
            
            return retVal;
        end

        -- Free the resources
        if pRecord ~= nil then
            windns_ffi.DnsRecordListFree( pRecord, ffi.C.DnsFreeRecordList );
        end 

        return nil
    end

    return closure
end

function DNSNameServer.A(self, domainToQuery) return self:Query(domainToQuery, ffi.C.DNS_TYPE_A) end
function DNSNameServer.MX(self, domainToQuery) return self:Query(domainToQuery, ffi.C.DNS_TYPE_MX) end
function DNSNameServer.CNAME(self, domainToQuery) return self:Query(domainToQuery, ffi.C.DNS_TYPE_CNAME) end

return DNSNameServer
