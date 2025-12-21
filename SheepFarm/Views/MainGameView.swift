//
//  MainGameView.swift
//  Fjallabær Sheep Farm
//

import SwiftUI

enum GameTab {
    case upgrades
    case sheep
    case automation
    case shop
}

struct MainGameView: View {
    @ObservedObject var gameManager: GameManager
    @State private var selectedTab: GameTab = .sheep
    @State private var buyMode: BuyMode = .one
    @State private var showSettings = false
    
    enum BuyMode {
        case one
        case max
        
        mutating func toggle() {
            self = (self == .one) ? .max : .one
        }
        
        var displayText: String {
            switch self {
            case .one: return "×1"
            case .max: return "Max"
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top Bar
                TopBar(gameManager: gameManager, showSettings: $showSettings)
                
                // Main Content Area
                ZStack {
                    Color(red: 0.87, green: 0.91, blue: 0.85) // Light green #DFE9D8
                        .ignoresSafeArea(edges: .horizontal)
                    
                    switch selectedTab {
                    case .sheep:
                        SheepFarmView(gameManager: gameManager, buyMode: $buyMode)
                    case .upgrades:
                        UpgradesView(gameManager: gameManager)
                    case .automation:
                        PlaceholderView(icon: "🤖", text: "Automation Coming Soon!")
                    case .shop:
                        PlaceholderView(icon: "🛒", text: "Shop Coming Soon!")
                    }
                }
                
                // Bottom Navigation Bar
                BottomNavigationBar(selectedTab: $selectedTab)
            }
            
            // Floating Buy Mode Toggle (only on Sheep tab)
            if selectedTab == .sheep {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        BuyModeToggle(buyMode: $buyMode)
                            .padding(.trailing, 20)
                            .padding(.bottom, 70) // Above bottom bar
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(gameManager: gameManager)
        }
    }
}

// MARK: - Top Bar
struct TopBar: View {
    @ObservedObject var gameManager: GameManager
    @Binding var showSettings: Bool
    
    var woolPerSecond: Double {
        return gameManager.calculateProduction()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Currency
            HStack(spacing: 4) {
                Text("💰")
                Text(gameManager.gameState.currency.formatNumber())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Wool
            HStack(spacing: 4) {
                Text("🧶")
                Text(gameManager.gameState.wool.formatNumber())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Text("(\(woolPerSecond.formatNumber())/s)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Sell button
            Button(action: {
                gameManager.sellWool()
            }) {
                Text("Sell")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(gameManager.gameState.wool > 0 ? Color.orange : Color.gray)
                    .cornerRadius(8)
            }
            .disabled(gameManager.gameState.wool == 0)
            
            // Settings
            Button(action: {
                showSettings = true
            }) {
                Text("⚙️")
                    .font(.system(size: 24))
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(Color(red: 0.13, green: 0.54, blue: 0.13)) // Dark green #228B22
        .frame(height: 50)
    }
}

// MARK: - Bottom Navigation Bar
struct BottomNavigationBar: View {
    @Binding var selectedTab: GameTab
    
    var body: some View {
        HStack(spacing: 0) {
            NavButton(icon: "⬆️", isSelected: selectedTab == .upgrades) {
                selectedTab = .upgrades
            }
            
            Spacer()
            
            NavButton(icon: "🐑", isSelected: selectedTab == .sheep) {
                selectedTab = .sheep
            }
            
            Spacer()
            
            NavButton(icon: "🤖", isSelected: selectedTab == .automation) {
                selectedTab = .automation
            }
            
            Spacer()
            
            NavButton(icon: "🛒", isSelected: selectedTab == .shop) {
                selectedTab = .shop
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 5)
        .background(Color(red: 0.13, green: 0.54, blue: 0.13)) // Dark green
        .frame(height: 50)
    }
}

struct NavButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 45, height: 45)
                }
                
                Text(icon)
                    .font(.system(size: 28))
            }
            .frame(width: 40, height: 40)
        }
    }
}

// MARK: - Buy Mode Toggle
struct BuyModeToggle: View {
    @Binding var buyMode: MainGameView.BuyMode
    
    var body: some View {
        Button(action: {
            buyMode.toggle()
        }) {
            Text(buyMode.displayText)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 35)
                .background(Color(red: 0.13, green: 0.54, blue: 0.13))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: 2)
                )
        }
        .shadow(radius: 4)
    }
}

// MARK: - Placeholder View
struct PlaceholderView: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(icon)
                .font(.system(size: 80))
            Text(text)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top, 20)
                
                // Game info
                if let region = gameManager.gameState.selectedRegion {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Farmer: \(gameManager.gameState.farmerName)")
                        Text("Region: \(region.name)")
                        Text("Weather: \(gameManager.gameState.currentWeather.emoji) \(gameManager.gameState.currentWeather.rawValue)")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Reset button
                Button(action: {
                    gameManager.deleteSaveGame()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Reset Game")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
