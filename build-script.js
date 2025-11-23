const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🔧 Sound Switcher Build Script');
console.log('================================');

try {
  // Clean previous builds
  console.log('🧹 Cleaning previous builds...');
  if (fs.existsSync('dist')) {
    fs.rmSync('dist', { recursive: true, force: true });
    console.log('✅ Removed dist folder');
  }
  if (fs.existsSync('dist-electron')) {
    fs.rmSync('dist-electron', { recursive: true, force: true });
    console.log('✅ Removed dist-electron folder');
  }

  // Build Vite project
  console.log('🏗️ Building Vite project...');
  execSync('npx vite build', { stdio: 'inherit' });
  console.log('✅ Vite build completed');

  // Build Electron app
  console.log('📦 Building Electron app...');
  execSync('npx electron-builder --win --config.win.sign=null --publish=never', { stdio: 'inherit' });
  console.log('✅ Electron build completed');

  console.log('');
  console.log('🎉 Build completed successfully!');
  console.log('📍 Your app is ready at: dist-electron\\win-unpacked\\Sound Switcher.exe');

} catch (error) {
  console.error('❌ Build failed:', error.message);
  process.exit(1);
}
