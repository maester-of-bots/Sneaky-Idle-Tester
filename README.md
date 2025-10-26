# Idle Clicker Game - iOS

A simple idle/incremental game for iOS built with SwiftUI.

## Game Mechanics

- Tap the blue circle to increment the counter by 1
- Every second, the counter auto-increments by 0.001 times its current value
- Numbers format automatically (K for thousands, M for millions)

## How to Build (Without a Mac)

This project uses GitHub Actions to build on macOS runners for free!

### Step 1: Push to GitHub

1. Create a new GitHub repository
2. Push this code:
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

### Step 2: Wait for Build

1. Go to your repo on GitHub
2. Click "Actions" tab
3. Watch the build run (takes 3-5 minutes)
4. When it's done, click on the workflow run
5. Scroll down to "Artifacts"
6. Download "IdleClicker-IPA"

### Step 3: Sideload with Sideloadly

1. Extract the downloaded ZIP
2. Open Sideloadly
3. Connect your iPhone
4. Drag the .ipa file into Sideloadly
5. Enter your Apple ID
6. Click "Start"

## Project Structure

```
IdleClicker/
├── .github/
│   └── workflows/
│       └── build.yml          # GitHub Actions build script
├── IdleClicker/
│   ├── ContentView.swift      # Main game UI
│   └── IdleClickerApp.swift   # App entry point
└── IdleClicker.xcodeproj/
    └── project.pbxproj        # Xcode project config
```

## Customization Ideas

Want to expand this? Here are some ideas:

- Add upgrades (increase per-tap amount)
- Add different buttons with different effects
- Save progress using UserDefaults
- Add animations and particle effects
- Implement prestige/reset mechanics
- Add background music
- **Add ads** (Google AdMob, Unity Ads)

## Adding Ads (Future)

To monetize later:
1. Sign up for Google AdMob
2. Add the AdMob SDK
3. Implement banner/interstitial ads
4. Test with test ad units first!

## Free Minutes on GitHub Actions

- Free tier: 2,000 minutes/month
- macOS runners use 10x multiplier
- So you get ~200 minutes of macOS time
- Each build takes ~3-5 minutes
- = ~40-60 builds per month for free

## Notes

- The IPA built by GitHub Actions won't be signed for App Store
- Perfect for sideloading and testing
- To publish to App Store, you'll need:
  - Apple Developer account ($99/year)
  - Proper code signing
  - App Store Connect setup

## License

Do whatever you want with this! It's yours now.
