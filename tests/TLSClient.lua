-- TLSClient.lua

local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;
local band = bit.band;

local sspi_ffi = require("sspi_ffi");
local sspi = require("sspi");

--2.0 Initialize Security Interface
local SecurityInterface = sspi.SecurityInterface;
local SecurityPackage = sspi.SecurityPackage;
local SecurityContext = require("SecurityContext");



local function CreateCreds(packageName, protocol, flags)
    packageName = packageName or sspi.schannel.UNISP_NAME
	protocol = protocol or ffi.C.SP_PROT_TLS1_CLIENT;
    flags = flags or bor(ffi.C.SCH_CRED_AUTO_CRED_VALIDATION, ffi.C.SCH_CRED_USE_DEFAULT_CREDS);
    
    local package, err = SecurityPackage:FindPackage(packageName);
	
	local authData = ffi.new("SCHANNEL_CRED");

	authData.dwVersion = ffi.C.SCHANNEL_CRED_VERSION;
	authData.grbitEnabledProtocols = protocol;
	authData.dwFlags = flags;

	local creds, err = package:CreateCredentials(ffi.C.SECPKG_CRED_OUTBOUND, authData);

	return creds;
end


local IO_BUFFER_SIZE = 10000;

local function ClientHandshakeLoop(Socket, phCreds, phContext, fDoInitialRead, pExtraData)

	local OutBuffer = ffi.new("SecBufferDesc"); 
	local InBuffer = ffi.new("SecBufferDesc");
    local InBuffers = ffi.new("SecBuffer[2]");
    local OutBuffers = ffi.new("SecBuffer[1]");
    local dwSSPIOutFlags = ffi.new("DWORD[1]");
    local cbData;
	local tsExpiry = nil;	-- ffi.new("TimeStamp");
    local fDoRead = fDoInitialRead;


    local dwSSPIFlags = bor(
    	ffi.C.ISC_REQ_SEQUENCE_DETECT,
    	ffi.C.ISC_REQ_REPLAY_DETECT,
    	ffi.C.ISC_REQ_CONFIDENTIALITY,
        ffi.C.ISC_RET_EXTENDED_ERROR,
        ffi.C.ISC_REQ_ALLOCATE_MEMORY,
        ffi.C.ISC_REQ_STREAM);

    -- Allocate data buffer.
    local IoBuffer = ffi.new("uint8_t[?]", IO_BUFFER_SIZE);
    if (IoBuffer == nil) then 
    	return false, SEC_E_INTERNAL_ERROR; 
    end

    local cbIoBuffer = 0;

    -- Loop until the handshake is finished or an error occurs.
    local scRet = SEC_I_CONTINUE_NEEDED;
    local err;

    while( scRet == SEC_I_CONTINUE_NEEDED        or
           scRet == SEC_E_INCOMPLETE_MESSAGE     or
           scRet == SEC_I_INCOMPLETE_CREDENTIALS ) do
