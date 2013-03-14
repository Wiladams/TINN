TINN
====

Test Infrastructure for Network Nodes
Tcp IP Networking Nodule

TINN Is Not Node

TINN is like a Swiss army knife for coding on the Windows platform.  With TINN, you can create any number
of interesting applications from somewhat scalable web services to collaborative video games.

TINN is based on the LuaJIT compiler.  As such, the programs you write for TINN are actually normal looking Lua scripts.

TINN provides some basic modules, including
*lpeg - for interesting text parsing and manipulation
*zlib - because you'll want to compress some stuff
*networking - because you'll want to talk to other things
*win32 - User32, GDI32, Kernel32, BCrypt, so you can easily put Windows based stuff together

In addition to the basics, TINN includes a fairly simple, but useful, event scheduler.  This scheduler supports the 
asynchronous networking module, as well as a general model for seamlessly dealing with cooperative processing.

Here is a very simple example of getting the IP address of the networking interface:

`local net = require("Network")()
print(net:GetLocalInterface())`


The general philosophy behind TINN is to make fairly mundane things very easy, make very hard things very approachable,
and keep really easy things really easy.

To run TINN, simply copy all the stuff in the ./bin directory into some place on your machine.
Run the tinn.exe program, and pass it the name of the script you want to run:

tinn.exe test_network.lua

And that's that.


