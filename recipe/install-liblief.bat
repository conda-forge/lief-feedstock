ninja -C build -v
if %errorlevel% neq 0 exit /b 1
ninja -C build -v install
if %errorlevel% neq 0 exit /b 1

if exist %PREFIX%\share\LIEF\examples rmdir /s /q %PREFIX%\share\LIEF\examples

if not exist %PREFIX%\bin mkdir %PREFIX%\bin\
if not exist %PREFIX%\bin\libLIEF.dll copy %PREFIX%\lib\libLIEF.dll %PREFIX%\bin\libLIEF.dll
if exist build\libLIEF.pdb (
  if not exist %PREFIX%\bin\libLIEF.pdb copy build\libLIEF.pdb %PREFIX%\bin\libLIEF.pdb
)
