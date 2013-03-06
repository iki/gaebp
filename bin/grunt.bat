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

%sufi% launch-npm grunt.grunt %0 --console Args "Grunt.js" "http://gruntjs.com"
exit /b %errorlevel%
