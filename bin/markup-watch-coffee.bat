@echo off
pushd "%~dp0/../app/site"
start coffee --compile --lint --watch js
popd


