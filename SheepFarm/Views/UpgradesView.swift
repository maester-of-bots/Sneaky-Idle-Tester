//
//  UpgradesView.swift
//  Fjallabær Sheep Farm
//

import SwiftUI

struct UpgradesView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("Upgrades")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.13, green: 0.54, blue: 0.13))
                    .padding(.top, 20)
                
                ForEach(UpgradeType.allCases, id: \.self) { upgradeType in
                    UpgradeCard(upgradeType: upgradeType, gameManager: gameManager)
                }
                
                Spacer(minLength: 30)
            }
            .padding(.horizontal, 20)
        }
    }
}

struct UpgradeCard: View {
    let upgradeType: UpgradeType
    @ObservedObject var gameManager: GameManager
    
    var currentLevel: Int {
        gameManager.gameState.upgradeLevels[upgradeType.rawValue] ?? 0
    }
    
    var cost: Double {
        gameManager.calculateUpgradeCost(upgradeType: upgradeType)
    }
    
    var canAfford: Bool {
        gameManager.canAffordUpgrade(upgradeType: upgradeType)
    }
    
    var isMaxLevel: Bool {
        currentLevel >= upgradeType.maxLevel
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            Text(upgradeType.icon)
                .font(.system(size: 40))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(upgradeType.rawValue)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(upgradeType.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                // Current level
                Text("Level: \(currentLevel) / \(upgradeType.maxLevel)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.13, green: 0.54, blue: 0.13))
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: geometry.size.width * (Double(currentLevel) / Double(upgradeType.maxLevel)), height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)
            }
            
            Spacer()
            
            // Buy button
            Button(action: {
                gameManager.buyUpgrade(upgradeType: upgradeType)
            }) {
                VStack(spacing: 2) {
                    if isMaxLevel {
                        Text("MAX")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text("Upgrade")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                        Text("\(cost.formatNumber()) kr")
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 80, height: 45)
                .background(isMaxLevel ? Color.gray : (canAfford ? Color.blue : Color.gray.opacity(0.6)))
                .cornerRadius(10)
            }
            .disabled(isMaxLevel || !canAfford)
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}
