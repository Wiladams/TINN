--pcaplog.lua
--[[
	References
	http://wiki.wireshark.org/Development/LibpcapFileFormat

--]]

local BlockFile = require("BlockFile")
local Stream = require("stream")


local PCapLog = {}
local PCapLog_mt = {
	__index = PCapLog,
}

function PCapLog.init(self, obj)

	setmetatable(obj, PCapLog_mt)

	obj:writeLogHeader()

	return obj;
end

function PCapLog.create(self, params)
	params = params or {}

	params.Outstream = params.OutStream or Stream(BlockFile("CONOUT$", nil, OPEN_EXISTING, FILE_SHARE_WRITE));
	params.SnapLength = params.SnapLength or 65535;

	return self:init(params)
end


ffi.cdef[[
#pragma pack(1)

typedef struct pcap_hdr_s {
        guint32 magic_number;   /* magic number */
        guint16 version_major;  /* major version number */
        guint16 version_minor;  /* minor version number */
        gint32  thiszone;       /* GMT to local correction */
        guint32 sigfigs;        /* accuracy of timestamps */
        guint32 snaplen;        /* max length of captured packets, in octets */
        guint32 network;        /* data link type */
} pcap_hdr_t;

typedef struct pcaprec_hdr_s {
        guint32 ts_sec;         /* timestamp seconds */
        guint32 ts_usec;        /* timestamp microseconds */
        guint32 incl_len;       /* number of octets of packet saved in file */
        guint32 orig_len;       /* actual length of packet */
} pcaprec_hdr_t;


static const int LINKTYPE_RAW = 101;
]]


function PCapLog.writeLogHeader(self)
	local magic = 0xa1b2c3d4;
	local version_major = 2;
	local version_minor = 4;
	local thiszone = 0;
	local sigfigs = 0;
	local snaplen = self.SnapLength;
	local network = ffi.C.LINKTYPE_RAW;

	local hdr = ffi.new("pcap_hdr_t", {
		magic, 
		version_major, 
		version_minor,
		thiszone,
		sigfigs,
		snaplen,
		network})

	self.OutStream:writeBytes(hdr, ffi.sizeof(hdr), 0)
end

function PCapLog.writeRecord(self, record)
	local ts_sec = 0;
	local ts_usec = 0;
	local incl_len = min(record.packetlength, self.SnapLength);
	local orig_len = record.packetlength;

	local hdr = ffi.new("pcaprec_hdr_t", {
		ts_sec,
		ts_usec,
		incl_len,
		orig_len,
	});

	self.OutStream:writeBytes(ffi.cast("const char *", hdr), ffi.sizeof(hdr), 0)

	-- now write the actual packet
	self.OutStream:writeBytes(record.data, incl_len, 0)
end

function PCapLog.close(self)
	self.OutStream:close();
end
