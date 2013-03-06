@echo off
::|Usage: sufi command [options]
::|
::|Runs a sufi command.
::|
::|All sufi commands are reentrant unless specified otherwise.
::|
::|Sufi stands for Shell Utilities, Functions and Instruments. See http://j.mp/sufi-lib.
::|
::@Version: 0.3

if not defined sufi set sufi=call %0

if "%~1"=="" call echo No sufi command specified. Run sufi --help for usage. >&2 && exit /b 2

call :%*
exit /b %errorlevel%

::|Configuration options:
::|
::|  Verbose=none/error/info*/debug
::|    Output no/error/info/debug messages to stderr.
::|
::|  LogFile=file
::|    Log command output and all messages to file.
::|
::|  DryRun=true/false*
::|    Preview only, do not actually run anything.
::|

::|About:
::|

:-h
:--help
:help
::|  -h, --help, help
::|    Show this help message and exit.
::|
::#Note: %~f0 evaluates to the script file name, even when %~0 evaluates to a called function name.
call :usage "%~f0"
exit /b %errorlevel%

:--version
::|  --version
::|    Show version string and exit.
::|
call :version - "%~f0"
exit /b %errorlevel%





::|Initialization commands:
::|

:init
::|  init command config-env/- config-file/- [args]
::|    Initializes environment: Cmd, Bin, Basedir, Command, Self, Name, Args,
::|    Startdir, Workdir, DryRun, Verbose, LogFile, LogLevel,
::|    ConfigFile, ConfigDirs, ExitCode.
::|
if "%~1"=="" call :error Script file is required: sufi init %* && exit /b 2
verify fail 2>nul || setlocal enableextensions disabledelayedexpansion || echo Requires extensions feature of command processor '%comspec%'. >&2 && exit /b 198
endlocal

::: set DryRun=
if not defined Verbose set Verbose=info
set Startdir=%cd%
set Workdir=%cd%
set LogFile=
set LogLevel=debug
set ExitCode=0

set Cmd=%~dpn1
set Bin=%~dp1
call :setenv Bin=%Bin:~0,-1%
set Self=%~1
set Command=%~n1
if "%~2"=="." (call :setenv ConfigEnv "%~n1") else (call :setenv ConfigEnv "%~2")
if "%~3"=="." (call :setenv ConfigFile "%~n1.cfg") else (call :setenv ConfigFile "%~3")
call :skip_first Args %*
call :skip_first Args %Args%
call :skip_first Args %Args%
call :abspath Basedir "%Bin%\.."
call :configure %ConfigFile% %ConfigEnv%
exit /b 0

:configure
::|  configure config-file [config-env-prefix]
::|
::|    Loads the config file if it's specified with a path component,
::|    or any config file located in Bin, Basedir, Home, Startdir and Workdir,
::|    and optionally prefixed with a dot.
::|
::|    Optionally loads all environment vars that start with prefix.
::|
::|    Changes directory to Workdir. Use setlocal to auto-restore it on exit.
::|    Also sets Workdir to it's canonical directory name (w/o junctions and ..).
::|
if not "%~2"=="" if not "%~2"=="-" call :loadenv "%~2"

if "%~1"=="" goto _configure_done
if "%~1"=="-" goto _configure_done
%sufi% haspath "%~1" && goto _configure_custom

:_configure_search
setlocal && call :unique_items ConfigDirs "%Bin%" "%Basedir%" "%Home%" "%Startdir%" "%Workdir%"
endlocal && for %%d in (%ConfigDirs%) do if not "%%~d"=="" for %%f in ("%~1" ".%~1") do if exist "%%~d\%%~f" %sufi% loadconf "%%~d\%%~f" . Windows || exit /b 1
goto _configure_update

:_configure_custom
%sufi% loadconf "%~1" || exit /b 1

:_configure_update
if not "%~2"=="" if not "%~2"=="-" call :loadenv "%~2"
:_configure_done

if defined Workdir if not "%Workdir%"=="%cd%" cd "%Workdir%" || exit /b 1 
if defined Workdir if not "%Workdir%"=="%cd%" set Workdir=%cd%
exit /b 0

:use
::|  use extension ...
::|    Checks extension and sets sufi_extension call variable, if needed.
::|
for %%x in (%*) do if not defined sufi_%%~x if exist "%~dpn0-%%~x%~x0" set sufi_%%~x=call "%~dpn0-%%~x%~x0" 
::#Note: Prints error for any missing extension first, then exits if any is missing.
for %%x in (%*) do if not defined sufi_%%~x call :error Requires sufi-%%~x extension. See http://j.mp/sufi-lib.
for %%x in (%*) do if not defined sufi_%%~x exit /b 1
exit /b 0

:optional-usage
:optional_usage
::|  optional_usage
::|    Outputs Self usage if there's -h or --help in Args and returns 0.
::|    Outputs Self version if there's -v or --version in Args and returns 0.
::|    Otherwise returns 2.
for %%a in (%Args%) do if "%%~a"=="-h" call :usage "%Self%" && exit /b 0 || exit /b 1
for %%a in (%Args%) do if "%%~a"=="--help" call :usage "%Self%" && exit /b 0 || exit /b 1
for %%a in (%Args%) do if "%%~a"=="--version" call :version - "%Self%" && exit /b 0 || exit /b 1
exit /b 2

:usage
::|  usage script ["var=value"] ...
::|    Outputs script usage.
::|
if "%~1"=="" call :error Script file is required: sufi usage %* && exit /b 2
setlocal
for %%v in (%*) do if not "%%~v"=="%~1" set %%~v
for /f "usebackq delims=| tokens=1*" %%l in ("%~1") do if "%%~l"=="::" call :eval echo.%%~m
exit /b %errorlevel%

:version
::|  version [--number] -/var/ script [prefix] [postfix]
::|    Outputs script version number or string, or sets var to it.
::|
::|    Default prefix and postfix return a '{name} v{version} {date} {time}',
::|    unless bare --number is requested.
::|
setlocal
if "%~1"=="--number" set _prefix_=%~4
if not "%~1"=="--number" if "%~3"=="" set _prefix_=%~n2 v
if not "%~1"=="--number" if not "%~3"=="" set _prefix_=%~3
if "%~1"=="--number" set _postfix_=%~5
if not "%~1"=="--number" if "%~4"=="" set _postfix_= %~t2
if not "%~1"=="--number" if not "%~4"=="" set _postfix_=%~4
if "%~1"=="--number" shift
if "%~2"=="" call :error Script file is required: sufi version %* && exit /b 2
if not exist "%~2" call :error Script file missing: '%~2' && exit /b 2
endlocal && for /f "usebackq tokens=1*" %%k in ("%~2") do if "%%~k"=="::@Version:" call :setenv "%~1" "%_prefix_%%%~l%_postfix_%" && exit /b 0 || exit 199
call :error Version not specified in '%~2'.
exit /b 1

