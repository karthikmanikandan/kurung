import Foundation
import Combine
import SwiftUI

@MainActor
class ReelsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var reels: [ReelModel] = []
    @Published var currentIndex: Double = 0.0  // Changed to Double for digitalCrownRotation
    @Published var crownRotation: Double = 0.0  // Digital Crown rotation value
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoadingMore = false
    @Published var showNewContentBanner = false // New banner for refresh notifications
    @Published var showSwipeHint = true // Show swipe hint on first load

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = AppConfig.baseURL
    private var lastCrownScrollTime: Date = Date()
    private var crownScrollCooldown: TimeInterval = 0.5
    private var fetchedReelIds = Set<String>() // Track fetched Shorts to prevent duplicates
    private var isLoadingMoreReels = false
    
    // Auto-refresh properties
    private var autoRefreshTimer: Timer?
    private let autoRefreshInterval: TimeInterval = AppConfig.Settings.autoRefreshInterval
    private var lastRefreshTime: Date = Date()
    private var originalReelsCount = 0 // Track original count for new content detection
    
    // MARK: - Computed Properties
    var currentReelIndex: Int {
        return Int(round(currentIndex))
    }
    
    var currentReel: ReelModel? {
        guard reels.indices.contains(currentReelIndex) else { return nil }
        return reels[currentReelIndex]
    }

    // MARK: - Initialization
    init() {
        fetchReels()
        startAutoRefresh()
        
        // Auto-hide swipe hint after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.showSwipeHint = false
        }
    }
    
    // MARK: - Auto-Refresh Logic
    private func startAutoRefresh() {
        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: autoRefreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.performAutoRefresh()
            }
        }
    }
    
    private func performAutoRefresh() {
        // Store current count to detect new content
        originalReelsCount = reels.count
        
        // Fetch fresh shorts
        fetchReels(limit: 10)

        // Reset scroll position to show new content
        currentIndex = 0.0
        
        // Show banner if new content is detected
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            if let self = self, self.reels.count > self.originalReelsCount {
                self.showNewContentBanner = true
                
                // Hide banner after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.showNewContentBanner = false
                }
            }
        }
        
        lastRefreshTime = Date()
    }

    func stopAutoRefresh() {
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil
    }
    
    // MARK: - Network Operations
    func fetchReels(limit: Int = 10) {
        guard let url = URL(string: "\(baseURL)/reels?limit=\(limit)") else {
            errorMessage = "Invalid URL: \(baseURL)/reels"
            return
        }
        
        // Fetching reels from backend
        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: ReelsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case let .failure(error) = completion {
                        // Network error occurred
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    // Received reels from backend
                    self?.processNewReels(response.reels)
                    self?.currentIndex = 0.0  // Reset to first Short
                }
            )
            .store(in: &cancellables)
    }
    
    private func processNewReels(_ newReels: [ReelModel]) {
        // Processing new reels
        
        // Filter out duplicates based on videoId instead of videoUrl
        let uniqueReels = newReels.filter { reel in
            !fetchedReelIds.contains(reel.videoId)
        }
        
        // Found unique reels
        
        // Process video URLs
        for reel in uniqueReels {
            // Validate URL format
            if URL(string: reel.videoUrl) != nil {
                // Valid URL format
            } else {
                // Invalid URL format
            }
        }
        
        // Add new unique reels
        reels.append(contentsOf: uniqueReels)
        
        // Update tracking set
        uniqueReels.forEach { reel in
            fetchedReelIds.insert(reel.videoId) // Use videoId instead of videoUrl
        }
        
        // Total reels in app: \(reels.count)
    }

    func loadMoreReels() {
        guard !isLoadingMoreReels else {
            return
        }
        
        isLoadingMoreReels = true
        isLoadingMore = true
        
        // Fetch additional reels
        fetchReels(limit: 5) // Smaller batch for smooth loading
        
        // Reset loading state after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.isLoadingMoreReels = false
            self?.isLoadingMore = false
        }
    }
    
    func refreshReels() {
        // Clear existing reels and start fresh
        reels.removeAll()
        fetchedReelIds.removeAll()
        currentIndex = 0.0
        fetchReels()
    }
    
    // MARK: - Video Management (AVPlayer)
    func loadVideo(for index: Int) {
        guard reels.indices.contains(index) else {
            return
        }
        
        // Loading video for index \(index)
        // Video will be loaded by VideoPlayerManager in ReelPlayerView
    }
    
    func cleanupPlayer() {
        // Cleanup handled by VideoPlayerManager
    }
    
    // MARK: - Digital Crown Navigation
    func handleCrownScroll(delta: Double) {
        let now = Date()
        guard now.timeIntervalSince(lastCrownScrollTime) >= crownScrollCooldown else {
            return
        }
        
        lastCrownScrollTime = now
        
        // Navigate videos with crown - improved for YouTube Shorts
        if delta > 0 {
            nextReel()
        } else {
            previousReel()
    }
    }
    
    // MARK: - Navigation
    func nextReel() {
        // Hide swipe hint when user starts navigating
        if showSwipeHint {
            showSwipeHint = false
        }
        
        let nextIndex = currentReelIndex + 1
        guard nextIndex < reels.count else {
            // Loop back to first video for YouTube Shorts experience
            currentIndex = 0.0
            // Looped back to first YouTube Short
            return
        }

        currentIndex = Double(nextIndex)
        // Navigated to YouTube Short \(nextIndex)

        // Check if we need to preload more videos
        if nextIndex >= reels.count - 2 && !isLoadingMoreReels {
            loadMoreReels()
        }
    }

    func previousReel() {
        // Hide swipe hint when user starts navigating
        if showSwipeHint {
            showSwipeHint = false
        }
        
        let prevIndex = currentReelIndex - 1
        guard prevIndex >= 0 else { 
            // Loop to last video for YouTube Shorts experience
            currentIndex = Double(reels.count - 1)
            // Looped to last YouTube Short
            return 
        }
        currentIndex = Double(prevIndex)
        // Navigated to YouTube Short \(prevIndex)
    }

    func goToReel(at index: Int) {
        guard reels.indices.contains(index) else { return }
        currentIndex = Double(index)
        loadVideo(for: index)
    }

    // MARK: - Cleanup
    @MainActor
    func cleanup() async {
        stopAutoRefresh()
        cancellables.removeAll()
        cleanupPlayer()
    }

    deinit {
        Task.detached { @MainActor [weak self] in
            await self?.cleanup()
        }
    }
}
