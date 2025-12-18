import Foundation

/// URLSession-based API client for Fuel backend
actor APIClient {
    static let shared = APIClient()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfig.timeoutInterval
        config.timeoutIntervalForResource = APIConfig.timeoutInterval * 2
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }
    
    // MARK: - Request Building
    
    private func buildRequest(
        endpoint: String,
        method: String,
        body: Data? = nil,
        contentType: String = "application/json",
        authenticated: Bool = false
    ) throws -> URLRequest {
        let url = APIConfig.url(for: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if authenticated, let token = KeychainService.read(.accessToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = body
        return request
    }
    
    // MARK: - GET
    
    func get<T: Decodable>(
        _ endpoint: String,
        authenticated: Bool = false
    ) async throws -> T {
        let request = try buildRequest(
            endpoint: endpoint,
            method: "GET",
            authenticated: authenticated
        )
        return try await execute(request)
    }
    
    // MARK: - POST (JSON)
    
    func post<T: Decodable, B: Encodable>(
        _ endpoint: String,
        body: B,
        authenticated: Bool = false
    ) async throws -> T {
        let bodyData = try encoder.encode(body)
        let request = try buildRequest(
            endpoint: endpoint,
            method: "POST",
            body: bodyData,
            authenticated: authenticated
        )
        return try await execute(request)
    }
    
    // MARK: - POST (Form URL Encoded) - for OAuth2 login
    
    func postForm<T: Decodable>(
        _ endpoint: String,
        formData: [String: String]
    ) async throws -> T {
        let bodyString = formData
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
            .joined(separator: "&")
        let bodyData = bodyString.data(using: .utf8)
        
        let request = try buildRequest(
            endpoint: endpoint,
            method: "POST",
            body: bodyData,
            contentType: "application/x-www-form-urlencoded"
        )
        return try await execute(request)
    }
    
    // MARK: - PUT
    
    func put<T: Decodable, B: Encodable>(
        _ endpoint: String,
        body: B,
        authenticated: Bool = true
    ) async throws -> T {
        let bodyData = try encoder.encode(body)
        let request = try buildRequest(
            endpoint: endpoint,
            method: "PUT",
            body: bodyData,
            authenticated: authenticated
        )
        return try await execute(request)
    }
    
    // MARK: - Execute Request
    
    private func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            
            // Handle error status codes
            switch httpResponse.statusCode {
            case 200...299:
                break // Success
            case 401:
                throw APIError.unauthorized
            case 404:
                throw APIError.notFound
            default:
                let errorMessage = parseErrorMessage(from: data)
                throw APIError.serverError(httpResponse.statusCode, errorMessage)
            }
            
            // Decode response
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
            
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    private func parseErrorMessage(from data: Data) -> String {
        if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
            return errorResponse.detail
        }
        return "Unknown error"
    }
}

