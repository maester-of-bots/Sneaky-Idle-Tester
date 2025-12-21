//
//  StartMenuView.swift
//  Fjallabær Sheep Farm
//

import SwiftUI

struct StartMenuView: View {
    @ObservedObject var gameManager: GameManager
    @Binding var showRegionSelection: Bool
    @Binding var showMainGame: Bool
    
    var body: some View {
        ZStack {
            // Cloudy gray background
            Color(red: 0.7, green: 0.73, blue: 0.75) // #B3BABF
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Title
                Text("Fjallabær Sheep Farm")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 20) {
                    // Continue Game button (only if save exists)
                    if gameManager.hasSavedGame() {
                        Button(action: {
                            showMainGame = true
                        }) {
                            Text("Continue Game")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 250, height: 60)
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                    }
                    
                    // New Farm button
                    Button(action: {
                        if gameManager.hasSavedGame() {
                            // Show confirmation dialog
                            showNewGameConfirmation()
                        } else {
                            showRegionSelection = true
                        }
                    }) {
                        Text("New Farm")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 250, height: 60)
                            .background(Color.green)
                            .cornerRadius(15)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    private func showNewGameConfirmation() {
        // In a real app, you'd use an alert here
        // For now, just delete and go to region selection
        gameManager.deleteSaveGame()
        showRegionSelection = true
    }
}
