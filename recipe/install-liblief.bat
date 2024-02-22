@echo ON

ninja -C build -v
if %errorlevel% neq 0 exit /b 1
ninja -C build -v install
if %errorlevel% neq 0 exit /b 1

if exist %PREFIX%\share\LIEF\examples rmdir /s /q %PREFIX%\share\LIEF\examples

if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN%

if not exist %LIBRARY_BIN%\LIEF.dll copy %LIBRARY_LIB%\LIEF.dll %LIBRARY_BIN%\LIEF.dll
if %errorlevel% neq 0 exit /b 1
if exist build\LIEF.pdb (
  if not exist %LIBRARY_BIN%\LIEF.pdb copy build\LIEF.pdb %LIBRARY_BIN%\LIEF.pdb
  if %errorlevel% neq 0 exit /b 1
)
