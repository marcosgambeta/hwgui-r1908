@echo off
if "%1" == "clean" goto CLEAN
if "%1" == "CLEAN" goto CLEAN

if not exist lib md lib
if not exist lib\win md lib\win
if not exist lib\win\msvc64 md lib\win\msvc64
if not exist obj md obj
if not exist obj\vc64 md obj\vc64

:BUILD

   nmake /Fmakefile.msvc64 %1 %2 %3 > make_msvc64.log
   if errorlevel 1 goto BUILD_ERR

:BUILD_OK

   goto EXIT

:BUILD_ERR

   notepad make_msvc64.log
   goto EXIT

:CLEAN
   del lib\win\msvc64\*.lib
   del lib\win\msvc64\*.bak
   del obj\vc64\*.obj
   del obj\vc64\*.c
   del make_msvc64.log

   goto EXIT

:EXIT
