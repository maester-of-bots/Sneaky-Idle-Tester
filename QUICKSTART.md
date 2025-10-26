# Quick Start Guide

## What You Have

A complete iOS idle clicker game that builds on GitHub's free macOS servers!

## What It Does

- Blue circle button in the center
- Tap it, number goes up by 1
- Every second, it auto-increases by 0.001 × current value
- That's it! Simple idle game mechanics.

## How to Use It (Step by Step)

### 1. Create a GitHub Account (if you don't have one)
Go to github.com and sign up - it's free

### 2. Create a New Repository
- Click "+" in top right → "New repository"
- Name it whatever (like "idle-clicker-game")
- Make it Public (required for free Actions)
- Don't initialize with anything
- Click "Create repository"

### 3. Upload Your Code

Option A - Use GitHub's web interface:
- Click "uploading an existing file"
- Drag the entire IdleClicker folder
- Commit

Option B - Use Git (if you have it):
```bash
cd IdleClicker
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

### 4. Watch It Build
- Go to your repo
- Click "Actions" tab at the top
- You'll see a workflow running
- Wait 3-5 minutes for it to complete
- Green checkmark = success!

### 5. Download Your App
- Click on the completed workflow
- Scroll down to "Artifacts"
- Click "IdleClicker-IPA" to download
- Unzip the downloaded file

### 6. Sideload to Your iPhone
- Open Sideloadly
- Connect your iPhone via USB
- Drag the .ipa file into Sideloadly
- Enter your Apple ID
- Click "Start"
- Wait for it to install
- Go to Settings → General → VPN & Device Management
- Trust your certificate
- Open the app!

## Troubleshooting

**Build fails?**
- Make sure your repo is public
- Check the Actions tab for error messages
- The workflow file might need the Xcode version adjusted

**Can't sideload?**
- Make sure Sideloadly is up to date
- Try restarting your iPhone
- Check that you're using a valid Apple ID

**App crashes?**
- The unsigned build from GitHub Actions might have issues
- This is normal for sideloaded apps
- Try rebuilding

## What's Next?

Once you have this working, you can:
1. Modify the code (ContentView.swift)
2. Push changes to GitHub
3. It auto-rebuilds
4. Download new IPA
5. Sideload again

This is your development loop without a Mac!

## Cost Breakdown

- GitHub account: FREE
- GitHub Actions: FREE (2000 min/month = ~200 macOS minutes)
- Sideloadly: FREE
- Your time: Priceless
- A Mac: NOT NEEDED! 💰

Total cost: $0

## Future: Adding Ads

When you're ready to monetize:
1. Sign up for Google AdMob (free)
2. Add AdMob SDK to your project
3. Place banner ads at the bottom
4. Implement interstitial ads between levels
5. Test with test ad IDs first!

You'll need to learn a bit more Swift, but this gets you started!
