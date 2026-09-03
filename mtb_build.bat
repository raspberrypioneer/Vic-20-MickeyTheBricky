:: Mickey the Bricky - perform a full build of program
:: USE_8k_MEMORY_LAYOUT = 0 for unexpanded memory layout or, = 1 for 8K+ expanded memory layout
@echo off
cd /d "%~dp0"

::-----------------------------------------------------------------------------------
set USE_8k_MEMORY_LAYOUT=0
set "PRG=mickey bricky.prg"
set LOAD_LOW=1
set LOAD_HIGH=16
call :create_prg_file_for_version
if errorlevel 1 exit /b 1

echo --- Unexpanded version built ---

::-----------------------------------------------------------------------------------
set USE_8k_MEMORY_LAYOUT=1
set "PRG=mickey bricky 8k.prg"
set LOAD_LOW=1
set LOAD_HIGH=18
call :create_prg_file_for_version
if errorlevel 1 exit /b 1

echo --- 8k version built ---

call .\mtb_verify.bat
if errorlevel 1 exit /b 1

goto :build_d64

::-----------------------------------------------------------------------------------
:: Subroutine to compile and copy renamed file into the prg folder
:create_prg_file_for_version

:: Compile main programs
.\bin\acme.exe -l .\build\symbols -o .\build\main -DUSE_8k_MEMORY_LAYOUT=%USE_8k_MEMORY_LAYOUT% .\main.asm
if errorlevel 1 (
    powershell write-host -back Red Compiled with errors
    exit /b 1
)
powershell write-host -back Green Compiled ok


:: Prefix the assembled payload with its generated two-byte little-endian PRG load address.
powershell -NoProfile -Command "$body = [IO.File]::ReadAllBytes('.\build\main'); $prg = [byte[]](@(%LOAD_LOW%, %LOAD_HIGH%) + $body); [IO.File]::WriteAllBytes('.\prg\%PRG%', $prg)"
if errorlevel 1 (
    powershell write-host -back Red Failed to create program file
    exit /b 1
)

exit /B

::-----------------------------------------------------------------------------------
:: Subroutine to build the d64 file with both the unexpanded and 8k versions included
:build_d64
if exist ".\d64\Mickey the Bricky.d64" del ".\d64\Mickey the Bricky.d64"
if errorlevel 1 (
    powershell -NoProfile write-host -back Red Failed to remove the previous D64 image
    exit /b 1
)
%PYPATH%\python .\utilities\create_d64.py
if errorlevel 1 (
    powershell -NoProfile write-host -back Red Failed to create the D64 image
    exit /b 1
)
powershell -NoProfile write-host -back Green D64 image created
exit /b 0
