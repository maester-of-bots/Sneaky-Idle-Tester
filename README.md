# 🐑 Fjallabær Sheep Farm - iOS Edition

An Icelandic idle farming game converted from web to iOS using SwiftUI!

## Features

- **Choose your region** - Start your farm in one of 6 Icelandic locations, each with different difficulty and bonuses
- **10 sheep tiers** - Unlock increasingly powerful sheep breeds
- **5 upgrade categories** - Improve your farm's production
- **Dynamic weather** - Weather affects your production
- **Wool processing** - Turn raw wool into valuable products
- **Automation** - Enable auto-sell and auto-process
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
├── Models.swift              # Data models
├── GameManager.swift         # Game logic
├── StartScreenView.swift     # Region selection
├── MainGameView.swift        # Main game UI
└── Views.swift               # Sheep list, upgrades, settings
```

## Gameplay

1. **Start** - Choose your name and region
2. **Click** - Tap the shear button to collect wool
3. **Sell** - Sell wool for currency (Krónur)
4. **Buy Sheep** - Purchase better sheep breeds
5. **Upgrade** - Buy upgrades to boost production
6. **Process** - Unlock processing to create valuable products
7. **Automate** - Enable automation for idle income

## Differences from Web Version

- **Mobile-optimized UI** - Tabs instead of 3-column layout
- **Touch-friendly** - Larger buttons and better spacing
- **Simplified Iceland map** - Button-based region selection instead of SVG
- **Core gameplay intact** - All main mechanics preserved
- **10 sheep tiers** - Simplified from 29 for mobile experience
- **5 key upgrades** - Focused on core progression

## Future Features

- More sheep tiers
- More upgrades
- Achievements
- Prestige system
- Sound effects
- Animations
- iCloud sync

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
