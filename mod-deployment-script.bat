@echo off
setlocal enabledelayedexpansion

REM Read version from info.json
set version=
for /f "tokens=2 delims=:," %%a in ('findstr /r "\"version\":" info.json 2^>nul') do (
    set version=%%a
    set version=!version:"=!
    set version=!version: =!
)

REM Read mod name from info.json
set modname=
for /f "tokens=2 delims=:," %%a in ('findstr /r "\"name\":" info.json 2^>nul') do (
    set modname=%%a
    set modname=!modname:"=!
    set modname=!modname: =!
)

REM Display found values for confirmation
echo Found mod name: !modname!
echo Found version: !version!

set output=!modname!_!version!
set target=%appdata%\Factorio\mods

REM Ensure output ends with .zip
set zipname=!output!
if /I not "!zipname:~-4!"==".zip" set zipname=!zipname!.zip

REM Remove output zip if it already exists in current directory
if exist "!zipname!" del /f /q "!zipname!"

echo Creating mod archive: !zipname!

REM Create a temporary directory with the proper structure
if exist "temp_mod_build" rmdir /s /q "temp_mod_build"
mkdir "temp_mod_build\!output!"

echo Copying mod files to temporary directory...

REM Copy all files in root directory to the temp folder
for %%F in (changelog.txt control.lua data-final-fixes.lua data.lua info.json LICENSE README.md settings.lua thumbnail.png) do (
    if exist "%%F" (
        copy /Y "%%F" "temp_mod_build\!output!\%%F" > nul
    )
)

REM Copy directories recursively
if exist "entity" xcopy /s /e /y "entity" "temp_mod_build\!output!\entity\" > nul
if exist "locale" xcopy /s /e /y "locale" "temp_mod_build\!output!\locale\" > nul
if exist "prototypes" xcopy /s /e /y "prototypes" "temp_mod_build\!output!\prototypes\" > nul

echo Creating ZIP archive...
powershell -Command "Compress-Archive -Path 'temp_mod_build\*' -DestinationPath '!zipname!' -Force"

REM Clean up temp directory
rmdir /s /q "temp_mod_build"

REM Copy zip to target directory, overwrite if exists
echo Copying to Factorio mods folder...
copy /Y "!zipname!" "%target%\!zipname!" > nul

echo Deployment complete: !zipname! copied to %target%

REM Launch Factorio
set factorio_exe=C:\Program Files (x86)\Steam\steamapps\common\Factorio\bin\x64\factorio.exe
if exist "!factorio_exe!" (
    echo Launching Factorio...
    start "" "!factorio_exe!"
) else (
    echo Warning: Factorio executable not found at: !factorio_exe!
    echo Please launch Factorio manually.
    pause
)

endlocal
