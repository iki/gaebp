@echo off
pushd "%~dp0/../app/site"
for %%f in (js\*.coffee) do call coffee --compile --lint %%f
for %%f in (js\*.js)     do call uglifyjs %%f --output %%f --compress --mangle
popd


