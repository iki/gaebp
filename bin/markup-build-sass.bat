@echo off
pushd "%~dp0/../app/site"
echo === sass --style compressed --unix-newlines --force --update css
call sass --style compressed --unix-newlines --force --update css
popd


