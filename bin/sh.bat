@echo off
::|Usage: %Command% [options]
::|
::|Runs %Application% (%Url%).
::|
::|You can install it using %Setup%.
::|
setlocal enableextensions
if not defined sufi if exist "%~dp0sufi.bat" (set sufi=call "%~dp0sufi.bat") else (set sufi=call sufi.bat)

%sufi% init "%~f0" - - %* || exit /b 1

%sufi% launch %0 --console Args "MSys/MSysGit bash unix shell" "http://mingw.org/wiki/msys" "msys, or git installer (http://msysgit.googlecode.com)" sh.exe Git\bin\sh.exe MinGW\msys\1.0\bin\sh.exe
exit /b %errorlevel%
