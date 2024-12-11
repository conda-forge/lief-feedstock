@echo ON
setlocal enabledelayedexpansion

set "CMAKE_ARGS=%CMAKE_ARGS% -DBUILD_STATIC_LIBS=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DBUILD_SHARED_LIBS=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_SKIP_RPATH=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DLIEF_EXAMPLES=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DLIEF_OPT_NLOHMANN_JSON_EXTERNAL=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DLIEF_OPT_MBEDTLS_EXTERNAL=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DLIEF_PY_LIEF_EXT=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DLIEF_PY_LIEF_EXT_SHARED=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DLIEF_PYTHON_API=OFF"

mkdir build

:: Suppresses warnings C4251, C4275 explicitly to reduce log size (may want to address this upstream).
:: refs:
::   - https://learn.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warning-level-1-c4251
::   - https://learn.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warning-level-2-c4275
cmake %CMAKE_ARGS% -LAH -G "Ninja" -B build  ^
    -DCMAKE_CXX_FLAGS="%CXXFLAGS% /nologo /EHsc /wd4251 /wd4275"  ^
    -DCMAKE_C_FLAGS="%CFLAGS% /nologo /EHsc /wd4251 /wd4275"  ^
    -DCMAKE_VERBOSE_MAKEFILE=ON  ^
    -DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS=OFF

if %errorlevel% neq 0 exit /b 1
