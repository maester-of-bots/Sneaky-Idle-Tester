import SwiftUI

struct LoadingScreen: View {
    @State private var isRotating = false
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            // Cloudy sky gray background
            Color(red: 0.7, green: 0.73, blue: 0.76)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Rotating loading icon
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.white, lineWidth: 8)
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1.0)
                            .repeatForever(autoreverses: false),
                        value: isRotating
                    )
                    .onAppear {
                        isRotating = true
                    }
                
                // Pulsing "Loading" text
                Text("Loading")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(isPulsing ? 0.4 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                        value: isPulsing
                    )
                    .onAppear {
                        isPulsing = true
                    }
            }
        }
    }
}

#Preview {
    LoadingScreen()
}
