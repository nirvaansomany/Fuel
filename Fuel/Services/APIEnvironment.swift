import Foundation

/// API Environment configuration for switching between local and production backends
enum APIEnvironment {
    case local
    case production
    
    /// The base URL for the API
    var baseURL: URL {
        switch self {
        case .local:
            // For iOS Simulator running on Mac - connects to localhost
            // For physical device on same network, use Mac's local IP
            #if targetEnvironment(simulator)
            return URL(string: "http://localhost:8000")!
            #else
            // For physical device testing, use your Mac's local IP
            // You can also use ngrok or similar for remote testing
            return URL(string: "http://192.168.1.100:8000")!  // Replace with your Mac's IP
            #endif
            
        case .production:
            // Production URL - replace with your deployed backend
            // Examples: Railway, Render, Fly.io, etc.
            return URL(string: "https://fuel-api.example.com")!
        }
    }
    
    /// Current active environment
    /// Change this to switch between local and production
    static var current: APIEnvironment {
        #if DEBUG
        return .local
        #else
        return .production
        #endif
    }
}

/// API Configuration
enum APIConfig {
    static var baseURL: URL {
        APIEnvironment.current.baseURL
    }
    
    /// Request timeout in seconds
    static let timeoutInterval: TimeInterval = 30
    
    /// API version prefix (if needed)
    static let apiVersion = ""
    
    /// Build full URL for an endpoint
    static func url(for endpoint: String) -> URL {
        baseURL.appendingPathComponent(endpoint)
    }
}