:lib-version
:lib_version
::|  lib_version [--number] [-/var/ [extension] [prefix] [postfix]]
::|    Outputs used sufi library or extension version, or sets var to it.
::|
 string,::|
setlocal
set _number_=&& if "%~1"=="--number" shift && set _number_=%~1
call :lib_source _source_ "%~2" || exit /b 1
endlocal && call :version %_number_% "%~1" "%_source_%" "%~3" "%~4"
exit /b %errorlevel%

:lib-source
:lib_source
::|  lib_source [-/var/ [extension]]
::|    Outputs used sufi library or extension source path, or sets var to it.
::|
if "%~2"=="" call :setenv "%~1" "%~f0" && exit /b 0 || exit 199
if not defined "sufi_%~2" call :use "%~2" || exit /b 1
setlocal
call :eval set _source_=%%sufi_%~2%%
set _source_=%_source_:call =%
set _source_=%_source_:"=%
if exist "%_source_%" endlocal && call :setenv "%~1" "%_source_%" && exit /b 0 || exit 199
call :error Can't locate sufi-%~2 extension source in '%_source_%'.
exit /b 1





::|Logging commands:
::|

:debug
::|  debug [message ...]
::|    Outputs message to stderr and log file, if enabled.
::|
@if "%Verbose%"=="debug" @echo # %* >&2
@if "%LogLevel%"=="debug" @call :log # %*
@exit /b 0
:info
::|  info [message ...]
::|    Outputs message to stderr and log file, if enabled.
::|
@if not "%Verbose%"=="none" @if not "%Verbose%"=="error" @echo.%* >&2
@if not "%LogLevel%"=="none" @if not "%LogLevel%"=="error" @goto log
@exit /b 0
:error
::|  error [message ...]
::|    Outputs message to stderr and log file, if enabled.
::|
@if not "%Verbose%"=="none" @echo.%* >&2
@if not "%LogLevel%"=="none" @goto log
@exit /b 0
:screenlog
::|  screenlog [message ...]
::|    Outputs [datetime] message to stdout and log file, if enabled.
::|
@echo [%date% %time%] %*
:log
::|  log [message ...]
::|    Outputs [datetime] message to log file, if enabled.
::|
@if defined LogFile @echo [%date% %time%] %* >> "%LogFile%"
@exit /b 0




::|Subprocess commands:
::|

:run
::|  run command [options]
::|    Runs command with options, unless dry run is requested.
::|
if "%~1"=="" call :error Command is required: sufi run %* && exit /b 2
setlocal
call :unquote _options_ %*
call :info === [%cd%] === %_options_%
endlocal
if "%DryRun%"=="true" exit /b 0
:run-quiet
:run_quiet
call %*
if errorlevel 1 call :debug Exit code %errorlevel% && exit /b %errorlevel%
exit /b 0

:try
::|  try command [options]
::|    Runs command with options and sets ExitCode on error.
::|
if "%~1"=="" call :error Command is required: sufi try %* && exit /b 2
call %*
if errorlevel 1 set ExitCode=%errorlevel%
exit /b %errorlevel%

:eval
::|  eval command [options]
::|    Runs command with options, reevaluated by command processor.
::|
%*
exit /b %errorlevel%

:local
::|  local command [options]
::|    Runs command with options in a temporary environment scope.
::|
if "%~1"=="" call :error Command is required: sufi local %* && exit /b 2
setlocal
call %*
exit /b %errorlevel%

:rolopt
::|  rolopt command [options]
::|    Rotates options to left, ie. runs command with option 2..N and option 1.
::|
if "%~1"=="" call :error Command is required: sufi rolopt %* && exit /b 2
setlocal
call :skip_first _args_ %*
if defined _args_ call :skip_first _args_ %_args_%
if defined _args_ set _args_=%_args_% %2
if not defined _args_ set _args_=%2
endlocal && call %1 %_args_%
exit /b %errorlevel%

:roropt
::|  roropt command [options]
::|    Rotates options to right, ie. runs command with option N and option 1..N-1.
::|
if "%~1"=="" call :error Command is required: sufi roropt %* && exit /b 2
setlocal
call :skip_first _args_ %*
if not defined _args_ goto _roropt_empty
for %%a in (%_args_%) do set _last_=%%a
set _args_=%_args_%:escape:
call :eval set _args_=%%_args_:%_last_%:escape:=%%
if not defined _args_ goto _roropt_lastonly
if "%_args_:~-1%"==" " set _args_=%_args_:~0,-1%
if not defined _args_ goto _roropt_lastonly
set _args_=%_last_% %_args_%
:_roropt_done
endlocal && call %1 %_args_%
exit /b %errorlevel%
:_roropt_empty
set _last_=
:_roropt_single
set _args_=%_last_%
goto _roropt_done

:output 
::|  output outputfile ext/- command [options]
::|    Runs command [options] with output redirected to file[ext].
if "%~1"=="" call :error Output file is required: sufi output %* && exit /b 2
if "%~3"=="" call :error Command is required: sufi output %* && exit /b 2
setlocal
if not "%~2"=="" if not "%~2"=="-" (set _output_="%~dpn1%~2") else (set _output_="%~f1%")
call :skip_first _args_ %*
call :skip_first _args_ %_args_%
call :run %_args_% > "%_output_%"
call :info ... saved to '%_output_:~1,-1%'
endlocal && exit /b %errorlevel%

:logged
::|  logged command [options]
::|    Runs command [options] with output duplexed to log file, if enabled.
::|
::|    Works in non-blocking mode, when tee.exe is installed in system path.
::|    You can get it at http://gnuwin32.sourceforge.net/packages/coreutils.htm.
::|
::|    To use reentantly, run it in a temporary environment scope.
::|
if "%~1"=="" call :error Command is required: sufi logged %* && exit /b 2
if not defined LogFile goto run_quiet
call :which _tee_ tee.exe
if errorlevel 1 goto _logged_via_tempfile
call :mktemp _tmp_ "%LogFile%.piperc-" .log
setlocal
( call %* 2>&1 || echo %errorlevel% > "%_tmp_%" ) | "%_tee_%" -a "%LogFile%"
endlocal
set _err_=0
if not exist "%_tmp_%" exit /b 0
for /f "usebackq tokens=1" %%x in ("%_tmp_%") do set _err_=%%x
del /f /q "%_tmp_%" >> "%LogFile%" 2>&1
goto _logged_exit
:_logged_via_tempfile
call :debug Tee.exe is required for non-blocking command output logging. You can install it from http://gnuwin32.sourceforge.net/packages/coreutils.htm.
call :mktemp _tmp "%LogFile%.output-" .log
call %* > "%_tmp_%" 2>&1
set _err_=%errorlevel%
if not exist "%_tmp_%" goto _logged_exit
type "%_tmp_%"
type "%_tmp_%" >> "%LogFile%"
del /f /q "%_tmp_%" >> "%LogFile%" 2>&1
:_logged_exit
if not "%_err_%"=="0" call :debug Exit code %_err_%
exit /b %_err_%




