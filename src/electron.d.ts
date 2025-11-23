export interface AudioDevice {
  id: string;
  name: string;
  isDefault: boolean;
  state: number;
  type: 'playback' | 'recording';
}

export interface AudioEnhancements {
  bassBoost: boolean;
  virtualSurround: boolean;
  roomCorrection: boolean;
  loudnessEqualization: boolean;
  available: boolean;
  error?: string;
}

export interface ElectronAPI {
  getPlaybackDevices: () => Promise<AudioDevice[] | { error: string }>;
  getRecordingDevices: () => Promise<AudioDevice[] | { error: string }>;
  setDefaultPlaybackDevice: (deviceId: string) => Promise<{ success: boolean } | { error: string }>;
  setDefaultRecordingDevice: (deviceId: string) => Promise<{ success: boolean } | { error: string }>;
  getDeviceEnhancements: (deviceId: string) => Promise<AudioEnhancements>;
  setDeviceEnhancement: (deviceId: string, enhancement: string, value: boolean) => Promise<{ success: boolean } | { error: string }>;
}

declare global {
  interface Window {
    electronAPI: ElectronAPI;
  }
}

