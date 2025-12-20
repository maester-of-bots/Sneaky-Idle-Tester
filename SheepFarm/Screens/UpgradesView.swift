import SwiftUI

struct UpgradesView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("⬆️ Upgrades")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.2))
                    .padding(.top, 30)
                
                Text("Boost your wool production!")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
                
                // Upgrades List
                VStack(spacing: 16) {
                    ForEach(Upgrade.allUpgrades) { upgrade in
                        UpgradeCard(upgrade: upgrade, gameManager: gameManager)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color(red: 0.87, green: 0.92, blue: 0.85))
    }
}

struct UpgradeCard: View {
    let upgrade: Upgrade
    @ObservedObject var gameManager: GameManager
    
    var currentLevel: Int {
        gameManager.gameState.upgradeLevels[upgrade.id] ?? 0
    }
    
    var cost: Double {
        gameManager.calculateUpgradeCost(upgrade)
    }
    
    var canAfford: Bool {
        gameManager.canAffordUpgrade(upgrade)
    }
    
    var isMaxed: Bool {
        currentLevel >= upgrade.maxLevel
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor)
                    .frame(width: 60, height: 60)
                
                Text(iconEmoji)
                    .font(.system(size: 30))
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(upgrade.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.2))
                    
                    Spacer()
                    
                    Text("Lv. \(currentLevel)/\(upgrade.maxLevel)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.7))
                        )
                }
                
                Text(upgrade.description)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                // Buy Button
                Button(action: {
                    gameManager.buyUpgrade(upgrade)
                }) {
                    HStack {
                        if isMaxed {
                            Text("MAXED")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("Upgrade")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(Int(cost)) kr")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(buttonColor)
                    )
                }
                .disabled(!canAfford || isMaxed)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    var iconEmoji: String {
        switch upgrade.id {
        case "shears": return "✂️"
        case "staff": return "👥"
        case "housing": return "🏠"
        case "clickPower": return "👆"
        case "processing": return "🏭"
        default: return "⬆️"
        }
    }
    
    var iconColor: Color {
        switch upgrade.id {
        case "shears": return Color.blue.opacity(0.2)
        case "staff": return Color.green.opacity(0.2)
        case "housing": return Color.orange.opacity(0.2)
        case "clickPower": return Color.purple.opacity(0.2)
        case "processing": return Color.red.opacity(0.2)
        default: return Color.gray.opacity(0.2)
        }
    }
    
    var buttonColor: Color {
        if isMaxed {
            return Color.gray.opacity(0.5)
        } else if canAfford {
            return Color.green.opacity(0.8)
        } else {
            return Color.gray.opacity(0.5)
        }
    }
}

#Preview {
    UpgradesView(gameManager: GameManager())
}
