import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            // Cloudy sky gray background
            Color(red: 0.7, green: 0.73, blue: 0.76)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Placeholder logo circle
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text("TGS")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                // Company name
                Text("TGS Entertainment")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    SplashScreen()
}
