--[[
	References:
	https://bitbucket.org/wilhelmy/lua-bencode/src

	public domain lua-module for handling bittorrent-bencoded data.
	This module includes both a recursive decoder and a recursive encoder.

--]]

local floor = math.floor
local sort, concat = table.sort, table.concat
local pairs, ipairs, type = pairs, ipairs, type
local tonumber = tonumber


local function islist(t)
	local n = #t
	for k, v in pairs(t) do
		if type(k) ~= "number" or floor(k) ~= k or k < 1 or k > n then
			return false
		end
	end
	for i = 1, n do
		if t[i] == nil then
			return false
		end
	end

	return true
end

local function isdictionary(t)
	return not islist(t)
end



-- recursively bencode x
local encode_funcs = {
		["string"] = function(x)
			return #x .. ":" .. x
		end,

		["number"] = function(x)
			if x % 1 ~= 0 then
				return nil, "number is not an integer: '" .. x .. "'"
			end

			return "i" .. x .. "e"
		end,

		["table"] = function(x)
			local ret = {}
			if islist(x) then
				table.insert(ret, "l")
				for k, v in ipairs(x) do
					table.insert(ret, encode(v))
				end
				table.insert(ret,"e")
			else -- dictionary
				table.insert(ret,"d")
				-- bittorrent requires the keys to be sorted.
				local sortedkeys = {}
				for k, v in pairs(x) do
					if type(k) ~= "string" then
						return nil, "bencoding requires dictionary keys to be strings"
					end
					sortedkeys[#sortedkeys + 1] = k
				end
				sort(sortedkeys)

				for k, v in ipairs(sortedkeys) do
					table.insert(ret,encode(v))
					table.insert(ret,encode(x[v]))
				end
				table.insert(ret,"e")
			end
			return table.concat(ret)
		end,
}

function encode(x)
	local tx = type(x)
	local func = encode_funcs[tx]
	if not func then
		return nil, tx .. " cannot be converted to an acceptable type for bencoding"
	end

	return func(x)
end

local function decode_integer(s, index)
	local a, b, int = s:find("^([0-9]+)e", index)

	if not int then
		return nil, "not a number: nil"
	end

	int = tonumber(int)

	if not int then
		return nil, "not a number: "..int
	end

	return int, b + 1
end

local function decode_list(s, index)
	local t = {}
	while s:sub(index, index) ~= "e" do
		local obj
		obj, index = decode(s, index)
		t[#t + 1] = obj
	end
	index = index + 1

	return t, index
end

local function decode_dictionary(s, index)
	local t = {}

	while s:sub(index, index) ~= "e" do
		local obj1
		obj1, index = decode(s, index)
		local obj2
		obj2, index = decode(s, index)
		t[obj1] = obj2
	end
	index = index + 1

	return t, index
end

local function decode_string(s, index)
	local a, b, len = s:find("^([0-9]+):", index)

	if not len then
		return nil, "not a length"
	end

	index = b + 1

	local v = s:sub(index, index + len - 1)
	index = index + len
	return v, index
end


function decode(s, index)
	index = index or 1
	local t = s:sub(index, index)

	if not t then
		return nil, "invalid index"
	end

	if t == "i" then
		return decode_integer(s, index + 1)
	elseif t == "l" then
		return decode_list(s, index + 1)
	elseif t == "d" then
		return decode_dictionary(s, index + 1)
	elseif t >= '0' and t <= '9' then
		return decode_string(s, index)
	else
		return nil, "invalid type"
	end
end

return {
	encode = encode,
	decode = decode,
}

