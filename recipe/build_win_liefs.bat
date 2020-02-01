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

set DEBUG=yes
if !DEBUG! == yes (
  set CFG=C:\opt\Shared.local\r\a\conda_build_config-dbg.yaml
  set SFX=_d
) else (
  set CFG=C:\opt\Shared.local\r\a\conda_build_config.yaml
  set SFX=dbg
)
rmdir /s /q C:\lief-build-2-py38-noact%SFX%
rmdir /s /q C:\lief-build-2-py37-noact%SFX%

call conda deactivate
pushd %~dp0..\..
  mkdir C:\lief-build-2-py38-noact%SFX%
  conda build lief-feedstock -c defaults --python=3.8 --croot C:\lief-build-2-py38-noact%SFX% --no-build-id -m %CFG% 2>&1 | C:\msys32\usr\bin\tee.exe C:\lief-build-2-py38-noact%SFX%\build.log
  mkdir C:\lief-build-2-py37-noact%SFX%
  conda build lief-feedstock -c defaults --python=3.7 --croot C:\lief-build-2-py37-noact%SFX% --no-build-id -m %CFG% 2>&1 | C:\msys32\usr\bin\tee.exe C:\lief-build-2-py37-noact%SFX%\build.log
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
echo %PATH% > path.cmd.conda-activate
call build_env_setup.bat
echo %PATH% > path.cmd.build_env_setup.bat
call conda_build.bat
echo %PATH% > path.cmd.conda_build.bat
call install-liblief.bat
echo %PATH% > path.cmd.install-liblief.bat
call install-py-lief.bat
echo %ErrorLevel%
echo %PATH% > path.cmd.install-py-lief.bat