::|Configuration commands:
::|

:getreg
::|  getreg -/var/ key [options]
::|    Outputs value of the registry key, or sets var to it.
::|    Use -ve option for default key value. See `reg query -h` for all options.
::|
if "%~2"=="" call :error Registry key is required: sufi getreg %* && exit /b 2
if not defined _reg_exe_ if  "%~nx2"=="reg.exe" exit /b 1
if not defined _reg_exe_ call :which _reg_exe_ reg.exe --system || exit /b 1
setlocal
call :debug Getting "%_reg_exe_%" query "%~2" %3 %4 %5 %6 %7 %8 %9
set _value_=
( for /f "usebackq tokens=2*" %%v in (`%_reg_exe_% query "%~2" %3 %4 %5 %6 %7 %8 %9`) do set _value_="%%~w" ) 2>nul 
if not defined _value_ call :setenv "%~1" && exit /b 1 || exit 199
endlocal && call :setenv "%~1" %_value_% && exit /b %errorlevel% || exit 199
::#Note: Returns reg exit code.

:getopt
::|  getopt args_var [options -/var/ value/{arg}] ...
::|    Outputs value if args_var contains any of options, or sets var to it.
::|    If {arg} is used, then the value is read from the next argument.
::|
if "%~1"=="" call :error Args variable name is required: sufi getopt %* && exit /b 2
call :debug Reading options from command line: %%%~1%%
if not defined %~1 exit /b 0
:_getopt_loop
if "%~2"=="" exit /b 0
verify fail 2>nul || setlocal enabledelayedexpansion || exit 198
call :eval set _args_=%%%~1%%
if "%~4"=="{arg}" goto _getopt_arg
endlocal && for %%o in (%~2) do for %%a in (%_args_%) do if %%a==%%o call :setenv "%~3" "%~4"
shift /2 && shift /2 && shift /2 
goto _getopt_loop
:_getopt_arg
set _undefined_=:undefined:%RANDOM%
set _arg_=%_undefined_%
for %%o in (%~2) do for %%a in (%_args_%) do (
    if defined _next_ set _next_=&&set _arg_=%%a
    if %%a==%%o set _next_=true
    )
if defined _next_ set _arg_=
endlocal && if not %_arg_%==%_undefined_% call :setenv "%~3" %_arg_%
shift /2 && shift /2 && shift /2 
goto _getopt_loop

:popopt
::|  popopt args_var [options -/var/ value/{arg}] ...
::|    Outputs value if args_var contains any of options, or sets var to it.
::|    If {arg} is used, then the value is read from the next argument.
::|    Removes the options from %%Args%%.
::|
if "%~1"=="" call :error Args variable name is required: sufi popopt %* && exit /b 2
call :debug Pulling options from command line: %%%~1%%
if not defined %~1 exit /b 0
:_popopt_loop
if "%~2"=="" exit /b 0
verify fail 2>nul || setlocal enabledelayedexpansion || exit 198
call :eval set _args_=%%%~1%%
if "%~4"=="{arg}" goto _popopt_arg
endlocal && for %%o in (%~2) do for %%a in (%_args_%) do if %%a==%%o call :setenv "%~3" "%~4" && call :remove_item "%~1" %%a
shift /2 && shift /2 && shift /2 
goto _popopt_loop
:_popopt_arg
set _undefined_=:undefined:%RANDOM%
set _arg_=%_undefined_%
for %%o in (%~2) do for %%a in (%_args_%) do (
    if defined _next_ call :remove_item "%~1" %%a && set _next_=&&set _arg_=%%a
    if %%a==%%o call :remove_item "%~1" %%a && set _next_=true
    )
if defined _next_ set _arg_=
endlocal && if not %_arg_%==%_undefined_% call :setenv "%~3" %_arg_%
shift /2 && shift /2 && shift /2 
goto _popopt_loop

:loadenv
::|  loadenv prefix [var ...]
::|    Loads all, or specified environment vars that start with prefix.
::|
if "%~1"=="" call :error Environment prefix is required: sufi loadenv %* && exit /b 2
call :debug Loading configuration from environment '%~1'
if "%~2"=="" ( for /f "usebackq tokens=1* delims==" %%v in (`set "%~1"`) do (
    set _loadenv_var_=:escape:%%~v
    call :setenv "%%_loadenv_var_::escape:%~1=%%" "%%~w"
    ) ) 2>nul
if not "%~2"=="" for %%v in (:escape:%*) do if not "%%~v"=="" if not %%v==:escape:%1 for %%p in ("%~1_" "%~1") do if defined %~1%%~v call :setenv "%%~v" %%%~1%%~v%%
exit /b %errorlevel%

:loadconf
::|  loadconf file [context] ...
::|    Loads environment variables from configuration file.
::|    Empty lines and lines starting with '#' are ignored.
::|    Any environment variables used in configuration values are expanded.
::|
::|    If any context is specified, only variables with .context extension
::|    are loaded. Use the dot '.' to specify a root context, or no extension.
::|
if not exist "%~1" call :error Configuration file not found: '%~1' && exit /b 1
setlocal
call :skip_first _cx_ %*
if defined _cx_ goto _loadconf_cx
call :debug Loading configuration file '%~1'
endlocal && for /f "usebackq eol=# delims== tokens=1*" %%k in ("%~1") do call :setenv_line "%%~k" %%l
exit /b %errorlevel%
:_loadconf_cx
call :debug Loading configuration file '%~1' [%_cx_%]
set _dx_=
for %%c in (%_cx_%) do call :append_item _dx_ ".%%~c"
set _dx_=%_dx_:"..=".%
set _dx_=%_dx_:"."=""%
endlocal && for /f "usebackq eol=# delims== tokens=1*" %%k in ("%~1") do for %%d in (%_dx_%) do if "%%~xk"=="%%~d" call :setenv_line "%%~nk" %%l
exit /b %errorlevel%




::|File system commands:
::|

:haspath
::|  haspath [path\]file
::|    Returns 0 if path is non-empty, 1 otherwise.
::|
if not "%~1"=="" if not "%~1"=="%~nx1" if not "%~1"=="%~n1." exit /b 0
exit /b 1

:is-abspath
:is_abspath
::|  haspath [path\]file
::|    Returns 0 if path is non-empty and absolute, 1 otherwise.
::|    Path without drive specification is considered relative.
::|
if "%~1"=="" exit /b 1
if "%~1"=="%~dpnx1" exit /b 0
if "%~1"=="%~dpn1." exit /b 0
::X if "%~1"=="%~pnx1" exit /b 0
::X if "%~1"=="%~pn1." exit /b 0
exit /b 1

:abspath
::|  abspath -/var path
::|    Outputs an existing absolute path, or sets var to it.
::|
if "%~1"=="" call :error Variable name or - is required: sufi abspath %* && exit /b 2
if exist "%~f2" call :setenv "%~1" "%~f2"  && exit /b 0 || exit 199
call :setenv "%~1" "" && exit /b 1 || exit 199

