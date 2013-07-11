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
%LUAC% luajit_ffi.lua luajit_ffi.obj
%LUAC% LuaState.lua LuaState.obj
%LUAC% core/MemoryStream.lua MemoryStream.obj
%LUAC% core/re.lua re.obj
%LUAC% Runtime.lua Runtime.obj
%LUAC% core/Query.lua Query.obj
%LUAC% Shell.lua Shell.obj
%LUAC% SimpleFiber.lua SimpleFiber.obj
%LUAC% core/stream.lua stream.obj
%LUAC% core/stringzutils.lua stringzutils.obj
%LUAC% TINNThread.lua TINNThread.obj
%LUAC% core/Vector.lua Vector.obj
%LUAC% vkeys.lua vkeys.obj
%LUAC% core/zlib.lua zlib.obj
@set TINNLIB=base64.obj BinaryStream.obj BitBang.obj Collections.obj dkjson.obj FileStream.obj  langutils.obj luajit_ffi.obj LuaState.obj MemoryStream.obj re.obj Query.obj ResourceMapper.obj Runtime.obj Shell.obj SimpleFiber.obj stream.obj stringzutils.obj TINNThread.obj Vector.obj vkeys.obj zlib.obj

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
%LUAC% Win32/apiset/core_console_l1_1_0.lua core_console_l1_1_0.obj
%LUAC% Win32/apiset/core_console_l2_1_0.lua core_console_l2_1_0.obj
%LUAC% Win32/apiset/core_datetime_l1_1_1.lua core_datetime_l1_1_1.obj
%LUAC% Win32/apiset/core_debug_l1_1_1.lua core_debug_l1_1_1.obj
%LUAC% Win32/apiset/core_errorhandling_l1_1_1.lua core_errorhandling_l1_1_1.obj
%LUAC% Win32/apiset/core_file_l1_2_0.lua core_file_l1_2_0.obj
%LUAC% Win32/apiset/core_file_l2_1_0.lua core_file_l2_1_0.obj
%LUAC% Win32/apiset/core_firmware_l1_1_0.lua core_firmware_l1_1_0.obj
%LUAC% Win32/apiset/core_interlocked.lua core_interlocked.obj
%LUAC% Win32/apiset/core_io_l1_1_1.lua core_io_l1_1_1.obj
%LUAC% Win32/apiset/core_libraryloader_l1_1_1.lua core_libraryloader_l1_1_1.obj
%LUAC% Win32/apiset/core_memory_l1_1_1.lua core_memory_l1_1_1.obj
%LUAC% Win32/apiset/core_namedpipe_l1_2_0.lua core_namedpipe_l1_2_0.obj
%LUAC% Win32/apiset/core_processenvironment.lua core_processenvironment.obj
%LUAC% Win32/apiset/core_processthreads_l1_1_1.lua core_processthreads_l1_1_1.obj
%LUAC% Win32/apiset/core_profile_l1_1_0.lua core_profile_l1_1_0.obj
%LUAC% Win32/apiset/core_psapi_l1_1_0.lua core_psapi_l1_1_0.obj
%LUAC% Win32/apiset/core_shutdown_l1_1_0.lua core_shutdown_l1_1_0.obj
%LUAC% Win32/apiset/core_string_l1_1_0.lua core_string_l1_1_0.obj
%LUAC% Win32/apiset/core_synch_l1_2_0.lua core_synch_l1_2_0.obj
%LUAC% Win32/apiset/core_sysinfo_l1_2_0.lua core_sysinfo_l1_2_0.obj
%LUAC% Win32/apiset/core_timezone_l1_1_0.lua core_timezone_l1_1_0.obj
%LUAC% Win32/apiset/crypt.lua crypt.obj
%LUAC% Win32/apiset/dsrole.lua dsrole.obj
%LUAC% Win32/apiset/Handle_ffi.lua Handle_ffi.obj
%LUAC% Win32/apiset/Heap_ffi.lua Heap_ffi.obj
%LUAC% Win32/apiset/httpapi.lua httpapi.obj
%LUAC% Win32/apiset/lmcons.lua lmcons.obj
%LUAC% Win32/apiset/NTSecAPI.lua NTSecAPI.obj
%LUAC% Win32/apiset/mswsock.lua mswsock.obj
%LUAC% Win32/apiset/power_base_l1_1_0.lua power_base_l1_1_0.obj
%LUAC% Win32/apiset/samcli.lua samcli.obj
%LUAC% Win32/apiset/security_base_l1_2_0.lua security_base_l1_2_0.obj
%LUAC% Win32/apiset/security_credentials_l1_1_0.lua security_credentials_l1_1_0.obj
%LUAC% Win32/apiset/security_lsalookup_l2_1_0.lua security_lsalookup_l2_1_0.obj
%LUAC% Win32/apiset/security_sddl_l1_1_0.lua security_sddl_l1_1_0.obj
%LUAC% Win32/apiset/service_core_l1_1_1.lua service_core_l1_1_1.obj
%LUAC% Win32/apiset/service_management_l1_1_0.lua service_management_l1_1_0.obj
%LUAC% Win32/apiset/sspicli.lua sspicli.obj
%LUAC% Win32/apiset/SubAuth.lua SubAuth.obj
%LUAC% Win32/apiset/UMS_ffi.lua UMS_ffi.obj
%LUAC% Win32/apiset/Util_ffi.lua Util_ffi.obj
%LUAC% Win32/apiset/WinBer_ffi.lua WinBer_ffi.obj
%LUAC% Win32/apiset/WinCon.lua WinCon.obj
%LUAC% Win32/apiset/wkscli.lua wkscli.obj
%LUAC% Win32/apiset/wldap32_ffi.lua wldap32_ffi.obj
%LUAC% Win32/apiset/ws2_32.lua ws2_32.obj

