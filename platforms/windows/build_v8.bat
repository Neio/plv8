
@echo off

echo "Downloading up third party sources"
pushd vendor\v8\base\trace_event\common
git.exe fetch -q --depth 1 origin 3da1e2fcf66acd5c7194497b4285ac163f32e239  || echo "git.exe command failed, but continuing..."
git.exe reset -q --hard 3da1e2fcf66acd5c7194497b4285ac163f32e239
git.exe log -n 1 --oneline
popd

pushd vendor\v8\build
git.exe fetch -q --depth 1 origin bbf7f0ed65548c4df862d2a2748e3a9b908a3217 
git.exe reset -q --hard bbf7f0ed65548c4df862d2a2748e3a9b908a3217
git.exe log -n 1 --oneline
popd

pushd vendor\v8\third_party\googletest\src
git.exe fetch -q --depth 1 origin 47f819c3ca54fb602f432904443e00a0a1fe2f42
git.exe reset -q --hard 47f819c3ca54fb602f432904443e00a0a1fe2f42
git.exe log -n 1 --oneline
popd

pushd vendor\v8\third_party\icu
git.exe fetch -q --depth 1 origin 75e34bcccea0be165c31fdb278b3712c516c5876
git.exe reset -q --hard 75e34bcccea0be165c31fdb278b3712c516c5876
git.exe log -n 1 --oneline
popd

pushd vendor\v8\third_party\jinja2
git.exe fetch -q --depth 1 origin ee69aa00ee8536f61db6a451f3858745cf587de6
git.exe reset -q --hard ee69aa00ee8536f61db6a451f3858745cf587de6
git.exe log -n 1 --oneline
popd

pushd vendor\v8\third_party\markupsafe
git.exe fetch -q --depth 1 origin 1b882ef6372b58bfd55a3285f37ed801be9137cd
git.exe reset -q --hard 1b882ef6372b58bfd55a3285f37ed801be9137cd
git.exe log -n 1 --oneline
popd

pushd vendor\v8\third_party\zlib
git.exe fetch -q --depth 1 origin 563140dd9c24f84bf40919196e9e7666d351cc0d
git.exe reset -q --hard 563140dd9c24f84bf40919196e9e7666d351cc0d
git.exe log -n 1 --oneline
popd

copy ..\..\Makefiles\gclient_args.gni vendor\v8\build\config\gclient_args.gni


echo "Generating v8 configuration"
pushd vendor\v8
python3.exe tools\dev\v8gen.py x64.release -v -- is_debug=false is_component_build=false v8_optimized_debug=true  v8_use_external_startup_data=false v8_enable_i18n_support=false is_clang=false use_custom_libcxx=false treat_warnings_as_errors=false v8_monolithic=true
echo "Building v8"
ninja -C out.gn\x64.release v8_monolith