:mktemp
::|  mktemp -/var/ prefix suffix
::|    Outputs name of a non-existent file, or sets var to it.
::|    formatted as prefix{unique_id}suffix.
::|
setlocal
:_mktemp_check
set _tmp_=%~2%Random%%~3
if exist "%_tmp_%" goto _mktemp_check
endlocal && call :setenv "%~1" "%_tmp_%"
exit /b 0

:clean
::|  clean dir [..]
::|    Removes dir content, or creates dir if it does not exist.
::|
if "%~1"=="" call :error Directory is required: sufi clean %* && exit /b 2
setlocal
set _x_=0
for %%d in (%*) do if not exist "%%~d" ( call :mkdir "%%~d" || set _x_=1) else (
    for /d %%s in ("%%~d\*") do call :rmdir "%%~s" || set _x_=1
    for %%f in ("%%~d\*") do call :rm "%%~f" || set _x_=1
    )
exit /b %_x_%

:clean_except
::|  clean_except dir exclude ...
::|    Removes dir content except excludes, or creates dir if it does not exist.
::|    excludes may be [subpath\]filename. Filemasks are not matched.
::|
if "%~1"=="" call :error Directory is required: sufi clean_except %* && exit /b 2
if not exist "%~1" call :mkdir %1 && exit /b 0 || exit /b 1
setlocal
set _x_=0
set _exclude_=
for %%i in (:escape:%*) do if not %%i==:escape:%1 call :append_unique_item _exclude_ "%~1\%%~i"
for /d %%s in ("%~1\*") do call :is_in "%%~s" %_exclude_% && call :debug Exclude '%%~s\' || call :rmdir "%%~s" || set _x_=1
for %%f in ("%~1\*") do call :is_in "%%~f" %_exclude_% && call :debug Exclude '%%~f' || call :rm "%%~f" || set _x_=1
exit /b %_x_%

:rm
::|  rm file [..]
::|    Removes files.
::|
for %%f in (%*) do if exist %%f call :run :logged del /f %%f
for %%f in (%*) do if exist %%f exit /b 1
exit /b 0

:rmdir
::|  rmdir dir [..]
::|    Removes dirs with all content.
::|
for %%d in (%*) do if exist %%d call :run :logged rd /s /q %%d
for %%d in (%*) do if exist %%d exit /b 1
exit /b 0

:mkdir
::|  mkdir dir [..]
::|    Creates dirs.
::|
for %%d in (%*) do if not exist %%d call :run :logged md %%d
for %%d in (%*) do if not exist %%d exit /b 1
exit /b 0

:datadirs
::|  datadirs [-/var]
::|    Outputs standard user data directories, one per line,
::|    or sets var to list of them.
::|
::|    Uses %%DataLocations%% list and %%Home%%, %%UserProfile%%, %%AppData%%,
::|    %%LocalAppData%%, %%AllUsersProfile%% and %%Public%% variables.
::|
setlocal
set _dirs_=
if defined DataLocations for %%d in (%DataLocations%) do if not "%%~d"=="" call :append_unique_item _dirs_ "%%~d"
if defined Home call :append_unique_item _dirs_ "%Home%"
if defined UserProfile call :append_unique_item _dirs_ "%UserProfile%"
::#Note: Conditions below are intentionally expanded to avoid command processor
::#      errors due to long lines, esp. in combination with unix line endings.
if defined AppData call :append_unique_item _dirs_ "%AppData%" && goto _datadirs_adrx
if not defined UserProfile goto _datadirs_adrx
if exist "%UserProfile%\AppData\Roaming" call :append_unique_item _dirs_ "%UserProfile%\AppData\Roaming" && goto _datadirs_adrx
if exist "%UserProfile%\Application Data" call :append_unique_item _dirs_ "%UserProfile%\Application Data"
:_datadirs_adrx
if defined LocalAppData call :append_unique_item _dirs_ "%LocalAppData%" && goto _datadirs_adlx
if not defined UserProfile goto _datadirs_adlx
if exist "%UserProfile%\AppData\Local" call :append_unique_item _dirs_ "%UserProfile%\AppData\Local" && goto _datadirs_adlx
if exist "%UserProfile%\Local Settings\Application Data" call :append_unique_item _dirs_ "%UserProfile%\Local Settings\Application Data"
:_datadirs_adlx
if defined AllUsersProfile call :append_unique_item _dirs_ "%AllUsersProfile%"
if defined Public call :append_unique_item _dirs_ "%Public%"
endlocal && call :setenv_list "%~1" %_dirs_%
exit /b %errorlevel%

:downloads
::|  downloads [-/var]
::|    Outputs standard user download directories, one per line,
::|    or sets var to list of them.
::|
::|    Uses %%DownloadLocations%% list and (User)ShellFolders registry.
::|
setlocal
set _dirs_=
if defined DownloadLocations for %%d in (%DownloadLocations%) do if not "%%~d"=="" call :append_unique_item _dirs_ "%%~d"
for %%r in (HKCU HKLM) do for %%u in ("User " "") do ( 
    for /f "usebackq tokens=2,3" %%c in (`reg query "%%~r\Software\Microsoft\Windows\CurrentVersion\Explorer\%%~uShell Folders" -v "{374DE290-123F-4565-9164-39C4925E467B}"`) do if not "%%~d"=="" ( 
        if "%%~c"=="REG_SZ" ( call :append_unique_item _dirs_ "%%~d" ) else if "%%~c"=="REG_EXPAND_SZ" ( call :append_unique_item _dirs_ "%%~d" ) 
        )  
    ) 2>nul
endlocal && call :setenv_list "%~1" %_dirs_%
exit /b %errorlevel%

:appdirs
::|  appdirs [-/var]
::|    Outputs standard application directories, one per line,
::|    or sets var to list of them.
::| 
::|    Uses %%AppLocations%% list and %%ProgramFiles%%, %%SystemDrive%% variables.
::|
setlocal
set _dirs_=
if defined AppLocations for %%d in (%AppLocations%) do if not "%%~d"=="" call :append_unique_item _dirs_ "%%~d"
if defined ProgramW6432 call :append_unique_item _dirs_ "%ProgramW6432%"
if defined ProgramFiles call :append_unique_item _dirs_ "%ProgramFiles%"
if defined ProgramFiles(x86) call :append_unique_item _dirs_ "%ProgramFiles(x86)%"
if defined SystemDrive call :append_unique_item _dirs_ "%SystemDrive%"
endlocal && call :setenv_list "%~1" %_dirs_%
exit /b %errorlevel%

:locate
::|  locate -/var/ [subpath\]name ...
::|    Outputs first existing subpath\name in directories read from stdin,
::|    or sets var to it.
::|
if not defined _findstr_exe_ call :which _findstr_exe_ findstr.exe --system || exit /b 1
for /f "usebackq tokens=*" %%d in (`"%_findstr_exe_%" /r .*`) do if not "%%~d"=="" for %%f in (:escape:%*) do if not %%f==:escape:%1 if exist "%%~d\%%~f" call :setenv "%~1" "%%~d\%%~f" && exit /b 0
call :debug Files not located: %*
exit /b 1