@set WINCOREAPI=core_console_l1_1_0.obj core_console_l2_1_0.obj core_datetime_l1_1_1.obj core_debug_l1_1_1.obj core_errorhandling_l1_1_1.obj core_file_l1_2_0.obj core_file_l2_1_0.obj core_firmware_l1_1_0.obj core_interlocked.obj core_io_l1_1_1.obj core_libraryloader_l1_1_1.obj core_memory_l1_1_1.obj core_namedpipe_l1_2_0.obj core_processenvironment.obj core_processthreads_l1_1_1.obj core_profile_l1_1_0.obj core_psapi_l1_1_0.obj core_shutdown_l1_1_0.obj core_string_l1_1_0.obj core_synch_l1_2_0.obj core_sysinfo_l1_2_0.obj core_timezone_l1_1_0.obj crypt.obj dsrole.obj Handle_ffi.obj Heap_ffi.obj httpapi.obj lmcons.obj mswsock.obj NTSecAPI.obj power_base_l1_1_0.obj samcli.obj security_base_l1_2_0.obj security_credentials_l1_1_0.obj security_lsalookup_l2_1_0.obj security_sddl_l1_1_0.obj service_core_l1_1_1.obj service_management_l1_1_0.obj sspicli.obj SubAuth.obj UMS_ffi.obj Util_ffi.obj WinBer_ffi.obj WinCon.obj wkscli.obj wldap32_ffi.obj ws2_32.obj


@rem Create the Win32 specific stuff
%LUAC% Win32/basetsd.lua basetsd.obj
%LUAC% Win32/BCrypt.lua BCrypt.obj
%LUAC% Win32/BCryptUtils.lua BCryptUtils.obj
%LUAC% Win32/console.lua console.obj
%LUAC% Win32/ConsoleWindow.lua ConsoleWindow.obj
%LUAC% Win32/datetime.lua datetime.obj
%LUAC% Win32/dbghelp_ffi.lua dbghelp_ffi.obj
%LUAC% Win32/EventScheduler.lua EventScheduler.obj
%LUAC% Win32/GDI32.lua GDI32.obj
%LUAC% Win32/gdi32_ffi.lua gdi32_ffi.obj
%LUAC% Win32/guiddef.lua guiddef.obj
%LUAC% Win32/Handle.lua Handle.obj
%LUAC% Win32/Heap.lua Heap.obj
%LUAC% Win32/IOCompletionPort.lua IOCompletionPort.obj
%LUAC% Win32/KeyMouse.lua KeyMouse.obj
%LUAC% Win32/logoncli_ffi.lua logoncli_ffi.obj
%LUAC% Win32/NativeWindow.lua NativeWindow.obj
%LUAC% Win32/NativeSocket.lua NativeSocket.obj
%LUAC% Win32/NetStream.lua NetStream.obj
%LUAC% Win32/netutils.lua netutils.obj
%LUAC% Win32/netutils_ffi.lua netutils_ffi.obj
%LUAC% Win32/Network.lua Network.obj
%LUAC% Win32/ntstatus.lua ntstatus.obj
%LUAC% Win32/OSModule.lua OSModule.obj
%LUAC% Win32/OSProcess.lua OSProcess.obj
%LUAC% Win32/processenvironment.lua processenvironment.obj
%LUAC% Win32/SCManager.lua SCManager.obj
%LUAC% Win32/SID.lua SID.obj
%LUAC% Win32/SocketIoPool.lua SocketIoPool.obj
%LUAC% Win32/SocketPool.lua SocketPool.obj
%LUAC% Win32/SocketUtils.lua SocketUtils.obj
%LUAC% Win32/schannel.lua schannel.obj
%LUAC% Win32/SecError.lua SecError.obj
%LUAC% Win32/sspi.lua sspi.obj
%LUAC% Win32/StopWatch.lua StopWatch.obj
%LUAC% Win32/SysInfo.lua SysInfo.obj
%LUAC% Win32/Token.lua Token.obj
%LUAC% Win32/UIOSimulator.lua UIOSimulator.obj
%LUAC% Win32/User32.lua User32.obj
%LUAC% Win32/user32_ffi.lua user32_ffi.obj
%LUAC% Win32/WebApp.lua WebApp.obj
%LUAC% Win32/win_error.lua win_error.obj
%LUAC% Win32/win_socket.lua win_socket.obj
%LUAC% Win32/WinBase.lua WinBase.obj
%LUAC% Win32/WinCrypt.lua WinCrypt.obj
%LUAC% Win32/WindowKind.lua WindowKind.obj
%LUAC% Win32/WinIoCtl.lua WinIoCtl.obj
%LUAC% Win32/WinNT.lua WinNT.obj
%LUAC% Win32/WinSock_Utils.lua WinSock_Utils.obj
%LUAC% Win32/Workstation.lua Workstation.obj
%LUAC% Win32/WTypes.lua WTypes.obj

