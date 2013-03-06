@echo off
pushd "%~dp0/../app/site"
start cmd /c watchmedo shell-command --patterns="*.shpaml" --command="sufi screenlog ${watch_event_type} ${watch_object} ${watch_src_path} && sufi output \"${watch_src_path}\" .html shpaml \"${watch_src_path}\""
popd