:locate-all
:locate_all
::|  locate_all [subpath\]name ...
::|    Outputs all existing subpath\name in directories read from stdin.
::|
if not defined _findstr_exe_ call :which _findstr_exe_ findstr.exe --system || exit /b 1
setlocal
set _x_=1
for /f "usebackq tokens=*" %%d in (`"%_findstr_exe_%" /r .*`) do if not "%%~d"=="" for %%f in (%*) do if exist "%%~d\%%~f" set _x_=0&& echo %%~d\%%~f
if "%_x_%"=="1" call :debug Files not located: %*
exit /b %_x_%

:locate-app
:locate_app
::|  locate_app -/var/ [subpath\]name ...
::|    Outputs first existing subpath\name in standard application directories.
::|    or sets var to it. See sufi appdirs command.
::|
if not defined CachedAppLocations call :appdirs CachedAppLocations
for %%f in (:escape:%*) do if not %%f==:escape:%1 if "%%~f"=="%%~dpnxf" (
        if exist "%%~f" call :setenv "%~1" "%%~f" && exit /b 0
    ) else ( 
        for %%d in (%CachedAppLocations%) do if not "%%~d"=="" if exist "%%~d\%%~f" call :setenv "%~1" "%%~d\%%~f" && exit /b 0
    )
if not "%Verbose%"=="debug" exit /b 1
setlocal
call :skip_first _files_ %*
call :debug Files not located in app locations: %_files_%
exit /b 1

:locate-app-all
:locate_app_all
::|  locate_app_all [subpath\]name ...
::|    Outputs all existing subpath\name in standard application directories.
::|    See sufi appdirs command.
::|
if not defined CachedAppLocations call :appdirs CachedAppLocations
setlocal
set _x_=1
for %%f in (:escape:%*) do if not %%f==:escape:%1 if "%%~f"=="%%~dpnxf" (
        if exist "%%~f" set _x_=0&& echo %%~f
    ) else ( 
        for %%d in (%CachedAppLocations%) do if not "%%~d"=="" if exist "%%~d\%%~f"  set _x_=0&& echo %%~d\%%~f
    )
if "%_x_%"=="1" call :debug Files not located in app locations: %*
exit /b %_x_%

:locate-cmd
:locate_cmd
::|  locate_cmd -/var/ [subpath\]filename [--system/--path/dir] ...
::|    Outputs absolute filename path, or sets var to it.
::|    Searches filename in dir, system root, or system path, as requested.
::|
if "%~2"=="" call :error Filename is required: sufi locate_cmd %* && exit /b 2
:_locate_cmd
if "%~3"=="--path" goto _locate_cmd_path
if "%~3"=="--system" goto _locate_cmd_sys
if .%3.==.. exit /b 1
if "%~3"=="" shift /3 && goto _locate_cmd
if exist "%~3\%~2" call :setenv "%~1" "%~3\%~2" && exit /b 0 || exit 199
if exist "%~3.\%~2" if exist "%~3%~2" call :setenv "%~1" "%~3%~2" && exit /b 0 || exit 199
shift /3 && goto _locate_cmd
:_locate_cmd_sys
if not defined SystemRoot goto _locate_cmd_win
if exist "%SystemRoot%\%~2" call :setenv "%~1" "%SystemRoot%\%~2" && exit /b 0 || exit 199
if exist "%SystemRoot%\system32\%~2" call :setenv "%~1" "%SystemRoot%\system32\%~2" && exit /b 0 || exit 199
shift /3 && goto _locate_cmd
:_locate_cmd_win
if not defined WinDir goto _locate_cmd
if exist "%WinDir%\%~2" call :setenv "%~1" "%WinDir%\%~2" && exit /b 0 || exit 199
if exist "%WinDir%\system32\%~2" call :setenv "%~1" "%WinDir%\system32\%~2" && exit /b 0 || exit 199
shift /3 && goto _locate_cmd
:_locate_cmd_path
setlocal
set _cmd_=%~f$path:2
if defined _cmd_ endlocal && call :setenv "%~1" "%_cmd_%" && exit /b %_x_% || exit 199
endlocal
shift /3 && goto _locate_cmd

:which
::|  which -/var/ [path\]command [--system/dir] ...
::|    Outputs absolute command path, if it exists, or sets var to it.
::|
::|    If path is absolute, command is only searched in it.
::|    Otherwise, path\command is searched in dirs and system path.
::|
::|    If command extension is omitted, standard extensions are searched
::|    using %%PathExt%% or '.com;.exe;.bat;.cmd' default value.
::|
::|    If command is specified without path and extension is none or exe, then
::|    'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\command.exe'.
::|    registry is searched at last.
::|
if "%~2"=="" call :error Command is required: sufi which %* && exit /b 2
if "%~2"=="%~dpnx2" goto :_which_fullpath
if "%~2"=="%~dpn2." goto :_which_fullpath
setlocal
set _dirs_=%*
call :eval set _dirs_=%%_dirs_:%1 %2=%%
if not "%~x2"=="" ( set _ext_=%~x2) else if defined PathExt ( set _ext_=. %PathExt:;= %) else ( set _ext_=. .com .exe .bat .cmd)
endlocal && ( for %%x in (%_ext_%) do call :locate_cmd "%~1" "%~n2%%~x" --path %_dirs_% && exit /b 0 ) || call :debug Command not located in system path: '%~2' (%_ext_%) [+%_dirs_%]
if not "%~x2"=="" if not "%~x2"==".exe" call :setenv "%~1" && exit /b 1 || exit 199
if not "%~nx2"=="%~2" if not "%~n2."=="%~2" call :setenv "%~1" && exit /b 1 || exit 199
call :getreg "%~1" "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%~n2.exe" -ve
exit /b %errorlevel%
:_which_fullpath
if exist "%~2" call :setenv "%~1" "%~2" && exit /b 0
setlocal
if not "%~x2"=="" ( set _ext_=%~x2) else if defined PathExt ( set _ext_=. %PathExt:;= %) else ( set _ext_=. .com .exe .bat .cmd)
endlocal && ( for %%x in (%_ext_%) do if exist "%~dpn2%%~x" call :setenv "%~1" "%~n2%%~x" && exit /b 0 ) || call :debug Command not located: '%~2' (%_ext_%)
exit /b 1

