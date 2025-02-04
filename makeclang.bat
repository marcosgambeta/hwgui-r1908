@echo off
if "%1" == "clean" goto CLEAN
if "%1" == "CLEAN" goto CLEAN

if not exist lib md lib
if not exist lib\cl md lib\cl
if not exist obj md obj
if not exist obj\cl md obj\cl

:BUILD

   mingw32-make.exe -f makefile.clang
   if errorlevel 1 goto BUILD_ERR

:BUILD_OK

   goto EXIT

:BUILD_ERR

   goto EXIT

:CLEAN
   del lib\*.a
   del lib\*.bak
   del obj\*.o
   del obj\*.c

   goto EXIT

:EXIT
