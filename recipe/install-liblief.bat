pushd build

ninja -v && ninja -v install
if %errorlevel% neq 0 exit /b 1
rmdir /s /q %PREFIX%\share\LIEF\examples
dir /s /q %PREFIX%\lib
mkdir %PREFIX%\bin\
move %PREFIX%\lib\libLIEF.dll %PREFIX%\bin\libLIEF.dll
