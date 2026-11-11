@echo off
rem ===========================================================================
rem  all-packing.bat [version suffix]
rem
rem  Builds every subpack of the RedstoneTech shader, assembles a complete
rem  resource pack from the pack\ folder and writes
rem  build\RedstoneTechShader[_<suffix>].mcpack
rem
rem  X-ray is listed in pack\manifest.json but is not compiled here yet, so the
rem  X-ray subpack ships without a material override (a warning is printed).
rem ===========================================================================
setlocal EnableExtensions
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

set "SUFFIX=%~1"
set "PACKNAME=RedstoneTechShader"
if not "%SUFFIX%"=="" set "PACKNAME=RedstoneTechShader_%SUFFIX%"

rem  Optional 2nd argument: press -> shrink every compiled bin (tools\press-bin.ps1).
set "PRESS_FLAG="
if /I "%~2"=="press" set "PRESS_FLAG=press"

setlocal EnableDelayedExpansion
set "FAILED="

call :build Default 3
call :build LightOverlay 2
call :build NightVision 1
call :build NightVision-LightOverlay 0
call :build NoChunkBorders 7
call :build NoChunkBorders-LightOverlay 6
call :build NoChunkBorders-NightVision 5
call :build NoChunkBorders-NightVision-LightOverlay 4
call :build X-ray 8

if defined FAILED (
    echo.
    echo [ERROR] one or more subpacks failed to compile, aborting assembly.
    endlocal
    exit /b 1
)

echo.
echo ------assembling resource pack------
set "PACKDIR=%ROOT%\build\pack"
if exist "%PACKDIR%" rmdir /s /q "%PACKDIR%"
robocopy "%ROOT%\pack" "%PACKDIR%" /MIR /NFL /NDL /NJH /NJS /NP /R:2 /W:2 >nul
if errorlevel 8 (
    echo [ERROR] failed to copy pack resources.
    endlocal
    exit /b 1
)

for %%V in (Default LightOverlay NightVision NightVision-LightOverlay NoChunkBorders NoChunkBorders-LightOverlay NoChunkBorders-NightVision NoChunkBorders-NightVision-LightOverlay X-ray) do (
    set "BIN=%ROOT%\build\bin\%%V\RenderChunk.material.bin"
    if not exist "!BIN!" (
        echo [ERROR] missing !BIN!
        set "FAILED=1"
    ) else (
        if not exist "%PACKDIR%\subpacks\%%V\renderer\materials" mkdir "%PACKDIR%\subpacks\%%V\renderer\materials"
        copy /y "!BIN!" "%PACKDIR%\subpacks\%%V\renderer\materials\RenderChunk.material.bin" >nul
        echo   subpacks\%%V
    )
)

if defined FAILED (
    echo [ERROR] assembly aborted.
    endlocal
    exit /b 1
)

echo.
echo ------compressing------
set "PY=py"
where py >nul 2>&1 || set "PY=python"
%PY% "%ROOT%\tools\make-mcpack.py" "%PACKDIR%" "%ROOT%\build\%PACKNAME%.mcpack"
if errorlevel 1 (
    echo [ERROR] compression failed.
    endlocal
    exit /b 1
)
copy /y "%ROOT%\build\%PACKNAME%.mcpack" "%ROOT%\build\%PACKNAME%.zip" >nul

echo.
echo ------done------
echo   %ROOT%\build\%PACKNAME%.mcpack
endlocal
exit /b 0

:build
call "%ROOT%\packing.bat" %1 %2 %PRESS_FLAG%
if errorlevel 1 (
    set "FAILED=1"
    echo [ERROR] %1 failed
)
exit /b 0
