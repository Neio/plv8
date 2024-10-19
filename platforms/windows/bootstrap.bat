powershell -File generate_upgrade.ps1
mkdir vendor
cd vendor
powershell -File ..\wget_depot_tools.ps1
mkdir depot_tools
cd depot_tools
unzip ..\depot_tools.zip
cd ..
set path=%~dp0vendor\depot_tools;%path%
set DEPOT_TOOLS_WIN_TOOLCHAIN=0
set SKIP_V8_GYP_ENV=1
set GYP_CHROMIUM_NO_ACTION=1
call fetch v8
cd v8
call git checkout 9.7.37
call gclient sync
cd ..\..
call build_v8.bat
