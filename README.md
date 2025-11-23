# Sound Switcher

A desktop application built with Electron and React for managing audio devices on Windows 10/11.

## Features

- 🔊 **Switch Default Playback Devices** - Easily change your default audio output device
- 🎤 **Switch Default Recording Devices** - Manage your microphone and recording devices
- 🎛️ **Sound Enhancements** - Control audio enhancements like bass boost, virtual surround, and more
- 💻 **Native Windows Integration** - Uses Windows COM APIs for reliable device management
- 🎨 **Modern UI** - Clean and intuitive interface built with React

## Prerequisites

- Windows 10 or Windows 11
- Node.js (v16 or higher)
- npm or yarn

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd sound-switcher
```

2. Install dependencies:
```bash
npm install
```

## Development

Run the application in development mode:

```bash
npm run dev
```

This will start both the Vite dev server and Electron application.

## Building

Build the application for Windows:

```bash
npm run build:win
```

The built application will be available in the `dist-electron` directory.

## How It Works

The application uses:
- **Electron** for the desktop application framework
- **React** for the user interface
- **PowerShell scripts** to interact with Windows audio APIs via COM objects
- **MMDeviceEnumerator** COM interface for device enumeration
- **CPolicyConfigClient** COM interface for setting default devices

## Permissions

The application requires:
- PowerShell execution permissions (handled automatically)
- Registry read access for audio device properties
- Registry write access for audio enhancements (requires admin for some operations)

## Troubleshooting

If you encounter issues:

1. **Devices not showing**: Ensure you have active audio devices connected
2. **Cannot set default device**: Try running the application as administrator
3. **Enhancements not working**: Some devices don't support all enhancement features

## License

MIT

