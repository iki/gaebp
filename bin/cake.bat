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

%sufi% launch-npm coffee-script.cake %0 --console Args "cake" "http://coffeescript.org"
exit /b %errorlevel%
