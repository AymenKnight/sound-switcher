@echo off
echo ========================================
echo Sound Switcher - Building Desktop App
echo ========================================
echo.

echo Checking for Node.js...
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Node.js is not installed!
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

echo Node.js found!
node --version
echo.

echo Checking for dependencies...
if not exist "node_modules\" (
    echo Installing dependencies...
    call npm install
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Failed to install dependencies!
        pause
        exit /b 1
    )
) else (
    echo Dependencies already installed.
)

echo.
echo ========================================
echo Cleaning previous builds...
echo ========================================
echo.

if exist "dist\" rmdir /s /q "dist"
if exist "dist-electron\" rmdir /s /q "dist-electron"

echo.
echo ========================================
echo Building Vite project...
echo ========================================
echo.

call npx vite build
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Vite build failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Building Electron app...
echo ========================================
echo.

call npx electron-builder --win --config.win.sign=null
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Electron build failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Build completed successfully!
echo ========================================
echo.
echo Your desktop app installer is ready in the dist-electron folder.
echo You can run: dist-electron\win-unpacked\Sound Switcher.exe
echo.
pause
