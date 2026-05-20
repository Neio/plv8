# CMake initial cache file (-C) for building v8-cmake with static MSVC runtime.
#
# Without this, cmake_minimum_required(VERSION 3.4) in v8-cmake keeps CMP0091=OLD,
# causing CMake's MSVC platform init to inject /MD into CMAKE_CXX_FLAGS_RELEASE.
# torque.exe then fails to run as a cmake custom-command subprocess because the
# MSVC CRT DLLs are not on PATH at that point.
#
# Setting these with FORCE before CMakeLists.txt is processed prevents the /MD
# injection (non-FORCE sets are no-ops when the cache already has a value).
set(CMAKE_CXX_FLAGS_DEBUG          "/MTd /Zi /Ob0 /Od /RTC1" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_RELEASE        "/MT /O2 /Ob2 /DNDEBUG"   CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "/MT /O2 /Ob2 /DNDEBUG /Zi" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_MINSIZEREL     "/MT /O1 /Ob1 /DNDEBUG"   CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_DEBUG            "/MTd /Zi /Ob0 /Od /RTC1" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELEASE          "/MT /O2 /Ob2 /DNDEBUG"   CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELWITHDEBINFO   "/MT /O2 /Ob2 /DNDEBUG /Zi" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_MINSIZEREL       "/MT /O1 /Ob1 /DNDEBUG"   CACHE STRING "" FORCE)