:launch
::|  launch script --console[-no-help]/"start_options" argsvar
::|    name homepage setup command [subpath\]filename ...
::|
::|    Locates and runs application.
::|
::|    Application is located using `sufi which - command script_path`,
::|    or `sufi locate_app - [subpath\]filename ...`.
::|
::|    Application is run using `start "name" start_options executable arguments`,
::|    unless start_options starts with '--console'.
::|
::|    Application arguments are read from variable argsvar.
::|
::|    Also shows script help usage, if --help is in arguments read from argsvar.
::|    In that case, only command line (--console) application is run.
::|  
::|    --} launch sh.bat --console AppArgs "MSys/MSysGit bash unix shell"
::|        http://mingw.org/wiki/msys
::|        "msys, or git installer (http://msysgit.googlecode.com)"
::|        sh.exe Git\bin\sh.exe MinGW\msys\1.0\bin\sh.exe
::|  
::|    --} launch wm.bat "" AppArgs WinMerge http://winmerge.org - WinMergeU.exe
::|        WinMerge\WinMergeU.exe
::|  
if "%~1"=="" call :error Script is required: sufi launch %* && exit /b 2
if "%~4"=="" call :error Application name is required: sufi launch %* && exit /b 2
if "%~6"=="" call :error Application executable is required: sufi launch %* && exit /b 2
setlocal
if "%~3"=="" set AppArgs=
if not "%~3"=="" if /i "%~3" neq "AppArgs" call :eval set AppArgs=%%%~3%%
set AppCommand=%~n1
set AppScript=%~1
set AppScriptPath=%~dp1
set AppStartOptions=%~2
set AppName=%~4
set AppUrl=%~5
set AppSetup=an installer from %~5
if not "%~6"=="" if not "%~6"=="-" set AppSetup=%~6
set AppExe=%~7
set AppFiles=%*
call :eval set AppFiles=%%AppFiles:%1 %2 %3 %4 %5 %6 %7=%%

set AppHelp=& for %%a in (%AppArgs%) do if "%%~a"=="--help" set AppHelp=true
if "%AppHelp%"=="true" %sufi% usage "%AppScript%" "Command=%AppCommand%" "Application=%AppName%" "Url=%AppUrl%" "Setup=%AppSetup%" || exit /b 1

set AppCmd=
call :which AppCmd "%AppExe%" "%AppScriptPath%"
if not defined AppCmd call :locate_app AppCmd %AppFiles%
if not defined AppCmd call :error %AppName% not located. You can install it using %AppSetup%.
if not defined AppCmd exit /b 1

if "%AppStartOptions:~0,9%"=="--console" goto _launch_console

:_launch_window
if "%AppHelp%"=="true" exit /b 0
call :run start "%AppName%" %AppStartOptions% "%AppCmd%" %AppArgs%
exit /b %errorlevel%

:_launch_console
if "%AppHelp%"=="true" if "%AppStartOptions%"=="--console-no-help"  exit /b 0
call :run "%AppCmd%" %AppArgs%
exit /b %errorlevel%

:launch-npm
:launch_npm
::|  launch_npm package.command script --console[-no-help]/"start_options" argsvar name homepage
::|
::|    Locates and runs command from a node.js package.
::|
::|    See `launch` command for more details.
::|
::|    --} launch-npm less.lessc lessc.bat --console Args LessCss http://lesscss.org
::|
if "%~n1"=="" call :error Node.js package is required: sufi launch-npm %* && exit /b 2
if "%~x1"=="" call :error Node.js package command is required: sufi launch-npm %* && exit /b 2

setlocal
set _cmd_=%~x1
set _cmd_=%_cmd_:~1%
set _inst_=npm install %~n1 -g
if "%~n1"=="npm" set _inst_=a Node.js installer from %~6

endlocal && call :launch "%~2" "%~3" "%~4" "%~5" "%~6" "%_inst_%" "%_cmd_%.cmd" "%~dp2%_cmd_%.cmd" "%~dp2npm\%_cmd_%.cmd" "%AppData%\npm\%_cmd_%.cmd" "%UserProfile%\Application Data\npm\%_cmd_%.cmd" "nodejs\%_cmd_%.cmd" "node.js\%_cmd_%.cmd"
exit /b %errorlevel%




::|Pipe commands:
::|
::|  Note: Environment changes anywhere in pipe are not reflected in current environment.
::|


:list
::|  list item ...
::|    Outputs one item per line. Quotes are stripped.
::|
for %%i in (%*) do echo.%%~i
exit /b %errorlevel%

:read
::|  read file
::|    Outputs file content.
::|
if not exist "%~1" call :error File not found: '%~1' && exit /b 1
type "%~1"
exit /b %errorlevel%

:readconf
::|  readconf file
::|    Outputs configuration file lines.
::|    Empty lines and lines starting with '#' are ignored.
::|
if not exist "%~1" call :error File not found: '%~1' && exit /b 1
if not defined _findstr_exe_ call :which _findstr_exe_ findstr.exe --system || exit /b 1
"%_findstr_exe_%" /v /b # "%~1"
exit /b %errorlevel%

:prepend-output
:prepend_output
::|  prepend_output command [options]
::|    Runs command with options and then passes stdin to stdout.
::|
if "%~1"=="" call :error Command is required: sufi prepend_output %* && exit /b 2
if not defined _findstr_exe_ call :which _findstr_exe_ findstr.exe --system || exit /b 1
call %*
"%_findstr_exe_%" /r .* && exit /b %errorlevel% || exit /b %errorlevel% 

:append-output
:append_output
::|  append_output command [options]
::|    Passes stdin to stdout and then runs command with options. 
::|
if "%~1"=="" call :error Command is required: sufi append_output %* && exit /b 2
if not defined _findstr_exe_ call :which _findstr_exe_ findstr.exe --system || exit /b 1
"%_findstr_exe_%" /r .*
call %*
exit /b %errorlevel%

:uniq
::|  uniq [--sort]
::|    Discards all but one of successive identical lines from stdin.
::|
if "%~1"=="--sort" if not defined _sort_exe call :which _sort_exe sort.exe --system || exit /b 1
if not "%~1"=="--sort" if not defined _findstr_exe_ call :which _findstr_exe_ findstr.exe --system || exit /b 1
verify fail 2>nul || setlocal enabledelayedexpansion || exit 198
set _last_line_=:undefined:%RANDOM%:
if "%~1"=="--sort" ( set _input_="%_sort_exe_%" ) else ( set _input_="%_findstr_exe_%" /r .* ) 
for /f "usebackq tokens=*" %%l in (`%_input_%`) do if not "%%~l"=="!_last_line_!" echo.%%l&& set _last_line_=%%~l
exit /b 0

:unsorted-uniq
:unsorted_uniq
::|  unsorted_uniq
::|    Discards all but first one of any identical lines from stdin.
::|
if not defined _findstr_exe_ call :which _findstr_exe_ findstr.exe --system || exit /b 1
setlocal
set _uniq_lines_=
for /f "usebackq tokens=*" %%l in (`"%_findstr_exe_%" /r .*`) do call :append_unique_item _uniq_lines_ "%%~l" && echo.%%l
exit /b 0

