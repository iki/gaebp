@echo off
::|Usage: %Command% [options]
::|
::|Downloads application source from Google App Engine:
::|
::|  appcfg [options] %DownloadOptions% 
::|
::|Configuration options:
::|
::|  Workdir=path
::|    Run in path. Defaults to '%Workdir%'.
::|
::|  DownloadOptions=options
::|    Use options for appcfg update.
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

%sufi% init "%~f0" AppEngineStaging appengine-staging.cfg %* && %sufi% use gae || exit /b 1
%sufi% optional-usage

%sufi_gae% appcfg %DownloadOptions% %*

exit /b %errorlevel%
