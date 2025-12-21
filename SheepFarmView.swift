//
//  SheepFarmView.swift
//  Fjallabær Sheep Farm
//

import SwiftUI

struct SheepFarmView: View {
    @ObservedObject var gameManager: GameManager
    @Binding var buyMode: MainGameView.BuyMode
    
    let columns = [
        GridItem(.fixed(160), spacing: 20),
        GridItem(.fixed(160), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                // Winding path background
                WindingPath()
                    .stroke(Color(red: 0.55, green: 0.27, blue: 0.07), lineWidth: 50) // Brown
                    .padding(.leading, 40)
                
                // Sheep cards in grid layout
                LazyVGrid(columns: columns, spacing: 25) {
                    ForEach(SheepTier.allTiers) { tier in
                        SheepCard(
                            tier: tier,
                            gameManager: gameManager,
                            buyMode: buyMode
                        )
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 30)
                .padding(.bottom, 30)
            }
        }
    }
}

// MARK: - Winding Path
struct WindingPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let startY: CGFloat = 80
        let segmentHeight: CGFloat = 220
        
        path.move(to: CGPoint(x: 0, y: startY))
        
        // Create 5 segments (one for each row of 2 sheep)
        for i in 0..<5 {
            let y = startY + CGFloat(i) * segmentHeight
            let midY = y + segmentHeight / 2
            let endY = y + segmentHeight
            
            // Alternate curves left and right
            if i % 2 == 0 {
                // Curve right
                path.addCurve(
                    to: CGPoint(x: rect.width, y: endY),
                    control1: CGPoint(x: 0, y: midY),
                    control2: CGPoint(x: rect.width, y: midY)
                )
            } else {
                // Curve left
                path.addCurve(
                    to: CGPoint(x: 0, y: endY),
                    control1: CGPoint(x: rect.width, y: midY),
                    control2: CGPoint(x: 0, y: midY)
                )
            }
        }
        
        return path
    }
}

// MARK: - Sheep Card
struct SheepCard: View {
    let tier: SheepTier
    @ObservedObject var gameManager: GameManager
    let buyMode: MainGameView.BuyMode
    
    var isUnlocked: Bool {
        gameManager.isSheepUnlocked(tier: tier)
    }
    
    var ownedCount: Int {
        gameManager.gameState.sheepCounts[tier.id] ?? 0
    }
    
    var currentCost: Double {
        gameManager.gameState.sheepCosts[tier.id] ?? tier.baseCost
    }
    
    var buyAmount: Int {
        switch buyMode {
        case .one:
            return 1
        case .max:
            return gameManager.maxAffordable(tier: tier)
        }
    }
    
    var canAfford: Bool {
        gameManager.canAffordSheep(tier: tier, amount: buyAmount)
    }
    
    var buttonText: String {
        if buyMode == .max {
            return "+\(buyAmount) 🐑"
        } else {
            return "+1 🐑"
        }
    }
    
    var buttonCostText: String {
        let cost = gameManager.calculateSheepCost(tier: tier, amount: buyAmount)
        return cost.formatNumber()
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Owned count badge
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 35, height: 35)
                
                Text("\(ownedCount)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Sheep emoji
            Text(tier.emoji)
                .font(.system(size: 42))
                .opacity(isUnlocked ? 1.0 : 0.3)
            
            // Sheep name
            Text(tier.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(red: 0.13, green: 0.54, blue: 0.13))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 32)
            
            // Wool production
            Text("\(tier.baseWool.formatNumber()) 🧶/s")
                .font(.system(size: 11))
                .foregroundColor(.gray)
            
            // Buy button
            Button(action: {
                if isUnlocked && buyAmount > 0 {
                    gameManager.buySheep(tier: tier, amount: buyAmount)
                }
            }) {
                VStack(spacing: 2) {
                    Text(buttonText)
                        .font(.system(size: 12, weight: .semibold))
                    Text("\(buttonCostText) kr")
                        .font(.system(size: 11))
                }
                .foregroundColor(.white)
                .frame(width: 95, height: 36)
                .background(isUnlocked && canAfford && buyAmount > 0 ? Color.blue : Color.gray)
                .cornerRadius(8)
            }
            .disabled(!isUnlocked || !canAfford || buyAmount == 0)
        }
        .frame(width: 110, height: 180)
        .padding(10)
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}
