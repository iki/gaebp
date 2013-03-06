@echo off
::|Usage: %Command% command [options]
::|
::|Runs a Google App Engine command.
::|
::|Configuration options:
::|
::|  Workdir=path
::|    Run in path. Defaults to '%Workdir%'.
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

%sufi% init "%~f0" AppEngine appengine.cfg %* && %sufi% use gae || exit /b 1
%sufi% optional-usage

%sufi_gae% %*

exit /b %errorlevel%
