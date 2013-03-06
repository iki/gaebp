@echo off
::|Usage: %Command% [option]
::|
::|Removes buildout paths and files:
::|
::|  %CleanDirs%
::|  %CleanFiles%
::|
::|Also removes all *-script.py and respective *(.exe) launchers
::|from binaries path %CleanBin%.
::|
::|Also cleans the following paths:
::|
::|  %CleanFrom%
::|  Except: %KeepFiles%
::|
::|Optionally cleans the download cache path %CleanCache%.
::|
::|Options:
::|
::|  -a, --all      Clean also download cache.
::|
::|Configuration options:
::|
::|  Workdir=path
::|    Run in path. Defaults to '%Workdir%'.
::|
::|  All=true/false*
::|    Clean also download cache.
::|
::|  CleanBin=path
::|    Remove all *-script.py and respective *(.exe) launchers from path.
::|
::|  CleanDirs=path ...
::|    Remove paths and their content
::|
::|  CleanFrom=path
::|    Remove content of paths, except KeepFiles files.
::|
::|  CleanFiles=file ...
::|    Remove files.
::|
::|  CleanCache=path
::|    Remove content of download cache path, except KeepFiles files.
::|
::|  KeepFiles=[subpath\]file ...
::|    Keep [subpath\]files when removing content.
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

:::Note: Use safe defaults. Nothing is removed. Use config file to specify cleanup targets.
set CleanBin=
set CleanDirs=
set CleanFiles=
set CleanCache=
set KeepFiles=

%sufi% init "%~f0" Cleanup . %* && %sufi% use cleanup || exit /b 1
%sufi% optional-usage && exit /b 0

set All=
%sufi% getopt Args "-a --all" All true

if defined CleanBin %sufi_cleanup% clean_python_scripts %CleanBin% || set ExitCode=1

if defined CleanDirs %sufi% try :rmdir %CleanDirs% 

if defined CleanFrom for %%d in (%CleanFrom%) do %sufi% try :clean_except "%%~d" %KeepFiles%

if defined CleanFiles %sufi% try :rm %CleanFiles% 

if not "%All%"=="true" exit /b %ExitCode%

if defined CleanCache %sufi% try :clean_except "%CleanCache%" %KeepFiles%

exit /b %ExitCode%
