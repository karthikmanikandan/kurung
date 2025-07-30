// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ReelsViewModel()
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .onAppear {
                        // Hide splash after 2.5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSplash = false
                            }
                        }
                    }
            } else {
                mainContent
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private var mainContent: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
            } else if let errorMessage = viewModel.errorMessage {
                EmptyStateView(
                    title: "Connection Error",
                    message: errorMessage,
                    actionTitle: "Retry",
                    action: {
                        viewModel.fetchReels()
    }
                )
            } else if viewModel.reels.isEmpty {
                EmptyStateView(
                    title: "No kurung Available",
                    message: "Pull to refresh or check your connection",
                    actionTitle: "Refresh",
                    action: {
                        viewModel.refreshReels()
                    }
                )
            } else {
                ReelPlayerView(viewModel: viewModel)
                    .focusable()
                    .digitalCrownRotation($viewModel.currentIndex, from: 0.0, through: Double(max(0, viewModel.reels.count - 1)), by: 1.0, sensitivity: .high)
                    .onChange(of: viewModel.currentIndex) { newIndex in
                        // Debounced crown scroll handling
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            let index = Int(round(newIndex))
                            if viewModel.reels.indices.contains(index) {
                                viewModel.goToReel(at: index)
                            }
                        }
                    }
            }
            
            // Loading more indicator
            if viewModel.isLoadingMore {
                VStack {
                    Spacer()
                    HStack {
                        ProgressView()
                            .scaleEffect(0.6)
                        Text("Loading more...")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
                    .padding(.bottom, 8)
                }
            }
        }
        .onAppear {
            if viewModel.reels.isEmpty {
                viewModel.fetchReels()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
    ContentView()
    }
}
