@echo off
echo ========================================
echo Sound Switcher - Quick Start
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
echo Starting Sound Switcher...
echo ========================================
echo.

call npm run dev

