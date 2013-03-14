
local JSON = require "dkjson"

tab = {}

jase = JSON.encode(tab)

print(jase)

nametab = {
	name = "William",
	mail = true,
	age = 48,
	address = {"123", "mockingbird lane"}
}

print(JSON.encode(nametab, {indent=true}))
