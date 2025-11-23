@echo off
echo ========================================
echo Sound Switcher - Building Desktop App
echo ========================================
echo.

echo Step 1: Building Vite project...
call npm run build
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Vite build failed!
    pause
    exit /b 1
)

echo.
echo Step 2: Cleaning previous build...
if exist "dist-packaged" rmdir /s /q "dist-packaged"

echo.
echo Step 3: Packaging with Electron...
call npx @electron/packager . "Sound Switcher" --platform=win32 --arch=x64 --out=dist-packaged --overwrite --prune=true --icon=electron/icon.ico
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Electron packaging failed!
    pause
    exit /b 1
)

echo.
echo Step 4: Copying PowerShell scripts and tools...
xcopy /E /I /Y "electron\scripts" "dist-packaged\Sound Switcher-win32-x64\resources\scripts\"
xcopy /E /I /Y "electron\tools" "dist-packaged\Sound Switcher-win32-x64\resources\tools\"

echo.
echo ========================================
echo Build completed successfully!
echo ========================================
echo.
echo Your app is ready at:
echo dist-packaged\Sound Switcher-win32-x64\Sound Switcher.exe
echo.
pause
