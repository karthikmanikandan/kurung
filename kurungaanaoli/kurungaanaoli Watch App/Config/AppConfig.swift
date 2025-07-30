import Foundation

// MARK: - App Configuration
struct AppConfig {
    // Backend URL - update this with your production server URL
    // For local development: "http://localhost:3000" (Mac's localhost)
    // For production: "https://your-production-server.com"
    // For ngrok testing: "https://d0568e27707e.ngrok-free.app"
    // For Render deployment: "https://kurung-backend-xxxx.onrender.com"
    static let baseURL = "https://kurung.onrender.com" // Live Render backend
    
    // API endpoints
    struct API {
        static let health = "/health"
        static let reels = "/reels"
        static let refresh = "/refresh"
    }
    
    // App settings
    struct Settings {
        static let defaultReelLimit = 10
        static let maxReelLimit = 20
        static let requestTimeout: TimeInterval = 90
        static let autoRefreshInterval: TimeInterval = 120 // 2 minutes
        static let videoCacheSize = 50 * 1024 * 1024 // 50MB
    }
    
    // App metadata
    struct Metadata {
        static let appName = "YouTube Shorts"
        static let appVersion = "1.0.0"
        static let buildNumber = "1"
    }
}
