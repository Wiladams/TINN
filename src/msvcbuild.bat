@rem Script to build TINN with MSVC.
@rem
@rem Either open a "Visual Studio .NET Command Prompt"
@rem (Note that the Express Edition does not contain an x64 compiler)
@rem -or-
@rem Open a "Windows SDK Command Shell" and set the compiler environment:
@rem     setenv /release /x86
@rem   -or-
@rem     setenv /release /x64
@rem
@rem Then cd to this directory and run this script.

@if not defined INCLUDE goto :FAIL

@setlocal
@set LJCOMPILE=cl /nologo /c /MD /O2 /W3 /D_CRT_SECURE_NO_DEPRECATE
@set LJLINK=link /nologo
@set LJMT=mt /nologo
@set LJLIB=lib /nologo
@set LUAC=luajit -b
@set LJDLLNAME=lua51.dll
@set LJLIBNAME=lua51.lib


@rem The TINN core library
%LUAC% core/base64.lua base64.obj
%LUAC% core/BinaryStream.lua BinaryStream.obj
%LUAC% core/BitBang.lua BitBang.obj
%LUAC% core/Collections.lua Collections.obj
%LUAC% core/dkjson.lua dkjson.obj
%LUAC% core/FileStream.lua FileStream.obj
%LUAC% core/langutils.lua langutils.obj
%LUAC% core/MemoryStream.lua MemoryStream.obj
%LUAC% core/re.lua re.obj
%LUAC% Runtime.lua Runtime.obj
%LUAC% SimpleFiber.lua SimpleFiber.obj
%LUAC% core/stream.lua stream.obj
%LUAC% core/stringzutils.lua stringzutils.obj
%LUAC% core/Vector.lua Vector.obj
%LUAC% vkeys.lua vkeys.obj
%LUAC% core/zlib.lua zlib.obj
@set TINNLIB=base64.obj BinaryStream.obj BitBang.obj Collections.obj dkjson.obj FileStream.obj  langutils.obj MemoryStream.obj re.obj ResourceMapper.obj Runtime.obj SimpleFiber.obj stream.obj stringzutils.obj Vector.obj vkeys.obj zlib.obj

@rem The Net library
%LUAC% net/CoSocketIo.lua CoSocketIo.obj
%LUAC% net/httpstatus.lua httpstatus.obj
%LUAC% net/HttpChunkIterator.lua HttpChunkIterator.obj
%LUAC% net/HttpHeaders.lua HttpHeaders.obj
%LUAC% net/HttpMessage.lua HttpMessage.obj
%LUAC% net/HttpRequest.lua HttpRequest.obj
%LUAC% net/HttpResponse.lua HttpResponse.obj
%LUAC% net/mime.lua mime.obj
%LUAC% net/peg_http.lua peg_http.obj
%LUAC% net/ResourceMapper.lua ResourceMapper.obj
%LUAC% net/StaticService.lua StaticService.obj
%LUAC% net/url.lua url.obj
%LUAC% net/utils.lua utils.obj
%LUAC% net/WebSocketStream.lua WebSocketStream.obj

@set NETLIB=CoSocketIo.obj httpstatus.obj HttpChunkIterator.obj HttpHeaders.obj HttpMessage.obj HttpRequest.obj HttpResponse.obj mime.obj peg_http.obj StaticService.obj url.obj utils.obj WebSocketStream.obj 

@rem Core windows API set
%LUAC% Win32/core_console.lua core_console.obj
%LUAC% Win32/core_processenvironment.lua core_processenvironment.obj
%LUAC% Win32/Handle_ffi.lua Handle_ffi.obj
%LUAC% Win32/Heap_ffi.lua Heap_ffi.obj
%LUAC% Win32/SysInfo_ffi.lua SysInfo_ffi.obj
%LUAC% Win32/UMS_ffi.lua UMS_ffi.obj
%LUAC% Win32/Util_ffi.lua Util_ffi.obj

@set WINCOREAPI=core_console.obj core_processenvironment.obj Handle_ffi.obj Heap_ffi.obj SysInfo_ffi.obj UMS_ffi.obj Util_ffi.obj


