# Substitutes @LANG_NAME@ and @PLV8_VERSION@, then runs MSVC preprocessor
# to evaluate #ifdef/#if blocks and produce the final SQL file.
#
# Required variables (passed via -D):
#   INPUT       - path to plv8.sql.common
#   OUTPUT      - destination .sql file
#   TMP         - temp .c file for the preprocessor
#   VERSION     - PLV8_VERSION string
#   PG_INCLUDE  - path to PostgreSQL include dir (for pg_config.h)
#   CXX_COMPILER - path to cl.exe

# Step 1: substitute @LANG_NAME@ -> plv8 and @PLV8_VERSION@ -> VERSION
file(READ "${INPUT}" content)
string(REPLACE "@LANG_NAME@" "plv8" content "${content}")
string(REPLACE "@PLV8_VERSION@" "${VERSION}" content "${content}")
file(WRITE "${TMP}" "${content}")

# Step 2: run cl.exe /EP (preprocess to stdout, no #line directives)
execute_process(
  COMMAND "${CXX_COMPILER}" /EP /nologo
    "/I${PG_INCLUDE}"
    "-DLANG_plv8=1"
    "${TMP}"
  OUTPUT_FILE "${OUTPUT}"
  RESULT_VARIABLE rc
)

if(NOT rc EQUAL 0)
  message(FATAL_ERROR "SQL preprocessing failed (exit code ${rc})")
endif()

# Strip #pragma and blank lines left by the preprocessor
file(READ "${OUTPUT}" sql_content)
string(REGEX REPLACE "#pragma [^\n]*\n" "" sql_content "${sql_content}")
string(REGEX REPLACE "\n{3,}" "\n\n" sql_content "${sql_content}")
string(STRIP sql_content "${sql_content}")
file(WRITE "${OUTPUT}" "${sql_content}\n")
