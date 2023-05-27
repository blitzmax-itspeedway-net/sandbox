@echo off
REM ADD THIS TO YOUR MODULE FOLDER

set module=maxgui.sizer
set rebuild=e:\rebuild\blitzmax.mods

echo %module%
echo ======================================================================

REM #
REM # VARIABLES
REM #

for /f "tokens=1,2 delims=." %%a in ("%module%") do set module.folder=%%a&set module.name=%%b
set module.temp=%TEMP%\%module.folder%.mod
set file.name=%module%_%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%

REM #
REM # FOLDER PREPARATION
REM #

if exist "%rebuild%\%file.name%" del "%rebuild%\%file.name%"
if exist "%module.temp%\*" rd /S /Q "%module.temp%"
mkdir "%module.temp%"

REM #
REM # INCLUDE FILES
REM #

rem call :archive README.txt

call :archive sizer.bmx
call :archive VERSION*.*

rem call :archive doc\intro.bbdoc	doc\

call :archive bin\*.bmx		bin\

call :archive examples\*.bmx		examples\

REM #
REM # ARCHIVE
REM #

"c:\program files\7-zip\7z" a "%rebuild%\%file.name%.zip" "-i!%module.temp%\"

goto exit

:archive
echo %1
if not exist "%module.temp%\%module.name%.mod\*" mkdir "%module.temp%\%module.name%.mod"
if not "%2"=="" if not exist "%module.temp%\%module.name%.mod\%2\*" mkdir "%module.temp%\%module.name%.mod\%2"
copy "%1" "%module.temp%\%module.name%.mod\%2" >nul
goto :EOF

:exit

pause
