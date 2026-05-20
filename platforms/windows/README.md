# Building PLV8 for Windows

## Prerequisites

- **Git**
- **Visual Studio 2019 or 2022** with the "Desktop development with C++" workload
- **CMake 3.15+** (included with Visual Studio, or install separately)
- **Python 3** (required by V8's build system inside v8-cmake)
- **Ninja** (required for the V8 build — install via `winget install Ninja-build.Ninja` or `choco install ninja`)
- **PostgreSQL 14+** — the Windows installer from postgresql.org

## Step 1: Clone and initialize submodules

```bat
git clone https://github.com/plv8/plv8
cd plv8
git submodule update --init --recursive
```

## Step 2: Build V8

V8 is built once from the `deps/v8-cmake` submodule. This step takes 20–60 minutes.

Open a **Developer Command Prompt for VS 2022** (or 2019), then from the repo root:

```bat
platforms\windows\build_v8.bat
```

V8 static libraries will be placed in `deps\v8-cmake\build\Release\`.

## Step 3: Configure plv8

From the repo root (still in Developer Command Prompt):

```bat
cmake -G "Visual Studio 17 2022" -A x64 ^
  -DCMAKE_INSTALL_PREFIX="C:\Program Files\PostgreSQL\16" ^
  -DPOSTGRESQL_VERSION=16 ^
  platforms\windows
```

Adjust the PostgreSQL path and version to match your installation.

Supported generators: `Visual Studio 17 2022`, `Visual Studio 16 2019`.

## Step 4: Build and package

```bat
cmake --build . --config Release --target Package
```

This produces a ZIP file such as `plv8-3.2.4-postgresql-16-x64.zip`.

## Step 5: Install

Extract the ZIP into your PostgreSQL installation directory:

```powershell
Expand-Archive plv8-3.2.4-postgresql-16-x64.zip -DestinationPath "C:\Program Files\PostgreSQL\16"
```

## Step 6: Enable the extension

Restart PostgreSQL, then:

```sql
CREATE EXTENSION plv8;
SELECT plv8_version();
```

## Optional: Generate upgrade SQL files

If you need upgrade scripts for older plv8 versions:

```powershell
platforms\windows\generate_upgrade.ps1 -Version 3.2.4
```

## Notes

- No PostgreSQL header patching is required. The `generic-msvc.h.patch` from older
  versions was needed for PG < 14 atomics and is no longer applicable.
- The `EXECUTION_TIMEOUT` feature is supported on Windows (uses `CreateThread`/
  `TerminateThread`). To enable it, add `-DCMAKE_CXX_FLAGS="/DEXECUTION_TIMEOUT"`
  to the cmake configure step.
- Only x64 builds are supported.