@rem Create the Win32 specific stuff
%LUAC% Win32/console.lua console.obj
%LUAC% Win32/BCrypt.lua BCrypt.obj
%LUAC% Win32/BCryptUtils.lua BCryptUtils.obj
%LUAC% Win32/datetime.lua datetime.obj
%LUAC% Win32/datetime_ffi.lua datetime_ffi.obj
%LUAC% Win32/dbghelp_ffi.lua dbghelp_ffi.obj
%LUAC% Win32/EventScheduler.lua EventScheduler.obj
%LUAC% Win32/GDI32.lua GDI32.obj
%LUAC% Win32/gdi32_ffi.lua gdi32_ffi.obj
%LUAC% Win32/guiddef.lua guiddef.obj
%LUAC% Win32/Handle.lua Handle.obj
%LUAC% Win32/Heap.lua Heap.obj
%LUAC% Win32/KeyMouse.lua KeyMouse.obj
%LUAC% Win32/NativeSocket.lua NativeSocket.obj
%LUAC% Win32/NetStream.lua NetStream.obj
%LUAC% Win32/Network.lua Network.obj
%LUAC% Win32/processenvironment.lua processenvironment.obj
%LUAC% Win32/SocketIoPool.lua SocketIoPool.obj
%LUAC% Win32/SocketPool.lua SocketPool.obj
%LUAC% Win32/SocketUtils.lua SocketUtils.obj
%LUAC% Win32/schannel.lua schannel.obj
%LUAC% Win32/SecError.lua SecError.obj
%LUAC% Win32/sspi.lua sspi.obj
%LUAC% Win32/sspi_ffi.lua sspi_ffi.obj
%LUAC% Win32/StopWatch.lua StopWatch.obj
%LUAC% Win32/SysInfo.lua SysInfo.obj
%LUAC% Win32/UIOSimulator.lua UIOSimulator.obj
%LUAC% Win32/User32.lua User32.obj
%LUAC% Win32/user32_ffi.lua user32_ffi.obj
%LUAC% Win32/WebApp.lua WebApp.obj
%LUAC% Win32/win_error.lua win_error.obj
%LUAC% Win32/win_kernel32.lua win_kernel32.obj
%LUAC% Win32/win_socket.lua win_socket.obj
%LUAC% Win32/WinBase.lua WinBase.obj
%LUAC% Win32/WinCrypt.lua WinCrypt.obj
%LUAC% Win32/WinNT.lua WinNT.obj
%LUAC% Win32/WinSock_Utils.lua WinSock_Utils.obj
%LUAC% Win32/WTypes.lua WTypes.obj

@set WIN32LIB=console.obj BCrypt.obj BCryptUtils.obj datetime.obj datetime_ffi.obj dbghelp_ffi.obj EventScheduler.obj GDI32.obj gdi32_ffi.obj guiddef.obj Handle.obj Heap.obj KeyMouse.obj NativeSocket.obj NetStream.obj Network.obj User32.obj user32_ffi.obj schannel.obj SecError.obj SocketIoPool.obj SocketPool.obj SocketUtils.obj sspi.obj sspi_ffi.obj StopWatch.obj SysInfo.obj UIOSimulator.obj  WebApp.obj win_error.obj win_kernel32.obj win_socket.obj WinBase.obj WinCrypt.obj WinNT.obj WinSock_Utils.obj WTypes.obj
 
@rem Create the graphics specific stuff
%LUAC% graphics/math_matrix.lua math_matrix.obj
%LUAC% graphics/quaternion.lua quaternion.obj

@set GRAPHICSLIB=math_matrix.obj quaternion


@rem Khronos library
%LUAC% khronos/gl.lua gl.obj
%LUAC% khronos/GLContext.lua GLContext.obj
%LUAC% khronos/glext.lua glext.obj
%LUAC% khronos/GLSLProgram.lua GLSLProgram.obj
%LUAC% khronos/GLTexture.lua GLTexture.obj
%LUAC% khronos/glu.lua glu.obj
%LUAC% khronos/GLWindow.lua GLWindow.obj
%LUAC% khronos/OglMan.lua OglMan.obj
%LUAC% khronos/View3D.lua View3D.obj
%LUAC% khronos/wglext.lua wglext.obj

@set KHRONOSLIB=gl.obj GLContext.obj glext.obj GLSLProgram.obj GLTexture.obj glu.obj GLWindow.obj OglMan.obj View3D.obj wglext.obj

%LJCOMPILE% lpeg.c
@if errorlevel 1 goto :BAD
@set CLIBS=lpeg.obj

%LJCOMPILE% tinn.c
@if errorlevel 1 goto :BAD
%LJLINK% /out:tinn.exe tinn.obj %CLIBS% %NETLIB% %TINNLIB% %GRAPHICSLIB% %KHRONOSLIB% %WINCOREAPI% %WIN32LIB% %LJLIBNAME%
@if errorlevel 1 goto :BAD
if exist tinn.exe.manifest^
  %LJMT% -manifest tinn.exe.manifest -outputresource:tinn.exe

@del *.obj *.manifest
@echo.
@echo === Successfully built TINN for Windows/%LJARCH% ===
move tinn.exe bin 
@goto :END
:BAD
@echo.
@echo *******************************************************
@echo *** Build FAILED -- Please check the error messages ***
@echo *******************************************************
@goto :END
:FAIL
@echo You must open a "Visual Studio .NET Command Prompt" to run this script
:END
