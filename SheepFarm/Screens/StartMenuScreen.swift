import SwiftUI

struct StartMenuScreen: View {
    let onNewFarm: () -> Void
    let onContinue: () -> Void

    @State private var hasSavedGame = false

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

                Spacer()

                // Buttons
                VStack(spacing: 16) {
                    // Continue button (only if saved game exists)
                    if hasSavedGame {
                        Button(action: onContinue) {
                            Text("Continue Game")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue.opacity(0.8))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                )
                        }
                    }

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
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Check if saved game exists
            hasSavedGame = UserDefaults.standard.data(forKey: "gameState") != nil
        }
    }
}

#Preview {
    StartMenuScreen(
        onNewFarm: {},
        onContinue: {}
    )
}