:do
::|  do command [options]
::|    Runs command options line for each stdin line, stops on failure.
::|
if "%~1"=="" call :error Command is required: sufi do %* && exit /b 2
if not defined _findstr_exe_ call :which _findstr_exe_ findstr.exe --system || exit /b 1
for /f "usebackq tokens=*" %%l in (`"%_findstr_exe_%" /r .*`) do call :debug Running %* "%%~l" && call %* "%%~l" || exit /b 1
exit /b 0

:any
::|  any command [options]
::|    Runs command options line for each stdin line. Succeeds if any succeeds.
::|
::|    TODO: Stop using a non-local variable _any_.
::|
if "%~1"=="" call :error Command is required: sufi any %* && exit /b 2
if not defined _findstr_exe_ call :which _findstr_exe_ findstr.exe --system || exit /b 1
set _any_=1
for /f "usebackq tokens=*" %%l in (`"%_findstr_exe_%" /r .*`) do call :debug Running any %* "%%~l" && call %* "%%~l" && set _any_=0
set _any_=&& exit /b %_any_%

:btw
::|  btw command [options]
::|    Runs command options line for each stdin line and passes it to stdout.
::|
if "%~1"=="" call :error Command is required: sufi btw %* && exit /b 2
if not defined _findstr_exe_ call :which _findstr_exe_ findstr.exe --system || exit /b 1
for /f "usebackq tokens=*" %%l in (`"%_findstr_exe_%" /r .*`) do ( 
    call :debug Running btw %* "%%~l"
    call %* "%%~l"
    echo.%%l
    )
exit /b 0

:filter
::|  filter command [options]
::|    Runs command options line for each stdin line and passes it to stdout
::|    on success.
::|
if "%~1"=="" call :error Command is required: sufi filter %* && exit /b 2
if not defined _findstr_exe_ call :which _findstr_exe_ findstr.exe --system || exit /b 1
for /f "usebackq tokens=*" %%l in (`"%_findstr_exe_%" /r .*`) do call %* "%%~l" && echo %%l
exit /b 0




::|Environment commands:
::|

:getenv
::|  getenv -/var/ source_var
::|    Outputs source_var value if defined, or sets var to it.
::|
if "%~2"=="" call :error Source variable name is required: sufi getenv %* && exit /b 2
if not defined %~2 if not "%~1"=="" if not "%~1"=="-" set %~1=
if not defined %~2 exit /b 1
if "%~1"=="" call :eval echo.%%%~2%%
if "%~1"=="-" call :eval echo.%%%~2%%
if not "%~1"=="" if not "%~1"=="-" call :eval set %~1=%%%~2%%
exit /b %errorlevel%

:setenv
::|  setenv -/var/ [value]
::|    Outputs value if not empty, or sets var to it.
::|
setlocal
if "%~1"=="" ( set _target_=-) else set _target_=%~1
if "%_target_%"=="-" if not "%~2"=="" echo.%~2
if "%_target_%"=="-" exit /b 0
if not "%_target_:~0,1%"=="_" call :debug Setting %_target_% = %~2
endlocal && set %_target_%=%~2
exit /b %errorlevel%

:setenv-line
:setenv_line
::|  setenv_line -/var/ [item ...]
::|    Outputs all items on a single line, or sets var to value.
::|    value may span multiple arguments.
::|
::|    --} setenv_line - A text line.   Multiple spaces and "quotes" are ok.
::|    A text line.   Multiple spaces and "quotes" are ok.
::|
:setenv-list
:setenv_list
::|  setenv_list -/var/ [item ...]
::|    Outputs all items, one per line, or sets var to value.
::|    value may span multiple arguments.
::|
::|    --} setenv_list - Item-1 "Item 2 (quotes are stripped)"
::|    Item-1
::|    Item 2 (quotes are stripped)
::|
setlocal
if "%~1"=="" ( set _target_=-) else set _target_=%~1
set _type_=%~0
set _type_=%_type_:~-5%
call :skip_first _items_ %*
:setenv-items
:setenv_items
if "%_target_%"=="-" if "%_type_%"=="_list" for %%i in (%_items_%) do echo.%%~i
if "%_target_%"=="-" if not "%_type_%"=="_list" echo.%_items_%
if "%_target_%"=="-" exit /b 0
if not "%_target_:~0,1%"=="_" call :debug Setting %_target_% = %_items_%
endlocal && set %_target_%=%_items_%
exit /b %errorlevel%

:unquote
::|  unquote -/var/ [item ...]
::|    Outputs all unqoted items, or sets var to them.
::|
setlocal
if "%~1"=="" ( set _target_=-) else set _target_=%~1
set _items_=
:_unquote_loop
shift
if "%~1"=="" if "%~2"=="" goto _unquote_end
set _item_="%~1"
if %_item_: =%==%_item_% if not %_item_%=="" set _item_=%_item_:~1,-1%
set _items_=%_items_% %_item_%
goto _unquote_loop
:_unquote_end
set _items_=%_items_:~1%
set _type_=_line
goto setenv_items

:is-in
:is_in
::|  is_in match item ...
::|    Returns 0 if any of items equals to match, 1 otherwise.
::|
if .%1.==.. call :error Search string is required: sufi is_in %* && exit /b 2
if .%2.==.. exit /b 1
for %%i in (:escape:%*) do if "%~1"=="%%~i" exit /b 0
exit /b 1

:append-item
:append_item
::|  append_item var item
::|    Sets var to item if not defined already, or appends space and item to var.
::|
if "%~1"=="" call :error Variable name is required: sufi append_item %* && exit /b 2
if not defined %~1 set %~1=%2&& exit /b 0
call :eval set %~1=%%%~1%% %2
exit /b %errorlevel%

:append-items
:append_items
::|  append_items var item ...
::|    Sets var to items if not defined already, or appends items to var.
::|
if "%~1"=="" call :error Variable name is required: sufi append_items %* && exit /b 2
setlocal
if defined %~1 call :eval set _items_=%%%~1%%
if not defined %~1 shift /2 && set _items_=%2
:_append_items
if .%2.==.. goto _append_items_done
set _items_=%_items_% %2
shift /2 && goto _append_items
:_append_items_done
endlocal && set %~1=%_items_%
exit /b %errorlevel%

:append-unique-item
:append_unique_item
::|  append_unique_item var item
::|    Sets var to item if not defined already, or appends space and item to var,
::|    if item is not already in var. 
::|    Any double quotes are stripped from item, and put around it.
::|
if "%~1"=="" call :error Variable name is required: sufi append_unique_item %* && exit /b 2
setlocal
set _item_="%~2"
if not defined %~1 endlocal && set %~1="%_item_:"=%"&& exit /b 0
call :eval set _items_=%%%~1%%
for %%i in (%_items_%) do if "%_item_:"=%"=="%%~i" exit /b 1
endlocal && set %~1=%_items_% "%_item_:"=%"
exit /b %errorlevel%

