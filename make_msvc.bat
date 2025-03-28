@echo off
if "%1" == "clean" goto CLEAN
if "%1" == "CLEAN" goto CLEAN

if not exist lib md lib
if not exist lib\win md lib\win
if not exist lib\win\msvc md lib\win\msvc
if not exist obj md obj
if not exist obj\vc md obj\vc

:BUILD

   nmake /Fmakefile.msvc %1 %2 %3 > make_msvc.log
   if errorlevel 1 goto BUILD_ERR

:BUILD_OK

   goto EXIT

:BUILD_ERR

   notepad make_msvc.log
   goto EXIT

:CLEAN
   del lib\win\msvc\*.lib
   del lib\win\msvc\*.bak
   del obj\vc\*.obj
   del obj\vc\*.c
   del make_msvc.log

   goto EXIT

:EXIT

