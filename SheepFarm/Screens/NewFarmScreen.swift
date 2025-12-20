import SwiftUI

// MARK: - Region Model
struct Region: Identifiable {
    let id: String
    let name: String
    let difficulty: String
    let description: String
    let startingCurrency: Double
    let weatherBonus: Double
    let productionBonus: Double

    static let all: [Region] = [
        Region(
            id: "reykjavik",
            name: "Reykjavík",
            difficulty: "Easy",
            description: "The capital region. Mild weather and access to markets make this an ideal starting location.",
            startingCurrency: 200,
            weatherBonus: 1.0,
            productionBonus: 1.0
        ),
        Region(
            id: "south",
            name: "South Iceland",
            difficulty: "Easy",
            description: "Rich farmlands with relatively mild weather. Good for beginners.",
            startingCurrency: 180,
            weatherBonus: 1.1,
            productionBonus: 1.0
        ),
        Region(
            id: "north",
            name: "North Iceland",
            difficulty: "Medium",
            description: "Cooler climate but excellent grazing. A balanced challenge.",
            startingCurrency: 150,
            weatherBonus: 0.9,
            productionBonus: 1.2
        ),
        Region(
            id: "eastfjords",
            name: "East Fjords",
            difficulty: "Medium",
            description: "Remote fjords with stunning scenery. Moderate difficulty.",
            startingCurrency: 140,
            weatherBonus: 0.85,
            productionBonus: 1.25
        ),
        Region(
            id: "westfjords",
            name: "Westfjords",
            difficulty: "Hard",
            description: "Harsh weather and remote location. For experienced farmers only!",
            startingCurrency: 100,
            weatherBonus: 0.7,
            productionBonus: 1.5
        )
    ]
}

// MARK: - New Farm Screen
struct NewFarmScreen: View {
    let onFarmCreated: ((String, Region)) -> Void
    let onCancel: () -> Void

    @State private var farmerName: String = ""
    @State private var selectedRegion: Region?

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.53, green: 0.81, blue: 0.92), // Sky blue
                    Color(red: 0.88, green: 0.96, blue: 1.0),  // Light blue
                    Color(red: 0.6, green: 0.98, blue: 0.6)    // Light green
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        Text("🐑 Choose Your Farm Location 🐑")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(red: 0.17, green: 0.37, blue: 0.18))
                            .multilineTextAlignment(.center)
                            .padding()

                        Text("Fjallabær Sheep Farm")
                            .font(.title2.bold())
                            .foregroundColor(Color(red: 0.18, green: 0.31, blue: 0.31))

                        // Region Selection
                        VStack(spacing: 15) {
                            ForEach(Region.all) { region in
                                RegionButton(
                                    region: region,
                                    isSelected: selectedRegion?.id == region.id
                                ) {
                                    selectedRegion = region
                                    // Auto-scroll to show region details
                                    withAnimation {
                                        proxy.scrollTo("regionDetails", anchor: .bottom)
                                    }
                                }
                            }
                        }
                        .padding()

                        // Selected Region Details
                        if let region = selectedRegion {
                            VStack(spacing: 12) {
                                Text("\(region.name) - \(region.difficulty)")
                                    .font(.title3.bold())
                                    .foregroundColor(Color(red: 0.17, green: 0.37, blue: 0.18))

                                Text(region.description)
                                    .font(.body)
                                    .foregroundColor(Color(red: 0.18, green: 0.31, blue: 0.31))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)

                                // Stats
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Starting Currency:")
                                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                                        Spacer()
                                        Text("\(Int(region.startingCurrency)) kr")
                                            .bold()
                                            .foregroundColor(.black)
                                    }
                                    HStack {
                                        Text("Weather Bonus:")
                                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                                        Spacer()
                                        Text("×\(String(format: "%.1f", region.weatherBonus))")
                                            .bold()
                                            .foregroundColor(.black)
                                    }
                                    HStack {
                                        Text("Production Bonus:")
                                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
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

                                // ⭐ FARMER NAME INPUT - TEXT COLOR IS HERE! ⭐
                                // Change the line below to make text visible:
                                // .foregroundColor(.black) ← CHANGE THIS TO ANY COLOR YOU WANT!
                                TextField("Enter your name", text: $farmerName)
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)  // ← TEXT COLOR HERE!
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                                    )

                                // Start Button
                                Button(action: {
                                    createFarm(region: region)
                                }) {
                                    Text("Start Farming!")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            farmerName.isEmpty ?
                                                Color.gray :
                                                Color(red: 0.13, green: 0.54, blue: 0.13)
                                        )
                                        .cornerRadius(10)
                                }
                                .disabled(farmerName.isEmpty)
                                .padding(.horizontal)
                            }
                            .padding()
                            .background(Color(red: 0.96, green: 0.96, blue: 0.86))
                            .cornerRadius(15)
                            .padding()
                            .id("regionDetails")
                        }

                        Spacer()

                        // Cancel Button
                        Button(action: onCancel) {
                            Text("Cancel")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }

    private func createFarm(region: Region) {
        let name = farmerName.isEmpty ? "Farmer" : farmerName
        onFarmCreated((name, region))
    }
}

// MARK: - Region Button Component
struct RegionButton: View {
    let region: Region
    let isSelected: Bool
    let action: () -> Void

    var difficultyColor: Color {
        switch region.difficulty {
        case "Easy": return Color(red: 0.56, green: 0.93, blue: 0.56)  // Light green
        case "Medium": return Color(red: 1.0, green: 0.92, blue: 0.23) // Yellow
        case "Hard": return Color(red: 1.0, green: 0.42, blue: 0.42)   // Light red
        default: return .gray
        }
    }

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(region.name)
                        .font(.headline.bold())
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                    Text(region.difficulty)
                        .font(.subheadline.bold())
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
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
        }
    }
}

#Preview {
    NewFarmScreen(
        onFarmCreated: { _ in },
        onCancel: {}
    )
}