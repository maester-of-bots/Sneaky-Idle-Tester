import SwiftUI

struct GameView: View {
    let farmID: UUID
    
    var body: some View {
        ZStack {
            // Cloudy sky gray background
            Color(red: 0.7, green: 0.73, blue: 0.76)
                .ignoresSafeArea()
            
            VStack {
                Text("Game View")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Farm ID: \(farmID.uuidString)")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .padding()
                
                Text("(Main game will go here)")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

#Preview {
    GameView(farmID: UUID())
}
