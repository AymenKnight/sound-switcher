import { useState, useEffect } from "react";

function Enhancements({ device, onRefresh }) {
  const [enhancements, setEnhancements] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadEnhancements();
  }, [device]);

  const loadEnhancements = async () => {
    if (!device) return;

    setLoading(true);
    setError(null);
    try {
      const result = await window.electronAPI.getDeviceEnhancements(device.id);
      if (result.error) {
        setError(result.error);
      } else {
        setEnhancements(result);
      }
    } catch (err) {
      console.error("Error loading enhancements:", err);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleToggle = async (
    enhancementKey,
    enhancementGuid,
    currentValue
  ) => {
    try {
      const result = await window.electronAPI.setDeviceEnhancement(
        device.id,
        enhancementKey,
        !currentValue
      );

      if (result.error) {
        setError(
          "⚠️ Administrator privileges required. Please run the app as administrator to modify enhancements."
        );
      } else {
        setError(null);
        await loadEnhancements();
        if (onRefresh) onRefresh();
      }
    } catch (err) {
      console.error("Error toggling enhancement:", err);
      setError(
        "⚠️ Administrator privileges required. Please run the app as administrator to modify enhancements."
      );
    }
  };

  if (loading) {
    return (
      <div className="enhancements">
        <h3>🎛️ Audio Enhancements</h3>
        <div className="loading">Loading...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="enhancements">
        <h3>🎛️ Audio Enhancements</h3>
        <p className="enhancement-error">{error}</p>
      </div>
    );
  }

  if (!enhancements || !enhancements.available) {
    return (
      <div className="enhancements">
        <h3>🎛️ Audio Enhancements</h3>
        <p className="enhancement-unavailable">
          No enhancements available for this device
        </p>
      </div>
    );
  }

  // Get the list of enhancements from the result
  const enhancementsList = enhancements.enhancements || [];
  const allDisabled = enhancements.allDisabled || false;

  // Icon mapping for known enhancements
  const iconMap = {
    virtualSurround: "🎧",
    speakerFill: "🔊",
    headphoneVirtualization: "🎵",
    bassBoost: "🔉",
    loudnessEqualization: "📊",
    roomCorrection: "🏠",
  };

  if (enhancementsList.length === 0) {
    return (
      <div className="enhancements">
        <h3>🎛️ Audio Enhancements</h3>
        <p className="enhancement-unavailable">
          No enhancements detected for this device
        </p>
      </div>
    );
  }

  return (
    <div className="enhancements">
      <h3>🎛️ Audio Enhancements</h3>

      {allDisabled && (
        <div className="enhancement-warning">
          ⚠️ All enhancements are disabled in Windows Sound settings
        </div>
      )}

      <div className="enhancement-list">
        {enhancementsList.map((enhancement) => {
          const isEnabled = enhancement.enabled && !allDisabled;
          const icon = iconMap[enhancement.key] || "🎛️";

          return (
            <div
              key={enhancement.guid}
              className="enhancement-item"
              title={enhancement.description || enhancement.name}
            >
              <span className="enhancement-label">
                <span className="enhancement-icon">{icon}</span>
                <span>
                  {enhancement.name}
                  <span
                    className={`enhancement-status ${
                      isEnabled ? "active" : "inactive"
                    }`}
                  >
                    {isEnabled ? " • On" : " • Off"}
                  </span>
                </span>
              </span>
              <label className="switch">
                <input
                  type="checkbox"
                  checked={isEnabled}
                  onChange={() =>
                    handleToggle(enhancement.key, enhancement.guid, isEnabled)
                  }
                  disabled={allDisabled}
                />
                <span className="slider"></span>
              </label>
            </div>
          );
        })}
      </div>
      <p className="enhancement-note">
        💡 Requires administrator privileges to modify. Click any toggle to
        enable/disable.
      </p>
    </div>
  );
}

export default Enhancements;
