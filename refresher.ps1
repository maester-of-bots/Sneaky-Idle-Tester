# Set paths
$downloads = "D:\Downloads"
$zipPath = Join-Path $downloads "SheepFarm.zip"
$extractPath = Join-Path $downloads "SheepFarm"
$dest = "G:\Code\Sneaky-Idle-Tester"

# Go to Downloads
Set-Location $downloads

# Check if zip exists
if (!(Test-Path $zipPath)) {
    Write-Host "SheepFarm.zip not found in $downloads" -ForegroundColor Red
    exit 1
}

# Extract the zip
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

# Remove the zip
Remove-Item $zipPath -Force

# Handle nested SheepFarm folder
$nested = Join-Path $extractPath "SheepFarm"
if (Test-Path $nested) {
    Get-ChildItem -Path $nested -Force | Move-Item -Destination $extractPath -Force
    Remove-Item $nested -Recurse -Force
}

# Remove existing SheepFarm and SheepFarm.xcodeproj from destination
$removeTargets = @("SheepFarm", "SheepFarm.xcodeproj")

foreach ($target in $removeTargets) {
    $targetPath = Join-Path $dest $target
    if (Test-Path $targetPath) {
        Remove-Item $targetPath -Recurse -Force
    }
}

# Move new files to destination, overwriting if needed
Get-ChildItem -Path $extractPath -Force | Move-Item -Destination $dest -Force

# Clean up extracted folder
Remove-Item $extractPath -Recurse -Force

# Git commit and push
Set-Location $dest
if (Test-Path ".git") {
    git add .
    git commit -m "Update SheepFarm files from archive"
    git push
} else {
    Write-Host "No git repo detected at $dest, skipping commit/push." -ForegroundColor Yellow
}

Write-Host "SheepFarm updated and pushed successfully." -ForegroundColor Green
