const fs = require("fs");
const sharp = require("sharp");
const toIco = require("to-ico");

async function generateIcon() {
  try {
    console.log("Generating icon from SVG...");

    // Read the SVG file
    const svgBuffer = fs.readFileSync("icon-source.svg");

    // Generate PNG images at different sizes
    const sizes = [16, 32, 48, 64, 128, 256];
    const pngBuffers = await Promise.all(
      sizes.map((size) => sharp(svgBuffer).resize(size, size).png().toBuffer())
    );

    // Convert to ICO
    console.log("Converting to ICO format...");
    const icoBuffer = await toIco(pngBuffers);

    // Save the ICO file
    fs.writeFileSync("icon.ico", icoBuffer);

    // Also save to electron folder
    if (!fs.existsSync("electron")) {
      fs.mkdirSync("electron");
    }
    fs.writeFileSync("electron/icon.ico", icoBuffer);

    // Generate PNG for tray icon (16x16 and 32x32)
    await sharp(svgBuffer)
      .resize(32, 32)
      .png()
      .toFile("electron/tray-icon.png");

    console.log("✓ Icon generated successfully!");
    console.log("  - icon.ico (root)");
    console.log("  - electron/icon.ico");
    console.log("  - electron/tray-icon.png");
  } catch (error) {
    console.error("Error generating icon:", error);
    process.exit(1);
  }
}

generateIcon();
