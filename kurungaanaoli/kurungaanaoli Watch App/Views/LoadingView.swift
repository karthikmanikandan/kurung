//
//  LoadingView.swift
//  kurungaanaoli Watch App
//
//  Created by Assistant on 27/07/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Custom Kurung Logo
                Image("KurungLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                
                // Loading text
                Text("Loading kurung...")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Shimmer loading bar
                ShimmerLoadingBar()
                    .frame(width: 120, height: 4)
                
                // Loading dots
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                            .scaleEffect(isAnimating ? 1.2 : 0.8)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct ShimmerLoadingBar: View {
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .cornerRadius(2)
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.6), Color.clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(2)
                    .frame(width: geometry.size.width * 0.3)
                    .offset(x: isAnimating ? geometry.size.width : -geometry.size.width * 0.3)
                    .animation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    LoadingView()
} 