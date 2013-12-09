-- NetMesh.lua
--[[
	Implementation of a network mesh
--]]

local ffi = require("ffi");
local Timer = require("Timer")
local IOCPSocket = require("IOCPSocket");
local SocketUtils = require("SocketUtils")
local Network = require("Network")
local UdpListener = require("UdpListener")



local selfhost = Network.getHostName(ffi.C.ComputerNameDnsHostname):lower()

local NetMesh = {
  HeartbeatInterval = 50 * 1000;	-- send out a hearbeat on this interval
  UdpPort = 1313;					-- port used to communicate UDP
  EliminateSelf = true;			-- don't consider self to be a peer
}
setmetatable(NetMesh, {
  __call = function(self, ...)
    return self:create(...)
  end,
})

local NetMesh_mt = {
  __index = NetMesh,
}

NetMesh.init = function(self, config)
  local err
  local obj = {
    Config = config,
    Peers = {},
    Listener = UdpListener(NetMesh.UdpPort)
  }

  obj.UdpSender, err = IOCPSocket:create(AF_INET, SOCK_DGRAM, 0);

  setmetatable(obj, NetMesh_mt)

  return obj;
end

NetMesh.create = function(self, configfile)
  -- load the configuration file
  local fs, err = io.open(configfile, "rb")
	
  if not fs then return nil, "could not load file" end

  local configdata = fs:read("*all")
  fs:close();
	
  local func, err = loadstring(configdata)
  local config = func()

  -- create self, so peers can be added
  local obj = self:init()


  -- for each of the peers within the config 
  -- create a new peer, and add it to the 
  -- list of peers for the first object
  for _,peerconfig in ipairs(config) do
		--print("PEER: ", peerconfig.name, peerconfig.host)
    if peerconfig.name:lower() ~= selfhost then
      obj:createPeer(peerconfig)
    end
  end


  -- add the heartbeat timer
  obj.HeartbeatTimer = Timer({
		Delay =  NetMesh.HeartbeatInterval;
		Period = NetMesh.HeartbeatInterval;
		OnTime = obj:onHeartbeat();})

  -- start a fiber which will run the UDP listener loop
  obj.Listener:run(self:onReceiveMessage())

  return obj;
end


NetMesh.createPeer = function(self, config)
  local address = SocketUtils.CreateSocketAddress(config.host, config.udpport or NetMesh.UdpPort)
  local addrlen = ffi.sizeof(address);
  self.Peers[config.name] = {
    name = config.name;
    host = config.host;
    address = address;
    addrlen = addrlen;
  }

  return true;
end

NetMesh.broadcastMessage = function(self, message, length)
    length = length or #message
    for _, peer in ipairs(self.Peers) do
        local bytessent, err = self.UdpSender:sendTo(peer.address, peer.addrlen, 
          message, length);
    end

    return true;
end


NetMesh.onHeartbeat = function(self)
  local message = "HELLO FROM: "..Network:getHostName();
  local closure = function(timer)
      self:broadcastMessage(message)
  end

  return closure
end


NetMesh.onReceiveMessage = function(self)
    local bufflen = 1500;
    local buff = ffi.new("uint8_t[1500]");

    local closure = function(buff, bufflen)
      local msg = ffi.string(buff, bufflen)
      print("RECEIVED: ", msg)
    end

    return closure, buff, bufflen;
end


return NetMesh

