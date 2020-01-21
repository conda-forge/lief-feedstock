rmdir /s /q C:\lief-build
rmdir /s /q C:\lief-build-py37
rmdir /s /q C:\lief-build-py38

:: call conda activate base
:: pushd %~dp0..\..
::   mkdir C:\lief-build
::   conda-build lief-feedstock -c defaults --python=3.8 --croot C:\lief-build --no-build-id 2>&1 | C:\msys32\usr\bin\tee.exe C:\lief-build\build.log
::   move C:\lief-build C:\lief-build-py38
::   mkdir C:\lief-build
::   conda-build lief-feedstock -c defaults --python=3.7 --croot C:\lief-build --no-build-id 2>&1 | C:\msys32\usr\bin\tee.exe C:\lief-build\build.log
::   move C:\lief-build C:\lief-build-py37
:: popd

:: rmdir /s /q C:\lief-build-2-py38-act
:: rmdir /s /q C:\lief-build-2-py37-act
:: 
:: pushd %~dp0..\..
::   mkdir C:\lief-build-2-py38-act
::   conda-build lief-feedstock -c defaults --python=3.8 --croot C:\lief-build-2-py38-act --no-build-id 2>&1 | C:\msys32\usr\bin\tee.exe C:\lief-build-2-py38-act\build.log
::   mkdir C:\lief-build-2-py37-act
::   conda-build lief-feedstock -c defaults --python=3.7 --croot C:\lief-build-2-py37-act --no-build-id 2>&1 | C:\msys32\usr\bin\tee.exe C:\lief-build-2-py37-act\build.log
:: popd

rmdir /s /q C:\lief-build-2-py38-noact
rmdir /s /q C:\lief-build-2-py37-noact

call conda deactivate
pushd %~dp0..\..
  mkdir C:\lief-build-2-py38-noact
  conda build lief-feedstock -c defaults --python=3.8 --croot C:\lief-build-2-py38-noact --no-build-id 2>&1 | C:\msys32\usr\bin\tee.exe C:\lief-build-2-py38-noact\build.log
  mkdir C:\lief-build-2-py37-noact
  conda build lief-feedstock -c defaults --python=3.7 --croot C:\lief-build-2-py37-noact --no-build-id 2>&1 | C:\msys32\usr\bin\tee.exe C:\lief-build-2-py37-noact\build.log
popd

:: activation stacking seems busted.
:: call "C:\opt\conda\Scripts\..\condabin\conda_hook.bat"
:: call "C:\opt\conda\Scripts\..\condabin\conda.bat" activate
:: call "C:\opt\conda\Scripts\..\condabin\conda.bat" activate "C:\lief-build-2-py38-noact\_h_env"
:: call "C:\opt\conda\Scripts\..\condabin\conda.bat" activate --stack "C:\lief-build-2-py38-noact\_build_env"
:: echo %PATH%
:: 
:: conda activate 

cmd.exe ::
pushd C:\lief-build-2-py38-noact\work
echo %PATH% > path.cmd.exe
conda activate
echo %PATH% > path.conda-activate
call build_env_setup.bat
echo %PATH% > path.build_env_setup.bat
call conda_build.bat
echo %PATH% > path.conda_build.bat
call install-liblief.bat
echo %PATH% > path.install-liblief.bat
call install-py-lief.bat
echo %ErrorLevel%
echo %PATH% > path.install-py-lief.bat
