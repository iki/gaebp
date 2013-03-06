@echo off
::|Usage: %Command% [options]
::|
::|Runs IPython console with current directory prepended to Python lib path.
::|
::|  Prefers to use IPython interpreter located in the same path, or above.
::|
::|Uses sufi library. See http://j.mp/sufi-lib.
::|
setlocal enableextensions
if not defined sufi if exist "%~dp0sufi.bat" (set sufi=call "%~dp0sufi.bat") else (set sufi=call sufi.bat)

%sufi% init "%~f0" - - %* || exit /b 1
%sufi% optional-usage

set Cmd=%Bin%\ipython-script

if exist "%Cmd%.py" (set Script="%Cmd%.py") else if exist "%Cmd%" (set Script="%Cmd%") else echo Python script not found: "%Cmd%.py" >&2 && exit /b 1
if exist "%Bin%\python.exe" (set Python="%Bin%\python.exe") else if exist "%Bin%\..\python.exe" (set Python="%Bin%\..\python.exe") else set Python="python.exe"

if %Script: =%==%Script% set Script=%Script:~1,-1%
if %Python: =%==%Python% set Python=%Python:~1,-1%

%sufi% run %Python% %Script% %Args%

exit /b %errorlevel%