@set WIN32LIB=basetsd.obj BCrypt.obj BCryptUtils.obj console.obj ConsoleWindow.obj datetime.obj dbghelp_ffi.obj EventScheduler.obj GDI32.obj gdi32_ffi.obj guiddef.obj Handle.obj Heap.obj IOCompletionPort.obj KeyMouse.obj logoncli_ffi.obj NativeSocket.obj NativeWindow.obj NetStream.obj netutils.obj netutils_ffi.obj Network.obj ntstatus.obj OSModule.obj OSProcess.obj processenvironment.obj SCManager.obj SID.obj User32.obj user32_ffi.obj schannel.obj SecError.obj SocketIoPool.obj SocketPool.obj SocketUtils.obj sspi.obj StopWatch.obj SysInfo.obj Token.obj UIOSimulator.obj  WebApp.obj win_error.obj win_socket.obj WinBase.obj WinCrypt.obj WindowKind.obj WinIoCtl.obj WinNT.obj WinSock_Utils.obj Workstation.obj WTypes.obj
 
@rem Create the computicle specific stuff
%LUAC% computicle/comp_msgpump.lua comp_msgpump.obj
%LUAC% computicle/Computicle.lua Computicle.obj
%LUAC% computicle/IOCPNetStream.lua IOCPNetStream.obj
%LUAC% computicle/IOCPSocket.lua IOCPSocket.obj
%LUAC% computicle/IOCPSocketIo.lua IOCPSocketIo.obj
%LUAC% computicle/IOProcessor.lua IOProcessor.obj
%LUAC% computicle/SocketOps.lua SocketOps.obj

@set COMPUTICLELIB=comp_msgpump.obj Computicle.obj IOCPNetStream.obj IOCPSocket.obj IOCPSocketIo.obj IOProcessor.obj SocketOps.obj



@rem Create the graphics specific stuff
%LUAC% graphics/math_matrix.lua math_matrix.obj
%LUAC% graphics/quaternion.lua quaternion.obj

@set GRAPHICSLIB=math_matrix.obj quaternion.obj


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
%LJLINK% /out:tinn.exe tinn.obj %CLIBS% %COMPUTICLELIB% %NETLIB% %TINNLIB% %GRAPHICSLIB% %KHRONOSLIB% %WINCOREAPI% %WIN32LIB%  %LJLIBNAME%
@if errorlevel 1 goto :BAD
if exist tinn.exe.manifest^
  %LJMT% -manifest tinn.exe.manifest -outputresource:tinn.exe

%LJCOMPILE% tinnsh.c
@if errorlevel 1 goto :BAD
%LJLINK% /out:tinnsh.exe tinnsh.obj %CLIBS% %COMPUTICLELIB% %NETLIB% %TINNLIB% %GRAPHICSLIB% %KHRONOSLIB% %WINCOREAPI% %WIN32LIB% %LJLIBNAME%
@if errorlevel 1 goto :BAD
if exist tinnsh.exe.manifest^
  %LJMT% -manifest tinnsh.exe.manifest -outputresource:tinnsh.exe



@del *.obj *.manifest
@echo.
@echo === Successfully built TINN for Windows/%LJARCH% ===
move tinn.exe bin 
move tinnsh.exe bin
copy /Y init.lua bin
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
