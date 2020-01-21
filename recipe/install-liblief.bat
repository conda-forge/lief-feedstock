pushd build

  ninja -v && ninja -v install
  if %errorlevel% neq 0 exit /b 1
  if exist %PREFIX%\share\LIEF\examples rmdir /s /q %PREFIX%\share\LIEF\examples
  if not exist %PREFIX%\bin mkdir %PREFIX%\bin\
  if not exist %PREFIX%\bin\libLIEF.dll move %PREFIX%\lib\libLIEF.dll %PREFIX%\bin\libLIEF.dll

popd
