import SwiftUI

// MARK: - Main Game View
struct GameView: View {
    let farmID: UUID
    @StateObject private var gameManager = GameManager()
    @State private var selectedTab: GameTab = .sheep
    @State private var buyMode: BuyMode = .one
    
    enum GameTab {
        case upgrades, sheep, automation, shop
    }
    
    enum BuyMode {
        case one, max
        
        var displayText: String {
            switch self {
            case .one: return "×1"
            case .max: return "Max"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.87, green: 0.92, blue: 0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // TOP BAR
                TopBar(
                    kroner: gameManager.gameState.currency,
                    wool: gameManager.gameState.wool,
                    woolPerSecond: gameManager.calculateProduction(),
                    onSellWool: {
                        gameManager.sellWool()
                    }
                )
                
                // MAIN CONTENT AREA
                ZStack {
                    // Content based on selected tab
                    switch selectedTab {
                    case .sheep:
                        ScrollView {
                            FarmPathView(gameManager: gameManager, buyMode: buyMode)
                                .padding(.bottom, 80)
                        }
                        
                    case .upgrades:
                        UpgradesView(gameManager: gameManager)
                        
                    case .automation:
                        AutomationView(gameManager: gameManager)
                        
                    case .shop:
                        ShopView(gameManager: gameManager)
                    }
                    
                    // Buy Mode Toggle (only show on sheep tab)
                    if selectedTab == .sheep {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                BuyModeToggle(buyMode: $buyMode)
                                    .padding(.trailing, 20)
                                    .padding(.bottom, 10)
                            }
                        }
                    }
                }
                
                // BOTTOM BAR
                BottomBar(selectedTab: $selectedTab)
            }
        }
        .onAppear {
            // Game loops already started in GameManager.init()
        }
        .onDisappear {
            gameManager.saveGame()
        }
    }
}

// MARK: - Top Bar
struct TopBar: View {
    let kroner: Double
    let wool: Double
    let woolPerSecond: Double
    var onSellWool: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 8) {
            // Kroner Display
            HStack(spacing: 8) {
                Text("💰")
                    .font(.system(size: 24))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Krónur")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    Text(formatNumber(kroner))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.2))
            )
            
            // Wool Display
            HStack(spacing: 8) {
                Text("🧶")
                    .font(.system(size: 24))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Wool")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    HStack(spacing: 4) {
                        Text(formatNumber(wool))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text("(\(formatNumber(woolPerSecond))/s)")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.2))
            )
            
            Spacer()
            
            // Sell Wool Button
            Button(action: {
                onSellWool?()
            }) {
                Text("Sell")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(wool > 0 ? Color.orange.opacity(0.8) : Color.gray.opacity(0.5))
                    )
            }
            .disabled(wool <= 0)
            .padding(.trailing, 14)
        }
        .frame(height: 50)
        .background(Color(red: 0.13, green: 0.54, blue: 0.13))
    }
    
    private func formatNumber(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "%.2fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "%.1fK", value / 1_000)
        } else {
            return String(format: "%.0f", value)
        }
    }
}

// MARK: - Bottom Bar
struct BottomBar: View {
    @Binding var selectedTab: GameView.GameTab
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(icon: "arrow.up.circle.fill", 
                     color: .yellow,
                     isSelected: selectedTab == .upgrades) {
                selectedTab = .upgrades
            }
            
            TabButton(icon: "🐑", 
                     isEmoji: true,
                     isSelected: selectedTab == .sheep) {
                selectedTab = .sheep
            }
            
            TabButton(icon: "🤖", 
                     isEmoji: true,
                     isSelected: selectedTab == .automation) {
                selectedTab = .automation
            }
            
            TabButton(icon: "cart.fill", 
                     color: .orange,
                     isSelected: selectedTab == .shop) {
                selectedTab = .shop
            }
        }
        .frame(height: 50)
        .background(Color(red: 0.13, green: 0.54, blue: 0.13))
    }
}

