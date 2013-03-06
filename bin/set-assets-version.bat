@echo off
::|Usage: %Command% version
::|
::|Moves css/style.*, js/script.js and js/plugins.js to *.version.*,
::|reflects the change in a git repository
::|and updates links in index*.html.
::|
::|Requires GNU SED, e.g. from MSys, MSysGit or GnuWin32.
::|
::|  See http://mingw.org/wiki/msys, or http://msysgit.googlecode.com,
::|  or http://gnuwin32.sourceforge.net/packages/sed.htm.
::|
::@Version: 0.3

setlocal enableextensions
if not defined sufi if exist "%~dp0sufi.bat" (set sufi=call "%~dp0sufi.bat") else (set sufi=call sufi.bat)

%sufi% init "%~f0" - - %* || exit /b 1
%sufi% optional-usage && exit /b 0

%sufi% which sed sed.exe --path Git\bin MinGW\msys\1.0\bin GnuWin\bin GnuWin32\bin || %sufi% error Sed not located. You can install it with MSys, MSysGit, or GnuWin32. && exit /b 1

pushd "%Basedir%\app\site"

set xref=
if exist config-*.* (set xref_pre=config-*) else (set xref_pre=*)
if exist %xref_pre%.html set xref=%xref% %xref_pre%.html
if exist %xref_pre%.haml set xref=%xref% %xref_pre%.haml
if exist %xref_pre%.shpaml set xref=%xref% %xref_pre%.shpaml

call :move css\style %1 .css --use %xref% || exit /b 1
call :move css\style %1 .less || exit /b 1
call :move css\style %1 .sass || exit /b 1

call :move js\app     %1 .js --use %xref% || exit /b 1
call :move js\site    %1 .js --use %xref% || exit /b 1
call :move js\script  %1 .js --use %xref% || exit /b 1
call :move js\plugins %1 .js --use %xref% || exit /b 1

call :move js\app     %1 .coffee || exit /b 1
call :move js\site    %1 .coffee || exit /b 1
call :move js\script  %1 .coffee || exit /b 1
call :move js\plugins %1 .coffee || exit /b 1

popd
exit /b 0

:move
if exist "%~1.%~2%~3" exit /b 0
if exist "%~1.*%~3" for %%f in ("%~1.*%~3") do %sufi% run git mv "%%~f" "%~1.%~2%~3" || %sufi% run mv "%%~f" "%~1.%~2%~3"  || exit /b 1
if exist "%~1%~3" %sufi% run git mv "%~1%~3" "%~1.%~2%~3" || %sufi% run mv "%~1%~3" "%~1.%~2%~3" || exit /b 1
if not exist "%~1.%~2%~3" exit /b 0
if not "%~4"=="--use" exit /b 0
if "%~5"=="" exit /b 0
:next
if "%~5"=="" pause && exit /b 0
if not exist "%~5" exit /b 1
for %%f in ("%~5") do %sufi% run "%sed%" -i "s/%~n1\.\?[0-9]*\%~3/%~n1.%~2%~3/" "%%~f" || exit /b 1
shift /5
goto next