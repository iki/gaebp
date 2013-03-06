@echo off
::|Usage: %Command% [options]
::|
::|Runs bootstrap:
::|
::|  python%PythonVersion% %Script% %Options% [options]
::|
::|  Uses Python%PythonVersion% from Windows registry, see python-getpath in sufi help.
::|
::|Optionally runs builder:
::|
::|  %Builder% %BuildOptions%
::|
::|Configuration options:
::|
::|  Workdir=path
::|    Run in path. Defaults to '%Workdir%'.
::|
::|  Script=script
::|    Run bootstrap script. Defaults to '%Bin%\%Command%.py'.
::|
::|  Options=options
::|    Run bootstrap with additional options.
::|
::|  PythonVersion=version
::|    Use Python version. Defaults to 2.7.
::|
::|  PythonPath=path
::|    Use Python installed at path\python.exe.
::|
::|  Builder=executable
::|    Use builder executable. Defaults to '%Bin%\buildout.exe'
::|
::|  BuildOptions=options
::|    Run builder with additional options.
::|
::|  AutoBuild=true*/false
::|    Run builder after bootstrap automatically.
::|
::|  SkipBootstrap=true*/false
::|    Skip bootstrap if builder already exists.
::|
::|  Environment variables are expanded. 
::|
::|  Different settings for more than one platform can be specified in single
::|  configuration file by appending .platform to variable names, e.g. '.Windows'.
::|
::|  Configuration options can also be set in environment with '%ConfigEnv%' prefix.
::|
::@Version: 0.3

setlocal enableextensions
if not defined sufi if exist "%~dp0sufi.bat" (set sufi=call "%~dp0sufi.bat") else (set sufi=call sufi.bat)

set PythonVersion=2.7
set PythonPath=

set Script=%~dpn0.py
set Options=

set Builder=%Bin%\buildout.exe
set BuildOptions=

set AutoBuild=true
set SkipBootstrap=true

%sufi% init "%~f0" Bootstrap . %* || exit /b 1
%sufi% optional-usage && exit /b 0

if not exist "%Script%"  %sufi% error Bootstrap script not found: '%Script%'. && exit /b 1

%sufi% python_getpath PythonPath "%PythonVersion%" || exit /b 1

if "%GetHelp%"=="true" %sufi% run "%PythonPath%\python.exe" "%Script%" --help && exit /b 0 || exit /b 1

if "%SkipBootstrap%"=="true" if defined Builder if exist "%Builder%" (
    %sufi% info Skipping bootstrap, builder already exists: '%Builder%'
    %sufi% info Either run cleanup, or set SkipBootstrap to 'false' to force re-bootstrap.
) else (
    %sufi% try :run :logged "%PythonPath%\python.exe" "%Script%" %Options% %Args%
    )

if defined Builder if exist "%Builder%" (
    if "%AutoBuild%"=="true" (
        %sufi% try :run :logged "%Builder%" %BuildOptions%
    ) else (
        %sufi% info Run builder to continue: '%Builder%' %BuildOptions%
    )
) else (
    %sufi% error Builder command not found: '%Builder%'
    set ExitCode=1
    )

exit /b %ExitCode%
