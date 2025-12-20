import SwiftUI

enum AppState {
    case splash
    case loading
    case startMenu
    case newFarm
    case playingGame
}

struct AppFlowView: View {
    @State private var currentState: AppState = .splash
    @StateObject private var gameManager = GameManager()
    
    var body: some View {
        ZStack {
            switch currentState {
            case .splash:
                SplashScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                currentState = .loading
                            }
                        }
                    }
                
            case .loading:
                LoadingScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            withAnimation {
                                // Check if game already exists
                                if UserDefaults.standard.data(forKey: "gameState") != nil {
                                    currentState = .playingGame
                                } else {
                                    currentState = .startMenu
                                }
                            }
                        }
                    }
                
            case .startMenu:
                StartMenuScreen(
                    onNewFarm: {
                        withAnimation {
                            currentState = .newFarm
                        }
                    },
                    onLoadFarm: { farmID in
                        withAnimation {
                            currentState = .playingGame
                        }
                    }
                )
                
            case .newFarm:
                NewFarmScreen(
                    onFarmCreated: { region in
                        gameManager.startGame(farmerName: region.0, region: region.1)
                        withAnimation {
                            currentState = .playingGame
                        }
                    },
                    onCancel: {
                        withAnimation {
                            currentState = .startMenu
                        }
                    }
                )
                
            case .playingGame:
                GameView(farmID: UUID())
                    .environmentObject(gameManager)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentState)
    }
}

