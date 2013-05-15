local dsrole = require("dsrole");

local info = dsrole.getPrimaryDomainInfo();

for k,v in pairs(info) do
    print(k,v)
end


