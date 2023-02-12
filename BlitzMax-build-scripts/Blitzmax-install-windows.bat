@echo off
REM INSTALLER BY BRAXTONRIVERS
REM https://github.com/bmx-ng/bcc/issues/610

set Curl_EXE=""
set SevenZip_EXE=""

set Version=0.129.3.45
set BlitzMax=BlitzMax
set BlitzMaxNG=%BlitzMax%NG
set BlitzMax_Tools_Folder=Tools
set BlitzMax_Bin_Folder=%BlitzMax%\bin
set BlitzMax_Stable_Release=%BlitzMax%_win32_x64_%Version%.7z
set BlitzMax_Download_Folder=%BlitzMaxNG%-v%Version%.Download

set BlitzMax_Git=https://github.com/bmx-ng
set BlitzMax_URL=%BlitzMax_Git%/bmx-ng/releases/download/v%Version%.win32.x64/%BlitzMax_Stable_Release%
set Curl_URL="https://curl.se/windows/"
set SevenZip_URL="https://7-zip.org"

echo Checking for required files ...
echo.

if not exist "%SevenZip_EXE%" (
	echo Please install 7-Zip!
	start "" "%SevenZip_URL%"
	exit
) else (
	echo ... Using 7z @ %SevenZip_EXE%
)

if not exist "%Curl_EXE%" (
	echo Please download Curl!
	start "" "%Curl_URL%"
	exit
) else (
	echo ... Using curl @ %Curl_EXE%
)

echo.

if not exist "%BlitzMax_Download_Folder%\" (
	echo Creating Download folder - %BlitzMax_Download_Folder% ...
	mkdir "%BlitzMax_Download_Folder%"
)

cd "%BlitzMax_Download_Folder%"

echo.
echo Downloading %BlitzMax%NG ...
echo.

rem the -k param is used to allow certificate errors
rem the -L param is used to follow redirections
%Curl_EXE% -k -L "%BlitzMax_URL%" -o "%BlitzMax_Stable_Release%"

if not exist "bcc.zip" %Curl_EXE% -k -L "%BlitzMax_Git%/bcc/archive/refs/heads/master.zip" -o "bcc.zip"
if not exist "bmk.zip" 	%Curl_EXE% -k -L "%BlitzMax_Git%/bmk/archive/refs/heads/master.zip" -o "bmk.zip"

if not exist "brl.mod.zip" %Curl_EXE% -k -L "%BlitzMax_Git%/brl.mod/archive/refs/heads/master.zip" -o "brl.mod.zip"
if not exist "pub.mod.zip" %Curl_EXE% -k -L "%BlitzMax_Git%/pub.mod/archive/refs/heads/master.zip" -o "pub.mod.zip"
if not exist "audio.mod.zip" %Curl_EXE% -k -L "%BlitzMax_Git%/audio.mod/archive/refs/heads/master.zip" -o "audio.mod.zip"
if not exist "text.mod.zip" %Curl_EXE% -k -L "%BlitzMax_Git%/text.mod/archive/refs/heads/master.zip" -o "text.mod.zip"
if not exist "random.mod.zip" %Curl_EXE% -k -L "%BlitzMax_Git%/random.mod/archive/refs/heads/master.zip" -o "random.mod.zip"
if not exist "sdl.mod.zip" %Curl_EXE% -k -L "%BlitzMax_Git%/sdl.mod/archive/refs/heads/master.zip" -o "sdl.mod.zip"
if not exist "net.mod.zip" %Curl_EXE% -k -L "%BlitzMax_Git%/net.mod/archive/refs/heads/master.zip" -o "net.mod.zip"
if not exist "image.mod.zip" %Curl_EXE% -k -L "%BlitzMax_Git%/image.mod/archive/refs/heads/master.zip" -o "image.mod.zip"
if not exist "maxgui.mod.zip" %Curl_EXE% -k -L "%BlitzMax_Git%/maxgui.mod/archive/refs/heads/master.zip" -o "maxgui.mod.zip"
if not exist "database.mod.zip" %Curl_EXE% -k -L "%BlitzMax_Git%/database.mod/archive/refs/heads/master.zip" -o "database.mod.zip"

