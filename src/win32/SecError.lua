 local bit = require("bit");
 local band = bit.band;
 local rshift = bit.rshift;
 local lshift = bit.lshift;

-- Success Cases
SEC_E_OK                         =(0x00000000);

-- Failure Cases
SEC_E_INSUFFICIENT_MEMORY		= (0x80090300);
SEC_E_INVALID_HANDLE			= (0x80090301);
SEC_E_UNSUPPORTED_FUNCTION		= (0x80090302);
SEC_E_INTERNAL_ERROR			= (0x80090304);

-- Success Cases
SEC_I_CONTINUE_NEEDED            =(0x00090312);
SEC_I_COMPLETE_NEEDED            =(0x00090313);
SEC_I_COMPLETE_AND_CONTINUE      =(0x00090314);
SEC_I_CONTEXT_EXPIRED            =(0x00090317);
SEC_E_INCOMPLETE_MESSAGE         =(0x80090318);
SEC_I_INCOMPLETE_CREDENTIALS     =(0x00090320);
SEC_I_RENEGOTIATE                =(0x00090321);



