import Foundation

/// API Environment configuration for switching between local and production backends
enum APIEnvironment {
    case local
    case production
    
    /// The base URL for the API
    var baseURL: URL {
        switch self {
        case .local:
            // Only used for simulator - connects to localhost
            return URL(string: "http://localhost:8000")!
            
        case .production:
            // Render deployment URL - used by physical devices and release builds
            return URL(string: "https://fuel-api-6jdw.onrender.com")!
        }
    }
    
    /// Human-readable name for debugging
    var name: String {
        switch self {
        case .local: return "Local Development"
        case .production: return "Production (Render)"
        }
    }
    
    /// Current active environment
    /// - Simulator in DEBUG: uses local backend (localhost)
    /// - Physical device: always uses production (Render)
    /// - Release builds: always uses production (Render)
    static var current: APIEnvironment {
        #if DEBUG
            #if targetEnvironment(simulator)
            // Simulator can use localhost
            return .local
            #else
            // Physical device in debug - use production since localhost won't work
            return .production
            #endif
        #else
        // Release builds always use production
        return .production
        #endif
    }
}

/// API Configuration - centralized settings
enum APIConfig {
    /// Base URL from current environment
    static var baseURL: URL {
        APIEnvironment.current.baseURL
    }
    
    /// Request timeout in seconds (longer for Render free tier cold starts)
    static let timeoutInterval: TimeInterval = 90
    
    /// API version prefix (empty for now)
    static let apiVersion = ""
    
    /// Build full URL for an endpoint
    static func url(for endpoint: String) -> URL {
        baseURL.appendingPathComponent(endpoint)
    }
    
    /// Log current configuration (debug only)
    static func logConfiguration() {
        #if DEBUG
        print("🔧 API Environment: \(APIEnvironment.current.name)")
        print("🔧 Base URL: \(baseURL.absoluteString)")
        #endif
    }
}
