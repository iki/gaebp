@echo off
::|Usage: sufi-gae COMMAND [OPTIONS]
::|
::|Runs a sufi google app engine extension command.
::|
::|App Engine is a PAAS by Google. See http://j.mp/app-engine.
::|This script comes from GAE Boiler Plate. See http://j.mp/gae-bp.
::|Sufi stands for Shell Utilities, Functions and I. See http://j.mp/sufi-lib.
::|
::@Version: 0.3

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

:gae
::|  gae [--logged] COMMAND [OPTIONS]
::|    Runs GAE SDK COMMAND.
::|
setlocal
if "%~1"=="--logged" (shift && set _logged_=:logged) else (set _logged_=)
if "%~1"=="" call :error GAE SDK command is required: sufi gae %* && exit /b 2
set _cmd_="%Bin%\%~n1.exe"
if not exist %_cmd_% %sufi% error GAE SDK command not found: '%_cmd_%' && %sufi% info Run '%Bin%\bootstrap' to get started. && exit /b 1
%sufi% skip_first _options_ %*
if defined _logged_ %sufi% skip_first _options_ %_options_%
endlocal && %sufi% run "%_cmd_%" %_options_%
exit /b %errorlevel%

:app
:appcfg
::|  app/appcfg [OPTIONS]
::|    Runs GAE SDK command appcfg.py.
::|
call :gae appcfg %*
exit /b %errorlevel%

:server
::|  server [OPTIONS]
::|    Runs GAE SDK command dev_appserver.py.
::|
call :gae --logged dev_appserver %*
exit /b %errorlevel%

:rsh
::|  rsh [OPTIONS]
::|    Runs GAE SDK command remote_api_shell.py.
::|
call :gae remote_api_shell %*
exit /b %errorlevel%

:load
::|  load [OPTIONS]
::|    Runs GAE SDK command bulkloader.py.
::|
call :gae bulkloader %*
exit /b %errorlevel%

:docs
::|  docs
::|    Opens local GAE Python docs 
::|    '%Workdir%\var\google_appengine\docs\appengine\docs\python\index.html'
::|    or hosted docs at 'http://code.google.com/appengine/docs/python/'.
::|
setlocal
set _docs_=%Workdir%\var\google_appengine\docs\appengine\docs\python\index.html
if exist "%_docs_%" endlocal && %sufi% run start "Local GAE documentation" "%_docs_%" && exit 0 || exit 1
%sufi% debug Local GAE documentation not found: '%_docs_%'
%sufi% run start "GAE documentation" "http://code.google.com/appengine/docs/python/"
exit /b %errorlevel%
