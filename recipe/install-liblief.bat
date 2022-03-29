pushd build

  ninja -v && ninja -v install
  if %errorlevel% neq 0 exit /b 1
  if exist %PREFIX%\share\LIEF\examples rmdir /s /q %PREFIX%\share\LIEF\examples
  if not exist %PREFIX%\bin mkdir %PREFIX%\bin\
  if not exist %PREFIX%\bin\LIEF.dll copy %PREFIX%\lib\LIEF.dll %PREFIX%\bin\LIEF.dll
  if exist LIEF.pdb (
    if not exist %PREFIX%\bin\LIEF.pdb copy LIEF.pdb %PREFIX%\bin\LIEF.pdb
  )

popd
