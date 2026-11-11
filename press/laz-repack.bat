@echo off
cd %~dp0

for /d %%i in (.\src\*) do (
	python -m lazurite pack %%i -o .\
)

timeout -t 1 >nul
pause