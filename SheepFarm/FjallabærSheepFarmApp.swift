//
//  FjallabærSheepFarmApp.swift
//  Fjallabær Sheep Farm
//

import SwiftUI

@main
struct FjallabærSheepFarmApp: App {
    @StateObject private var gameManager = GameManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var gameManager: GameManager
    
    @State private var showSplash = true
    @State private var showLoading = true
    @State private var showRegionSelection = false
    @State private var showMainGame = false
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView(showSplash: $showSplash)
            } else if showLoading {
                LoadingView(showLoading: $showLoading)
            } else if showMainGame {
                MainGameView(gameManager: gameManager)
            } else if showRegionSelection {
                RegionSelectionView(gameManager: gameManager, showMainGame: $showMainGame)
            } else {
                StartMenuView(
                    gameManager: gameManager,
                    showRegionSelection: $showRegionSelection,
                    showMainGame: $showMainGame
                )
            }
        }
    }
}
