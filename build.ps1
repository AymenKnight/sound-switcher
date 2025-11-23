Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Sound Switcher - Building Desktop App" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check for Node.js
Write-Host "Checking for Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Node.js is not installed!" -ForegroundColor Red
    Write-Host "Please install Node.js from https://nodejs.org/" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Check for dependencies
Write-Host "Checking for dependencies..." -ForegroundColor Yellow
if (!(Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to install dependencies!" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
} else {
    Write-Host "Dependencies already installed." -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Cleaning previous builds..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Clean previous builds
if (Test-Path "dist") {
    Remove-Item -Recurse -Force "dist"
    Write-Host "Cleaned dist folder" -ForegroundColor Green
}
if (Test-Path "dist-electron") {
    Remove-Item -Recurse -Force "dist-electron"
    Write-Host "Cleaned dist-electron folder" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building Vite project..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Build Vite project
npx vite build
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Vite build failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Vite build completed successfully!" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building Electron app..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Build Electron app
npx electron-builder --win --config.win.sign=null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Electron build failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your desktop app is ready!" -ForegroundColor Green
Write-Host "Location: dist-electron\win-unpacked\Sound Switcher.exe" -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to exit"