::whiletop::
        if(0 == cbIoBuffer or scRet == SEC_E_INCOMPLETE_MESSAGE) then -- Read data from server.
        
            if (fDoRead) then
                cbData, err = Socket:receive(IoBuffer + cbIoBuffer, IO_BUFFER_SIZE - cbIoBuffer, 0 );
                if not cbData and (err == SOCKET_ERROR) then
                    --print("**** Error reading data from server: ",err);
                    scRet = SEC_E_INTERNAL_ERROR;
                    break;
                elseif (cbData == 0) then
                    --print("**** Server unexpectedly disconnected");
                    scRet = SEC_E_INTERNAL_ERROR;
                    break;
                end
                --print("#### bytes of handshake data received: ", cbData);
                
                cbIoBuffer = cbIoBuffer + cbData;
            else
              fDoRead = true;
            end
        end


        -- Set up the input buffers. Buffer 0 is used to pass in data
        -- received from the server. Schannel will consume some or all
        -- of this. Leftover data (if any) will be placed in buffer 1 and
        -- given a buffer type of SECBUFFER_EXTRA.
        InBuffers[0].pvBuffer   = IoBuffer;
        InBuffers[0].cbBuffer   = cbIoBuffer;
        InBuffers[0].BufferType = ffi.C.SECBUFFER_TOKEN;

        InBuffers[1].pvBuffer   = nil;
        InBuffers[1].cbBuffer   = 0;
        InBuffers[1].BufferType = ffi.C.SECBUFFER_EMPTY;

        InBuffer.cBuffers       = 2;
        InBuffer.pBuffers       = InBuffers;
        InBuffer.ulVersion      = ffi.C.SECBUFFER_VERSION;


        -- Set up the output buffers. These are initialized to nil
        -- so as to make it less likely we'll attempt to free random
        -- garbage later.
        OutBuffers[0].pvBuffer  = nil;
        OutBuffers[0].BufferType= ffi.C.SECBUFFER_TOKEN;
        OutBuffers[0].cbBuffer  = 0;

        OutBuffer.cBuffers      = 1;
        OutBuffer.pBuffers      = OutBuffers;
        OutBuffer.ulVersion     = ffi.C.SECBUFFER_VERSION;

        -- Call InitializeSecurityContext.
        scRet = SecurityInterface.InitializeSecurityContextA(phCreds,
			phContext,
			nil,
			dwSSPIFlags,
			0,
			ffi.C.SECURITY_NATIVE_DREP,
			InBuffer,
			0,
			nil,
			OutBuffer,
			dwSSPIOutFlags,
			tsExpiry );


        -- If InitializeSecurityContext was successful (or if the error was 
        -- one of the special extended ones), send the contents of the output
        -- buffer to the server.
        if(scRet == SEC_E_OK                or
           scRet == SEC_I_CONTINUE_NEEDED   or
           FAILED(scRet) and band(dwSSPIOutFlags[0], ffi.C.ISC_RET_EXTENDED_ERROR)>0) then
        
            if(OutBuffers[0].cbBuffer ~= 0 and OutBuffers[0].pvBuffer ~= nil) then
            
                cbData, err = Socket:send(OutBuffers[0].pvBuffer, OutBuffers[0].cbBuffer, 0 );
                if(not cbData and err == SOCKET_ERROR or cbData == 0) then
                    --print( "**** Error sending data to server (2): ", err);
                    --DisplayWinSockError( WSAGetLastError() );
                    SecurityInterface.FreeContextBuffer(OutBuffers[0].pvBuffer);
                    SecurityInterface.DeleteSecurityContext(phContext);
                    return false, SEC_E_INTERNAL_ERROR;
                end

                --print("## bytes of handshake data sent: ", cbData);

                -- Free output buffer.
                SecurityInterface.FreeContextBuffer(OutBuffers[0].pvBuffer);
                OutBuffers[0].pvBuffer = nil;
            end
        end

        -- If InitializeSecurityContext returned SEC_E_INCOMPLETE_MESSAGE,
        -- then we need to read more data from the server and try again.
        if(scRet == SEC_E_INCOMPLETE_MESSAGE) then
        	goto whiletop; -- continue
        else


        -- If InitializeSecurityContext returned SEC_E_OK, then the 
        -- handshake completed successfully.
        if(scRet == SEC_E_OK) then
        
            -- If the "extra" buffer contains data, this is encrypted application
            -- protocol layer stuff. It needs to be saved. The application layer
            -- will later decrypt it with DecryptMessage.
            print("Handshake was successful");

            if(InBuffers[1].BufferType == ffi.C.SECBUFFER_EXTRA) then
                pExtraData.pvBuffer = ffi.new("uint8_t[?]", InBuffers[1].cbBuffer);

                if(pExtraData.pvBuffer == nil) then                
                	return false, SEC_E_INTERNAL_ERROR; 
                end

                ffi.copy( pExtraData.pvBuffer,
                            IoBuffer + (cbIoBuffer - InBuffers[1].cbBuffer),
                            InBuffers[1].cbBuffer );

                pExtraData.cbBuffer   = InBuffers[1].cbBuffer;
                pExtraData.BufferType = ffi.C.SECBUFFER_TOKEN;

                print( "## bytes of app data were bundled with handshake data: ", pExtraData.cbBuffer );        
            else
                pExtraData.pvBuffer   = nil;
                pExtraData.cbBuffer   = 0;
                pExtraData.BufferType = ffi.C.SECBUFFER_EMPTY;
            end
            break; -- Bail out to quit
        end



        -- Check for fatal error.
        if(FAILED(scRet)) then
        	print("**** Error returned by InitializeSecurityContext (2): ", string.format("0x%x",scRet)); 
        	break; 
        end

        -- If InitializeSecurityContext returned SEC_I_INCOMPLETE_CREDENTIALS,
        -- then the server just requested client authentication. 
        if(scRet == SEC_I_INCOMPLETE_CREDENTIALS) then
        
            -- Busted. The server has requested client authentication and
            -- the credential we supplied didn't contain a client certificate.
            -- This function will read the list of trusted certificate
            -- authorities ("issuers") that was received from the server
            -- and attempt to find a suitable client certificate that
            -- was issued by one of these. If this function is successful, 
            -- then we will connect using the new certificate. Otherwise,
            -- we will attempt to connect anonymously (using our current credentials).
            --GetNewClientCredentials(phCreds, phContext);

            -- Go around again.
            fDoRead = false;
            scRet = SEC_I_CONTINUE_NEEDED;
            --continue;
        end

        -- Copy any leftover data from the "extra" buffer, and go around again.
        if ( InBuffers[1].BufferType == ffi.C.SECBUFFER_EXTRA ) then
        	ffi.copy(IoBuffer, IoBuffer + (cbIoBuffer - InBuffers[1].cbBuffer), InBuffers[1].cbBuffer);
            cbIoBuffer = InBuffers[1].cbBuffer;
        else
          cbIoBuffer = 0;
        end
    	end
    end

    -- Delete the security context in the case of a fatal error.
    if(FAILED(scRet)) then
    	SecurityInterface.DeleteSecurityContext(phContext);
    end


    return scRet;
