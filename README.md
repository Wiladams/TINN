TINN
===

TINN is a Swiss army knife for coding on the Windows platform, using the lua language.  
With TINN, you can create any number of interesting applications from somewhat scalable 
web services to collaborative video games.

TINN is based on the LuaJIT compiler.  As such, the programs you write for TINN are actually 
normal looking LuaJIT scripts.

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
local Network = require("Network")
print("local: ", Network:GetLocalAddress())
```  
  
The general philosophy behind TINN is to make fairly mundane things very easy, make very hard things very approachable, and keep really easy things really easy.  
  

Building TINN
-------------

Within the src directory, you will find almost everything you need to build TINN.  As TINN is specifically
meant for Windows, there is a msvcbuild.bat file.  If you've ever compiled the LuaJIT project, this will look
very familiar because it's derived from the LuaJIT build file, with very project specific modifications.
*	Bring up a Visual Studio command prompt  
*	cd to the src directory  
*	run the msvcbuild.bat script  

You will end up with a tinn.exe file located in the '.\bin' directory.  To use TINN, you will need the copy all the stuff in the '.\bin' directory to a location of your choosing.  Best is to move the directory to somewhere, and then make that part of your path.  The root directory also contains the files to somewhere in your PATH.

Using TINN
----------

Run the tinn.exe program, and pass it the name of the script you want to run:

tinn.exe test_network.lua


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

* cabinet.lua<p>
* core_console_l1_1_0.lua<p>
* core_console_l2_1_0.lua<p>
* core_datetime_l1_1_1.lua<p>
* core_debug_l1_1_1.lua<p>
* core_errorhandling_l1_1_1.lua<p>
* core_file_l1_2_0.lua<p>
* core_file_l2_1_0.lua<p>
* core_firmware_l1_1_0.lua<p>
* core_interlocked.lua<p>
* core_io_l1_1_1.lua<p>
* core_libraryloader_l1_1_1.lua<p>
* core_memory_l1_1_1.lua<p>
* core_namedpipe_l1_2_0.lua<p>
* core_processenvironment.lua<p>
* core_processthreads_l1_1_1.lua<p>
* core_profile_l1_1_0.lua<p>
* core_psapi_l1_1_0.lua<p>
* core_shutdown_l1_1_0.lua<p>
* core_string_l1_1_0.lua<p>
* core_synch_l1_2_0.lua<p>
* core_sysinfo_l1_2_0.lua<p>
* core_timezone_l1_1_0.lua<p>
* crypt.lua<p>
* dsrole.lua<p>
* Handle_ffi.lua<p>
* Heap_ffi.lua<p>
* httpapi.lua<p>
* lmcons.lua<p>
* mswsock.lua<p>
* NTSecAPI.lua<p>
* power_base_l1_1_0.lua<p>
* samcli.lua<p>
* security_base_l1_2_0.lua<p>
* security_credentials_l1_1_0.lua<p>
* security_lsalookup_l2_1_0.lua<p>
* security_sddl_l1_1_0.lua<p>
* service_core_l1_1_1.lua<p>
* service_management_l1_1_0.lua<p>
* sspicli.lua<p>
* sspi_ffi.lua<p>
* SubAuth.lua<p>
* UMS_ffi.lua<p>
* Util_ffi.lua<p>
* WinBer_ffi.lua<p>
* WinCon.lua<p>
* wkscli.lua<p>

License
-------
Microsoft Public License
