@echo off
pause

for /r .\src\ %%i in (*.Fragment.glsl) do (
	glslangValidator.exe "%%i" --aml -G -Od -S frag -o ".\tmp.spirv"
	spirv-opt.exe ".\tmp.spirv" -Os -o ".\tmp.spirv" 
	spirv-cross.exe ".\tmp.spirv" --version 310es --output "tmp.glsl"
	if not exist .\tmp.glsl goto :error
	copy /y tmp.glsl "%%i" > nul
	del tmp.spirv tmp.glsl
)
echo.

for /r .\src\ %%i in (*.Vertex.glsl) do (
	glslangValidator.exe "%%i" --aml -G -Od -S vert -o ".\tmp.spirv"
	spirv-opt.exe ".\tmp.spirv" -Os -o ".\tmp.spirv" 
	spirv-cross.exe ".\tmp.spirv" --version 310es --output "tmp.glsl"
	if not exist .\tmp.glsl goto :error
	copy /y tmp.glsl "%%i" > nul
	del tmp.spirv tmp.glsl
)
echo.

for /r .\src\ %%i in (*.Compute.glsl) do (
	glslangValidator.exe "%%i" --aml -G -Od -S comp -o ".\tmp.spirv"
	spirv-opt.exe ".\tmp.spirv" -Os -o ".\tmp.spirv" 
	spirv-cross.exe ".\tmp.spirv" --version 310es --output "tmp.glsl"
	if not exist .\tmp.glsl goto :error
	copy /y tmp.glsl "%%i" > nul
	del tmp.spirv tmp.glsl
)
echo.

goto :done

:error
echo.
echo Process failed.
echo.
pause
goto :EOF

:done
echo.
echo All Done.
echo.
timeout -t 1 >nul
pause 








