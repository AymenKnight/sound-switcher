function TitleBar() {
  const handleMinimize = () => {
    window.electronAPI.windowMinimize();
  };

  const handleClose = () => {
    window.electronAPI.windowClose();
  };

  return (
    <div className="title-bar">
      <div className="title-bar-drag">
        <span className="app-title">🔊 Sound Switcher</span>
      </div>
      <div className="title-bar-controls">
        <button
          className="title-bar-button minimize"
          onClick={handleMinimize}
          title="Minimize to tray"
        >
          <svg width="12" height="12" viewBox="0 0 12 12">
            <rect x="0" y="5" width="12" height="2" fill="currentColor" />
          </svg>
        </button>
        <button
          className="title-bar-button close"
          onClick={handleClose}
          title="Hide to tray (Right-click tray icon to quit)"
        >
          <svg width="12" height="12" viewBox="0 0 12 12">
            <path
              d="M0,0 L12,12 M12,0 L0,12"
              stroke="currentColor"
              strokeWidth="1.5"
            />
          </svg>
        </button>
      </div>
    </div>
  );
}

export default TitleBar;
