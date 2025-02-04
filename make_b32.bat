@echo off
if "%1" == "clean" goto CLEAN
if "%1" == "CLEAN" goto CLEAN

if not exist lib md lib
if not exist lib\b32 md lib\b32
if not exist obj md obj
if not exist obj\b32 md obj\b32
if not exist obj\b32\bin md obj\b32\bin
if not exist obj\b32\mt md obj\b32\mt
:BUILD

rem   make -fmakefile.bc  > make_b32.log
rem   if errorlevel 1 goto BUILD_ERR
rem   set ACTIVEX_SUPPORT=ON
make -l EXE_OBJ_DIR=obj\b32\bin OBJ_DIR=obj\b32 -fmakefile.bc %1 %2 %3 > make_b32.log
if errorlevel 1 goto BUILD_ERR
make -l OBJ_DIR=obj\b32\mt -DHB_THREAD_SUPPORT -DHB_MT=mt -fmakefile.bc %2 %3 >> make_b32.log
if errorlevel 1 goto BUILD_ERR


:BUILD_OK

   goto EXIT

:BUILD_ERR

   notepad make_b32.log
   goto EXIT

:CLEAN
   del lib\b32\*.lib
   del lib\b32\*.bak
   del obj\b32\*.obj
   del obj\b32\*.c
   del obj\b32\bin\*.exe
   del obj\b32\bin\*.dll
   del obj\b32\mt\*.obj
   del obj\b32\mt\*.c

   del make_b32.log

   goto EXIT

:EXIT

