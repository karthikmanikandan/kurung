import Foundation

// MARK: - Reel Model (matches backend JSON exactly)
struct ReelModel: Codable, Identifiable {
    let id = UUID()
    let type: String
    let link: String
    let videoId: String
    let videoUrl: String
    let scrapedAt: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case link
        case videoId
        case videoUrl
        case scrapedAt
    }
    
    // Custom initializer for safe URL conversion
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.link = try container.decode(String.self, forKey: .link)
        self.videoId = try container.decode(String.self, forKey: .videoId)
        self.videoUrl = try container.decode(String.self, forKey: .videoUrl)
        self.scrapedAt = try container.decode(String.self, forKey: .scrapedAt)
    }
    
    // Convenience initializer for testing
    init(type: String = "reel", link: String, videoId: String, videoUrl: String, scrapedAt: String = ISO8601DateFormatter().string(from: Date())) {
        self.type = type
        self.link = link
        self.videoId = videoId
        self.videoUrl = videoUrl
        self.scrapedAt = scrapedAt
    }
}

// MARK: - API Response Models
struct ReelsResponse: Codable {
    let reels: [ReelModel]
    let metadata: ReelsMetadata
}

struct ReelsMetadata: Codable {
    let total: Int
    let scrapedAt: String
    let source: String
}

// MARK: - Network Error Types
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
}
