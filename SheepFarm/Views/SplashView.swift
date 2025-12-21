//
//  SplashView.swift
//  Fjallabær Sheep Farm
//

import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool
    
    var body: some View {
        ZStack {
            // Cloudy gray background
            Color(red: 0.7, green: 0.73, blue: 0.75) // #B3BABF
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("TGS Entertainment")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
        }
        .onAppear {
            // Auto-advance after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showSplash = false
            }
        }
    }
}
