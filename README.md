TINN
====

As an acronym, TINN could stand for many things:
*	Test Infrastructure for Network Nodes
*	Tcp IP Networking Nodule

One thing is for sure though  
	
	TINN Is Not Node


TINN is like a Swiss army knife for coding on the Windows platform.  With TINN, you can create any number
of interesting applications from somewhat scalable web services to collaborative video games.

TINN is based on the LuaJIT compiler.  As such, the programs you write for TINN are actually normal looking Lua scripts.

Included in the box with TINN are some basic modules  
*	lpeg - for interesting text parsing and manipulation  
*	zlib - because you'll want to compress some stuff  
*	networking - because you'll want to talk to other things  
*	win32 - User32, GDI32, Kernel32, BCrypt, so you can easily put Windows based stuff together  

In addition to the basics, TINN includes a fairly simple, but useful, event scheduler.  
This scheduler supports a cooperative multi-tasking networking module, as well as a general 
model for seamlessly dealing with cooperative processing.  
  
Here is a very simple example of getting the IP address of the networking interface:  

`local net = require("Network")()`  
`print(net:GetLocalInterface())`  
  
  
The general philosophy behind TINN is to make fairly mundane things very easy, make very hard things very approachable, and keep really easy things really easy.  
  

Building TINN
-------------

Within the src directory, you will find almost everything you need to build TINN.  As TINN is specifically
meant for Windows, there is a msvcbuild.bat file.  If you've ever compiled the LuaJIT project, this will look
very familiar because it's the same file, with some specific modifications.
*	Bring up a Visual Studio command prompt  
*	cd to the src directory  
*	run the msvcbuild.bat script  

You will end up with a tinn.exe file.  To use TINN, you will need the lua51.dll, and zlib1.dll.  These are provided in the root directory of the project.  Simply copy these to some directory, along with the tinn.exe and you can then run tinn.  The root directory also contains the files msvcr100.dll and msvcp100.dll.  These are 
the C runtime library files for Visual Studio 10.0.  If they're not already on your machine, you should include them as well.

Using TINN
----------

Run the tinn.exe program, and pass it the name of the script you want to run:

tinn.exe test_network.lua

And that's that.


