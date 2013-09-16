--[[
	References:

	http://www.ietf.org/rfc/rfc2396.txt
	URI

	http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html
	HTTP/1.1
--]]

local m=require("lpeg")

local P = m.P
local R = m.R
local S = m.S
local C = m.C
local Cf = m.Cf
local Ct = m.Ct
local Cp = m.Cp
local match = m.match

function hextochar(lexeme)
	--print("Lexeme: ", lexeme);
	return string.char(tonumber(lexeme, 16));
end

local CRLF = P("\r\n");
local LE = P(P"\r\n" + P"\n") * Cp()
local LINE = P(1-LE)^0
local SP = S("\t ")^1
local OPT_SP = S("\t ")^0
local dot = P'.'

local digit 			= R("09")
local upalpha 			= R("AZ")
local lowalpha 			= R("az")
local alpha 			= lowalpha + upalpha
local alphanum 			= alpha + digit
local hex 				= digit + R("af", "AF")


-- Character categories

local escaped 			= P'%' * C(hex*hex)/hextochar
local mark			 	= S("-_.!~*'()");
local unreserved		= alphanum + mark
local reserved 			= S(";/?:@&=+,$");
local uric				= reserved + unreserved + escaped

local authority_reserved 	= S(";/?:@")
local uri_delims			= S('<>#%"')
local uri_unwise			= S("{}|\\^[]'")

local fragment			= uric^1
local query				= uric^1

local pchar				= unreserved + escaped + S(":@&=+$,")
local param				= pchar^1
local segment			= C(pchar^1 * (P';' * param)^0)
local path_segments		= Ct(segment * (P'/' * segment)^0)

-- Host patterns
local port = digit^1
local IPv4address = digit^1 * dot * digit^1 * dot * digit^1 * dot * digit^1
local toplabel =  C(alpha * (alphanum + P'-')^0) -- + alpha
local domainlabel = C(alphanum * P(alphanum + P'-')^0)
local hostname = P(domainlabel * dot)^0 * toplabel * dot^-1
local host = hostname + IPv4address
local hostport = host * P(P':' * port)^-1

local userinfo			= P(unreserved + escaped + S(";:&=+$,"))^1
local server			= P((C(userinfo) * P'@')^-1 * C(hostport))^-1

local reg_name			= P(unreserved + escaped + S("$,;:@&=+"))^1

--local authority_end = P(P'/'+P'?')
--local authority = P"//" * C(P(1-authority_reserved)^0) * authority_end^-1
--local authority 		= server + reg_name
local authority 		= server + reg_name

local scheme = alpha * P(alpha + digit + P'+' + P'-' + P'.')^0

local rel_segment		= P(unreserved + escaped + S(";@&=+$,"))^1

local abs_path			= C(P'/' * path_segments)
local net_path 			= P"//" * C(authority) * P(abs_path)^-1
local rel_path			= rel_segment * (abs_path)^-1

local uric_no_slash			= unreserved + S(";?:@&=+,$") + escaped

local opaque_part		= uric_no_slash * uric^0
local hier_part			= P(net_path + abs_path) * P(P'?' * query)^-1

local relativeURI = P(net_path + abs_path + rel_path) * P(P'?' * query)^-1
local absoluteURI = C(scheme) * P':' * P(hier_part + opaque_part)
local URI_Reference		= P(absoluteURI + relativeURI) * P(P'#' * C(fragment))^-1

--local path				= abs_path + opaque_part



local P_token = P(1-SP)^1
local P_Field = P(1-(P':'+SP))^1
local header_name = C(P(alpha * P(alphanum + P'-')^1))
local header_value = C(P(1)^0)
local header = Ct(header_name * P':' * OPT_SP * header_value)

local Method =
	P"GET" +
	P"HEAD" +
	P"POST" +
	P"PUT" +
	P"DELETE" +
	P"TRACE" +
	P"CONNECT" +
	P"OPTIONS"

local HTTP_Version = P"HTTP" * P'/' * C(digit^1) * P'.' * C(digit^1)
local P_Response_Line = HTTP_Version * SP * C(digit^1) * SP * C(P(1)^0)

-- URI Parsing
--local P_abs_path = P'/' * path_segments
--local P_net_path = P"//" * authority * P(abs_path)^-1
--local P_hier_part = P(P_net_path + P_abs_path) * P(P'?' * P_token)^-1
--local uric = reserved + unreserved + escaped



local P_URI = C(scheme) * P':' * C(P_token)
local P_URL = C(scheme) * P':' * authority

--local host = host_ipaddress + host_fqn
--local Request_URI = P"*" + absoluteURI | abs_path | authority
local Request_URI = P_token

local http_URL = P"http:" * "//" * Ct(host) * P(':' * C(port))^-1 * P(abs_path * P('?' * query)^-1)^-1 * Cp()




-- Request processing
--local Request_Line = C(Method) * SP  * C(P_token) * SP * HTTP_Version * CRLF
local Request_Line = C(Method) * SP  * C(P_token) * SP * HTTP_Version




return {
	Request_Line = Request_Line,
	P_Header = header,
	Response_Line = P_Response_Line,
	AbsoluteURI = absoluteURI,
	URI_Reference = URI_Reference,
	Authority = authority,
	path_segments = path_segments,
	http_URL = http_URL,

	-- Parsing components
	LE = LE,		-- Line Ending
	LINE = LINE,

	Match = match,
}
