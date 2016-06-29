TINN
===
Make some changes
As an acronym, TINN could stand for many things:
*	Test Infrastructure for Network Nodes
*	Tcp IP Networking Nodule

One thing is for sure though  
	
	TINN Is Not Node


TINN is like a Swiss army knife for coding on the Windows platform.  With TINN, you can create any number
of interesting applications from somewhat scalable web services to collaborative video games.

TINN is based on the LuaJIT compiler.  As such, the programs you write for TINN are actually normal looking LuaJIT scripts.

Included in the box with TINN are some basic modules  
*	lpeg - for interesting text parsing and manipulation  
*	zlib - because you'll want to compress some stuff  
*	networking - because you'll want to talk to other things  
*	win32 - User32, GDI32, Kernel32, BCrypt, so you can easily put Windows based stuff together

As TINN is focused on Windows development, there is quite a lot available in the windows bindings.
There is the concept of api sets, which reflect the layering of APIs since Windows 7.  Within the api sets
you will find items such as ldap, sspi, libraryloader, processthreads, security_base, etc.

In addition to the basics, TINN includes a fairly simple, but useful, event scheduler.  
This scheduler supports a cooperative multi-tasking networking module, as well as a general 
model for seamlessly dealing with cooperative processing.  
  
Here is a very simple example of getting the IP address of the networking interface:  
```
local net = require("Network")()`  
print(net:GetLocalInterface())`  
```  
  
The general philosophy behind TINN is to make fairly mundane things very easy, make very hard things very approachable, and keep really easy things really easy.  
  

Building TINN
-------------

Within the src directory, you will find almost everything you need to build TINN.  As TINN is specifically
meant for Windows, there is a msvcbuild.bat file.  If you've ever compiled the LuaJIT project, this will look
very familiar because it's the same file, with some specific modifications.
*	Bring up a Visual Studio command prompt  
*	cd to the src directory  
*	run the msvcbuild.bat script  

You will end up with a tinn.exe file located in the '.\bin' directory.  To use TINN, you will need the copy all the stuff in the '.\bin' directory to a location of your choosing.  Best is to move the directory to somewhere, and then make that part of your path.  The root directory also contains the files msvcr100.dll and msvcp100.dll.  These are the C runtime library files for Visual Studio 10.0.

Using TINN
----------

Run the tinn.exe program, and pass it the name of the script you want to run:

tinn.exe test_network.lua


TINN introduces a couple of fairly useful constructs.  'include' and 'use'.

the "require()" function is native the the Lua language.  'include' builds upon this by making a global variable with
the same name as the required module.

include('dsrole')

This will make available a global variable with the name 'dsrole'.  This gives you a ready handle on the module.  Really
it's different than simply calling 'require' where it is needed, as the system also maintains a handle on the module.

use('dsrole')

The 'use()' function is slightly different.  It will also perform a 'require' on the module, but it will also make global anything that is returned from the call.  This assumes that what is returned from the call is a table.  This is useful for
quickly turning a module into a set of globally accessible functions.  So, if you have a module that looks like the following:

```
-- dsrole.lua
local dsrole = {
    DsRoleFreeMemory = Lib.DsRoleFreeMemory,
    DsRoleGetPrimaryDomainInformation = Lib.DsRoleGetPrimaryDomainInformation,    
};
```

return dsrole

If you then call:

use("dsrole")

The functions, DsRoleFreeMemory, and DsRoleGetPrimaryDomainInformation will become functions in the global namespace.
this is very convenient from the programmer's perspective as it makes coding look very similar to what you would do 
if you were simply programming in 'C' using these APIs.  At the same time, you are not forced to use this mechanism.
If you prefer to maintain functions in their modular scoped spaces, then you can simply use the regular 'require' function.  Ideally, you should not use the 'use' mechanism.

Examples
--------
There are a growing number of examples to be found in the TINNSnips project:  
https://github.com/Wiladams/TINNSnips  


Windows API Sets
----------------

Windows API Sets are documented here:
http://msdn.microsoft.com/en-us/library/windows/desktop/hh802935(v=vs.85).aspx

The primary benefit of the API sets is to create a layering within the Wondows APIs such that lower layers do not have to pull in higher layers.  On Windows 8, each set is actually represented by a .dll alias, which the library loader knows how to deal with.  It will only load in the code necessary for the function set.  This mechanism doesn't work on down level platforms (windows 7), so the plain libraries, such as 'kernel32.dll' are referenced.

The general approach of these ffi interfaces is to provide basic FFI access to the core routines in each set.  They are relatively unadorned, meaning there are no wrappers to make thing easier.  The basic interfaces are there and that's it.  The one benefit is that each file returns a table that contains all the referenced API calls.  This makes it convenient to do something like the following:

```
local console = require("core_console_l1_1_0");
console.AllocConsole();
```

The user does not need to know which library contains the AllocConsole call.  This also makes helps to keep the names out of the global namespace, but provide a mechanism to export them into the global namespace if that is desirable.

The API sets that are currently implemented.

cabinet.lua<p>
core_console_l1_1_0.lua<p>
core_console_l2_1_0.lua<p>
core_datetime_l1_1_1.lua<p>
core_debug_l1_1_1.lua<p>
core_errorhandling_l1_1_1.lua<p>
core_file_l1_2_0.lua<p>
core_file_l2_1_0.lua<p>
core_firmware_l1_1_0.lua<p>
core_interlocked.lua<p>
core_io_l1_1_1.lua<p>
core_libraryloader_l1_1_1.lua<p>
core_memory_l1_1_1.lua<p>
core_namedpipe_l1_2_0.lua<p>
core_processenvironment.lua<p>
core_processthreads_l1_1_1.lua<p>
core_profile_l1_1_0.lua<p>
core_psapi_l1_1_0.lua<p>
core_shutdown_l1_1_0.lua<p>
core_string_l1_1_0.lua<p>
core_synch_l1_2_0.lua<p>
core_sysinfo_l1_2_0.lua<p>
core_timezone_l1_1_0.lua<p>
crypt.lua<p>
dsrole.lua<p>
Handle_ffi.lua<p>
Heap_ffi.lua<p>
httpapi.lua<p>
lmcons.lua<p>
mswsock.lua<p>
NTSecAPI.lua<p>
power_base_l1_1_0.lua<p>
samcli.lua<p>
security_base_l1_2_0.lua<p>
security_credentials_l1_1_0.lua<p>
security_lsalookup_l2_1_0.lua<p>
security_sddl_l1_1_0.lua<p>
service_core_l1_1_1.lua<p>
service_management_l1_1_0.lua<p>
sspicli.lua<p>
sspi_ffi.lua<p>
SubAuth.lua<p>
UMS_ffi.lua<p>
Util_ffi.lua<p>
WinBer_ffi.lua<p>
WinCon.lua<p>
wkscli.lua<p>

License
-------
Microsoft Public License
