@echo ON
setlocal enabledelayedexpansion
:: Variable LF contains "line feed" character. Do not remove the following 2 blank lines!
set LF=^


for /F "tokens=1,2 delims=. " %%a in ("%PY_VER%") do (
   set "PY_MAJOR=%%a"
   set "PY_MINOR=%%b"
)

:: It turns out that python3.lib is the DLL import lib and python37.lib is a static lib
:: Who'd have thought it?
set PY_LIB=python%PY_MAJOR%%PY_MINOR%.lib

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

echo Top of install-py-lief.bat: INCLUDE=%INCLUDE%
echo Top of install-py-lief.bat: LIBRARY_INC=%LIBRARY_INC%
echo Top of install-py-lief.bat: LIB=%LIB%
echo Top of install-py-lief.bat: INCLUDE=%INCLUDE%
echo Top of install-py-lief.bat: LIBRARY_LIB=%LIBRARY_LIB%

set "CMAKE_ARGS=%CMAKE_ARGS% -DBUILD_STATIC_LIBS=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DBUILD_SHARED_LIBS=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_SKIP_RPATH=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DLIEF_EXAMPLES=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DLIEF_OPT_NLOHMANN_JSON_EXTERNAL=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DLIEF_PY_LIEF_EXT=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DLIEF_PYTHON_API=ON"

set "CMAKE_ARGS=%CMAKE_ARGS% -DLIEF_DISABLE_FROZEN=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DPYTHON_EXECUTABLE=%PREFIX%\python.exe"
set "CMAKE_ARGS=%CMAKE_ARGS% -DPYTHON_VERSION=%PY_VER%"
set "CMAKE_ARGS=%CMAKE_ARGS% -DPYTHON_LIBRARY=%PREFIX%\libs\%PY_LIB%"
set "CMAKE_ARGS=%CMAKE_ARGS% -DPYTHON_INCLUDE_DIR:PATH=%PREFIX%\include"
set "CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_VERBOSE_MAKEFILE=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS="

set CC=cl.exe
set CXX=cl.exe

cd api\python

if not exist config-default.toml.bak copy config-default.toml config-default.toml.bak
del config-default.toml
for /f %%l in (config-default.toml.bak) do (
  echo %%l
  if "%%l" == "[lief.build]" (
    echo lief-install-dir = "%LIBRARY_PREFIX:\=\\%"
    echo extra-cmake-opt = [
    for /f "delims=" %%a in ("%CMAKE_ARGS: =!LF!%") do (
      set "arg=%%a"
      echo "!arg:\=\\!",
    )
    echo ]
  )
) >> config-default.toml
if %errorlevel% neq 0 exit /b 1

for /f "useback delims=" %%e in (^
`%PYTHON% -c "from sysconfig import get_config_var as get; print(get('EXT_SUFFIX') or get('SO'))"`) do (
  set "EXT_SUFFIX=%%e"
)
if %errorlevel% neq 0 exit /b 1

pip install --no-deps --no-build-isolation --ignore-installed --no-index -vv .
if %errorlevel% neq 0 exit /b 1

if exist %PREFIX%\share\LIEF\examples rmdir /s /q %PREFIX%\share\LIEF\examples
