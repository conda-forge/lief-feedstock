@echo ON
setlocal enabledelayedexpansion
:: Variable LF contains "line feed" character. Do not remove the following 2 blank lines!
set LF=^


set "CMAKE_ARGS=%CMAKE_ARGS% -DBUILD_STATIC_LIBS=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DBUILD_SHARED_LIBS=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_SKIP_RPATH=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DLIEF_EXAMPLES=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DLIEF_OPT_NLOHMANN_JSON_EXTERNAL=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DLIEF_PY_LIEF_EXT=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DLIEF_PY_LIEF_EXT_SHARED=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DLIEF_PYTHON_API=ON"

set "CMAKE_ARGS=%CMAKE_ARGS% -DLIEF_DISABLE_FROZEN=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS="

cd api\python

if not exist config-default.toml.bak copy config-default.toml config-default.toml.bak
del config-default.toml
(
  echo off
  for /f "delims=" %%l in (config-default.toml.bak) do (
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
  echo on
)
type config-default.toml
if %errorlevel% neq 0 exit /b 1

for /f "useback delims=" %%e in (^
`%PYTHON% -c "from sysconfig import get_config_var as get; print(get('EXT_SUFFIX') or get('SO'))"`) do (
  set "EXT_SUFFIX=%%e"
)
if %errorlevel% neq 0 exit /b 1

pip install --no-deps --no-build-isolation --ignore-installed --no-index -vv .
if %errorlevel% neq 0 exit /b 1

if exist %PREFIX%\share\LIEF\examples rmdir /s /q %PREFIX%\share\LIEF\examples
