const {
  app,
  BrowserWindow,
  ipcMain,
  Tray,
  Menu,
  nativeImage,
} = require("electron");
const path = require("path");
const { exec } = require("child_process");
const util = require("util");
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
let playbackDevices = [];
let recordingDevices = [];

// Function to get playback devices
async function getPlaybackDevices() {
  try {
    const psScript = getResourcePath(
      path.join("scripts", "get-playback-devices.ps1")
    );
    const { stdout } = await execPromise(
      `powershell -ExecutionPolicy Bypass -File "${psScript}"`
    );
    return JSON.parse(stdout.trim());
  } catch (error) {
    console.error("Error getting playback devices:", error);
    return [];
  }
}

// Function to get recording devices
async function getRecordingDevices() {
  try {
    const psScript = getResourcePath(
      path.join("scripts", "get-recording-devices.ps1")
    );
    const { stdout } = await execPromise(
      `powershell -ExecutionPolicy Bypass -File "${psScript}"`
    );
    return JSON.parse(stdout.trim());
  } catch (error) {
    console.error("Error getting recording devices:", error);
    return [];
  }
}

// Function to set default playback device
async function setDefaultPlaybackDevice(deviceId) {
  try {
    const psScript = getResourcePath(
      path.join("scripts", "set-default-playback.ps1")
    );
    await execPromise(
      `powershell -ExecutionPolicy Bypass -File "${psScript}" -DeviceId "${deviceId}"`
    );
    return true;
  } catch (error) {
    console.error("Error setting playback device:", error);
    return false;
  }
}

// Function to set default recording device
async function setDefaultRecordingDevice(deviceId) {
  try {
    const psScript = getResourcePath(
      path.join("scripts", "set-default-recording.ps1")
    );
    await execPromise(
      `powershell -ExecutionPolicy Bypass -File "${psScript}" -DeviceId "${deviceId}"`
    );
    return true;
  } catch (error) {
    console.error("Error setting recording device:", error);
    return false;
  }
}

// Function to update tray menu with current devices
async function updateTrayMenu() {
  playbackDevices = await getPlaybackDevices();
  recordingDevices = await getRecordingDevices();

  const playbackMenuItems = playbackDevices.map((device) => ({
    label: device.name,
    type: "radio",
    checked: device.isDefault,
    click: async () => {
      await setDefaultPlaybackDevice(device.id);
      await updateTrayMenu(); // Refresh menu
    },
  }));

  const recordingMenuItems = recordingDevices.map((device) => ({
    label: device.name,
    type: "radio",
    checked: device.isDefault,
    click: async () => {
      await setDefaultRecordingDevice(device.id);
      await updateTrayMenu(); // Refresh menu
    },
  }));

  const contextMenu = Menu.buildFromTemplate([
    {
      label: "🔊 Playback Devices",
      enabled: false,
    },
    ...playbackMenuItems,
    { type: "separator" },
    {
      label: "🎤 Recording Devices",
      enabled: false,
    },
    ...recordingMenuItems,
    { type: "separator" },
    {
      label: "🔄 Refresh Devices",
      click: async () => {
        await updateTrayMenu();
      },
    },
    {
      label: "Show App",
      click: () => {
        if (mainWindow) {
          mainWindow.show();
          mainWindow.focus();
        }
      },
    },
    { type: "separator" },
    {
      label: "Quit",
      click: () => {
        app.isQuitting = true;
        app.quit();
      },
    },
  ]);

  tray.setContextMenu(contextMenu);
}

