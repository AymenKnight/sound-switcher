import React from 'react';

function DeviceList({ devices, onDeviceSelect, type }) {
  if (!devices || devices.length === 0) {
    return (
      <div className="loading">
        No {type} devices found
      </div>
    );
  }

  return (
    <div className="device-list">
      {devices.map((device) => (
        <div
          key={device.id}
          className={`device-card ${device.isDefault ? 'active' : ''}`}
          onClick={() => onDeviceSelect(device)}
        >
          <div className="device-icon">
            {type === 'playback' ? '🔊' : '🎤'}
          </div>
          <div className="device-info">
            <div className="device-name">{device.name}</div>
            <div className="device-status">
              {device.state === 1 ? 'Active' : 'Inactive'}
            </div>
          </div>
          {device.isDefault && (
            <div className="device-badge">Default</div>
          )}
        </div>
      ))}
    </div>
  );
}

export default DeviceList;

