# Building Sound Switcher

## Icon Generation

The app includes a custom icon with a speaker, microphone, and switching arrows. If you need to regenerate it:

```bash
npm run generate-icon
```

This will create:

- `icon.ico` - Main application icon
- `electron/icon.ico` - Icon for the packaged app
- `electron/tray-icon.png` - System tray icon (32x32 PNG)

The icon source is in `icon-source.svg` and can be edited if you want to customize it.

## Quick Build

### Option 1: Using the build script (Recommended)

```bash
build-simple.bat
```

### Option 2: Using npm

```bash
npm run build:win
```

### Option 3: Manual steps

```bash
# 1. Build the React app
npm run build

# 2. Package with Electron
npx @electron/packager . "Sound Switcher" --platform=win32 --arch=x64 --out=dist-packaged --overwrite --prune=true

# 3. Copy resources (PowerShell)
Copy-Item -Recurse -Force "electron\scripts" "dist-packaged\Sound Switcher-win32-x64\resources\"
Copy-Item -Recurse -Force "electron\tools" "dist-packaged\Sound Switcher-win32-x64\resources\"
```

## Running the Built App

After building, run:

```
dist-packaged\Sound Switcher-win32-x64\Sound Switcher.exe
```

## Features

- **Frameless Window**: Custom title bar with minimize, maximize, and close buttons
- **System Tray**: Close button minimizes to tray instead of closing the app
- **Quit from Tray**: Right-click the tray icon and select "Quit" to fully close the app

## Development Mode

To run in development mode:

```bash
npm run dev
```

This will start both the Vite dev server and Electron app with hot-reload enabled.
