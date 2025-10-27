import SwiftUI

struct MainGameView: View {
    @ObservedObject var gameManager: GameManager
    @State private var showSettings = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color(hex: "87CEEB"), Color(hex: "E0F6FF"), Color(hex: "98FB98")],
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
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
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

struct HeaderView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 8) {
            Text("🐑 Fjallabær Sheep Farm 🐑")
                .font(.title2.bold())
                .foregroundColor(Color(hex: "2F4F4F"))
            
            Text(gameManager.gameState.farmerName + "'s Farm")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Weather display
            HStack {
                Text(gameManager.gameState.weather.emoji)
                Text(gameManager.gameState.weather.description)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(hex: "E6F3FF"))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: "87CEEB"), lineWidth: 2)
            )
        }
        .padding()
        .background(Color.white.opacity(0.9))
    }
}

struct FarmView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats panel
                StatsPanel(gameManager: gameManager)
                
                // Sheep button
                VStack(spacing: 10) {
                    Button(action: {
                        gameManager.clickSheep()
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(colors: [Color(hex: "FFE4E1"), Color(hex: "FFF8DC")],
                                                 startPoint: .topLeading,
                                                 endPoint: .bottomTrailing)
                                )
                                .frame(width: 120, height: 120)
                                .shadow(radius: 10)
                            
                            Text("✂️")
                                .font(.system(size: 50))
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Text("Click to shear wool!")
                        .font(.subheadline.bold())
                        .foregroundColor(Color(hex: "2F4F4F"))
                }
                .padding()
                
                // Wool actions
                VStack(spacing: 12) {
                    // Sell Wool
                    ActionButton(
                        title: "🧶 Sell Raw Wool",
                        subtitle: "Wool: \(gameManager.gameState.wool.formatNumber()) (worth \(Int(gameManager.gameState.wool * 10)) kr)",
                        color: Color(hex: "DAA520"),
                        enabled: gameManager.gameState.wool >= 1.0
                    ) {
                        gameManager.sellWool()
                    }
                    
                    // Process Wool
                    if gameManager.gameState.processingUnlocked {
                        ActionButton(
                            title: "🧵 Process Wool",
                            subtitle: "Convert 100 wool → products",
                            color: Color(hex: "8B4513"),
                            enabled: gameManager.gameState.wool >= 100
                        ) {
                            gameManager.processWool()
                        }
                        
                        // Sell Products
                        ActionButton(
                            title: "👕 Sell Products",
                            subtitle: "Products: \(gameManager.gameState.products) (worth \(gameManager.gameState.products * 500) kr)",
                            color: Color(hex: "4682B4"),
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
                            .foregroundColor(Color(hex: "2F4F4F"))
                        
                        Toggle("Auto-sell Raw Wool", isOn: $gameManager.gameState.autoSellWool)
                            .foregroundColor(Color(hex: "1a1a1a"))
                        Toggle("Auto-process Wool", isOn: $gameManager.gameState.autoProcess)
                            .foregroundColor(Color(hex: "1a1a1a"))
                        Toggle("Auto-sell Products", isOn: $gameManager.gameState.autoSellProducts)
                            .foregroundColor(Color(hex: "1a1a1a"))
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
                .foregroundColor(Color(hex: "2F4F4F"))
                .padding(.bottom, 4)
            
            StatRow(label: "💰 Krónur", value: gameManager.gameState.currency.formatCurrency())
            StatRow(label: "🐑 Total Sheep", value: "\(gameManager.getTotalSheep())")
            StatRow(label: "🧶 Raw Wool", value: gameManager.gameState.wool.formatNumber())
            StatRow(label: "👕 Products", value: "\(gameManager.gameState.products)")
            StatRow(label: "Wool/sec", value: gameManager.getWoolPerSecond().formatNumber())
            StatRow(label: "Total Multiplier", value: "×\(String(format: "%.2f", gameManager.getTotalMultiplier()))")
            
            if gameManager.gameState.processingUnlocked {
                let processingLevel = gameManager.gameState.upgradeLevels["processing"] ?? 0
                StatRow(label: "Processing Bonus", value: "+\(processingLevel * 20)%")
            }
        }
        .padding()
        .background(Color(hex: "F5F5DC"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "DEB887"), lineWidth: 2)
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
                .foregroundColor(Color(hex: "1a1a1a"))
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(Color(hex: "000000"))
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
        .disabled(!enabled)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
