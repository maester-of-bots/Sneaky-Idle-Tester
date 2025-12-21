//
//  RegionSelectionView.swift
//  Fjallabær Sheep Farm
//

import SwiftUI

struct RegionSelectionView: View {
    @ObservedObject var gameManager: GameManager
    @Binding var showMainGame: Bool
    
    @State private var selectedRegion: Region?
    @State private var farmerName: String = ""
    @State private var scrollToDetails = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    // Header section
                    VStack(spacing: 20) {
                        Text("🐑 Choose Your Farm Location 🐑")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 40)
                            .padding(.horizontal)
                        
                        // Region buttons
                        VStack(spacing: 15) {
                            ForEach(Region.allRegions) { region in
                                RegionButton(
                                    region: region,
                                    isSelected: selectedRegion?.id == region.id,
                                    onSelect: {
                                        selectedRegion = region
                                        withAnimation {
                                            scrollToDetails = true
                                            proxy.scrollTo("details", anchor: .top)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(minHeight: UIScreen.main.bounds.height * 0.6)
                    
                    // Details card (shown when region selected)
                    if let region = selectedRegion {
                        RegionDetailsCard(
                            region: region,
                            farmerName: $farmerName,
                            onStartFarming: {
                                gameManager.startGame(farmerName: farmerName, region: region)
                                showMainGame = true
                            }
                        )
                        .id("details")
                        .padding(.top, 20)
                    }
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.53, green: 0.81, blue: 0.92), // Sky blue
                        Color(red: 0.68, green: 0.85, blue: 0.90), // Light blue
                        Color(red: 0.78, green: 0.93, blue: 0.71)  // Light green
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
}

struct RegionButton: View {
    let region: Region
    let isSelected: Bool
    let onSelect: () -> Void
    
    var difficultyColor: Color {
        switch region.difficultyColor {
        case "green": return .green
        case "yellow": return .yellow
        case "red": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                // Difficulty indicator
                Circle()
                    .fill(difficultyColor)
                    .frame(width: 20, height: 20)
                
                // Region name and difficulty
                VStack(alignment: .leading, spacing: 4) {
                    Text(region.name)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(region.difficulty)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.7))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
            )
        }
    }
}

struct RegionDetailsCard: View {
    let region: Region
    @Binding var farmerName: String
    let onStartFarming: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Region description
            Text(region.description)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            // Stats
            VStack(alignment: .leading, spacing: 10) {
                Text("Region Stats:")
                    .font(.system(size: 18, weight: .bold))
                
                HStack {
                    Text("💰 Starting Currency:")
                    Spacer()
                    Text("\(Int(region.startingCurrency)) kr")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("🌤 Weather Bonus:")
                    Spacer()
                    Text("\(String(format: "%.0f%%", region.weatherBonus * 100))")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("🐑 Production Bonus:")
                    Spacer()
                    Text("\(String(format: "%.0f%%", region.productionBonus * 100))")
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .background(Color.white.opacity(0.5))
            .cornerRadius(10)
            
            // Farmer name input
            VStack(alignment: .leading, spacing: 10) {
                Text("Farmer Name:")
                    .font(.system(size: 16, weight: .semibold))
                
                TextField("Enter your name", text: $farmerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.black) // BLACK text
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
            }
            
            // Start button
            Button(action: onStartFarming) {
                Text("Start Farming!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(farmerName.isEmpty ? Color.gray : Color.green)
                    .cornerRadius(12)
            }
            .disabled(farmerName.isEmpty)
        }
        .padding(25)
        .background(Color.white.opacity(0.85))
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
}
