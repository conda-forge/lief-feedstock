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

if "%DEBUG_C%" == "yes" (
  set BUILD_TYPE=Debug
  set DEBUG_SUFFIX=_d
) else (
  set BUILD_TYPE=Release
  set DEBUG_SUFFIX=
)

:: mkdir build-%PY_VER%
:: pushd build-%PY_VER%

mkdir build-py
pushd build-py

:: It turns out that python3.lib is the DLL import lib and python37.lib is a static lib
:: Who'd have thought it?
set PY_LIB=python%PY_MAJOR%%PY_MINOR%%DEBUG_SUFFIX%.lib

:: CMake/OpenCV like Unix-style paths.
set UNIX_PREFIX=%PREFIX:\=/%
set UNIX_LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%
set UNIX_LIBRARY_BIN=%LIBRARY_BIN:\=/%
set UNIX_SP_DIR=%SP_DIR:\=/%
set UNIX_SRC_DIR=%SRC_DIR:\=/%

:: Yes, we build it statically for the Python extension. This is because I failed
:: to fix the following problem with Python 3.8:
::
:: (C:\opt\b\lief-win\_build_env) (base) C:\opt\b\lief-win\work\build-pylief>C:\opt\b\lief-win\_h_env\python.exe -c "import lief"
:: Fatal Python error: _PyInterpreterState_Get(): no current thread state
:: Python runtime state: initialized
:: 
:: Current thread 0x000052b4 (most recent call first):
::   File "<frozen importlib._bootstrap>", line 219 in _call_with_frames_removed
::   File "<frozen importlib._bootstrap_external>", line 1101 in create_module
::   File "<frozen importlib._bootstrap>", line 556 in module_from_spec
::   File "<frozen importlib._bootstrap>", line 657 in _load_unlocked
::   File "<frozen importlib._bootstrap>", line 975 in _find_and_load_unlocked
::   File "<frozen importlib._bootstrap>", line 991 in _find_and_load
::   File "<string>", line 1 in <module>
:: edit: Does LIEF_DISABLE_FROZEN fix this? Well, no, it causes more problems:
::
:: -DLIEF_DISABLE_FROZEN=ON leads to the following problem with Python 3.7:
:: (C:\opt\b\lief-win\_build_env) (base) C:\opt\b\lief-win\work\build-pylief>C:\opt\b\lief-win\_h_env\python.exe -c "import lief"
:: Traceback (most recent call last):
::   File "<string>", line 1, in <module>
:: ImportError: OS_ABI: element "GNU" already exists!

if %PY_VER% == 3.8 (
  set SHARED_BUILD=OFF
  set STATIC_BUILD=ON
::  set SHARED_BUILD=ON
::  set STATIC_BUILD=OFF
) else (
  set SHARED_BUILD=OFF
  set STATIC_BUILD=ON
::  set SHARED_BUILD=ON
::  set STATIC_BUILD=OFF
)

set CC=cl.exe
set CXX=cl.exe

cmake -LAH -G "Ninja"  ^
    -DCMAKE_BUILD_TYPE="%BUILD_TYPE%"  ^
    -DCMAKE_INSTALL_PREFIX=%PREFIX%  ^
    -DBUILD_SHARED_LIBS:BOOL=%SHARED_BUILD%  ^
    -DBUILD_STATIC_LIBS:BOOL=%STATIC_BUILD%  ^
    -DLIEF_PYTHON_API=ON  ^
    -DLIEF_DISABLE_FROZEN=OFF  ^
    -DCMAKE_SKIP_RPATH=ON  ^
    -DLIEF_PYTHON_API=ON  ^
    -DLIEF_INSTALL_PYTHON=ON  ^
    -DPYTHON_EXECUTABLE=%PREFIX%\python.exe  ^
    -DPYTHON_VERSION=%PY_VER%  ^
    -DPYTHON_LIBRARY=%PREFIX%\libs\%PY_LIB%  ^
    -DPYTHON_INCLUDE_DIR:PATH=%PREFIX%\include  ^
    -DCMAKE_VERBOSE_MAKEFILE=ON  ^
    -DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS=OFF  ^
    -DCMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS=OFF  ^
    ..
if %errorlevel% neq 0 exit /b 1

:: If we do not create this directory, then a cmake copy command will copy a pyd to a file
:: called lief, instead of putting it in that directory (or so it seems at least).
mkdir api\python\lief

ninja -v pyLIEF

:: We might need to clean some stuff manually here.
if "%DEBUG_C%" == "yes" (
  patch -p1<%RECIPE_DIR%\pybind11-MSVC-allow-debug-python.patch
  ninja -v pyLIEF
)

ninja -v install

:: We end up with an exe called lief which is weird.
pushd api\python
  :: We may want to have our own dummy setup.py so we get a dist-info folder. It would
  :: be nice to use LIEF's setup.py but it places too many constraints on the build.
  :: %PYTHON% setup.py install --single-version-externally-managed --record=record.txt
  if "%DEBUG_C%" == "yes" (
    copy lief\lief.pyd %SP_DIR%\lief_d.pyd
    if exist lief.pdb copy lief.pdb %SP_DIR%\lief_d.pdb
  ) else (
    copy lief\lief.pyd %SP_DIR%\lief.pyd
    if exist lief.pdb copy lief.pdb %SP_DIR%\lief.pdb
  )
popd

:: When pywin32 (or something else) modifies PATH in funny ways we can end up with conda run
:: not working at all properly, and the sys python getting run instead (for example).
set CONDA_TEST_SAVE_TEMPS=1
echo "(install-py-lief.bat) PATH just before conda run -p %RECIPE_DIR%\echo_path.bat is %PATH%"
where conda
call conda run -p %PREFIX% --debug-wrapper-scripts call %RECIPE_DIR%\echo_path.bat
echo "(install-py-lief.bat) Done call conda run -p"
if %errorlevel% neq 0 exit /b 1

:: The commented out tests above are overkill, but we should run this one at least.
:: Add --debug-wrapper-scripts to the conda run calls to see what goes on.
call conda run -p %PREFIX% python --version 2>&1 | findstr /r /c:%PY_VER%
if %errorlevel% neq 0 exit /b 1

call conda run -p %PREFIX% python -v -c "import lief" 2>&1 | findstr /r /c:"The specified module could not be found"
if %errorlevel% neq 1 exit /b 1

call conda run -p %PREFIX% python -v -c "import lief" 2>&1 | findstr /r /c:"no current thread state"
if %errorlevel% neq 1 exit /b 1

rmdir /s /q %PREFIX%\share\LIEF\examples
