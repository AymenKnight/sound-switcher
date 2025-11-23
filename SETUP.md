# Setup Guide for Sound Switcher

## Quick Start

Follow these steps to get the application running:

### 1. Install Dependencies

Open PowerShell or Command Prompt in the project directory and run:

```bash
npm install
```

This will install all required dependencies including:
- Electron
- React
- Vite
- electron-builder
- And other development tools

### 2. Run in Development Mode

To start the application in development mode:

```bash
npm run dev
```

This command will:
- Start the Vite development server on port 5173
- Launch the Electron application
- Enable hot-reload for React components
- Open DevTools for debugging

### 3. Build for Production

To create a distributable Windows application:

```bash
npm run build:win
```

The installer will be created in the `dist-electron` directory.

## Project Structure

```
sound-switcher/
├── electron/
│   ├── main.js              # Electron main process
│   ├── preload.js           # Preload script for IPC
│   └── scripts/             # PowerShell scripts for Windows audio APIs
│       ├── get-playback-devices.ps1
│       ├── get-recording-devices.ps1
│       ├── set-default-playback.ps1
│       ├── set-default-recording.ps1
│       ├── get-enhancements.ps1
│       └── set-enhancement.ps1
├── src/
│   ├── components/          # React components
│   │   ├── DeviceList.jsx
│   │   └── Enhancements.jsx
│   ├── App.jsx              # Main React component
│   ├── main.jsx             # React entry point
│   ├── index.css            # Global styles
│   └── electron.d.ts        # TypeScript definitions
├── index.html               # HTML template
├── package.json             # Project configuration
├── vite.config.js           # Vite configuration
└── README.md                # Documentation
```

## How the Application Works

### Audio Device Management

The application uses Windows COM APIs through PowerShell scripts:

1. **MMDeviceEnumerator** - Enumerates all audio devices
2. **CPolicyConfigClient** - Sets default audio devices
3. **Registry Access** - Reads and modifies audio enhancement settings

### IPC Communication

- **Main Process** (Electron): Executes PowerShell scripts and manages the application window
- **Renderer Process** (React): Displays the UI and handles user interactions
- **Preload Script**: Safely exposes IPC methods to the renderer process

### Security

The application uses Electron's security best practices:
- Context isolation enabled
- Node integration disabled in renderer
- Preload script for controlled IPC exposure

## Troubleshooting

### Issue: "Cannot find module" errors
**Solution**: Run `npm install` again to ensure all dependencies are installed.

### Issue: PowerShell execution policy errors
**Solution**: The scripts use `-ExecutionPolicy Bypass` flag, but if issues persist, run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue: Devices not appearing
**Solution**: 
- Ensure you have audio devices connected
- Check Windows Sound settings to verify devices are enabled
- Try running the app as administrator

### Issue: Cannot set default device
**Solution**: Run the application as administrator. Right-click the executable and select "Run as administrator".

### Issue: Enhancements not working
**Solution**: 
- Not all audio devices support enhancements
- Some enhancements require specific drivers
- Try running as administrator for registry write access

## Development Tips

### Hot Reload
When running in development mode, React components will hot-reload automatically. However, changes to Electron main process files require restarting the application.

### Debugging
- **React DevTools**: Automatically opens in development mode
- **Console Logs**: Check both the terminal and DevTools console
- **PowerShell Errors**: Check the terminal for PowerShell script errors

### Adding New Features

To add new audio device features:

1. Create a new PowerShell script in `electron/scripts/`
2. Add an IPC handler in `electron/main.js`
3. Expose the method in `electron/preload.js`
4. Update TypeScript definitions in `src/electron.d.ts`
5. Use the method in your React components

## Building for Distribution

The `electron-builder` configuration in `package.json` creates:
- NSIS installer for Windows
- Portable executable
- Auto-update support (if configured)

To customize the build:
- Edit the `build` section in `package.json`
- Add custom icons in the `build/` directory
- Configure code signing for production releases

## Next Steps

After setup, you can:
1. Customize the UI styling in `src/index.css`
2. Add more audio enhancement options
3. Implement keyboard shortcuts
4. Add system tray integration
5. Create custom device profiles
6. Add auto-start on Windows boot

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the PowerShell script outputs
3. Check Windows Event Viewer for system-level errors
4. Ensure Windows audio services are running

