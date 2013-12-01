-- BGProtocol.lua
--[[
	Implementation of Boundary Gateway Protocol (BGP)
--]]

local ffi = require("ffi");
local Timer = require("Timer")
local IOCPSocket = require("IOCPSocket");
local SocketUtils = require("SocketUtils")
local Network = require("Network")

--[[
	BGP Relies on the presence of a fully connected graph
	The Protocol object is initialized by reading a list of nodes
	and creating the right channels between each of the nodes.
--]]

--[[
print("ComputerNameNetBIOS: ", Network.getHostName(ffi.C.ComputerNameNetBIOS))
print("ComputerNameDnsHostname: ", Network.getHostName(ffi.C.ComputerNameDnsHostname))
print("ComputerNameDnsDomain: ", Network.getHostName(ffi.C.ComputerNameDnsDomain))
print("ComputerNameDnsFullyQualified: ", Network.getHostName(ffi.C.ComputerNameDnsFullyQualified))
print("ComputerNamePhysicalNetBIOS: ", Network.getHostName(ffi.C.ComputerNamePhysicalNetBIOS))
print("ComputerNamePhysicalDnsHostname: ", Network.getHostName(ffi.C.ComputerNamePhysicalDnsHostname))
print("ComputerNamePhysicalDnsDomain: ", Network.getHostName(ffi.C.ComputerNamePhysicalDnsDomain))
print("ComputerNamePhysicalDnsFullyQualified: ", Network.getHostName(ffi.C.ComputerNamePhysicalDnsFullyQualified))
--]]

local selfhost = Network.getHostName(ffi.C.ComputerNameDnsHostname):lower()
--print("Self Host: ",selfhost)

local BGPPeer = {
  HeartbeatInterval = 50 * 1000;	-- send out a hearbeat on this interval
  UdpPort = 1313;					-- port used to communicate UDP
  EliminateSelf = true;			-- don't consider self to be a peer
}
setmetatable(BGPPeer, {
  __call = function(self, ...)
    return self:create(...)
  end,
})

local BGPPeer_mt = {
  __index = BGPPeer,
}

BGPPeer.init = function(self, config)
  local err
  local obj = {
    Config = config,
    Peers = {},
  }

  -- if there is config information, then use
  -- it to setup sockets to the peer
  if config then
    -- create the client socket
    obj.Name = config.name;
    obj.UdpSender, err = IOCPSocket:create(AF_INET, SOCK_DGRAM, 0);
    obj.UdpPeerAddress, err = SocketUtils.CreateSocketAddress(config.host, config.udpport or BGPPeer.UdpPort)


    obj.UdpPeerAddressLen = ffi.sizeof(obj.UdpPeerAddress);
  end

  setmetatable(obj, BGPPeer_mt)

  return obj;
end

BGPPeer.create = function(self, configfile)
  -- load the configuration file
  local fs, err = io.open(configfile, "rb")
	
  if not fs then return nil, "could not load file" end

  local configdata = fs:read("*all")
  fs:close();
	
  local func, err = loadstring(configdata)
  local config = func()

  -- create self, so peers can be added
  local obj = self:init()

  -- add the udp socket
  -- Setup the server socket
  obj.UdpListener, err = IOCPSocket:create(AF_INET, SOCK_DGRAM, 0);
  if not obj.UdpListener then
    return nil, err;
  end

  local success, err = obj.UdpListener:bindToPort(BGPPeer.UdpPort);

  if not success then
    return nil, err;
  end

  -- for each of the peers within the config 
  -- create a new peer, and add it to the 
  -- list of peers for the first object
  for _,peerconfig in ipairs(config) do
		--print("PEER: ", peerconfig.name, peerconfig.host)
    if peerconfig.name:lower() ~= selfhost then
      obj:createPeer(peerconfig)
    end
  end

  -- Need to setup a listener for the UDP port

  -- add the heartbeat timer
  obj.HeartbeatTimer = Timer({
		Delay =  BGPPeer.HeartbeatInterval;
		Period = BGPPeer.HeartbeatInterval;
		OnTime = obj:onHeartbeat();})

  -- start a fiber which will run the UDP listener loop
  spawn(obj:handleUdpListen())

  return obj;
end

BGPPeer.onHeartbeat = function(self)
  local message = "HELLO FROM: "..Network:getHostName();
  local closure = function(timer)

  for peername, peer in pairs(self.Peers) do
    local bytessent, err = peer.UdpSender:sendTo(peer.UdpPeerAddress, peer.UdpPeerAddressLen, 
      message, #message);

    end
  end

  return closure
end

BGPPeer.addPeer = function(self, peer)
  self.Peers[peer.Name] = peer
end

BGPPeer.createPeer = function(self, peerconfig)
  self:addPeer(BGPPeer:init(peerconfig));
end

local count = 0;
BGPPeer.onReceiveHeartBeat = function(self, buff, bytesread)
  count = count + 1
  print("onReceiveHeartBeat: ", count, ffi.string(buff, bytesread));
end


BGPPeer.handleUdpListen = function(self)
  local bufflen = 1500;
  local buff = ffi.new("uint8_t[1500]");
  local from = sockaddr_in();
  local fromLen = ffi.sizeof(from);


  local closure = function()

    while true do
      local bytesread, err = self.UdpListener:receiveFrom(from, fromLen, buff, bufflen);

      if not bytesread then
        print("receiveFrom ERROR: ", err)
        return false, err;
      end

      self:onReceiveHeartBeat(buff, bytesread)
    end
  end

  return closure
end


return BGPPeer

