@echo ON
setlocal enabledelayedexpansion

if "%DEBUG_C%" == "yes" (
  set BUILD_TYPE=Debug
) else (
  set BUILD_TYPE=Release
)

:: All builds done in a subdir so CMake caches are not found next time.
mkdir build
pushd build

if "%PY3K%" == "0" (
    echo "Copying stdint.h for windows"
    copy "%LIBRARY_INC%\stdint.h" %SRC_DIR%\modules\calib3d\include\stdint.h
    copy "%LIBRARY_INC%\stdint.h" %SRC_DIR%\modules\videoio\include\stdint.h
    copy "%LIBRARY_INC%\stdint.h" %SRC_DIR%\modules\highgui\include\stdint.h
)

:: CMake/OpenCV like Unix-style paths for some reason.
set UNIX_PREFIX=%PREFIX:\=/%
set UNIX_LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%
set UNIX_LIBRARY_BIN=%LIBRARY_BIN:\=/%
set UNIX_SP_DIR=%SP_DIR:\=/%
set UNIX_SRC_DIR=%SRC_DIR:\=/%

set CC=cl.exe
set CXX=cl.exe

cmake -LAH -G "Ninja"  ^
    -DCMAKE_BUILD_TYPE="%BUILD_TYPE%"  ^
    -DBUILD_SHARED_LIBS:BOOL=ON  ^
    -DLIEF_PYTHON_API=OFF  ^
    -DCMAKE_CXX_FLAGS="%CXXFLAGS% /wd4359"  ^
    -DCMAKE_C_FLAGS="%CFLAGS% /wd4359"  ^
    -DCMAKE_INSTALL_PREFIX=%PREFIX%  ^
    -DCMAKE_SKIP_RPATH=ON  ^
    -DCMAKE_VERBOSE_MAKEFILE=ON  ^
    -DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS=OFF  ^
    ..
if %errorlevel% neq 0 exit /b 1
