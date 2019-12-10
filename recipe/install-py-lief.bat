@echo ON
setlocal enabledelayedexpansion

if "%PY3K%" == "0" (
    echo "Copying stdint.h for windows"
    copy "%LIBRARY_INC%\stdint.h" %SRC_DIR%\modules\calib3d\include\stdint.h
    copy "%LIBRARY_INC%\stdint.h" %SRC_DIR%\modules\videoio\include\stdint.h
    copy "%LIBRARY_INC%\stdint.h" %SRC_DIR%\modules\highgui\include\stdint.h
)

for /F "tokens=1,2 delims=. " %%a in ("%PY_VER%") do (
   set "PY_MAJOR=%%a"
   set "PY_MINOR=%%b"
)
set PY_LIB=python%PY_MAJOR%%PY_MINOR%.lib

:: CMake/OpenCV like Unix-style paths for some reason.
set UNIX_PREFIX=%PREFIX:\=/%
set UNIX_LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%
set UNIX_LIBRARY_BIN=%LIBRARY_BIN:\=/%
set UNIX_SP_DIR=%SP_DIR:\=/%
set UNIX_SRC_DIR=%SRC_DIR:\=/%

cmake . -LAH -G "Ninja"  ^
    -DCMAKE_BUILD_TYPE="Release"  ^
    -DCMAKE_INSTALL_PREFIX=%PREFIX%  ^
    -DCMAKE_SKIP_RPATH=ON  ^
    -DLIEF_PYTHON_API=ON  ^
    -DLIEF_INSTALL_PYTHON=ON  ^
    -DPYTHON_VERSION=%PY_VER%  ^
    -DPYTHON_LIBRARY=%PREFIX%\libs\python%CONDA_PY%.lib  ^
    -DPYTHON_LIBRARY_DEBUG=%PREFIX%\libs\python%CONDA_PY%.lib  ^
    -DPYTHON_INCLUDE_DIR:PATH=%PREFIX%\include  ^
    -DCMAKE_VERBOSE_MAKEFILE=ON  ^
    -DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS=OFF  ^
    -DCMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS=OFF

:: If we do not create this directory, then a cmake copy command will copy a pyd to a file
:: called lief, instead of putting it in that directory (or so it seems at least).
pushd api\python
  mkdir lief
popd

:: cmake --build . --config Release --target CLEAN -- VERBOSE=1  -- -j%CPU_COUNT%
:: cmake --build . --config Release --target INSTALL -- VERBOSE=1
ninja -v pyLIEF && ninja -v install
:: cmake --build . --config Release --target pyLIEF

:: We end up with an exe called lief which is weird.
pushd api\python
dir /s /q
::  %PYTHON% setup.py install --single-version-externally-managed --record=record.txt
  copy lief.pyd %SP_DIR%\
popd
