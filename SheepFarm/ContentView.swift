import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        Group {
            if gameManager.showStartScreen {
                StartScreenView(gameManager: gameManager)
            } else {
                MainGameView(gameManager: gameManager)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(GameManager())
    }
}
