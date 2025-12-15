import SwiftUI

// MARK: - Achievements View
struct AchievementsView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("🏆 Achievements")
                    .font(.title3.bold())
                    .foregroundColor(GameColors.darkGreen)
                    .padding()
                
                // Progress bar
                let unlockedCount = gameManager.gameState.unlockedAchievements.count
                let totalCount = Achievement.allAchievements.count
                let progress = Double(unlockedCount) / Double(totalCount)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.subheadline.bold())
                        Spacer()
                        Text("\(unlockedCount)/\(totalCount)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 20)
                                .cornerRadius(10)
                            
                            Rectangle()
                                .fill(GameColors.gold)
                                .frame(width: geometry.size.width * progress, height: 20)
                                .cornerRadius(10)
                        }
                    }
                    .frame(height: 20)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Achievement list
                ForEach(Achievement.allAchievements) { achievement in
                    AchievementRow(
                        achievement: achievement,
                        isUnlocked: gameManager.gameState.unlockedAchievements.contains(achievement.id),
                        progress: getAchievementProgress(achievement: achievement)
                    )
                }
            }
            .padding()
        }
    }
    
    func getAchievementProgress(achievement: Achievement) -> Double {
        let totalSheep = gameManager.getTotalSheep()
        let totalUpgrades = gameManager.gameState.upgradeLevels.values.reduce(0, +)
        
        switch achievement.requirementType {
        case "sheep":
            return min(Double(totalSheep) / achievement.requirement, 1.0)
        case "wool":
            return min(gameManager.gameState.totalWoolEarned / achievement.requirement, 1.0)
        case "clicks":
            return min(Double(gameManager.gameState.totalClicks) / achievement.requirement, 1.0)
        case "upgrades":
            return min(Double(totalUpgrades) / achievement.requirement, 1.0)
        case let type where type.starts(with: "tier:"):
            let tierId = String(type.dropFirst(5))
            let count = gameManager.gameState.sheepCounts[tierId] ?? 0
            return count >= Int(achievement.requirement) ? 1.0 : 0.0
        default:
            return 0.0
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    let isUnlocked: Bool
    let progress: Double
    
    var body: some View {
        HStack(spacing: 12) {
            // Emoji
            Text(achievement.emoji)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(isUnlocked ? GameColors.gold.opacity(0.3) : Color.gray.opacity(0.2))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isUnlocked ? GameColors.gold : Color.gray, lineWidth: 2)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.name)
                    .font(.headline.bold())
                    .foregroundColor(isUnlocked ? GameColors.darkText : .gray)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(GameColors.mediumText)
                
                if !isUnlocked && progress > 0 {
                    HStack(spacing: 4) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 6)
                                    .cornerRadius(3)
                                
                                Rectangle()
                                    .fill(GameColors.gold)
                                    .frame(width: geometry.size.width * progress, height: 6)
                                    .cornerRadius(3)
                            }
                        }
                        .frame(height: 6)
                        
                        Text("\(Int(progress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 40)
                    }
                }
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(GameColors.springGreen)
                    .font(.title2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isUnlocked ? Color.white : Color.gray.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isUnlocked ? GameColors.gold : Color.gray.opacity(0.3), lineWidth: isUnlocked ? 2 : 1)
        )
        .opacity(isUnlocked ? 1.0 : 0.7)
    }
}

// MARK: - Sheep List View
struct SheepListView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("🐑 Sheep Breeds Available")
                    .font(.title3.bold())
                    .foregroundColor(GameColors.darkGreen)
                    .padding()
                
                ForEach(SheepTier.allTiers) { tier in
                    SheepTierRow(tier: tier, gameManager: gameManager)
                }
            }
            .padding()
        }
    }
}

struct SheepTierRow: View {
    let tier: SheepTier
    @ObservedObject var gameManager: GameManager
    
    var isUnlocked: Bool {
        gameManager.isSheepUnlocked(tier)
    }
    
    var cost: Double {
        gameManager.gameState.sheepCosts[tier.id] ?? tier.baseCost
    }
    
    var count: Int {
        gameManager.gameState.sheepCounts[tier.id] ?? 0
    }
    
    var canAfford: Bool {
        gameManager.gameState.currency >= cost && isUnlocked
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Emoji
            Text(tier.emoji)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(Color.white.opacity(0.5))
                .cornerRadius(10)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(tier.name)
                    .font(.headline.bold())
                    .foregroundColor(isUnlocked ? GameColors.darkText : .gray)
                
                Text("\(tier.baseWool.formatNumber()) wool/sec each")
                    .font(.caption)
                    .foregroundColor(GameColors.mediumText)
                
                if count > 0 {
                    HStack(spacing: 4) {
                        Text("Owned: \(count)")
                            .font(.caption.bold())
                            .foregroundColor(.blue)
                        Text("(\((tier.baseWool * Double(count)).formatNumber())/sec)")
                            .font(.caption)
                            .foregroundColor(GameColors.springGreen)
                    }
                }
                
                if !isUnlocked, let reqTier = tier.requirementTier {
                    let reqCount = tier.requirementCount
                    let currentCount = gameManager.gameState.sheepCounts[reqTier] ?? 0
                    Text("Requires \(reqCount) \(reqTier) sheep (\(currentCount)/\(reqCount))")
                        .font(.caption)
                        .foregroundColor(GameColors.brown)
                }
            }
            
            Spacer()
            