end


local function PerformClientHandshake(Socket, phCreds, pszServerName)
	
	local phNewContext = ffi.new("CtxtHandle");


    local OutBuffer = ffi.new("SecBufferDesc");
    local OutBuffers = ffi.new("SecBuffer[1]");
 	local pfContextAttr = ffi.new("DWORD[1]");
    local tsExpiry = ffi.new("TimeStamp");
    local scRet;


    local dwSSPIFlags = bor(
    	ffi.C.ISC_REQ_SEQUENCE_DETECT,
    	ffi.C.ISC_REQ_REPLAY_DETECT, 
    	ffi.C.ISC_REQ_CONFIDENTIALITY,
        ffi.C.ISC_RET_EXTENDED_ERROR, 
        ffi.C.ISC_REQ_ALLOCATE_MEMORY, 
        ffi.C.ISC_REQ_STREAM);


    --  Initiate a ClientHello message and generate a token.
    OutBuffers[0].pvBuffer   = nil;
    OutBuffers[0].BufferType = ffi.C.SECBUFFER_TOKEN;
    OutBuffers[0].cbBuffer   = 0;

    OutBuffer.cBuffers  = 1;
    OutBuffer.pBuffers  = OutBuffers;
    OutBuffer.ulVersion = ffi.C.SECBUFFER_VERSION;

    scRet = SecurityInterface.InitializeSecurityContextA(  phCreds,
		nil,
		pszServerName,
		dwSSPIFlags,
		0,
		ffi.C.SECURITY_NATIVE_DREP,
		nil,
		0,
		phNewContext,
		OutBuffer,
		pfContextAttr,
		nil );

    if (scRet ~= SEC_I_CONTINUE_NEEDED)  then
    	print(string.format("**** Error %d returned by InitializeSecurityContext (1)", scRet)); 
    	return scRet; 
    end

    -- Send response to server if there is one.
    if(OutBuffers[0].cbBuffer ~= 0 and OutBuffers[0].pvBuffer ~= nil) then
    
        local cbData, err = Socket:send(OutBuffers[0].pvBuffer, OutBuffers[0].cbBuffer, 0 );
        if not cbData then
        --if( cbData == SOCKET_ERROR or cbData == 0 ) then
            print("**** Error sending data to server (1): ", err);
            SecurityInterface.FreeContextBuffer(OutBuffers[0].pvBuffer);
            SecurityInterface.DeleteSecurityContext(phNewContext);
            return SEC_E_INTERNAL_ERROR;
        end

        print("handshake bytes sent: ", cbData);

        SecurityInterface.FreeContextBuffer(OutBuffers[0].pvBuffer); -- Free output buffer.
        OutBuffers[0].pvBuffer = nil;
    end
    
	local pExtraData = ffi.new("SecBuffer");

    local success, err =  ClientHandshakeLoop(Socket, phCreds, phNewContext, true, pExtraData);
    
    if not success then
        return false, err;
    end

    return phNewContext;
