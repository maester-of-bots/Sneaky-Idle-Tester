# How to Add Your App Icon to Your iOS Project

## Quick Overview
I've created a cute sheep-themed app icon for your farm game! It features a happy sheep, wool, coins (kr), and a pastoral background.

## Files Created
- **sheep_farm_icon.png** - 1024x1024 PNG (ready to use!)
- **sheep_farm_icon.svg** - Vector source file (for future edits)

---

## Method 1: Using Xcode's App Icon Set (Recommended)

### Step 1: Open Your Project in Xcode
1. Open your SheepFarm project in Xcode
2. In the Project Navigator (left sidebar), find the **Assets.xcassets** folder
3. Click on it to open the asset catalog

### Step 2: Find AppIcon
Inside Assets.xcassets, you'll see an **AppIcon** entry. Click on it.

You'll see a grid of empty icon slots for different sizes (iPhone, iPad, etc.)

### Step 3: Add Your Icon

**Option A: Drag & Drop (Easiest)**
1. Download the `sheep_farm_icon.png` file
2. Drag the PNG file directly onto the **1024x1024** slot labeled "App Store"
3. Xcode will automatically generate all other sizes!

**Option B: Manual Selection**
1. Click on the **1024x1024** slot
2. In the Attributes Inspector (right sidebar), click "+" or find the file path option
3. Select your `sheep_farm_icon.png` file
4. Xcode will automatically generate all other sizes!

### Step 4: Build and Run
That's it! When you build and run your app, you'll see the new icon on the home screen.

---

## Method 2: Using Asset Catalog Generator (Alternative)

If you want more control or Xcode isn't auto-generating all sizes:

### Option 1: Use an Online Tool
1. Go to https://appicon.co/ or https://www.appicon.build/
2. Upload your `sheep_farm_icon.png` (1024x1024)
3. Click "Generate"
4. Download the resulting AppIcon.appiconset folder
5. In Xcode, right-click AppIcon → "Show in Finder"
6. Replace the contents with your new generated files
7. Return to Xcode and clean build (Cmd+Shift+K, then Cmd+B)

### Option 2: Use Command Line (For Developers)
```bash
# Install iconutil (built into macOS)
# Or use: brew install imagemagick

# Generate iconset from your 1024x1024 PNG
mkdir AppIcon.iconset
sips -z 16 16 sheep_farm_icon.png --out AppIcon.iconset/icon_16x16.png
sips -z 32 32 sheep_farm_icon.png --out AppIcon.iconset/icon_16x16@2x.png
# ... (repeat for all sizes)

iconutil -c icns AppIcon.iconset
```

---

## Icon Sizes Required by iOS (FYI)

Xcode should auto-generate these from your 1024x1024 icon:

### iPhone
- 20x20 (2x, 3x) - Spotlight/Settings
- 29x29 (2x, 3x) - Settings
- 40x40 (2x, 3x) - Spotlight
- 60x60 (2x, 3x) - App Icon
- 1024x1024 - App Store

### iPad (if you support iPad)
- 20x20 (1x, 2x)
- 29x29 (1x, 2x)
- 40x40 (1x, 2x)
- 76x76 (1x, 2x)
- 83.5x83.5 (2x)
- 1024x1024 - App Store

**Don't worry:** Modern Xcode (14+) automatically generates all these from your single 1024x1024 image!

---

## Troubleshooting

### Icon Not Showing After Build?
1. **Clean Build Folder**: In Xcode, Product → Clean Build Folder (Shift+Cmd+K)
2. **Delete App from Simulator/Device**: Hold icon → Delete, then rebuild
3. **Restart Simulator/Device**: Sometimes the cache needs clearing
4. **Check Asset Catalog**: Make sure AppIcon shows a preview of your icon

### Icon Looks Blurry?
- Make sure you're using the PNG file (not the SVG)
- Verify the PNG is exactly 1024x1024 pixels
- Don't use transparency (iOS icons must have no alpha channel)

### Getting Error About Alpha Channel?
Your icon has transparency, but iOS icons can't. The PNG I created should work, but if you edit it:
```bash
# Remove alpha channel using ImageMagick
convert sheep_farm_icon.png -background white -alpha remove -alpha off sheep_farm_icon_no_alpha.png
```

### Want to Edit the Icon?
Use the SVG file (`sheep_farm_icon.svg`) in any vector editor:
- Adobe Illustrator
- Figma
- Inkscape (free)
- Sketch

Then export as PNG at 1024x1024 and follow the steps above.

---

## iOS Design Guidelines

Your icon follows Apple's design guidelines:
- ✅ Simple and recognizable
- ✅ No transparency
- ✅ Fills the entire square
- ✅ Visually appealing at all sizes
- ✅ Represents your app's purpose

Apple applies rounded corners automatically - you don't need to round them yourself!

---

## Next Steps

1. Add the icon using Method 1 (easiest)
2. Build and run your app
3. Check your home screen
4. If you like it, you're done!
5. If you want changes, edit the SVG and regenerate

---

## Quick Reference

**File you need:** `sheep_farm_icon.png`  
**Where it goes:** Assets.xcassets → AppIcon → 1024x1024 slot  
**What Xcode does:** Automatically generates all other sizes  
**Result:** Beautiful sheep icon on your app! 🐑

Enjoy your new app icon!