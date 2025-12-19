import SwiftUI

struct SavedFarm: Identifiable, Codable {
    let id: UUID
    let name: String
    let lastPlayed: Date
    let totalSheep: Int
    let totalKroner: Double
    
    init(id: UUID = UUID(), name: String, lastPlayed: Date = Date(), totalSheep: Int = 0, totalKroner: Double = 0) {
        self.id = id
        self.name = name
        self.lastPlayed = lastPlayed
        self.totalSheep = totalSheep
        self.totalKroner = totalKroner
    }
}

struct StartMenuScreen: View {
    @State private var savedFarms: [SavedFarm] = []
    let onNewFarm: () -> Void
    let onLoadFarm: (UUID) -> Void
    
    var body: some View {
        ZStack {
            // Cloudy sky gray background
            Color(red: 0.7, green: 0.73, blue: 0.76)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Game title
                Text("Fjallabær Sheep Farm")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 60)
                
                // Saved farms rectangle container
                VStack(spacing: 0) {
                    if savedFarms.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.3))
                            
                            Text("No saved farms")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("Start a new farm to begin")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // List of saved farms
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(savedFarms) { farm in
                                    SavedFarmRow(farm: farm)
                                        .onTapGesture {
                                            onLoadFarm(farm.id)
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.5)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                )
                .padding(.horizontal, 30)
                
                Spacer()
                
                // New Farm button
                Button(action: onNewFarm) {
                    Text("New Farm")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.8))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            loadSavedFarms()
        }
    }
    
    private func loadSavedFarms() {
        // Load saved farms from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "savedFarms"),
           let decoded = try? JSONDecoder().decode([SavedFarm].self, from: data) {
            savedFarms = decoded.sorted { $0.lastPlayed > $1.lastPlayed }
        }
    }
}

struct SavedFarmRow: View {
    let farm: SavedFarm
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(farm.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 20) {
                    HStack(spacing: 4) {
                        Image(systemName: "camera.macro")
                        Text("\(farm.totalSheep)")
                            .font(.system(size: 14))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "coloncurrencysign.circle")
                        Text(String(format: "%.0f kr", farm.totalKroner))
                            .font(.system(size: 14))
                    }
                }
                .foregroundColor(.white.opacity(0.8))
                
                Text("Last played: \(formatDate(farm.lastPlayed))")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.4))
                .font(.system(size: 16, weight: .semibold))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.2))
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    StartMenuScreen(
        onNewFarm: {},
        onLoadFarm: { _ in }
    )
}
