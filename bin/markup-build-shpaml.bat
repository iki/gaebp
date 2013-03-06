@echo off
pushd "%~dp0/../app/site"
for %%f in (*.shpaml) do call sufi output "%%~f" .html shpaml "%%~f"
popd


