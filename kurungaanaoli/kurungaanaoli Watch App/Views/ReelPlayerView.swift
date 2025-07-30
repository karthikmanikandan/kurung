import SwiftUI
import AVKit
import AVFoundation

struct ReelPlayerView: View {
    @ObservedObject var viewModel: ReelsViewModel
    @State private var showTransitionOverlay = false
    @State private var isLoading = false
    @State private var hasError = false
    @StateObject private var videoPlayer = VideoPlayerManager()
    @State private var isPlaying: Bool = true
    
    var body: some View {
            ZStack {
            if let currentReel = viewModel.currentReel {
                VideoPlayerView(
                    videoUrl: currentReel.videoUrl,
                    videoPlayer: videoPlayer,
                    isPlaying: $isPlaying
                )
                .aspectRatio(9/16, contentMode: .fill) // Proper vertical aspect ratio for YouTube Shorts
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                .focusable(true) // Enable focus for Digital Crown
                .digitalCrownRotation($viewModel.crownRotation, from: -100, through: 100, by: 1.0, sensitivity: .high, isContinuous: false, isHapticFeedbackEnabled: true)
                .onChange(of: viewModel.crownRotation) { newValue in
                    // Handle crown rotation for video navigation
                    let delta = newValue - viewModel.crownRotation
                    if abs(delta) > 2 { // Threshold for navigation
                        if delta > 0 {
                            viewModel.nextReel()
                        } else {
                            viewModel.previousReel()
                        }
                    }
                }
                // Swipe Gestures for Video Navigation
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            let verticalAmount = value.translation.height
                            let horizontalAmount = value.translation.width
                            
                            // Determine if it's a vertical or horizontal swipe
                            if abs(verticalAmount) > abs(horizontalAmount) {
                                // Vertical swipe
                                if verticalAmount < -30 { // Swipe up
                                    viewModel.nextReel()
                                } else if verticalAmount > 30 { // Swipe down
                                    viewModel.previousReel()
                                }
                } else {
                                // Horizontal swipe (alternative navigation)
                                if horizontalAmount < -30 { // Swipe left
                                    viewModel.nextReel()
                                } else if horizontalAmount > 30 { // Swipe right
                                    viewModel.previousReel()
                                }
                            }
                        }
                )
                .onAppear { loadCurrentVideo() }
                .onDisappear { cleanupPlayer() }
                .animation(.easeInOut(duration: 0.2), value: viewModel.currentIndex)
                .onTapGesture { togglePlayPause() }
                
                // New Content Banner
                if viewModel.showNewContentBanner {
                    VStack {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.yellow)
                            Text("New kurung Loaded!")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        
                        Spacer()
                    }
                    .padding(.top, 8)
                    .animation(.easeInOut(duration: 0.5), value: viewModel.showNewContentBanner)
                }
                
                // Loading overlay with improved design
                if videoPlayer.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.3)
                        Text("Loading kurung...")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.7))
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                    .transition(.opacity.combined(with: .scale))
                }
                
                // Error overlay with retry option
                if videoPlayer.hasError {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Text("Video failed to load")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Button("Tap to retry") {
                            reloadVideo()
                        }
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.8))
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                    .transition(.opacity.combined(with: .scale))
                }
                
                // Transition overlay
                if showTransitionOverlay {
                    Color.black
                        .opacity(0.3)
                        .transition(.opacity)
                }
                
                // Swipe hint overlay (shows briefly on first load)
                if viewModel.showSwipeHint {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "arrow.up")
                                .foregroundColor(.white.opacity(0.7))
                            Text("Swipe up/down to navigate")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                            Image(systemName: "arrow.down")
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        .padding(.bottom, 20)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.easeInOut(duration: 0.5), value: viewModel.showSwipeHint)
                }
            } else {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Text("Loading Videos...")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.top, 12)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onChange(of: viewModel.currentIndex) { newIndex in
            showTransitionOverlay = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                showTransitionOverlay = false
            }
        }
    }
    
    private func loadCurrentVideo() {
        guard let currentReel = viewModel.currentReel else { return }
        videoPlayer.loadVideo(url: currentReel.videoUrl)
        isPlaying = true // Start playing when video loads
    }
    
    private func togglePlayPause() {
        if isPlaying {
            videoPlayer.pause()
            isPlaying = false
            } else {
            videoPlayer.play()
            isPlaying = true
        }
    }
    
    private func reloadVideo() {
        videoPlayer.reloadVideo()
        isPlaying = true
    }
    
    private func cleanupPlayer() {
        videoPlayer.cleanup()
        viewModel.cleanupPlayer()
    }
}

