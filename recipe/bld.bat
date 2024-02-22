@echo ON
setlocal enabledelayedexpansion

:: All builds done in a subdir so CMake caches are not found next time.
mkdir build
pushd build

set CC=cl.exe
set CXX=cl.exe

cmake -LAH -G "Ninja"  ^
    %CMAKE_ARGS% ^
    -DBUILD_SHARED_LIBS:BOOL=ON  ^
    -DLIEF_PYTHON_API=OFF  ^
    -DCMAKE_CXX_FLAGS="%CXXFLAGS% /EHsc /wd4359"  ^
    -DCMAKE_C_FLAGS="%CFLAGS% /EHsc /wd4359"  ^
    -DCMAKE_SKIP_RPATH=ON  ^
    -DCMAKE_VERBOSE_MAKEFILE=ON  ^
    -DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS=OFF  ^
    -DLIEF_EXTERNAL_PYBIND11=ON ^
    -DLIEF_OPT_NLOHMANN_JSON_EXTERNAL=ON ^
    ..
if %errorlevel% neq 0 exit /b 1
