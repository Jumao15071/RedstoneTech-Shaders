@echo off
rem ===========================================================================
rem  packing.bat <subpack name> <SUBPACKS index>
rem
rem  Compiles one subpack of RedstoneTechShaders and writes
rem  build\bin\<subpack name>\RenderChunk.material.bin
rem
rem  SUBPACKS index (see RenderChunk\shaders\RCN_config.h):
rem    0 NightVision-LightOverlay            4 NoChunkBorders-NightVision-LightOverlay
rem    1 NightVision                         5 NoChunkBorders-NightVision
rem    2 LightOverlay                        6 NoChunkBorders-LightOverlay
rem    3 Default                             7 NoChunkBorders
rem    8 X-ray  =  SUBPACKS 0，但改用 RenderChunkXray 工程（fragment_xray.sc）
rem ===========================================================================
setlocal EnableExtensions
set "NAME=%~1"
set "IDX=%~2"

if "%NAME%"=="" goto :usage
if "%IDX%"=="" goto :usage

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "SRC=%ROOT%\RedstoneTechShaders"
set "WORK=%ROOT%\build\work"
set "OUT=%ROOT%\build\bin\%NAME%"
set "LAZURITE=%ROOT%\tools\lazurite-0.12.0"

rem --- locate the vanilla material library (schema source for the merge) ------
rem  local.env.bat is machine-specific and not committed; use it to point at a
rem  vanilla material folder outside the repo.
if exist "%ROOT%\local.env.bat" call "%ROOT%\local.env.bat"
set "VANILLA=%REDSTONE_VANILLA_MATERIALS%"
if not exist "%VANILLA%\RenderChunk.material.bin" set "VANILLA=%ROOT%\..\Vanilla\materials"
if not exist "%VANILLA%\RenderChunk.material.bin" set "VANILLA=%ROOT%\..\vanilla\materials"
if not exist "%VANILLA%\RenderChunk.material.bin" set "VANILLA=%ROOT%\vanilla\materials"
if not exist "%VANILLA%\RenderChunk.material.bin" goto :no_vanilla

rem --- python + lazurite ------------------------------------------------------
set "PY=py"
where py >nul 2>&1 || set "PY=python"
where %PY% >nul 2>&1 || goto :no_python

set "PYTHONPATH=%LAZURITE%;%PYTHONPATH%"
%PY% -c "import lazurite, pyjson5, myers, pcpp, Crypto, sympy" >nul 2>&1
if errorlevel 1 goto :no_deps

echo ------prepare %NAME% (SUBPACKS=%IDX%)------
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\tools\prepare-work.ps1" -Src "%SRC%" -Work "%WORK%" -Vanilla "%VANILLA%"
if errorlevel 1 goto :failed

if not exist "%OUT%" mkdir "%OUT%"

echo ------compiling %NAME%------
rem  X-ray is not a macro switch: it is SUBPACKS 0 built from the RenderChunkXray
rem  project, which uses fragment_xray.sc instead of fragment.sc.
set "MAT=RenderChunk"
set "DEFS=SUBPACKS=%IDX%"
if "%IDX%"=="8" set "MAT=RenderChunkXray"
if "%IDX%"=="8" set "DEFS=SUBPACKS=0"
pushd "%WORK%"
%PY% -m lazurite build . -o "%OUT%" -m %MAT% -d %DEFS%
set "RC=%ERRORLEVEL%"
popd
if not "%RC%"=="0" goto :failed

rem  lazurite names the output after the material folder; the pack expects RenderChunk.
if not "%MAT%"=="RenderChunk" (
    if exist "%OUT%\%MAT%.material.bin" move /y "%OUT%\%MAT%.material.bin" "%OUT%\RenderChunk.material.bin" >nul
)

rem  Optional 3rd argument: press -> shrink the ESSL shaders (see tools\press-bin.ps1).
if /I "%~3"=="press" (
    echo ------pressing %NAME%------
    powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\tools\press-bin.ps1" -Bin "%OUT%\RenderChunk.material.bin"
    if errorlevel 1 goto :failed
)

echo ------compile completed: %OUT%\RenderChunk.material.bin------
exit /b 0

:no_vanilla
echo [ERROR] vanilla material library not found.
echo         Set the REDSTONE_VANILLA_MATERIALS environment variable to the folder
echo         that contains the vanilla *.material.bin files, or place it at
echo         "%ROOT%\..\Vanilla\materials".
exit /b 1

:no_python
echo [ERROR] Python 3 was not found on PATH.
exit /b 1

:no_deps
echo [ERROR] Missing Python dependencies.
echo         Install them with:  pip install pyjson5 myers pcpp pycryptodome sympy
exit /b 1

:failed
echo [ERROR] build failed for %NAME%
exit /b 1

:usage
echo Usage: packing.bat ^<subpack name^> ^<SUBPACKS index^>
echo Example: packing.bat Default 3
exit /b 1
