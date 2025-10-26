import SwiftUI

struct ContentView: View {
    @State private var counter: Double = 0
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Button(action: {
                    incrementCounter()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 200, height: 200)
                            .shadow(radius: 10)
                        
                        Text(formatNumber(counter))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                Text("Auto-increment: +\(formatNumber(counter * 0.001))/sec")
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .onAppear {
            startAutoIncrement()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    func incrementCounter() {
        counter += 1
    }
    
    func startAutoIncrement() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            counter += counter * 0.001
        }
    }
    
    func formatNumber(_ num: Double) -> String {
        if num >= 1000000 {
            return String(format: "%.2fM", num / 1000000)
        } else if num >= 1000 {
            return String(format: "%.2fK", num / 1000)
        } else if num >= 1 {
            return String(format: "%.2f", num)
        } else {
            return String(format: "%.4f", num)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
