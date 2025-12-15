import SwiftUI

struct MainGameView: View {
    @ObservedObject var gameManager: GameManager
    @State private var showSettings = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [GameColors.skyBlue, GameColors.lightSky, GameColors.grass],
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HeaderView(gameManager: gameManager)
                    
                    // Tab selection
                    Picker("", selection: $selectedTab) {
                        Text("Farm").tag(0)
                        Text("Sheep").tag(1)
                        Text("Upgrades").tag(2)
                        Text("Achievements").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    // Content based on tab
                    TabView(selection: $selectedTab) {
                        FarmView(gameManager: gameManager)
                            .tag(0)
                        
                        SheepListView(gameManager: gameManager)
                            .tag(1)
                        
                        UpgradesView(gameManager: gameManager)
                            .tag(2)
                        
                        AchievementsView(gameManager: gameManager)
                            .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                
                // Achievement notifications
                VStack {
                    Spacer()
                    ForEach(gameManager.newAchievements) { achievement in
                        AchievementNotification(achievement: achievement) {
                            gameManager.dismissAchievement(achievement)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(gameManager: gameManager, isPresented: $showSettings)
            }
        }
    }
}

struct AchievementNotification: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    @State private var isShowing = false
    
    var body: some View {
        HStack(spacing: 12) {
            Text(achievement.emoji)
                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("🏆 Achievement Unlocked!")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                Text(achievement.name)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(
            LinearGradient(colors: [GameColors.gold, GameColors.darkGold],
                          startPoint: .leading,
                          endPoint: .trailing)
        )
        .cornerRadius(15)
        .shadow(radius: 10)
        .offset(y: isShowing ? 0 : 200)
        .onAppear {
            withAnimation(.spring()) {
                isShowing = true
            }
        }
    }
}

struct HeaderView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 8) {
            Text("🐑 Fjallabær Sheep Farm 🐑")
                .font(.title2.bold())
                .foregroundColor(GameColors.darkGreen)
            
            Text(gameManager.gameState.farmerName + "'s Farm")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // BIG CURRENCY DISPLAY
            HStack {
                Text("💰")
                    .font(.title)
                Text(gameManager.gameState.currency.formatCurrency())
                    .font(.title.bold())
                    .foregroundColor(GameColors.darkText)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(GameColors.gold.opacity(0.3))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(GameColors.darkGold, lineWidth: 2)
            )
            
            // Production rate (prominently displayed)
            let productionRate = gameManager.getWoolPerSecond()
            if productionRate > 0 {
                HStack(spacing: 6) {
                    Text("⚡")
                    Text(productionRate.formatCompact() + "/sec")
                        .font(.subheadline.bold())
                    if gameManager.woolGainThisSecond > 0 {
                        Text("+\(gameManager.woolGainThisSecond.formatCompact())")
                            .font(.caption.bold())
                            .foregroundColor(GameColors.springGreen)
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(GameColors.springGreen.opacity(0.2))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(GameColors.springGreen, lineWidth: 2)
                )
            }
            
            // Weather display
            HStack {
                Text(gameManager.gameState.weather.emoji)
                Text(gameManager.gameState.weather.description)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(GameColors.lightBlue)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(GameColors.skyBlue, lineWidth: 2)
            )
        }
        .padding()
        .background(Color.white.opacity(0.9))
    }
}

struct FarmView: View {
    @ObservedObject var gameManager: GameManager
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats panel
                StatsPanel(gameManager: gameManager)
                
                // Sheep button with animation
                VStack(spacing: 10) {
                    Button(action: {
                        gameManager.clickSheep()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isAnimating = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isAnimating = false
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(colors: [Color(hex: "FFE4E1"), GameColors.wheat],
                                                 startPoint: .topLeading,
                                                 endPoint: .bottomTrailing)
                                )
                                .frame(width: 120, height: 120)
                                .shadow(radius: isAnimating ? 15 : 10)
                            
                            Text("✂️")
                                .font(.system(size: 50))
                                .rotationEffect(.degrees(isAnimating ? 20 : 0))
                        }
                    }
                    .buttonStyle(BounceButtonStyle())
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    
                    Text("Click to shear wool!")
                        .font(.subheadline.bold())
                        .foregroundColor(GameColors.darkGreen)
                    
