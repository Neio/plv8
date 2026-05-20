@echo off
setlocal

set V8_CMAKE_DIR=%~dp0..\..\deps\v8-cmake
set V8_BUILD_DIR=%V8_CMAKE_DIR%\build

echo Configuring v8 via cmake (Ninja + MSVC)...
cmake -C "%~dp0v8_cache_init.cmake" ^
    -S "%V8_CMAKE_DIR%" -B "%V8_BUILD_DIR%" ^
    -G Ninja ^
    -DCMAKE_C_COMPILER=cl ^
    -DCMAKE_CXX_COMPILER=cl ^
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_C_FLAGS="/utf-8" ^
    -DCMAKE_CXX_FLAGS="/utf-8"
if %ERRORLEVEL% neq 0 (
    echo ERROR: cmake configure failed
    exit /b %ERRORLEVEL%
)

echo Building v8 (this will take 20-60 minutes)...
cmake --build "%V8_BUILD_DIR%"
if %ERRORLEVEL% neq 0 (
    echo ERROR: v8 build failed
    exit /b %ERRORLEVEL%
)

echo V8 build complete. Libraries are in: %V8_BUILD_DIR%\
endlocal
