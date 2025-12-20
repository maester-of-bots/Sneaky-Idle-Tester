import SwiftUI

// MARK: - Sheep Type Model
struct SheepType: Identifiable {
    let id: Int
    let name: String
    let baseCost: Double
    let baseProduction: Double
    let emoji: String
    
    static let allTypes: [SheepType] = [
        SheepType(id: 1, name: "Icelandic Sheep", baseCost: 10, baseProduction: 0.1, emoji: "🐑"),
        SheepType(id: 2, name: "Leader Sheep", baseCost: 50, baseProduction: 0.5, emoji: "🐏"),
        SheepType(id: 3, name: "Merino Sheep", baseCost: 200, baseProduction: 2.0, emoji: "🐑"),
        SheepType(id: 4, name: "Suffolk Sheep", baseCost: 1000, baseProduction: 10, emoji: "🐏"),
        SheepType(id: 5, name: "Jacob Sheep", baseCost: 5000, baseProduction: 50, emoji: "🐑"),
        SheepType(id: 6, name: "Dorset Sheep", baseCost: 25000, baseProduction: 250, emoji: "🐏"),
        SheepType(id: 7, name: "Romney Sheep", baseCost: 125000, baseProduction: 1250, emoji: "🐑"),
        SheepType(id: 8, name: "Leicester Sheep", baseCost: 625000, baseProduction: 6250, emoji: "🐏"),
        SheepType(id: 9, name: "Cotswold Sheep", baseCost: 3000000, baseProduction: 30000, emoji: "🐑"),
        SheepType(id: 10, name: "Golden Fleece", baseCost: 15000000, baseProduction: 150000, emoji: "✨")
    ]
}

// MARK: - Game State
class GameState: ObservableObject {
    @Published var kroner: Double = 200
    @Published var specialCurrency: Int = 0
    @Published var sheepCounts: [Int: Int] = [:]
    @Published var buyMode: BuyMode = .one
    
    enum BuyMode {
        case one
        case max
        
        var displayText: String {
            switch self {
            case .one: return "×1"
            case .max: return "Max"
            }
        }
    }
    
    func buyAmount(for sheepType: SheepType) -> Int {
        switch buyMode {
        case .one:
            return 1
        case .max:
            return maxAffordable(for: sheepType)
        }
    }
    
    func maxAffordable(for sheepType: SheepType) -> Int {
        guard sheepType.baseCost > 0 else { return 0 }
        return max(0, Int(kroner / sheepType.baseCost))
    }
    
    func canBuy(_ sheepType: SheepType, amount: Int) -> Bool {
        let totalCost = sheepType.baseCost * Double(amount)
        return kroner >= totalCost
    }
    
    func buySheep(_ sheepType: SheepType, amount: Int) {
        let totalCost = sheepType.baseCost * Double(amount)
        guard canBuy(sheepType, amount: amount) else { return }
        
        kroner -= totalCost
        sheepCounts[sheepType.id, default: 0] += amount
    }
}

// MARK: - Main Game View
struct GameView: View {
    let farmID: UUID
    @StateObject private var gameState = GameState()
    @State private var selectedTab: GameTab = .sheep
    
    enum GameTab {
        case upgrades, sheep, automation, shop
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.87, green: 0.92, blue: 0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // TOP BAR
                TopBar(kroner: gameState.kroner, specialCurrency: gameState.specialCurrency)
                
                // MAIN SCROLLABLE AREA
                ZStack {
                    ScrollView {
                        FarmPathView(gameState: gameState)
                            .padding(.bottom, 80) // Space for buy mode button
                    }
                    
                    // Buy Mode Toggle Button (floating above bottom bar)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            BuyModeToggle(gameState: gameState)
                                .padding(.trailing, 20)
                                .padding(.bottom, 10)
                        }
                    }
                }
                
                // BOTTOM BAR
                BottomBar(selectedTab: $selectedTab)
            }
        }
    }
}

// MARK: - Top Bar
struct TopBar: View {
    let kroner: Double
    let specialCurrency: Int
    
    var body: some View {
        HStack(spacing: 12) {
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

            // Special Currency Display
            HStack(spacing: 8) {
                Text("⭐")
                    .font(.system(size: 24))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Special")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    Text("\(specialCurrency)")
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

            Spacer()

            // Settings Button
            Button(action: {
                // Settings action
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.white)
            }
            .padding(.trailing, 14)
        }
        .frame(height: 50)
        .background(Color(red: 0.13, green: 0.54, blue: 0.13)) // Dark green
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
        .background(Color(red: 0.13, green: 0.54, blue: 0.13)) // Dark green
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
    @ObservedObject var gameState: GameState

    var body: some View {
        ZStack {
            // Winding brown path
            Path { path in
                let width = UIScreen.main.bounds.width
                let startX = width / 2

                path.move(to: CGPoint(x: startX, y: 0))

                // Create a winding path
                for i in 0...20 {
                    let y = CGFloat(i) * 200
                    let x = startX + sin(CGFloat(i) * 0.5) * 60
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color(red: 0.55, green: 0.27, blue: 0.07), lineWidth: 50) // Brown
            .opacity(0.6)

            // Sheep farms along the path
            VStack(spacing: 140) {
                ForEach(Array(stride(from: 0, to: SheepType.allTypes.count, by: 2)), id: \.self) { index in
                    HStack(spacing: 35) {
                        // Left sheep farm
                        if index < SheepType.allTypes.count {
                            SheepFarmCard(
                                sheepType: SheepType.allTypes[index],
                                gameState: gameState
                            )
                        }

                        Spacer()

                        // Right sheep farm
                        if index + 1 < SheepType.allTypes.count {
                            SheepFarmCard(
                                sheepType: SheepType.allTypes[index + 1],
                                gameState: gameState
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
    let sheepType: SheepType
    @ObservedObject var gameState: GameState

    var buyAmount: Int {
        gameState.buyAmount(for: sheepType)
    }

    var totalCost: Double {
        sheepType.baseCost * Double(buyAmount)
    }

    var canAfford: Bool {
        gameState.canBuy(sheepType, amount: buyAmount)
    }

    var body: some View {
        VStack(spacing: 8) {
            // Sheep count owned
            Text("\(gameState.sheepCounts[sheepType.id, default: 0])")
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

            // Sheep name
            Text(sheepType.name)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.2))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 28)

            // Buy button
            Button(action: {
                gameState.buySheep(sheepType, amount: buyAmount)
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
                        .fill(canAfford ?
                              Color(red: 0.53, green: 0.81, blue: 0.92) : // Light blue
                              Color.gray.opacity(0.5))
                )
            }
            .disabled(!canAfford)
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
    @ObservedObject var gameState: GameState
    
    var body: some View {
        Button(action: {
            gameState.buyMode = gameState.buyMode == .one ? .max : .one
        }) {
            Text(gameState.buyMode.displayText)
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

#Preview {
    GameView(farmID: UUID())
}
