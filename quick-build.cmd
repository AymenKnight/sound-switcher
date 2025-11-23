@echo off
echo Building Sound Switcher...
echo.

REM Clean previous builds
if exist dist rmdir /s /q dist
if exist dist-electron rmdir /s /q dist-electron

REM Build Vite project
echo Building Vite project...
call npx vite build
if %ERRORLEVEL% NEQ 0 (
    echo Vite build failed!
    pause
    exit /b 1
)

REM Build Electron app
echo Building Electron app...
call npx electron-builder --win --config.win.sign=null --publish=never
if %ERRORLEVEL% NEQ 0 (
    echo Electron build failed!
    pause
    exit /b 1
)

echo.
echo Build completed!
echo Run: dist-electron\win-unpacked\Sound Switcher.exe
pause