                    // WOOL COUNTER
                    VStack(spacing: 4) {
                        Text("🧶 Wool Collected")
                            .font(.caption.bold())
                            .foregroundColor(GameColors.darkText)
                        Text(gameManager.gameState.wool.formatNumber())
                            .font(.title2.bold())
                            .foregroundColor(GameColors.brown)
                    }
                    .padding()
                    .background(GameColors.wheat)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(GameColors.brown, lineWidth: 2)
                    )
                }
                .padding()
                
                // Wool actions
                VStack(spacing: 12) {
                    // Sell Wool
                    ActionButton(
                        title: "🧶 Sell Raw Wool",
                        subtitle: "\(gameManager.gameState.wool.formatNumber()) wool = \((gameManager.gameState.wool * 10).formatNumber()) kr",
                        color: GameColors.darkGold,
                        enabled: gameManager.gameState.wool >= 1.0
                    ) {
                        gameManager.sellWool()
                    }
                    
                    // Process Wool
                    if gameManager.gameState.processingUnlocked {
                        ActionButton(
                            title: "🧵 Process Wool",
                            subtitle: "Convert \((floor(gameManager.gameState.wool / 100) * 100).formatNumber()) wool → products",
                            color: GameColors.brown,
                            enabled: gameManager.gameState.wool >= 100
                        ) {
                            gameManager.processWool()
                        }
                        
                        // Sell Products
                        ActionButton(
                            title: "👕 Sell Products",
                            subtitle: "\(gameManager.gameState.products) products = \((Double(gameManager.gameState.products) * 500).formatNumber()) kr",
                            color: GameColors.steelBlue,
                            enabled: gameManager.gameState.products > 0
                        ) {
                            gameManager.sellProducts()
                        }
                    }
                }
                .padding()
                
                // Automation toggles
                if gameManager.gameState.processingUnlocked {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🤖 Automation")
                            .font(.headline.bold())
                            .foregroundColor(GameColors.darkGreen)
                        
                        Toggle("Auto-sell Raw Wool", isOn: $gameManager.gameState.autoSellWool)
                            .foregroundColor(GameColors.darkText)
                        Toggle("Auto-process Wool", isOn: $gameManager.gameState.autoProcess)
                            .foregroundColor(GameColors.darkText)
                        Toggle("Auto-sell Products", isOn: $gameManager.gameState.autoSellProducts)
                            .foregroundColor(GameColors.darkText)
                    }
                    .padding()
                    .background(Color(hex: "fffaf2"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "e0c27a"), lineWidth: 1)
                    )
                    .padding()
                }
            }
        }
    }
}

struct StatsPanel: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📊 Farm Statistics")
                .font(.headline.bold())
                .foregroundColor(GameColors.darkGreen)
                .padding(.bottom, 4)
            
            // Highlight production
            HStack {
                Text("⚡ Production:")
                    .font(.subheadline.bold())
                    .foregroundColor(GameColors.darkText)
                Spacer()
                Text(gameManager.getWoolPerSecond().formatNumber() + "/sec")
                    .font(.subheadline.bold())
                    .foregroundColor(GameColors.springGreen)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(Color(hex: "90EE90").opacity(0.3))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(GameColors.springGreen, lineWidth: 2)
            )
            
            StatRow(label: "🐑 Total Sheep", value: "\(gameManager.getTotalSheep())")
            StatRow(label: "🧶 Raw Wool", value: gameManager.gameState.wool.formatNumber())
            StatRow(label: "👕 Products", value: "\(gameManager.gameState.products)")
            StatRow(label: "Total Multiplier", value: "×\(String(format: "%.2f", gameManager.getTotalMultiplier()))")
            StatRow(label: "🏆 Achievements", value: "\(gameManager.gameState.unlockedAchievements.count)/\(Achievement.allAchievements.count)")
            
            if gameManager.gameState.processingUnlocked {
                let processingLevel = gameManager.gameState.upgradeLevels["processing"] ?? 0
                StatRow(label: "Processing Bonus", value: "+\(processingLevel * 20)%")
            }
        }
        .padding()
        .background(GameColors.beige)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(GameColors.tan, lineWidth: 2)
        )
        .padding()
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(GameColors.darkText)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.black)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.white)
        .cornerRadius(6)
    }
}

struct ActionButton: View {
    let title: String
    let subtitle: String
    let color: Color
    let enabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(enabled ? color : Color.gray)
            .cornerRadius(10)
        }
        .buttonStyle(BounceButtonStyle())
        .disabled(!enabled)
    }
}