:append-unique-items
:append_unique_items
::|  append_unique_items var item ...
::|    Appends unique items to var, or puts unique items var if not defined already.
::|    Any double quotes are stripped from items, and put around them.
::|
if "%~1"=="" call :error Variable name is required: sufi append_unique_items %* && exit /b 2
setlocal
if defined %~1 call :eval set _items_=%%%~1%%
if defined %~1 goto _append_unique_items
:_unique_items
shift /2 && set _item_=%2
if not defined _item_ set _items_=&&goto _append_unique_items_done
set _items_="%_item_:"=%"
:_append_unique_items
set _item_=%2
if not defined _item_ goto _append_unique_items_done
for %%i in (%_items_%) do if "%_item_:"=%"=="%%~i" shift /2 && goto _append_unique_items
set _items_=%_items_% "%_item_:"=%"
shift /2 && goto _append_unique_items
:_append_unique_items_done
endlocal && set %~1=%_items_%
exit /b %errorlevel%

:unique-items
:unique_items
::|  unique_items var item ...
::|    Puts unique items to var.
::|    Any double quotes are stripped from items, and put around them.
::|
if "%~1"=="" call :error Variable name is required: sufi unique_items %* && exit /b 2
setlocal
goto _unique_items

:replace-item
:replace_item
::|  replace_item var item REPLACEMENT
::|    Replaces item in var list with REPLACEMENT.
::|
if "%~1"=="" call :error Variable name is required: sufi replace_item %* && exit /b 2
if not defined %~1 exit /b 0
verify fail 2>nul || setlocal enabledelayedexpansion || exit 198
set _item_="%~2"
call :eval set _items_=%%%~1%%
set _new_=
for %%i in (%_items_%) do (
    set _i_="%%~i"
    set _i_=!_i_:"='!
    if "%_item_:"='%"=="!_i_!" ( set _new_=!_new_! %3) else ( set _new_=!_new_! %%i)
    )
if defined _new_ set _new_=%_new_:~1%
endlocal && set %~1=%_new_%
exit /b %errorlevel%

:remove-item
:remove_item
::|  remove_item var item
::|    Removes item from var list.
::|
if "%~1"=="" call :error Variable name is required: sufi remove_item %* && exit /b 2
if not defined %~1 exit /b 0
verify fail 2>nul || setlocal enabledelayedexpansion || exit 198
set _item_="%~2"
call :eval set _items_=%%%~1%%
set _left_items_=
for %%i in (%_items_%) do (
    set _i_="%%~i"
    set _i_=!_i_:"='!
    if not "%_item_:"='%"=="!_i_!" set _left_items_=!_left_items_! %%i
    )
if defined _left_items_ set _left_items_=%_left_items_:~1%
endlocal && set %~1=%_left_items_%
exit /b %errorlevel%

:unsafe-remove-item
:unsafe_remove_item
::|  remove_item var item
::|    Removes item from var list in a fast and unsafe way.
::|
if "%~1"=="" call :error Variable name is required: sufi remove_item %* && exit /b 2
if not defined %~1 exit /b 0
call :eval set %~1=%%%~1:%2=%%
exit /b %errorlevel%

:skip-first
:skip_first
::|  skip_first var item ...
::|    Sets var to all items, but first.
::|
if "%~1"=="" call :error Variable name is required: sufi skip_first %* && exit /b 2
if .%3==. set %~1=&& exit /b 0
set %~1=:skip_first:%*
call :eval set %~1=%%%~1::skip_first:%1 %2 =%%
exit /b %errorlevel%





::|Python commands:
::|

:python-getpath
:python_getpath
::|  python_getpath [--reset] -/var/ [version]
::|    Outputs located python path, or sets an undefined var to it,
::|    or checks if a defined var points to a valid python installation,
::|    or resets the defined var to the located python path.
::|    
::|    If version is specified, then python path is read from the
::|    'HKLM\SOFTWARE\Python\PythonCore\version\InstallPath' registry key,
::|    or searched in standard install locations. See 'locate_app' in sufi help.
::|
::|    Otherwise a default python.exe is searched in system path, or in the
::|    'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Python.exe'
::|    registry key. See 'which' command in sufi help.
::|
if "%~1"=="--reset" shift && if not "%~2"=="" if not "%~2"=="-" if defined "%~2" set %2=
setlocal
if "%~1"=="" goto _python_getpath_output
if not "%~1"=="-" if defined %~1 call :eval set _path_=%%%~1%%
:_python_getpath_output

set _version_=%~2
if "%_version_%"=="" goto _python_getpath_default
:_python_getpath_version
if not defined _path_ call :getreg _path_ "HKLM\SOFTWARE\Python\PythonCore\%_version_%\InstallPath" /ve
if not defined _path_ call :locate_app _path_ "Python%_version_:.=%\python.exe" "Python%_version_%\python.exe"
if not defined _path_ call :error Python %_version_% is required. You can install it from http://python.org/%_version_%.
goto _python_getpath_set
:_python_getpath_default
if not defined _path_ call :which _path_ python.exe
if not defined _path_ call :locate_app _path_ "Python\python.exe"
if not defined _path_ call :error Python is required. You can install it from http://python.org.
:_python_getpath_set
if not defined _path_ exit /b 1

if "%_path_:~-11%"=="\python.exe" set _path_=%_path_:\python.exe=%
if "%_path_:~-1%"=="\" set _path_=%_path_:~0,-1%

call :python_checkpath "%_path_%" "%_version_%" || exit /b 1

endlocal && call :setenv "%~1" "%_path_%"
exit /b %errorlevel%

:python-checkpath
:python_checkpath
::|  python_checkpath path [version]
::|    Checks if path points to a valid python installation.
::|
if "%~1"=="" call :error Python path is required: sufi_python checkpath %* && exit /b 2
if exist "%~1\python.exe" exit /b 0
if "%~2"=="" call :error Python not found at '%~1\python.exe'. You can install it from http://python.org.
if not "%~2"=="" call :error Python %~2 not found at '%~1\python.exe'. You can install it from http://python.org/%~2.
exit /b 1

::|Note: All commands return codes compliant with LSB service return codes:
::|  0:ok, 1:error, 2:invalid arguments, 3:not implemented, 4:access denied,
::|  5:not installed, 6:not configured, 7:not running,
::|  or custom application codes: 198:os error, 199:something is broken.   
::|  See http://refspecs.linuxfoundation.org/LSB_4.1.0/LSB-Core-generic/LSB-Core-generic/iniscrptact.html.
::|
::|Note: Microsoft command processor exhibited various bugs in handling long constructs,
::|  esp. in combination with unix line endings in this batch script.
::|
::|  The issues were usually observed as 'cannot find the batch label specified' errors.
::|  To avoid them, most long constructs using parenthesis and if-else were replaced
::|  with less readable, but more robust expanded conditions and goto's.
::|  Also, shift was used to avoid using delayed expansion in loops, where possible.
::|
::|  If you get any further 'cannot find the batch label specified' errors,
::|  please checkout this script with DOS/Windows line endings (CRLF, \r\n).
::|
