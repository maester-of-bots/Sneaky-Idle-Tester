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
    @State private var selectedFarmID: UUID?
    
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
                                currentState = .startMenu
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
                        selectedFarmID = farmID
                        withAnimation {
                            currentState = .playingGame
                        }
                    }
                )
                
            case .newFarm:
                NewFarmScreen(
                    onFarmCreated: { farmID in
                        selectedFarmID = farmID
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
                GameView(farmID: selectedFarmID ?? UUID())
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentState)
    }
}
