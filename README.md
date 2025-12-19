# 🐑 Fjallabær Sheep Farm - iOS Edition

An Icelandic idle farming game converted from web to iOS using SwiftUI!

## ✨ Recent Updates (v1.1)

### 🎯 New Features
- **Achievement System** - 10 achievements with progress tracking and notifications
- **Visual Production Feedback** - See wool being produced in real-time
- **Click Animations** - Satisfying bouncy feedback when shearing
- **Progress Indicators** - Visual bars for upgrades and achievements

### 🐛 Critical Fixes
- Fixed invisible text field in region selection
- Improved visual hierarchy throughout the app
- Better button feedback and animations

### 🎨 Visual Improvements
- Centralized color system for consistency
- Enhanced production stats display
- Better achievement notifications
- Improved UI polish and animations

---

# Generative Description

- The app opens to a solid color background - cloudy sky gray.  A (Basic, placeholder) logo is in the middle of the screen, and underneath the words "TGS Entertainment"
- After 2 seconds, this screen goes away and is replaced with a basic loading icon that will move / turn like a loading icon should, with the large words "Loading" pulsing in and out underneath.
- After 5 seconds, this gives way to the start menu screen.  The start menu screen contains the name of the game (Placeholder for now) Fjallabær Sheep Farm.  It displays a rectangle shape that goes from just below the text to just above the bottom of the screen.  There is a rounnded rectangular button underneath the rectangle that says "New Farm".  if pressed, it takes the user to the New Farm screen.  If there are saved farms, each one will be a rectangular entry in the larger rectangle.  If pressed, loads the user's farm
- New Farm screen:


___

## Features

- **Choose your region** - Start your farm in one of 6 Icelandic locations, each with different difficulty and bonuses
- **10 sheep tiers** - Unlock increasingly powerful sheep breeds
- **5 upgrade categories** - Improve your farm's production
- **Dynamic weather** - Weather affects your production
- **Wool processing** - Turn raw wool into valuable products
- **Automation** - Enable auto-sell and auto-process
- **Achievements** - Unlock 10 achievements as you progress
- **Save/Load** - Your progress is automatically saved
- **Import/Export** - Transfer your save between devices

## How to Build

### With GitHub Actions (No Mac Required!)

1. Fork or upload this repo to GitHub
2. Go to Actions tab
3. The workflow will build automatically
4. Download the IPA from Artifacts
5. Sideload with Sideloadly or AltStore

### With Xcode (If you have a Mac)

1. Open `SheepFarm.xcodeproj` in Xcode
2. Select your device/simulator
3. Click Run (⌘R)

## Game Structure

```
SheepFarm/
├── SheepFarmApp.swift       # Main app entry
├── ContentView.swift         # Root view
├── Models.swift              # Data models & achievements
├── GameManager.swift         # Game logic & achievement tracking
├── Utilities.swift           # Colors, formatters, button styles
├── StartScreenView.swift     # Region selection
├── MainGameView.swift        # Main game UI with tabs
└── Views.swift               # Sheep list, upgrades, achievements, settings
```

## Gameplay

1. **Start** - Choose your name and region
2. **Click** - Tap the shear button to collect wool
3. **Sell** - Sell wool for currency (Krónur)
4. **Buy Sheep** - Purchase better sheep breeds
5. **Upgrade** - Buy upgrades to boost production
6. **Process** - Unlock processing to create valuable products
7. **Automate** - Enable automation for idle income
8. **Achieve** - Unlock achievements and track your progress

## Achievements 🏆

- 🐑 **First Flock** - Buy your first sheep
- 🐏 **Growing Farm** - Own 10 total sheep
- 👨‍🌾 **Shepherd** - Own 100 total sheep
- 🧶 **Wool Baron** - Collect 1,000 total wool
- 💰 **Wool Tycoon** - Collect 1,000,000 total wool
- 🔧 **Improvement** - Buy your first upgrade
- ✂️ **Dedicated Shearer** - Click 100 times
- ✨ **Master Shearer** - Click 1,000 times
- 👑 **Elite Farmer** - Unlock Elite Sheep tier
- 🐉 **Dragon Tamer** - Unlock Dragon Sheep tier

## Differences from Web Version

- **Mobile-optimized UI** - Tabs instead of 3-column layout
- **Touch-friendly** - Larger buttons and better spacing
- **Simplified Iceland map** - Button-based region selection instead of SVG
- **Core gameplay intact** - All main mechanics preserved
- **10 sheep tiers** - Simplified from 29 for mobile experience
- **5 key upgrades** - Focused on core progression
- **Achievement system** - iOS-exclusive feature
- **Visual polish** - Animations and improved feedback

## Future Features

- Sound effects
- Prestige system
- iCloud sync
- More achievements
- Seasonal events
- Daily challenges

## Building for App Store

To publish to the App Store, you'll need:
1. Apple Developer account ($99/year)
2. Proper code signing
3. App icons and screenshots
4. Privacy policy
5. App Store Connect setup

## Credits

Original web game concept adapted for iOS.
Built with SwiftUI and ❤️ for idle game fans!

## License

Feel free to use, modify, and learn from this code!