end



-- 6.0  Authenticate the server's credentials
-- 7.0  Get the server's certificate.
-- 8.0  Verify the server's certificate

--[[
    Function: EncryptSend

-- http://msdn.microsoft.com/en-us/library/aa375378(VS.85).aspx
-- The encrypted message is encrypted in place, overwriting the original contents of its buffer.
--]]
local function EncryptSend(Socket, phContext, pbIoBuffer, Sizes ) 
    pbIoBuffer = ffi.cast("uint8_t *",pbIoBuffer);

    local numBuffers = 4;
    local scRet;            -- unsigned long cbBuffer;    // Size of the buffer, in bytes
    local Message = ffi.new("SecBufferDesc");        -- unsigned long BufferType;  // Type of the buffer (below)
    local Buffers = ffi.new("SecBuffer[4]");    -- void    SEC_FAR * pvBuffer;   // Pointer to the buffer


    local pbMessage = pbIoBuffer + Sizes.cbHeader; -- Offset by "header size"
    local cbMessage = strlen(pbMessage);
    print("EncryptSend(), Sending bytes of plaintext: ", cbMessage); 
     
    if(fVerbose) then 
        PrintHexDump(cbMessage, pbMessage); 
        print(); 
    end


    -- Encrypt the HTTP request.
    Buffers[0].pvBuffer     = pbIoBuffer;                                -- Pointer to buffer 1
    Buffers[0].cbBuffer     = Sizes.cbHeader;                        -- length of header
    Buffers[0].BufferType   = ffi.C.SECBUFFER_STREAM_HEADER;    -- Type of the buffer 

    Buffers[1].pvBuffer     = pbMessage;                                -- Pointer to buffer 2
    Buffers[1].cbBuffer     = cbMessage;                                -- length of the message
    Buffers[1].BufferType   = ffi.C.SECBUFFER_DATA;                        -- Type of the buffer 
                                                                                            
    Buffers[2].pvBuffer     = pbMessage + cbMessage;        -- Pointer to buffer 3
    Buffers[2].cbBuffer     = Sizes.cbTrailer;                    -- length of the trailor
    Buffers[2].BufferType   = ffi.C.SECBUFFER_STREAM_TRAILER;    -- Type of the buffer 

    Buffers[3].pvBuffer     = nill --ffi.C.SECBUFFER_EMPTY;                    -- Pointer to buffer 4
    Buffers[3].cbBuffer     = ffi.C.SECBUFFER_EMPTY;                    -- length of buffer 4
    Buffers[3].BufferType   = ffi.C.SECBUFFER_EMPTY;                    -- Type of the buffer 4 


    Message.ulVersion       = ffi.C.SECBUFFER_VERSION;    -- Version number
    Message.cBuffers        = numBuffers;                                    -- Number of buffers - must contain four SecBuffer structures.
    Message.pBuffers        = Buffers;                        -- Pointer to array of buffers
    scRet = SecurityInterface.EncryptMessage(phContext, 0, Message, 0); -- must contain four SecBuffer structures.
    
    if (FAILED(scRet)) then
        print("**** Error returned by EncryptMessage: ", scRet); 
        return false, scRet;
    end

    -- Send the encrypted data to the server.
    local totalLength = Buffers[0].cbBuffer + Buffers[1].cbBuffer + Buffers[2].cbBuffer;
    local cbData, err = Socket:send(pbIoBuffer, totalLength, 0);

    print("bytes of encrypted data sent: ", cbData);
    
    if(fVerbose) then
        PrintHexDump(cbData, pbIoBuffer); 
        print(); 
    end

    -- send( Socket, pbIoBuffer,    Sizes.cbHeader + strlen(pbMessage) + Sizes.cbTrailer,  0 );
    
    return cbData; 
