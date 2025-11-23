import { useState, useEffect } from 'react';

function Enhancements({ device, onRefresh }) {
  const [enhancements, setEnhancements] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadEnhancements();
  }, [device]);

  const loadEnhancements = async () => {
    if (!device) return;
    
    setLoading(true);
    try {
      const result = await window.electronAPI.getDeviceEnhancements(device.id);
      setEnhancements(result);
    } catch (err) {
      console.error('Error loading enhancements:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleToggle = async (enhancement, currentValue) => {
    try {
      await window.electronAPI.setDeviceEnhancement(
        device.id,
        enhancement,
        !currentValue
      );
      await loadEnhancements();
      if (onRefresh) onRefresh();
    } catch (err) {
      console.error('Error toggling enhancement:', err);
    }
  };

  if (loading) {
    return (
      <div className="enhancements">
        <h3>Sound Enhancements</h3>
        <div className="loading">Loading enhancements...</div>
      </div>
    );
  }

  if (!enhancements || !enhancements.available) {
    return (
      <div className="enhancements">
        <h3>Sound Enhancements</h3>
        <p style={{ color: '#666', fontSize: '14px' }}>
          No enhancements available for this device
        </p>
      </div>
    );
  }

  return (
    <div className="enhancements">
      <h3>Sound Enhancements for {device.name}</h3>
      
      <div className="enhancement-item">
        <span>Bass Boost</span>
        <label className="switch">
          <input
            type="checkbox"
            checked={enhancements.bassBoost || false}
            onChange={() => handleToggle('bassBoost', enhancements.bassBoost)}
          />
          <span className="slider"></span>
        </label>
      </div>

      <div className="enhancement-item">
        <span>Virtual Surround</span>
        <label className="switch">
          <input
            type="checkbox"
            checked={enhancements.virtualSurround || false}
            onChange={() => handleToggle('virtualSurround', enhancements.virtualSurround)}
          />
          <span className="slider"></span>
        </label>
      </div>

      <div className="enhancement-item">
        <span>Room Correction</span>
        <label className="switch">
          <input
            type="checkbox"
            checked={enhancements.roomCorrection || false}
            onChange={() => handleToggle('roomCorrection', enhancements.roomCorrection)}
          />
          <span className="slider"></span>
        </label>
      </div>

      <div className="enhancement-item">
        <span>Loudness Equalization</span>
        <label className="switch">
          <input
            type="checkbox"
            checked={enhancements.loudnessEqualization || false}
            onChange={() => handleToggle('loudnessEqualization', enhancements.loudnessEqualization)}
          />
          <span className="slider"></span>
        </label>
      </div>
    </div>
  );
}

export default Enhancements;

