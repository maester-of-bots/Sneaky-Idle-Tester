import SwiftUI

struct StartScreenView: View {
    @ObservedObject var gameManager: GameManager
    @State private var farmerName: String = ""
    @State private var selectedRegion: Region?
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "87CEEB"), Color(hex: "E0F6FF"), Color(hex: "98FB98")],
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("🐑 Choose Your Farm Location 🐑")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "2c5f2d"))
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("Fjallabær Sheep Farm")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    // Regions
                    VStack(spacing: 15) {
                        ForEach(Region.all, id: \.id) { region in
                            RegionButton(region: region,
                                       isSelected: selectedRegion?.id == region.id) {
                                selectedRegion = region
                            }
                        }
                    }
                    .padding()
                    
                    // Selected region info
                    if let region = selectedRegion {
                        VStack(spacing: 12) {
                            Text("\(region.name) - \(region.difficulty)")
                                .font(.title3.bold())
                                .foregroundColor(Color(hex: "2c5f2d"))
                            
                            Text(region.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Starting Currency:")
                                    Spacer()
                                    Text("\(Int(region.startingCurrency)) kr")
                                        .bold()
                                }
                                HStack {
                                    Text("Weather Bonus:")
                                    Spacer()
                                    Text("×\(String(format: "%.1f", region.weatherBonus))")
                                        .bold()
                                }
                                HStack {
                                    Text("Production Bonus:")
                                    Spacer()
                                    Text("×\(String(format: "%.1f", region.productionBonus))")
                                        .bold()
                                }
                            }
                            .font(.subheadline)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            
                            // Name input
                            TextField("Enter your name", text: $farmerName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
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
                                    .background(farmerName.isEmpty ? Color.gray : Color(hex: "228b22"))
                                    .cornerRadius(10)
                            }
                            .disabled(farmerName.isEmpty)
                            .padding(.horizontal)
                        }
                        .padding()
                        .background(Color(hex: "f5f5dc"))
                        .cornerRadius(15)
                        .padding()
                    }
                    
                    Spacer()
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
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(region.difficulty)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Circle()
                    .fill(difficultyColor)
                    .frame(width: 30, height: 30)
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
            )
        }
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
