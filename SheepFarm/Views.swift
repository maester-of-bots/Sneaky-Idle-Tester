import SwiftUI

struct SheepListView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("🐑 Sheep Breeds Available")
                    .font(.title3.bold())
                    .foregroundColor(Color(hex: "2F4F4F"))
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
    
    var canAfford: Bool {
        gameManager.canAffordSheep(tier)
    }
    
    var cost: Double {
        gameManager.gameState.sheepCosts[tier.id] ?? tier.baseCost
    }
    
    var count: Int {
        gameManager.gameState.sheepCounts[tier.id] ?? 0
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
                    .foregroundColor(isUnlocked ? Color(hex: "1a1a1a") : Color.gray)
                
                Text("\(tier.baseWool.formatNumber()) wool/sec each")
                    .font(.caption)
                    .foregroundColor(Color(hex: "333333"))
                
                if count > 0 {
                    Text("Owned: \(count)")
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                }
                
                if !isUnlocked, let reqTier = tier.requirementTier {
                    let reqCount = tier.requirementCount
                    let currentCount = gameManager.gameState.sheepCounts[reqTier] ?? 0
                    Text("Requires \(reqCount) \(reqTier) sheep (\(currentCount)/\(reqCount))")
                        .font(.caption)
                        .foregroundColor(Color(hex: "8B4513"))
                }
            }
            
            Spacer()
            
            // Buy button
            Button(action: {
                gameManager.buySheep(tier: tier)
            }) {
                VStack(spacing: 2) {
                    Text("Buy")
                        .font(.caption.bold())
                    Text(cost.formatCurrency())
                        .font(.caption2)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(canAfford && isUnlocked ? Color(hex: "228B22") : Color.gray)
                .cornerRadius(8)
            }
            .disabled(!canAfford || !isUnlocked)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isUnlocked ? Color.white : Color.gray.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(canAfford && isUnlocked ? Color(hex: "4682B4") : Color.gray, lineWidth: 2)
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

struct UpgradesView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("🔧 Farm Upgrades")
                    .font(.title3.bold())
                    .foregroundColor(Color(hex: "2F4F4F"))
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
                        .foregroundColor(Color(hex: "1a1a1a"))
                    
                    Text(upgrade.description)
                        .font(.caption)
                        .foregroundColor(Color(hex: "333333"))
                    
                    HStack {
                        Text("Level: \(currentLevel)/\(upgrade.maxLevel)")
                            .font(.caption.bold())
                            .foregroundColor(.blue)
                        
                        if !isMaxLevel {
                            Text("•")
                                .foregroundColor(Color(hex: "333333"))
                            Text("Next: \(cost.formatCurrency())")
                                .font(.caption)
                                .foregroundColor(Color(hex: "333333"))
                        }
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
                            .background(canAfford ? Color(hex: "4682B4") : Color.gray)
                            .cornerRadius(8)
                    }
                    .disabled(!canAfford)
                } else {
                    Text("MAX")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(hex: "32CD32"))
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
                Text("Are you sure? This will delete all progress!")
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
