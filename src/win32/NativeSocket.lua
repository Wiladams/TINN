
local ffi = require "ffi"

local WinSock = require "WinSock_Utils"
local ws2_32 = require("ws2_32");



ffi.cdef[[
typedef struct {
	SOCKET			Handle;
	WSAPOLLFD		fdarray;
} Socket_Win32;
]]


local NativeSocket = ffi.typeof("Socket_Win32");
local NativeSocket_mt = {
	__gc = function(self)
		--print("GC: NativeSocket: ", self.Handle, success, err);
		-- Force close on socket
		-- To ensure it's really closed
		local success, err = self:ForceClose();
	end,
	
	__new = function(ct, handle, family, socktype, protocol, flags)
		family = family or AF_INET;
		socktype = socktype or SOCK_STREAM;
		protocol = protocol or 0;
		flags = flags or WSA_FLAG_OVERLAPPED;

--print("NativeSocket:CT(): ", handle);	

		if not handle then
			handle = ws2_32.socket(family, socktype, protocol);
	
			if handle == INVALID_SOCKET then
				return nil, ws2_32.WSAGetLastError();
			end
		end
				
--print("NativeSocket:CCT(): ", handle);	

		local obj = ffi.new(ct);
		obj.Handle = handle;
		obj.fdarray.fd = handle;

		return obj;
	end,
	
	__index = {
		getNativeHandle = function(self)
			return ffi.cast("HANDLE", ffi.cast("intptr_t", self.Handle));
		end,

		--[[
			Setting various options
		--]]
		--
		-- SetKeepAlive
		-- Note: timeout and interval are in milliseconds
		SetKeepAlive = function(self, keepalive, timeout, interval)
			--[[
			struct tcp_keepalive {
    			ULONG onoff;
    			ULONG keepalivetime;
    			ULONG keepaliveinterval;
			};
			--]]
			timeout = timeout or 60*2*1000	-- two minutes
			interval = interval or 1*1000	-- one second

			local keeper = tcp_keepalive(1, timeout, interval);
			if not keepalive then
				keeper.onoff = 0;
			end
			local outbuffsize = ffi.sizeof(tcp_keepalive)
			local outbuff = ffi.new("uint8_t[?]", outbuffsize);
			local pbytesreturned = ffi.new("int32_t[1]")

			local success, err = WinSock.WSAIoctl(self.Handle, SIO_KEEPALIVE_VALS, 
				keeper, ffi.sizeof(tcp_keepalive),
				outbuff, outbuffsize,
				pbytesreturned);
			--print("SetKeepAlive, bytesreturned: ", pbytesreturned[0], outbuffsize)

			return success, err
		end,

		SetNoDelay = function(self, nodelay)
			local oneint = ffi.new("int[1]");
			if nodelay then
				oneint[0] = 1
			end

			return WinSock.setsockopt(self.Handle, IPPROTO_TCP, TCP_NODELAY, oneint, ffi.sizeof(oneint))
		end,
		
		SetNonBlocking = function(self, nonblocking)
			local oneint = ffi.new("int[1]");
			if nonblocking then
				oneint[0] = 1
			end

			return WinSock.ioctlsocket(self.Handle, FIONBIO, oneint);
		end,
		
		SetReuseAddress = function(self, reuse)
			local oneint = ffi.new("int[1]");
			if reuse then
				oneint[0] = 1
			end

			return WinSock.setsockopt(self.Handle, SOL_SOCKET, SO_REUSEADDR, oneint, ffi.sizeof(oneint))
		end,
		
		SetExclusiveAddress = function(self, exclusive)
			local oneint = ffi.new("int[1]");
			if exclusive then
				oneint[0] = 1
			end

			return WinSock.setsockopt(self.Handle, SOL_SOCKET, SO_EXCLUSIVEADDRUSE, oneint, ffi.sizeof(oneint))
		end,
		
		--[[
			Reading Socket Options
		--]]
		GetConnectionTime = function(self)
			local poptvalue = ffi.new('int[1]')
			local poptsize = ffi.new('int[1]',ffi.sizeof('int'))
			local size = ffi.sizeof('int')

			local success, err = WinSock.getsockopt(self.Handle, SOL_SOCKET, SO_CONNECT_TIME, poptvalue, poptsize)
		
		--print("GetConnectionTime, getsockopt:", success, err)
			if not success then
				return nil, err
			end

			return poptvalue[0];		
		end,

		GetLastError = function(self)
			local poptvalue = ffi.new('int[1]')
			local poptsize = ffi.new('int[1]',ffi.sizeof('int'))
			local size = ffi.sizeof('int')

			local success, err = WinSock.getsockopt(self.Handle, SOL_SOCKET, SO_ERROR, poptvalue, poptsize)
		
			if not success then
				return err
				--return nil, err
			end

			return poptvalue[0];
		end,

		--[[
			Connection Management
		--]]
		IsConnected = function(self)
			success, err = self:GetConnectionTime()
			if success and success >= 0 then
				return true
			end

			return false
		end,

		CloseDown = function(self)
			--print("++++++++++   CLOSEDOWN ++++++++++")
			local success, err = WinSock.DisconnectEx(self.Handle,nil,0,0);
			--print("DisconnectEx(): ", success, err);

			return WinSock.closesocket(self.Handle);
		end,

		ForceClose = function(self)
			return WinSock.closesocket(self.Handle);
		end,
		
		Shutdown = function(self, how)
			how = how or SD_SEND
			
			return WinSock.shutdown(self.Handle, how)
		end,
		
		ShutdownReceive = function(self)
			return WinSock.shutdown(self.Handle, SD_RECEIVE)
		end,

		ShutdownSend = function(self)
			return WinSock.shutdown(self.Handle, SD_SEND)
		end,



		--[[
			Client Socket Routines
		--]]
		ConnectTo = function(self, address)
			local name = ffi.cast("const struct sockaddr *", address)
			local namelen = ffi.sizeof(address)
			return WinSock.connect(self.Handle, name, namelen);
		end,

		--[[
			Server socket routines
		--]]
		MakePassive = function(self, backlog)
			backlog = backlog or 5
			return WinSock.listen(self.Handle, backlog)
		end,

		Accept = function(self)
			local handle, err =  WinSock.accept(self.Handle, nil, nil);

			if not handle then
				return false, err
			end
			
			return NativeSocket(handle)
		end,
		
		Bind = function(self, addr, addrlen)
			return WinSock.bind(self.Handle, addr, addrlen)
		end,
		
		--[[
			Data Transport
		--]]
		GetBytesPendingReceive = function(self)
			local oneint = ffi.new("int[1]");
			local success, err = WinSock.ioctlsocket(self.Handle, FIONREAD, oneint);
			if success then
				return oneint[0]
			end
			
			return false, err
		end,
	
		CanReadWithoutBlocking = function(self)
			self.fdarray.events = POLLRDNORM;

			-- wait a few milliseconds to see if there's
			-- anything waiting
			local success, err = WinSock.WSAPoll(self.fdarray, 1, 0);
			
			if not success then
				return false, err				
			end
			
			if success > 0 then
				return true
			end
			
			return false, "wouldblock";
		end,
		
		CanWriteWithoutBlocking = function(self)
			--local fdarray = WSAPOLLFD()
			--fdarray.fd = self.Handle;
			self.fdarray.events = POLLWRNORM;

			local success, err = WinSock.WSAPoll(self.fdarray, 1, 0);
			if not success then
				return false, err
			end

			if ret == 0 then
				return false, "wouldblock"
			end

			return true
		end,

		Send = function(self, buff, bufflen)
			bufflen = bufflen or #buff

			return WinSock.send(self.Handle, buff, bufflen);
		end,

		Receive = function(self, buff, bufflen)
			return WinSock.recv(self.Handle, buff, bufflen);
		end,
	},
}
NativeSocket = ffi.metatype(NativeSocket, NativeSocket_mt);


return NativeSocket;