import SwiftUI

struct NewFarmScreen: View {
    let onFarmCreated: (UUID) -> Void
    let onCancel: () -> Void
    
    @State private var farmName: String = ""
    
    var body: some View {
        ZStack {
            // Cloudy sky gray background
            Color(red: 0.7, green: 0.73, blue: 0.76)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("New Farm")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 60)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Farm Name")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    TextField("Enter farm name", text: $farmName)
                        .font(.system(size: 20))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.9))
                        )
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        createFarm()
                    }) {
                        Text("Create Farm")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(farmName.isEmpty ? Color.gray.opacity(0.5) : Color.green.opacity(0.8))
                            )
                    }
                    .disabled(farmName.isEmpty)
                    
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func createFarm() {
        let newFarm = SavedFarm(
            name: farmName.isEmpty ? "My Farm" : farmName,
            lastPlayed: Date(),
            totalSheep: 0,
            totalKroner: 100.0
        )
        
        // Save to UserDefaults
        var savedFarms: [SavedFarm] = []
        if let data = UserDefaults.standard.data(forKey: "savedFarms"),
           let decoded = try? JSONDecoder().decode([SavedFarm].self, from: data) {
            savedFarms = decoded
        }
        savedFarms.append(newFarm)
        
        if let encoded = try? JSONEncoder().encode(savedFarms) {
            UserDefaults.standard.set(encoded, forKey: "savedFarms")
        }
        
        onFarmCreated(newFarm.id)
    }
}

#Preview {
    NewFarmScreen(
        onFarmCreated: { _ in },
        onCancel: {}
    )
}