struct TabButton: View {
    let icon: String
    var color: Color = .white
    var isEmoji: Bool = false
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.white.opacity(0.3) : Color.clear)
                    .frame(width: 40, height: 40)
                
                if isEmoji {
                    Text(icon)
                        .font(.system(size: 24))
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Farm Path View
struct FarmPathView: View {
    @ObservedObject var gameManager: GameManager
    let buyMode: GameView.BuyMode
    
    var body: some View {
        ZStack {
            // Winding brown path
            Path { path in
                let width = UIScreen.main.bounds.width
                let startX = width / 2
                
                path.move(to: CGPoint(x: startX, y: 0))
                
                for i in 0...20 {
                    let y = CGFloat(i) * 200
                    let x = startX + sin(CGFloat(i) * 0.5) * 60
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color(red: 0.55, green: 0.27, blue: 0.07), lineWidth: 50)
            .opacity(0.6)
            
            // Sheep farms
            VStack(spacing: 140) {
                ForEach(Array(stride(from: 0, to: SheepTier.allTiers.count, by: 2)), id: \.self) { index in
                    HStack(spacing: 35) {
                        if index < SheepTier.allTiers.count {
                            SheepFarmCard(
                                sheepType: SheepTier.allTiers[index],
                                gameManager: gameManager,
                                buyMode: buyMode
                            )
                        }
                        
                        Spacer()
                        
                        if index + 1 < SheepTier.allTiers.count {
                            SheepFarmCard(
                                sheepType: SheepTier.allTiers[index + 1],
                                gameManager: gameManager,
                                buyMode: buyMode
                            )
                        }
                    }
                    .padding(.horizontal, 15)
                }
            }
            .padding(.top, 50)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Sheep Farm Card
struct SheepFarmCard: View {
    let sheepType: SheepTier
    @ObservedObject var gameManager: GameManager
    let buyMode: GameView.BuyMode
    
    var buyAmount: Int {
        switch buyMode {
        case .one:
            return 1
        case .max:
            return gameManager.maxAffordable(sheepType)
        }
    }
    
    var totalCost: Double {
        gameManager.calculateSheepCost(sheepType, amount: buyAmount)
    }
    
    var canAfford: Bool {
        buyAmount > 0 && gameManager.canAffordSheep(sheepType, amount: buyAmount)
    }
    
    var isUnlocked: Bool {
        gameManager.isSheepUnlocked(sheepType)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Sheep count owned
            Text("\(gameManager.gameState.sheepCounts[sheepType.id, default: 0])")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 35, height: 35)
                .background(
                    Circle()
                        .fill(Color.green.opacity(0.7))
                )
            
            // Sheep emoji
            Text(sheepType.emoji)
                .font(.system(size: 28))
                .opacity(isUnlocked ? 1.0 : 0.3)
            
            // Sheep name
            Text(sheepType.name)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.2))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 28)
            
            // Buy button
            Button(action: {
                gameManager.buySheep(tier: sheepType, amount: buyAmount)
            }) {
                VStack(spacing: 4) {
                    Text("+\(buyAmount) \(sheepType.emoji)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                    Text("\(Int(totalCost)) kr")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(width: 95, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(canAfford && isUnlocked ? 
                              Color(red: 0.53, green: 0.81, blue: 0.92) :
                              Color.gray.opacity(0.5))
                )
            }
            .disabled(!canAfford || !isUnlocked)
        }
        .frame(width: 110, height: 180)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Buy Mode Toggle
struct BuyModeToggle: View {
    @Binding var buyMode: GameView.BuyMode
    
    var body: some View {
        Button(action: {
            buyMode = buyMode == .one ? .max : .one
        }) {
            Text(buyMode.displayText)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 35)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.13, green: 0.54, blue: 0.13))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                )
        }
    }
}

// MARK: - Placeholder Views
struct AutomationView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("🤖 Automation")
                    .font(.title.bold())
                    .padding(.top, 40)
                
                Text("Coming soon!")
                    .foregroundColor(.gray)
            }
        }
    }
}

struct ShopView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("🛒 Shop")
                    .font(.title.bold())
                    .padding(.top, 40)
                
                Text("Coming soon!")
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    GameView(farmID: UUID())
}
