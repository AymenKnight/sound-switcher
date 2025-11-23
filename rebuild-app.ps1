Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Sound Switcher - Complete Rebuild" -ForegroundColor Cyan
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
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 1: Cleaning everything..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Clean everything
if (Test-Path "node_modules") {
    Write-Host "Removing node_modules..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force "node_modules"
}
if (Test-Path "dist") {
    Write-Host "Removing dist..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force "dist"
}
if (Test-Path "dist-electron") {
    Write-Host "Removing dist-electron..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force "dist-electron"
}
if (Test-Path "package-lock.json") {
    Write-Host "Removing package-lock.json..." -ForegroundColor Yellow
    Remove-Item -Force "package-lock.json"
}

Write-Host "Clean completed!" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 2: Fresh install..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Fresh install
Write-Host "Installing dependencies..." -ForegroundColor Yellow
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to install dependencies!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Dependencies installed successfully!" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 3: Building Vite project..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Build Vite project
npx vite build
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Vite build failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Vite build completed!" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 4: Building Electron app..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Build Electron app with verbose output
npx electron-builder --win --config.win.sign=null --publish=never
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Electron build failed!" -ForegroundColor Red
    Write-Host "Trying alternative build method..." -ForegroundColor Yellow
    
    # Try building just the portable version
    npx electron-builder --win portable --config.win.sign=null --publish=never
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Alternative build also failed!" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Rebuild completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check what was built
if (Test-Path "dist-electron\win-unpacked\Sound Switcher.exe") {
    Write-Host "✅ Unpacked executable: dist-electron\win-unpacked\Sound Switcher.exe" -ForegroundColor Green
}
if (Test-Path "dist-electron\*.exe") {
    $installers = Get-ChildItem "dist-electron\*.exe"
    foreach ($installer in $installers) {
        Write-Host "✅ Installer: $($installer.Name)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Your desktop app should now work properly!" -ForegroundColor Green
Write-Host "Try running: dist-electron\win-unpacked\Sound Switcher.exe" -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to exit"
