cmake_minimum_required(VERSION 3.15)

set(PLV8_VERSION "3.2.4")

project("plv8" VERSION 3.2.4 LANGUAGES CXX)

set(POSTGRESQL_DIR "${CMAKE_INSTALL_PREFIX}"
  CACHE PATH "PostgreSQL binary directory")
set(POSTGRESQL_VERSION "unknown"
  CACHE STRING "PostgreSQL version")

# Resolve repo root (this CMakeLists lives in platforms/windows/)
set(PLV8_ROOT "${CMAKE_SOURCE_DIR}/../..")

set(V8_CMAKE_DIR "${PLV8_ROOT}/deps/v8-cmake")
set(V8_BUILD_DIR "${V8_CMAKE_DIR}/build")
set(V8_INCLUDE_DIR "${V8_CMAKE_DIR}/v8/include")

if(NOT EXISTS "${V8_BUILD_DIR}/v8_libbase.lib")
  message(FATAL_ERROR
    "V8 has not been built yet. Run platforms/windows/build_v8.bat from the repo root first.")
endif()

# ---- Generate plv8_config.h ----
set(PLV8_CONFIG_H "${CMAKE_BINARY_DIR}/plv8_config.h")
file(WRITE "${PLV8_CONFIG_H}"
  "#define PLV8_VERSION \"${PLV8_VERSION}\"\n")

# ---- Generate plv8.control ----
set(EXTENSION_CONTROL "${CMAKE_BINARY_DIR}/plv8.control")
configure_file("${PLV8_ROOT}/plv8.control.common" "${EXTENSION_CONTROL}" @ONLY)

# ---- Generate plv8--VERSION.sql via MSVC preprocessor ----
set(EXTENSION_SQL "${CMAKE_BINARY_DIR}/plv8--${PLV8_VERSION}.sql")
set(SUBST_SQL_TMP "${CMAKE_BINARY_DIR}/plv8_subst.c")

add_custom_command(
  OUTPUT "${EXTENSION_SQL}"
  COMMAND ${CMAKE_COMMAND}
    "-DINPUT=${PLV8_ROOT}/plv8.sql.common"
    "-DOUTPUT=${EXTENSION_SQL}"
    "-DTMP=${SUBST_SQL_TMP}"
    "-DVERSION=${PLV8_VERSION}"
    "-DPG_INCLUDE=${POSTGRESQL_DIR}/include"
    "-DCXX_COMPILER=${CMAKE_CXX_COMPILER}"
    -P "${CMAKE_SOURCE_DIR}/preprocess_sql.cmake"
  DEPENDS "${PLV8_ROOT}/plv8.sql.common"
  COMMENT "Generating plv8--${PLV8_VERSION}.sql"
)

add_custom_target(extension_sql ALL DEPENDS "${EXTENSION_SQL}")

# ---- Sources ----
set(SOURCES
  "${PLV8_ROOT}/plv8.cc"
  "${PLV8_ROOT}/plv8_func.cc"
  "${PLV8_ROOT}/plv8_param.cc"
  "${PLV8_ROOT}/plv8_allocator.cc"
  "${PLV8_ROOT}/plv8_guc.cc"
  "${PLV8_ROOT}/plv8_type.cc")

add_library(libplv8 SHARED ${SOURCES})
set_target_properties(libplv8 PROPERTIES OUTPUT_NAME "plv8-${PLV8_VERSION}")
add_dependencies(libplv8 extension_sql)

target_include_directories(libplv8 PRIVATE
  "${POSTGRESQL_DIR}/include/server/port/win32_msvc"
  "${POSTGRESQL_DIR}/include/server/port/win32"
  "${POSTGRESQL_DIR}/include/server"
  "${POSTGRESQL_DIR}/include"
  "${V8_INCLUDE_DIR}"
  "${CMAKE_BINARY_DIR}"
  "${PLV8_ROOT}")

target_link_directories(libplv8 PRIVATE
  "${POSTGRESQL_DIR}/lib"
  "${V8_BUILD_DIR}")

# V8 is built with /MT (static CRT via v8_cache_init.cmake).  plv8 must match
# or the linker will reject duplicate CRT symbols.
set_property(TARGET libplv8 PROPERTY
  MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

target_compile_options(libplv8 PRIVATE /EHsc /std:c++20 /W3)

target_compile_definitions(libplv8 PRIVATE
  JSONB_DIRECT_CONVERSION
  _STAT_DEFINED
  $<$<CONFIG:Debug>:_ITERATOR_DEBUG_LEVEL=0>)

target_link_libraries(libplv8 PRIVATE
  postgres
  v8_base_without_compiler
  v8_compiler
  v8_snapshot
  v8_inspector
  v8_libplatform
  v8_libsampler
  v8_torque_generated
  v8_libbase
  winmm
  dbghelp)

# ---- Install ----
install(TARGETS libplv8
  DESTINATION "lib")

install(FILES "${EXTENSION_CONTROL}"
  DESTINATION "share/extension")

install(FILES "${EXTENSION_SQL}"
  DESTINATION "share/extension")

# ---- Package ----
set(CPACK_GENERATOR "ZIP")
set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF)
set(CPACK_PACKAGE_VERSION "${PLV8_VERSION}")

if(CMAKE_CL_64)
  set(PLV8_ARCH "x64")
else()
  set(PLV8_ARCH "x86")
endif()

set(CPACK_PACKAGE_FILE_NAME
  "plv8-${PLV8_VERSION}-postgresql-${POSTGRESQL_VERSION}-${PLV8_ARCH}")

include(CPack)
