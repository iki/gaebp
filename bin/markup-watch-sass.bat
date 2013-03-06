@echo off
pushd "%~dp0/../app/site"
start sass --unix-newlines --watch css
popd