end


--[[
    Function: DecryptReceive
    
    -- calls recv() - blocking socket read
    -- http:--msdn.microsoft.com/en-us/library/ms740121(VS.85).aspx

-- The encrypted message is decrypted in place, overwriting the original contents of its buffer.
-- http:--msdn.microsoft.com/en-us/library/aa375211(VS.85).aspx

--]]
local function DecryptReceive( Socket, phCreds, phContext, pbIoBuffer,cbIoBufferLength ) 
    pbIoBuffer = ffi.cast("uint8_t *", pbIoBuffer);

    local ExtraBuffer = ffi.new("SecBuffer");
    local pDataBuffer;
    local pExtraBuffer;

    local numBuffers = 4;
    local Message = ffi.new("SecBufferDesc");        -- unsigned long BufferType;  -- Type of the buffer (below)
    local Buffers = ffi.new("SecBuffer[?]",numBuffers);    -- void    SEC_FAR * pvBuffer;   -- Pointer to the buffer

    local cbData, length;
    local buff;
    local i;


    -- Read data from server until done.
    local cbIoBuffer = 0;
    local scRet = 0;

    -- Read some data.
    while(true) do 
    
        if( cbIoBuffer == 0 or scRet == SEC_E_INCOMPLETE_MESSAGE ) then
            -- get the data
            cbData, err = Socket:receive(pbIoBuffer + cbIoBuffer, cbIoBufferLength - cbIoBuffer, 0);
            print("cbData, err: ", cbData, err);

            if not cbData then
                printf("**** Error reading data from server: ", err);
                scRet = SEC_E_INTERNAL_ERROR;
                break;
            elseif (cbData == 0) then -- Server disconnected.
                if (cbIoBuffer >0) then
                    print("**** Server unexpectedly disconnected");
                    scRet = SEC_E_INTERNAL_ERROR;
                    return false, scRet;
                else
                  break; -- All Done
                end
            else -- success
                print("bytes of (encrypted) application data received: ", cbData);
                
                cbIoBuffer = cbIoBuffer + cbData;
            end
        end

        -- Decrypt the received data. 
        Buffers[0].pvBuffer     = pbIoBuffer;
        Buffers[0].cbBuffer     = cbIoBuffer;
        Buffers[0].BufferType   = ffi.C.SECBUFFER_DATA;  -- Initial Type of the buffer 1
        Buffers[1].BufferType   = ffi.C.SECBUFFER_EMPTY; -- Initial Type of the buffer 2 
        Buffers[2].BufferType   = ffi.C.SECBUFFER_EMPTY; -- Initial Type of the buffer 3 
        Buffers[3].BufferType   = ffi.C.SECBUFFER_EMPTY; -- Initial Type of the buffer 4 

        Message.ulVersion       = ffi.C.SECBUFFER_VERSION;    -- Version number
        Message.cBuffers        = numBuffers;                                    -- Number of buffers - must contain four SecBuffer structures.
        Message.pBuffers        = Buffers;                        -- Pointer to array of buffers
        
        scRet = SecurityInterface.DecryptMessage(phContext, Message, 0, nil);
        
        if (scRet == SEC_I_CONTEXT_EXPIRED ) then
            break; -- Server signalled end of session
        end

        if( scRet ~= SEC_E_OK and scRet ~= SEC_I_RENEGOTIATE and scRet ~= SEC_I_CONTEXT_EXPIRED ) then
             return false, scRet; 
        end



        -- Locate data and (optional) extra buffers.
        pDataBuffer  = nil;
        pExtraBuffer = nil;

        for i = 1, 3 do
            if ( pDataBuffer  == nil and Buffers[i].BufferType == ffi.C.SECBUFFER_DATA  ) then
                pDataBuffer  = Buffers[i];
            end

            if ( pExtraBuffer == nil and Buffers[i].BufferType == ffi.C.SECBUFFER_EXTRA ) then
                pExtraBuffer = Buffers[i];
            end
        end

        -- Return a decrypted data packet.
        if(pDataBuffer) then
            length = pDataBuffer.cbBuffer;
            if ( length>0 ) then -- check if last two chars are CR LF
 
                buff = pDataBuffer.pvBuffer; -- printf( "n-2= %d, n-1= %d \n", buff[length-2], buff[length-1] );
                
                break;
           end
        end

        -- Move any "extra" data to the input buffer.
        if(pExtraBuffer) then
            ffi.copy(pbIoBuffer, pExtraBuffer.pvBuffer, pExtraBuffer.cbBuffer);
            cbIoBuffer = pExtraBuffer.cbBuffer; 
        else
            cbIoBuffer = 0;
        end

        -- The server wants to perform another handshake sequence.
        if (scRet == SEC_I_RENEGOTIATE) then
        
            print("Server requested renegotiate!");

            scRet = ClientHandshakeLoop( Socket, phCreds, phContext, false, ExtraBuffer);
            if (scRet ~= SEC_E_OK) then
                return false, scRet;
            end


            if(ExtraBuffer.pvBuffer) then 
                -- Move any "extra" data to the input buffer.
                ffi.copy(pbIoBuffer, ExtraBuffer.pvBuffer, ExtraBuffer.cbBuffer);
                cbIoBuffer = ExtraBuffer.cbBuffer;
            end
        end
    end

    return buff, length;
