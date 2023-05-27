@echo off
title MODULE REBUILD

REM # Copy this into your module folder
REM # Change the module name

set module=maxgui.forms

del *.a >NUL
del *.i >NUL
del *.bak >NUL
del .bmx\*.o >NUL
del .bmx\*.s >NUL
del examples\*.bak >NUL
cls

ECHO MODULE REBUILD
echo ======================================================================

c:\blitzmax\bin\bmk makemods -a %module%
echo ------------------------------------------------------------
c:\blitzmax\bin\bmk makemods -a -h %module%
echo ------------------------------------------------------------

pause