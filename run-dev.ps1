Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Sound Switcher - Development Mode" -ForegroundColor Cyan
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
Write-Host "Starting Sound Switcher in Development Mode..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will:" -ForegroundColor Yellow
Write-Host "1. Start Vite dev server on http://localhost:5173" -ForegroundColor Yellow
Write-Host "2. Launch Electron desktop window" -ForegroundColor Yellow
Write-Host "3. Enable hot reload for development" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Ctrl+C to stop the application" -ForegroundColor Yellow
Write-Host ""

# Start development mode
npm run dev
