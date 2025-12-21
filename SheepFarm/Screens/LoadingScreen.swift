//
//  LoadingView.swift
//  Fjallabær Sheep Farm
//

import SwiftUI

struct LoadingView: View {
    @Binding var showLoading: Bool
    @State private var isRotating = false
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            // Cloudy gray background
            Color(red: 0.7, green: 0.73, blue: 0.75) // #B3BABF
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Rotating circular spinner
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.white, lineWidth: 8)
                    .frame(width: 60, height: 60)
                    .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
                    .animation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false), value: isRotating)
                
                // Pulsing "Loading..." text
                Text("Loading...")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .opacity(isPulsing ? 0.5 : 1.0)
                    .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
                
                Spacer()
            }
        }
        .onAppear {
            isRotating = true
            isPulsing = true
            
            // Auto-advance after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                showLoading = false
            }
        }
    }
}
