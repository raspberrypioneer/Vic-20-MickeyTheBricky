:: Mtb - perform a full build of program
@echo off

:: Build main program
.\bin\acme.exe -l .\build\symbols -o .\build\mtb .\main.asm

:: Add the 2 load adddress bytes for the PRG header (PRG header created using Notepad++ with hex editor plugin)
::copy /b .\build\prgheader.bin+.\build\mtb ".\prg\Mickey the Bricky.prg" >nul
copy /b .\build\prgheader8k.bin+.\build\mtb ".\prg\Mickey the Bricky.prg" >nul
echo Done!
