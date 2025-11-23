const { app, BrowserWindow, ipcMain, Tray, Menu, nativeImage } = require('electron');
const path = require('path');
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

// Helper function to get the correct path for scripts and tools
function getResourcePath(relativePath) {
  if (app.isPackaged) {
    // In production, resources are in the resources folder
    return path.join(process.resourcesPath, relativePath);
  } else {
    // In development, resources are in the electron folder
    return path.join(__dirname, relativePath);
  }
}

let mainWindow;
let tray;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 900,
    height: 700,
    frame: false,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
    autoHideMenuBar: true,
    resizable: true,
    minimizable: true,
    maximizable: true,
    show: false, // Don't show until ready
    titleBarStyle: 'hidden',
    titleBarOverlay: false,
  });

  // Load the app
  if (process.env.NODE_ENV === 'development' || !app.isPackaged) {
    mainWindow.loadURL('http://localhost:5173');
    mainWindow.webContents.openDevTools();
  } else {
    mainWindow.loadFile(path.join(__dirname, '../dist/index.html'));
  }
}

app.whenReady().then(() => {
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

// IPC Handlers for audio device management
ipcMain.handle('get-playback-devices', async () => {
  try {
    const psScript = getResourcePath(path.join('scripts', 'get-playback-devices.ps1'));
    console.log('Executing PowerShell script:', psScript);
    const { stdout, stderr } = await execPromise(`powershell -ExecutionPolicy Bypass -File "${psScript}"`);

    if (stderr) {
      console.error('PowerShell stderr:', stderr);
    }

    console.log('PowerShell stdout:', stdout);

    if (!stdout || stdout.trim() === '') {
      return { error: 'No output from PowerShell script' };
    }

    const result = JSON.parse(stdout.trim());
    return result;
  } catch (error) {
    console.error('Error getting playback devices:', error);
    return { error: error.message };
  }
});

ipcMain.handle('get-recording-devices', async () => {
  try {
    const psScript = getResourcePath(path.join('scripts', 'get-recording-devices.ps1'));
    console.log('Executing PowerShell script:', psScript);
    const { stdout, stderr } = await execPromise(`powershell -ExecutionPolicy Bypass -File "${psScript}"`);

    if (stderr) {
      console.error('PowerShell stderr:', stderr);
    }

    console.log('PowerShell stdout:', stdout);

    if (!stdout || stdout.trim() === '') {
      return { error: 'No output from PowerShell script' };
    }

    const result = JSON.parse(stdout.trim());
    return result;
  } catch (error) {
    console.error('Error getting recording devices:', error);
    return { error: error.message };
  }
});

ipcMain.handle('set-default-playback-device', async (event, deviceId) => {
  try {
    const psScript = getResourcePath(path.join('scripts', 'set-default-playback.ps1'));
    await execPromise(`powershell -ExecutionPolicy Bypass -File "${psScript}" -DeviceId "${deviceId}"`);
    return { success: true };
  } catch (error) {
    console.error('Error setting playback device:', error);
    return { error: error.message };
  }
});

ipcMain.handle('set-default-recording-device', async (event, deviceId) => {
  try {
    const psScript = getResourcePath(path.join('scripts', 'set-default-recording.ps1'));
    await execPromise(`powershell -ExecutionPolicy Bypass -File "${psScript}" -DeviceId "${deviceId}"`);
    return { success: true };
  } catch (error) {
    console.error('Error setting recording device:', error);
    return { error: error.message };
  }
});

ipcMain.handle('get-device-enhancements', async (event, deviceId) => {
  try {
    const psScript = getResourcePath(path.join('scripts', 'get-enhancements.ps1'));
    const { stdout } = await execPromise(`powershell -ExecutionPolicy Bypass -File "${psScript}" -DeviceId "${deviceId}"`);
    return JSON.parse(stdout);
  } catch (error) {
    console.error('Error getting enhancements:', error);
    return { error: error.message };
  }
});

ipcMain.handle('set-device-enhancement', async (event, deviceId, enhancement, value) => {
  try {
    const psScript = getResourcePath(path.join('scripts', 'set-enhancement.ps1'));
    await execPromise(`powershell -ExecutionPolicy Bypass -File "${psScript}" -DeviceId "${deviceId}" -Enhancement "${enhancement}" -Value ${value}`);
    return { success: true };
  } catch (error) {
    console.error('Error setting enhancement:', error);
    return { error: error.message };
  }
});