echo.
echo Unpacking - %BlitzMaxNG% ...
echo.
if exist "%BlitzMax%" (
	echo %BlitzMax% already unpacked ...
) else (
	%SevenZip_EXE% x "%BlitzMax_Stable_Release%" -r -y
)

echo.
echo Unpacking module updates ...
echo.
if exist "mod\brl.mod" (
	echo module updates already unpacked ...
) else (
	%SevenZip_EXE% x "brl.mod.zip" -o"mod" -r -y
	%SevenZip_EXE% x "pub.mod.zip" -o"mod" -r -y
	%SevenZip_EXE% x "audio.mod.zip" -o"mod" -r -y
	%SevenZip_EXE% x "text.mod.zip" -o"mod" -r -y
	%SevenZip_EXE% x "random.mod.zip" -o"mod" -r -y
	%SevenZip_EXE% x "sdl.mod.zip" -o"mod" -r -y
	%SevenZip_EXE% x "net.mod.zip" -o"mod" -r -y
	%SevenZip_EXE% x "image.mod.zip" -o"mod" -r -y
	%SevenZip_EXE% x "maxgui.mod.zip" -o"mod" -r -y
	%SevenZip_EXE% x "database.mod.zip" -o"mod" -r -y

	cd mod
	ren "brl.mod-master" "brl.mod"
	ren "pub.mod-master" "pub.mod"
	ren "audio.mod-master" "audio.mod"
	ren "text.mod-master" "text.mod"
	ren "random.mod-master" "random.mod"
	ren "sdl.mod-master" "sdl.mod"
	ren "net.mod-master" "net.mod"
	ren "image.mod-master" "image.mod"
	ren "maxgui.mod-master" "maxgui.mod"
	ren "database.mod-master" "database.mod"
	cd ..
)

%SevenZip_EXE% x "bcc.zip" -o"%BlitzMax_Tools_Folder%" -r -y
%SevenZip_EXE% x "bmk.zip" -o"%BlitzMax_Tools_Folder%" -r -y

echo.
echo Compiling - bcc ...
echo.
cd "%BlitzMax_Bin_Folder%"
bmk.exe makeapp -r -t console "..\..\%BlitzMax_Tools_Folder%\bcc-master\bcc.bmx"
cd ..\..

echo.
echo Updating - bcc ...
echo.
cd "%BlitzMax_Tools_Folder%\bcc-master"
copy /Y "bcc.exe" "..\..\%BlitzMax_Bin_Folder%\bcc.exe"
cd ..\..

echo.
echo Updating modules - so we can update bmk
echo.
cd "%BlitzMax%"
ren "mod" "mod.old"
cd ..
move /Y "mod" "%BlitzMax%\mod"

echo.
echo Compiling - bmk ...
echo.
cd "%BlitzMax_Bin_Folder%"
bmk.exe makeapp -r -t console "..\..\%BlitzMax_Tools_Folder%\bmk-master\bmk.bmx"
cd ..\..

echo.
echo Updating - bmk ...
echo.
cd "%BlitzMax_Tools_Folder%\bmk-master"
copy /Y "bmk.exe" "..\..\%BlitzMax_Bin_Folder%\bmk.exe"
copy /Y "core.bmk" "..\..\%BlitzMax_Bin_Folder%\core.bmk"
copy /Y "custom.bmk" "..\..\%BlitzMax_Bin_Folder%\core.bmk"
copy /Y "make.bmk" "..\..\%BlitzMax_Bin_Folder%\make.bmk"
cd ..\..

cd ..
echo.
echo %BlitzMaxNG% - Setup Complete.
echo.
pause
