const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("electronAPI", {
  getPlaybackDevices: () => ipcRenderer.invoke("get-playback-devices"),
  getRecordingDevices: () => ipcRenderer.invoke("get-recording-devices"),
  setDefaultPlaybackDevice: (deviceId) =>
    ipcRenderer.invoke("set-default-playback-device", deviceId),
  setDefaultRecordingDevice: (deviceId) =>
    ipcRenderer.invoke("set-default-recording-device", deviceId),
  getDeviceEnhancements: (deviceId) =>
    ipcRenderer.invoke("get-device-enhancements", deviceId),
  setDeviceEnhancement: (deviceId, enhancement, value) =>
    ipcRenderer.invoke("set-device-enhancement", deviceId, enhancement, value),
  // Window controls
  windowMinimize: () => ipcRenderer.invoke("window-minimize"),
  windowMaximize: () => ipcRenderer.invoke("window-maximize"),
  windowClose: () => ipcRenderer.invoke("window-close"),
  windowIsMaximized: () => ipcRenderer.invoke("window-is-maximized"),
});
