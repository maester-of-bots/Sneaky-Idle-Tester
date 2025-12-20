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

Main Farm UI:
Two bars, one at the top, one at the bottom, spanning the horizontal length of the screen.  These are maybe 1/16th the vertical length of the screen each.  They are dark gree in background color.  
The bottom bar contains four circular icons.  One has a golden arrow pointed up, one has a sheep face, one has a robot face, and one has a shopping cart.  This is for upgrades, sheep, automation, and shop respectively.
The top bar contains a smaller rectangular field taking up about 1/3 of the horizontal width of the top bar.  This is where the total kroner the user has is shown.  There's a second rectangle, about 1/3th the remaining horizontal space, where amount of (placeholder special ingame currency) is located.  Then there's a circular "Settings" gear to the right.
The remainder of the screen is scrollable up and down.  To *start* with we can say put a winding brown trail that starts from the bottom of the phone and goes up to the top.  On eithe rside there are TWO sheep farms, spaced evenly in each quadrent along the path.  THat's four sheep farm per screen.  There ought to be 10 sheep types initialy, so it'll scroll up to show six more sheep farms, three on each side.  The point of the sheep farms is to primarily purchase sheep, so there should be a button that says +1 (sheep emoji) then KR (price here) below that.  Make it a nice light blue, roundeed rectangle button that takes up about 1/5th the space as the sheep farm.
If the farmer has enough money, clicking the buy button will buy him a sheep.
There is also a small rectangular button above the bottom bar, at the right, that lets the user toggle between "x1" and "Max you can afford" aka "Max" for how many sheep to buy.  The buttons to buy sheep should update immediately to reflect.





I've updated the code, please refer to the new file.  A couple of changes to make please:

Add three new tiers to Automation Systems.  The first tier (Original) Enables auto-selling raw wool.  The second tier enables auto-processing raw wool.  The third tier enables selling the products.    The fourth tier creates a console under Farm Statistics with an option for each and to turn them on or off.

Come up with five new whimsically farm upgrades, like Icelandic elves or some shit like that.

Update the SHeep Breeds available area.   Make it so that it only shows two tiers of sheep that are unavailable.  Change the Unavailable sheep tier rows to be grayed out all toether.  When a sheep tier is available, make the row 2.5x as big, and in the middle between the text on the left and the buttom on the right, give each tier their own specific pasture where those specific sheep will appear.

Can you update the core aspect of the game?  I would like to change the Sheep button that the user clicks for free sheep, to a "Shear your Sheep" button to get wool.  Additionally, I'd like the normal free sheep to be updated to cost 10kr.

Lastly, I want scaling costs for the sheep as you buy them.  Use your best judgement for the mechanics of the game, but I'm thinking at least 2x-5x cost increase.  But again, up to your best judgement.

    At the start screen with "Choose your farm location", it should scroll to the bottom to show the description automatically
    The "Enter your name" text needs to be updated to be white, it's not legible now
    After starting, I bought one sheep. I see the game update that I have production now, but it doesn't make raw wool OR money go up
    The "Click to shear wool" button doesn't do anything
    The "Sell raw wool" button doesn't do anything
    Buying upgrades works, but it isn't updated until I restart the app

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
