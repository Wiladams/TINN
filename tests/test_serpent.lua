local serpent = require("serpent")


local tbl = {
	people = {
		["william"] = {First = "William", Last="Adams"},
		["mubeen"] = {First = "Mubeen", Last = "Begum"},
		["yasmin"] = {First = "Yasmin", Last = "Adams"},
	}
}

local stbl = serpent.encode(tbl)

print("========")
print(stbl)
print("--------")

print(serpent.decode(stbl))


