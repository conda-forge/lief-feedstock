pushd build

ninja -v && ninja -v install
if errorlevel 1 exit /b 1
rmdir /s /q %PREFIX%\share\LIEF\examples
