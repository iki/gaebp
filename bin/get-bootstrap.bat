@echo off
for %%h in (-h --help) do if "%~1"=="%%h" echo usage: %~n0 [version] [path]>&2 && exit /b 0

set lib=%~n0
set lib=%lib:get-=%

set ver=2.3.0
set url=http://netdna.bootstrapcdn.com/twitter-bootstrap/%ver%/js/%lib%
set ext=.js:.js .min.js:.min.js
set dir=%~dp0..\app\site\js\lib


if not "%~1"=="" set ver=%~1
if not "%~2"=="" set dir=%~2

if exist "%dir%" pushd "%dir%"

for %%x in (%ext%) do (
    for /f "delims=: tokens=1,2" %%y in ("%%~x") do (
        echo === [%cd%] === curl %url%%%y ^> %lib%-%ver%%%z >&2
        curl %url%%%y -R -o %lib%-%ver%%%z -z %lib%-%ver%%%z
        )
    )

if exist "%dir%" popd