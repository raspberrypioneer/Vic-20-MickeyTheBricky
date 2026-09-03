:: Mickey the Bricky - verify existing PRG files without rebuilding them
@echo off
cd /d "%~dp0"

fc.exe /b ".\prg\mickey bricky.prg" ".\prg\Mickey the Bricky original.prg" >nul
if errorlevel 1 (
    powershell -NoProfile write-host -back Red Unexpanded program does not match the original
    exit /b 1
)
powershell -NoProfile write-host -back Green Unexpanded program matches the original

fc.exe /b ".\prg\mickey bricky 8k.prg" ".\prg\mickey bricky 8k tested.prg" >nul
if errorlevel 1 (
    powershell -NoProfile write-host -back Red 8K program does not match the tested reference
    exit /b 1
)
powershell -NoProfile write-host -back Green 8K program matches the tested reference

exit /b 0
