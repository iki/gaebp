@echo off
::|Usage: %Command% [options]
::|
::|Runs Python console with current directory prepended to Python lib path.
::|
::|  Prefers to use Python interpreter located in the same path, or above.
::|
::|Uses sufi library. See http://j.mp/sufi-lib.
::|
setlocal enableextensions
if not defined sufi if exist "%~dp0sufi.bat" (set sufi=call "%~dp0sufi.bat") else (set sufi=call sufi.bat)

%sufi% init "%~f0" - - %* || exit /b 1
%sufi% optional-usage

set Python=python.exe
if exist "%Bin%\%Python%" (set Python="%Bin%\%Python%") else if exist "%Bin%\..\%Python%" (set Python="%Bin%\..\%Python%") else set Python="%Python%"

if %Python: =%==%Python% set Python=%Python:~1,-1%

set pythonpath=.;%pythonpath%

%sufi% run %Python% %Args%

exit /b %errorlevel%
