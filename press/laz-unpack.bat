@echo off
cd %~dp0

for %%i in (.\*.material.bin) do (
	python -m lazurite unpack %%i -o .\src\
)

timeout -t 1 >nul
pause