// Video Player Manager
class VideoPlayerManager: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isLoading = false
    @Published var hasError = false
    @Published var errorMessage: String = ""
    
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var playerItemObserver: NSKeyValueObservation?
    private var playerObserver: NSKeyValueObservation?
    private var timeoutTimer: Timer?
    
                    // Fallback video URLs for testing - using working Google videos
                private let fallbackVideos = [
                    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
                    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
                    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
                    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
                    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4"
                ]
    
                    func loadVideo(url: String) {
                    // VideoPlayerManager loading video: \(url)
                    isLoading = true
                    hasError = false
                    errorMessage = ""
                    
                    guard let videoURL = URL(string: url) else {
                        // Invalid URL format: \(url)
                        hasError = true
                        isLoading = false
                        errorMessage = "Invalid video URL"
                        return
                    }
                    
                    // Check if URL is HTTPS and log status
                    if videoURL.scheme == "https" {
                        // Loading HTTPS URL - should work without ATS issues
                    } else if videoURL.scheme == "http" {
                        // Loading HTTP URL - ATS should allow this
                    }
        
        // Cleanup previous player
        cleanup()
        
        // Start timeout timer
        startTimeoutTimer()
        
        // Create new player item with better configuration
        playerItem = AVPlayerItem(url: videoURL)
        playerItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = false
        playerItem?.automaticallyPreservesTimeOffsetFromLive = false
        
        // Create new player with optimized settings
        player = AVPlayer(playerItem: playerItem)
        player?.automaticallyWaitsToMinimizeStalling = false
        player?.rate = 1.0
        
        // Add observers
        setupObservers()
        
        // Start playing with slight delay for better performance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.player?.play()
        }
        
                            // VideoPlayerManager setup complete for: \(url)
    }
    
                    func play() {
                    // Playing video
                    player?.play()
                }
                
                func pause() {
                    // Pausing video
                    player?.pause()
                }
    
                    func reloadVideo() {
                    if let currentURL = playerItem?.asset as? AVURLAsset {
                        // Reloading video: \(currentURL.url.absoluteString)
                        loadVideo(url: currentURL.url.absoluteString)
                    } else {
                        // No current video to reload
                    }
                }
    
                    func loadFallbackVideo() {
                    let fallbackURL = fallbackVideos.randomElement() ?? fallbackVideos[0]
                    // Loading fallback video: \(fallbackURL)
                    loadVideo(url: fallbackURL)
                }
    
    func cleanup() {
        // Cancel timeout timer
        timeoutTimer?.invalidate()
        timeoutTimer = nil
        
        // Remove time observer
        if let timeObserver = timeObserver, let player = player {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        // Remove KVO observers
        playerItemObserver?.invalidate()
        playerItemObserver = nil
        playerObserver?.invalidate()
        playerObserver = nil
        
        // Remove notification observers
        NotificationCenter.default.removeObserver(self)
        
        // Pause and cleanup player
        player?.pause()
        player = nil
        playerItem = nil
        
        isLoading = false
        hasError = false
        errorMessage = ""
    }
    
    private func startTimeoutTimer() {
                            timeoutTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { [weak self] _ in
                        DispatchQueue.main.async {
                            if self?.isLoading == true {
                                // Video loading timeout - showing error instead of fallback
                                self?.hasError = true
                                self?.isLoading = false
                                self?.errorMessage = "Video loading timeout"
                                // Don't auto-fallback to prevent loops - let user retry manually
                            }
                        }
                    }
    }
    
    private func setupObservers() {
        guard let player = player, let playerItem = playerItem else { return }
        
        // Observe player item status using modern KVO
                            playerItemObserver = playerItem.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
                        DispatchQueue.main.async {
                            // PlayerItem status changed to: \(item.status.rawValue)
                            switch item.status {
                            case .readyToPlay:
                                // PlayerItem ready to play
                                self?.timeoutTimer?.invalidate()
                                self?.isLoading = false
                            case .failed:
                                let errorMessage = item.error?.localizedDescription ?? "Unknown error"
                                // PlayerItem failed: \(errorMessage)
                                self?.timeoutTimer?.invalidate()
                                self?.hasError = true
                                self?.isLoading = false
                                self?.errorMessage = errorMessage
                                
                                // Check if it's an ATS/SSL error and try HTTP fallback immediately
                                if errorMessage.contains("SSL") || errorMessage.contains("secure connection") || errorMessage.contains("App Transport Security") || errorMessage.contains("-1022") {
                                    // ATS/SSL error detected, trying HTTP fallback immediately
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self?.loadFallbackVideo()
                                    }
                                } else {
                                    // Try fallback after a short delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        self?.loadFallbackVideo()
                                    }
                                }
                            case .unknown:
                                // PlayerItem status unknown
                                self?.isLoading = true
                            @unknown default:
                                // PlayerItem unknown status
                                self?.isLoading = true
                            }
                        }
                    }
    
        // Observe player status using modern KVO
                            playerObserver = player.observe(\.status, options: [.new, .initial]) { [weak self] player, _ in
                        DispatchQueue.main.async {
                            // Player status changed to: \(player.status.rawValue)
                            switch player.status {
                            case .readyToPlay:
                                // Player ready to play
                                self?.timeoutTimer?.invalidate()
                                self?.isLoading = false
                            case .failed:
                                let errorMessage = player.error?.localizedDescription ?? "Unknown error"
                                // Player failed: \(errorMessage)
                                self?.timeoutTimer?.invalidate()
                                self?.hasError = true
                                self?.isLoading = false
                                self?.errorMessage = errorMessage
                                
                                // Check if it's an ATS/SSL error and try HTTP fallback immediately
                                if errorMessage.contains("SSL") || errorMessage.contains("secure connection") || errorMessage.contains("App Transport Security") || errorMessage.contains("-1022") {
                                    // ATS/SSL error detected, trying HTTP fallback immediately
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self?.loadFallbackVideo()
                                    }
                                } else {
                                    // Try fallback after a short delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        self?.loadFallbackVideo()
                                    }
                                }
                            case .unknown:
                                // Player status unknown
                                self?.isLoading = true
                            @unknown default:
                                // Player unknown status
                                self?.isLoading = true
                            }
                        }
                    }
        
        // Add notification for when video ends
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }
    
                    @objc private func playerItemDidReachEnd() {
                    // Video ended - looping
                    // Loop the video
                    player?.seek(to: .zero)
                    player?.play()
                }
    
    deinit {
        cleanup()
    }
}

// Custom VideoPlayer for watchOS
struct VideoPlayerView: View {
    let videoUrl: String
    @ObservedObject var videoPlayer: VideoPlayerManager
    @Binding var isPlaying: Bool
    
    var body: some View {
        ZStack {
            if let player = videoPlayer.player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                        isPlaying = true
                    }
                    .onDisappear {
                        player.pause()
                        isPlaying = false
                    }
        } else {
                Color.black
            }
        }
        .onAppear {
            // Add a small delay to ensure ATS settings are applied
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                videoPlayer.loadVideo(url: videoUrl)
            }
        }
        .onChange(of: videoUrl) { newUrl in
            videoPlayer.loadVideo(url: newUrl)
            isPlaying = true
        }
    }
}

#Preview {
    ReelPlayerView(viewModel: ReelsViewModel())
        .preferredColorScheme(.dark)
}


