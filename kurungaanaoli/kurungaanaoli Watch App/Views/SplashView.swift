import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var showMainContent = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Custom Kurung Logo
                Image("KurungLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                
                // App Name
                Text("kurung")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.8).delay(0.3), value: isAnimating)
                
                // Tagline
                Text("Watch. Scroll. Enjoy.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.8).delay(0.6), value: isAnimating)
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.8).delay(0.9), value: isAnimating)
            }
        }
        .onAppear {
            isAnimating = true
            
            // Simulate loading time and transition to main content
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showMainContent = true
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .preferredColorScheme(.dark)
} 