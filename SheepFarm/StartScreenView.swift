import SwiftUI

struct StartScreenView: View {
    @ObservedObject var gameManager: GameManager
    @State private var farmerName: String = ""
    @State private var selectedRegion: Region?
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [GameColors.skyBlue, GameColors.lightSky, GameColors.grass],
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        Text("🐑 Choose Your Farm Location 🐑")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(GameColors.forestGreen)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Text("Fjallabær Sheep Farm")
                            .font(.title2.bold())
                            .foregroundColor(GameColors.darkGreen)
                        
                        // Regions
                        VStack(spacing: 15) {
                            ForEach(Region.all, id: \.id) { region in
                                RegionButton(region: region,
                                           isSelected: selectedRegion?.id == region.id) {
                                    selectedRegion = region
                                    // Auto-scroll to selected region details
                                    withAnimation {
                                        proxy.scrollTo("regionDetails", anchor: .bottom)
                                    }
                                }
                            }
                        }
                        .padding()
                        
                        // Selected region info
                        if let region = selectedRegion {
                            VStack(spacing: 12) {
                                Text("\(region.name) - \(region.difficulty)")
                                    .font(.title3.bold())
                                    .foregroundColor(GameColors.forestGreen)
                                
                                Text(region.description)
                                    .font(.body)
                                    .foregroundColor(GameColors.darkGreen)
                                    .multilineTextAlignment(.center)
                                
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Starting Currency:")
                                            .foregroundColor(GameColors.darkText)
                                        Spacer()
                                        Text("\(Int(region.startingCurrency)) kr")
                                            .bold()
                                            .foregroundColor(.black)
                                    }
                                    HStack {
                                        Text("Weather Bonus:")
                                            .foregroundColor(GameColors.darkText)
                                        Spacer()
                                        Text("×\(String(format: "%.1f", region.weatherBonus))")
                                            .bold()
                                            .foregroundColor(.black)
                                    }
                                    HStack {
                                        Text("Production Bonus:")
                                            .foregroundColor(GameColors.darkText)
                                        Spacer()
                                        Text("×\(String(format: "%.1f", region.productionBonus))")
                                            .bold()
                                            .foregroundColor(.black)
                                    }
                                }
                                .font(.subheadline)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                
                                // Name input - FIXED: Dark text on white background
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Your Name:")
                                        .font(.subheadline.bold())
                                        .foregroundColor(GameColors.darkGreen)
                                    
                                    TextField("Enter your name", text: $farmerName)
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(GameColors.darkGreen, lineWidth: 2)
                                        )
                                }
                                .padding(.horizontal)
                                
                                // Start button
                                Button(action: {
                                    if !farmerName.isEmpty && selectedRegion != nil {
                                        gameManager.startGame(farmerName: farmerName, region: region)
                                    }
                                }) {
                                    Text("Start Farming!")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(farmerName.isEmpty ? Color.gray : GameColors.springGreen)
                                        .cornerRadius(10)
                                }
                                .buttonStyle(BounceButtonStyle())
                                .disabled(farmerName.isEmpty)
                                .padding(.horizontal)
                            }
                            .padding()
                            .background(GameColors.beige)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .padding()
                            .id("regionDetails")
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

struct RegionButton: View {
    let region: Region
    let isSelected: Bool
    let action: () -> Void
    
    var difficultyColor: Color {
        switch region.difficulty {
        case "Easy": return Color(hex: "90ee90")
        case "Medium": return Color(hex: "ffeb3b")
        case "Hard": return Color(hex: "ff6b6b")
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(region.name)
                        .font(.headline.bold())
                        .foregroundColor(GameColors.darkText)
                    Text(region.difficulty)
                        .font(.subheadline.bold())
                        .foregroundColor(GameColors.mediumText)
                }
                Spacer()
                Circle()
                    .fill(difficultyColor)
                    .frame(width: 30, height: 30)
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.3) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
            )
            .shadow(color: isSelected ? .blue.opacity(0.3) : .clear, radius: 8)
        }
        .buttonStyle(BounceButtonStyle())
    }
}
