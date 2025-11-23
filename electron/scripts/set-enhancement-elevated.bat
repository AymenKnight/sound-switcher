@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0set-enhancement.ps1" -DeviceId "%~1" -Enhancement "%~2" -Value %~3
