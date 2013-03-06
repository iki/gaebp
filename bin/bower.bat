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

%sufi% launch-npm bower.bower %0 --console Args "Twitter Bower" "http://twitter.github.com/bower"
exit /b %errorlevel%
