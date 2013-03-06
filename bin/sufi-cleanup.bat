@echo off
::|Usage: sufi-cleanup COMMAND [OPTIONS]
::|
::|Runs a cleanup command.
::|
::|Sufi stands for Shell Utilities, Functions and I. See http://j.mp/sufi-lib.
::|
::@Version: 0.3a

if not defined sufi if exist "%~dp0sufi.bat" (set sufi=call "%~dp0sufi.bat") else (set sufi=call sufi.bat)

if "%~1"=="" echo No command specified. Run %~n0 --help for usage. >&2 && exit /b 2

call :%*
exit /b %errorlevel%

::|Commands:
::|

:-h
:--help
:help
::|  -h, --help, help
::|    Show this help message and exit.
::|
%sufi% usage "%~f0"
exit /b %errorlevel%

:--version
::|  --version
::|    Show version string and exit.
::|
%sufi% version - "%~f0"
exit /b %errorlevel%

:clean_python_scripts
::|  clean_python_scripts DIR
::|    Removes all NAME-script.py and respective NAME(.exe) launchers from DIR.
if not exist "%~1" %sufi% mkdir "%~1" && exit /b 0 || exit /b 1
setlocal
set _x_=0
for %%s in ("%~1\*-script.py") do call :clean_python_script "%%s" || set _x_=1
exit /b %_x_%

:clean_python_script
::|  clean_python_script [DIR\]NAME-script.py
::|    Removes NAME-script.py and respective NAME(.exe) launchers from DIR.
setlocal
set _name_=%~1
set _name_=%_name_:-script.py=%
if "%_name_%"=="%~1" %sufi% error Unexpected script name: '%~1' && exit /b 1
%sufi% rm "%~1" "%_name_%" "%_name_%.exe"
exit /b %errorlevel%
