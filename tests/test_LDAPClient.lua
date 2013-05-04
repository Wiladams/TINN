-- test_LDAPClient.lua
--
-- Reference
-- http://msdn.microsoft.com/en-us/library/aa367016(v=vs.85).aspx
--

local ffi = require("ffi");
local LDAPClient = require("LDAPClient");
local strutils = require("stringzutils");

local printf = function(fmt, ...)
	print(string.format(fmt,...));
end

-- Create the client
local function createClient(HostName)
	local client, err = LDAPClient {HostName=HostName};

	assert(client, err);

	-- Connect to the server
	assert(client:connect());
	
	return client;
end

-- Do binding/authentication

-- Issue query
--[[
ldap.provider_url = ldap://ldap.testathon.net:389/
ldap.id_field = cn
ldap.object_context = OU=users,DC=testathon,DC=net
ldap.search_context = OU=users,DC=testathon,DC=net
ldap.email_field = mail
ldap.surname_field = sn
ldap.givenname_field = givenName
ldap.phone_field = telephoneNumber
ldap.search_scope = 2
ldap.search.user = CN=stuart,OU=users,DC=testathon,DC=net
ldap.search.password = stuart

ULONG ldap_search_sA(
        LDAP            *ld,
        const char *     base,
        ULONG           scope,
        const char *     filter,
        const char *           attrs[],
        ULONG           attrsonly,
        LDAPMessage     **res
    );
--]]
local function doSearch(client)
    ----------------------------------------------------------
    -- Perform a synchronous search of fabrikam.com for 
    -- all user objects that have a "person" category.
    ----------------------------------------------------------
    local errorCode = ffi.C.LDAP_SUCCESS;
    local pSearchResult = ffi.new("LDAPMessage *[1]");
    local pMyFilter = "(&(objectCategory=person)(objectClass=user))";
    local pMyAttributes = ffi.new("const char *[6]");

    pMyAttributes[0] = "cn";
    pMyAttributes[1] = "company";
    pMyAttributes[2] = "department";
    pMyAttributes[3] = "telephoneNumber";
    pMyAttributes[4] = "memberOf";
    pMyAttributes[5] = nil;
    
    local errorCode = client.Native.ldap_search_sA(
                    client.Handle.Handle,    -- Session handle
                    "DC=testathon,DC=net",              -- DN to start search
                    ffi.C.LDAP_SCOPE_SUBTREE, -- Scope
                    pMyFilter,          -- Filter
                    pMyAttributes,      -- Retrieve list of attributes
                    0,                  -- Get both attributes and values
                    pSearchResult);    -- [out] Search results
    
    if (errorCode ~= ffi.C.LDAP_SUCCESS) then
        print(string.format("ldap_search_s failed with 0x%0x ",errorCode));
        --client.Native.ldap_unbind_s(pLdapConnection);
        if (pSearchResult ~= nil) then
           --ldap_msgfree(pSearchResult);
        end

        return false;
    end

    print("ldap_search succeeded");

    return pSearchResult[0];
end



-- Get results
--[=[
local function printResults(pLdapConnection, pSearchResult)
	----------------------------------------------------------
    -- Get the number of entries returned.
    ----------------------------------------------------------
    local numberOfEntries;
    
    numberOfEntries = wldap32.Native.ldap_count_entries(
                        pLdapConnection,    -- Session handle
                        pSearchResult);     -- Search result
    
    if(numberOfEntries == 0) then
        print(string.format("ldap_count_entries failed with 0x%0lx ",errorCode));

        return false;
    end
    
    printf("The number of entries is: %d ", numberOfEntries);
    
    
    ----------------------------------------------------------
    -- Loop through the search entries, get, and output the
    -- requested list of attributes and values.
    ----------------------------------------------------------
    LDAPMessage* pEntry = nil;
    PCHAR pEntryDN = nil;
    local iCnt = 0;
    char* sMsg;
    BerElement* pBer = nil;
    PCHAR pAttribute = nil;
    PCHAR* ppValue = nil;
    local iValue = 0;
    
    for iCnt=0, numberOfEntries-1 do
    
        -- Get the first/next entry.
        if( iCnt == 0) then
            pEntry = ldap_first_entry(pLdapConnection, pSearchResult);
        else
            pEntry = ldap_next_entry(pLdapConnection, pEntry);
        end

        -- Output a status message.
        --sMsg = (!iCnt ? "ldap_first_entry" : "ldap_next_entry");
        if( pEntry == nil ) then
            printf("%s failed with 0x%0lx \n", sMsg, LDAPClient.Native.LdapGetLastError());
            return false;
        else
            printf("%s succeeded\n",sMsg);
        end

        -- Output the entry number.
        printf("ENTRY NUMBER %i \n", iCnt);
                
        -- Get the first attribute name.
        pAttribute = LDAPClient.Native.ldap_first_attribute(
                      pLdapConnection,   -- Session handle
                      pEntry,            -- Current entry
                      &pBer);            -- [out] Current BerElement
        
        -- Output the attribute names for the current object
        -- and output values.
        while(pAttribute ~= nil) do
        
            -- Output the attribute name.
            printf("     ATTR: %s",pAttribute);
            
            -- Get the string values.

            ppValue = ldap_get_values(
                          pLdapConnection,  -- Session Handle
                          pEntry,           -- Current entry
                          pAttribute);      -- Current attribute

            -- Print status if no values are returned (NULL ptr)
            if(ppValue == nil) then
                printf(": [NO ATTRIBUTE VALUE RETURNED]");

            -- Output the attribute values
            else
            
                iValue = LDAPClient.Native.ldap_count_values(ppValue);
                if(!iValue) then
                
                    printf(": [BAD VALUE LIST]");
                
                else
                
                    -- Output the first attribute value
                    printf(": %s", *ppValue);

                    -- Output more values if available
                    for z=1, iValue-1 do
                        printf(", %s", ppValue[z]);
                    end
                end
            end 

            -- Free memory.
            if(ppValue ~= nil) then  
                LDAPClient.Native.ldap_value_free(ppValue);
            end

            ppValue = nil;
            LDAPClient.Native.ldap_memfree(pAttribute);
            
            -- Get next attribute name.
            pAttribute = LDAPClient.Native.ldap_next_attribute(
                            pLdapConnection,   -- Session Handle
                            pEntry,            -- Current entry
                            pBer);             -- Current BerElement
            printf("\n");
        end
        
        if( pBer ~= nil ) then
            LDAPClient.Native.ber_free(pBer,0);
        end

        pBer = nil;
    end
end
--]=]



local client = createClient("ldap.testathon.net:389");

local results = doSearch(client);
