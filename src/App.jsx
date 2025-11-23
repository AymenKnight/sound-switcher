import { useState, useEffect } from "react";
import TitleBar from "./components/TitleBar";
import DeviceList from "./components/DeviceList";

function App() {
  const [activeTab, setActiveTab] = useState("playback");
  const [playbackDevices, setPlaybackDevices] = useState([]);
  const [recordingDevices, setRecordingDevices] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadDevices();
  }, []);

  const loadDevices = async () => {
    setLoading(true);
    setError(null);

    try {
      const [playback, recording] = await Promise.all([
        window.electronAPI.getPlaybackDevices(),
        window.electronAPI.getRecordingDevices(),
      ]);

      if (playback.error) {
        throw new Error(playback.error);
      }
      if (recording.error) {
        throw new Error(recording.error);
      }

      setPlaybackDevices(Array.isArray(playback) ? playback : []);
      setRecordingDevices(Array.isArray(recording) ? recording : []);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleDeviceSelect = async (device) => {
    try {
      if (activeTab === "playback") {
        await window.electronAPI.setDefaultPlaybackDevice(device.id);
      } else {
        await window.electronAPI.setDefaultRecordingDevice(device.id);
      }

      await loadDevices(); // Reload to update default status
    } catch (err) {
      setError(err.message);
    }
  };

  const currentDevices =
    activeTab === "playback" ? playbackDevices : recordingDevices;

  return (
    <div className="app">
      <TitleBar />
      <div className="header">
        <h1>Sound Switcher</h1>
        <p>Quick audio device switching</p>
      </div>

      <div className="content">
        {error && (
          <div className="error">
            <strong>Error:</strong> {error}
          </div>
        )}

        <div className="tabs">
          <button
            className={`tab ${activeTab === "playback" ? "active" : ""}`}
            onClick={() => setActiveTab("playback")}
          >
            🔊 Playback Devices
          </button>
          <button
            className={`tab ${activeTab === "recording" ? "active" : ""}`}
            onClick={() => setActiveTab("recording")}
          >
            🎤 Recording Devices
          </button>
        </div>

        {loading ? (
          <div className="loading">Loading devices...</div>
        ) : (
          <>
            <DeviceList
              devices={currentDevices}
              onDeviceSelect={handleDeviceSelect}
              type={activeTab}
            />
          </>
        )}
      </div>
    </div>
  );
}

export default App;