end


local ClientSession = {}
setmetatable(ClientSession, {
    __call = function(self, ...)
        return self:create(...);
    end,
    })

-- metatable for instances
ClientSession_mt = {
    __index = ClientSession;
}

ClientSession.init = function(self, sock, serverName)

    -- 3.0  Create an SSPI credential
    local creds = CreateCreds();

    -- 5.0  Perform handshaking
    local phContext, err = PerformClientHandshake(sock, creds, ffi.cast("char *",serverName));

    if not phContext then
        print("Error from PerformClientHandshake: ", err);
        return false, err;
    end

    local secContext = SecurityContext(phContext);
    local Sizes = secContext:GetAttribute(ffi.C.SECPKG_ATTR_STREAM_SIZES);
    
    --local Sizes = ffi.new("SecPkgContext_StreamSizes");
    --local scRet = SecurityInterface.QueryContextAttributesA( phContext, ffi.C.SECPKG_ATTR_STREAM_SIZES, Sizes );

    local ioLength = Sizes.cbHeader  +  Sizes.cbMaximumMessage  +  Sizes.cbTrailer;

print("SIZES");
print("Header: ", Sizes.cbHeader);
print("MaxMessage: ", Sizes.cbMaximumMessage);
print("Trailer: ", Sizes.cbTrailer);


    local obj = {
        Credentials = creds;
        Socket = sock;
        Context = phContext;
        Sizes = Sizes;
        IoBufferLength = ioLength;
        IoBuffer = ffi.new("uint8_t[?]", ioLength);
    }
    setmetatable(obj, ClientSession_mt);

    return obj;
end

ClientSession.create = function(self, ...)
    return self:init(...);
end

ClientSession.Send = function(self, message)
    local maxbytes = math.min(self.Sizes.cbMaximumMessage, #message);
--    local cbIoBufferLength = self.Sizes.cbHeader  +  self.Sizes.cbMaximumMessage  +  self.Sizes.cbTrailer;
--    local pbIoBuffer       = ffi.new("uint8_t[?]", IoBufferLength);
    ffi.copy( self.IoBuffer+self.Sizes.cbHeader, message, maxbytes);    -- message begins after the header


    local res, err = EncryptSend(self.Socket, self.Context, self.IoBuffer, self.Sizes );

    return res, err;
end



return {
    ConnectToServer = ConnectToServer;
    CreateCreds = CreateCreds;
    PerformClientHandshake = PerformClientHandshake;

    EncryptSend = EncryptSend;
    DecryptReceive = DecryptReceive;

    CreateClientSession = CreateClientSession;

    ClientSession = ClientSession;
}