            // Buy button
            Button(action: {
                gameManager.buySheep(tier: tier)
            }) {
                VStack(spacing: 2) {
                    Text("BUY")
                        .font(.callout.bold())
                    Text(cost.formatCurrency())
                        .font(.caption)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(canAfford ? GameColors.springGreen : Color.gray.opacity(0.5))
                .cornerRadius(8)
            }
            .buttonStyle(BounceButtonStyle())
            .disabled(!canAfford)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isUnlocked ? Color.white : Color.gray.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(canAfford ? GameColors.limeGreen : Color.gray, lineWidth: canAfford ? 3 : 2)
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

// MARK: - Upgrades View
struct UpgradesView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("🔧 Farm Upgrades")
                    .font(.title3.bold())
                    .foregroundColor(GameColors.darkGreen)
                    .padding()
                
                ForEach(Upgrade.allUpgrades) { upgrade in
                    UpgradeRow(upgrade: upgrade, gameManager: gameManager)
                }
            }
            .padding()
        }
    }
}

struct UpgradeRow: View {
    let upgrade: Upgrade
    @ObservedObject var gameManager: GameManager
    
    var currentLevel: Int {
        gameManager.gameState.upgradeLevels[upgrade.id] ?? 0
    }
    
    var cost: Double {
        gameManager.getUpgradeCost(upgrade)
    }
    
    var canAfford: Bool {
        gameManager.canAffordUpgrade(upgrade)
    }
    
    var isMaxLevel: Bool {
        currentLevel >= upgrade.maxLevel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(upgrade.name)
                        .font(.headline.bold())
                        .foregroundColor(GameColors.darkText)
                    
                    Text(upgrade.description)
                        .font(.caption)
                        .foregroundColor(GameColors.mediumText)
                    
                    HStack {
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 8)
                                    .cornerRadius(4)
                                
                                Rectangle()
                                    .fill(isMaxLevel ? GameColors.springGreen : GameColors.steelBlue)
                                    .frame(width: geometry.size.width * (Double(currentLevel) / Double(upgrade.maxLevel)), height: 8)
                                    .cornerRadius(4)
                            }
                        }
                        .frame(height: 8)
                        
                        Text("\(currentLevel)/\(upgrade.maxLevel)")
                            .font(.caption.bold())
                            .foregroundColor(isMaxLevel ? GameColors.springGreen : .blue)
                            .frame(width: 50)
                    }
                    
                    if !isMaxLevel {
                        Text("Next: \(cost.formatCurrency())")
                            .font(.caption)
                            .foregroundColor(GameColors.mediumText)
                    }
                }
                
                Spacer()
                
                if !isMaxLevel {
                    Button(action: {
                        gameManager.buyUpgrade(upgrade)
                    }) {
                        Text("Upgrade")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(canAfford ? GameColors.steelBlue : Color.gray)
                            .cornerRadius(8)
                    }
                    .buttonStyle(BounceButtonStyle())
                    .disabled(!canAfford)
                } else {
                    Text("MAX")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(GameColors.limeGreen)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(canAfford && !isMaxLevel ? Color(hex: "4caf50") : Color.gray.opacity(0.5), lineWidth: 2)
        )
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var gameManager: GameManager
    @Binding var isPresented: Bool
    @State private var showResetAlert = false
    @State private var exportText = ""
    @State private var importText = ""
    @State private var showExport = false
    @State private var showImport = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Game Info")) {
                    HStack {
                        Text("Farmer Name")
                        Spacer()
                        Text(gameManager.gameState.farmerName)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Region")
                        Spacer()
                        Text(gameManager.gameState.region.capitalized)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Clicks")
                        Spacer()
                        Text("\(gameManager.gameState.totalClicks)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Wool Earned")
                        Spacer()
                        Text(gameManager.gameState.totalWoolEarned.formatNumber())
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Achievements")
                        Spacer()
                        Text("\(gameManager.gameState.unlockedAchievements.count)/\(Achievement.allAchievements.count)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Save Management")) {
                    Button(action: {
                        gameManager.saveGame()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save Game Now")
                        }
                    }
                    
                    Button(action: {
                        exportText = gameManager.exportSave()
                        showExport = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export Save")
                        }
                    }
                    
                    Button(action: {
                        showImport = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down.on.square")
                            Text("Import Save")
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        showResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset Farm")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
            .alert("Reset Farm?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    gameManager.resetGame()
                    isPresented = false
                }
            } message: {
                Text("Are you sure? This will delete all progress and achievements!")
            }
            .sheet(isPresented: $showExport) {
                ExportView(saveData: exportText)
            }
            .sheet(isPresented: $showImport) {
                ImportView(onImport: { text in
                    gameManager.importSave(text)
                    isPresented = false
                })
            }
        }
    }
}

struct ExportView: View {
    let saveData: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Copy this save data:")
                    .font(.headline)
                
                ScrollView {
                    Text(saveData)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Button(action: {
                    UIPasteboard.general.string = saveData
                }) {
                    Label("Copy to Clipboard", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
            .navigationTitle("Export Save")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ImportView: View {
    @State private var importText = ""
    @Environment(\.dismiss) var dismiss
    let onImport: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Paste your save data:")
                    .font(.headline)
                
                TextEditor(text: $importText)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .frame(height: 300)
                
                Button(action: {
                    onImport(importText)
                    dismiss()
                }) {
                    Label("Import Save", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(importText.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(importText.isEmpty)
                .padding()
            }
            .padding()
            .navigationTitle("Import Save")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