function createTray() {
  // Create tray icon
  const iconPath = path.join(__dirname, "tray-icon.png");
  const icon = nativeImage.createFromPath(iconPath);
  tray = new Tray(icon);

  tray.setToolTip("Sound Switcher");

  // Initial menu load
  updateTrayMenu();

  tray.on("click", () => {
    if (mainWindow) {
      if (mainWindow.isVisible()) {
        mainWindow.hide();
      } else {
        mainWindow.show();
        mainWindow.focus();
      }
    }
  });
}

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 380,
    height: 520,
    frame: false,
    icon: path.join(__dirname, "icon.ico"),
    resizable: false,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      contextIsolation: true,
      nodeIntegration: false,
    },
    autoHideMenuBar: true,
    minimizable: true,
    maximizable: false,
    show: false,
    titleBarStyle: "hidden",
    titleBarOverlay: false,
    backgroundColor: "#667eea",
  });

  // Load the app
  if (process.env.NODE_ENV === "development" || !app.isPackaged) {
    mainWindow.loadURL("http://localhost:5173");
    mainWindow.webContents.openDevTools();
  } else {
    mainWindow.loadFile(path.join(__dirname, "../dist/index.html"));
  }

  mainWindow.once("ready-to-show", () => {
    mainWindow.show();
  });

  // Minimize to tray instead of closing
  mainWindow.on("close", (event) => {
    if (!app.isQuitting) {
      event.preventDefault();
      mainWindow.hide();
      return false;
    }
  });
}

app.whenReady().then(() => {
  createTray();
  createWindow();

  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") {
    app.quit();
  }
});

// IPC Handlers for audio device management
ipcMain.handle("get-playback-devices", async () => {
  try {
    const psScript = getResourcePath(
      path.join("scripts", "get-playback-devices.ps1")
    );
    console.log("Executing PowerShell script:", psScript);
    const { stdout, stderr } = await execPromise(
      `powershell -ExecutionPolicy Bypass -File "${psScript}"`
    );

    if (stderr) {
      console.error("PowerShell stderr:", stderr);
    }

    console.log("PowerShell stdout:", stdout);

    if (!stdout || stdout.trim() === "") {
      return { error: "No output from PowerShell script" };
    }

    const result = JSON.parse(stdout.trim());
    return result;
  } catch (error) {
    console.error("Error getting playback devices:", error);
    return { error: error.message };
  }
});

ipcMain.handle("get-recording-devices", async () => {
  try {
    const psScript = getResourcePath(
      path.join("scripts", "get-recording-devices.ps1")
    );
    console.log("Executing PowerShell script:", psScript);
    const { stdout, stderr } = await execPromise(
      `powershell -ExecutionPolicy Bypass -File "${psScript}"`
    );

    if (stderr) {
      console.error("PowerShell stderr:", stderr);
    }

    console.log("PowerShell stdout:", stdout);

    if (!stdout || stdout.trim() === "") {
      return { error: "No output from PowerShell script" };
    }

    const result = JSON.parse(stdout.trim());
    return result;
  } catch (error) {
    console.error("Error getting recording devices:", error);
    return { error: error.message };
  }
});

ipcMain.handle("set-default-playback-device", async (event, deviceId) => {
  try {
    const psScript = getResourcePath(
      path.join("scripts", "set-default-playback.ps1")
    );
    await execPromise(
      `powershell -ExecutionPolicy Bypass -File "${psScript}" -DeviceId "${deviceId}"`
    );
    return { success: true };
  } catch (error) {
    console.error("Error setting playback device:", error);
    return { error: error.message };
  }
});

ipcMain.handle("set-default-recording-device", async (event, deviceId) => {
  try {
    const psScript = getResourcePath(
      path.join("scripts", "set-default-recording.ps1")
    );
    await execPromise(
      `powershell -ExecutionPolicy Bypass -File "${psScript}" -DeviceId "${deviceId}"`
    );
    return { success: true };
  } catch (error) {
    console.error("Error setting recording device:", error);
    return { error: error.message };
  }
});

// Window control handlers
ipcMain.handle("window-minimize", () => {
  if (mainWindow) {
    mainWindow.hide(); // Hide to tray instead of minimize
  }
});

ipcMain.handle("window-maximize", () => {
  if (mainWindow) {
    if (mainWindow.isMaximized()) {
      mainWindow.unmaximize();
    } else {
      mainWindow.maximize();
    }
  }
});

ipcMain.handle("window-close", () => {
  if (mainWindow) {
    mainWindow.hide(); // Hide to tray instead of close
  }
});

ipcMain.handle("window-is-maximized", () => {
  return mainWindow ? mainWindow.isMaximized() : false;
});
