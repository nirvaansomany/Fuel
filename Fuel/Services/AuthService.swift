import Foundation
import SwiftUI

/// Authentication service managing user session
@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published private(set) var isAuthenticated = false
    @Published private(set) var currentUser: UserResponse?
    @Published private(set) var isLoading = false
    @Published var error: String?
    
    private init() {
        // Check if we have a stored token on launch
        checkStoredSession()
    }
    
    // MARK: - Session Management
    
    private func checkStoredSession() {
        if let token = KeychainService.read(.accessToken), !token.isEmpty {
            isAuthenticated = true
            // Fetch current user data
            Task {
                await fetchCurrentUser()
            }
        }
    }
    
    // MARK: - Signup
    
    func signup(
        email: String,
        name: String,
        password: String,
        profile: ProfileCreateRequest? = nil
    ) async -> Bool {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            let request = SignupRequest(
                email: email,
                name: name,
                password: password,
                profile: profile
            )
            
            let response: UserWithTokenResponse = try await APIClient.shared.post(
                "/auth/signup",
                body: request
            )
            
            // Store token
            _ = KeychainService.save(response.access_token, for: .accessToken)
            _ = KeychainService.save(email, for: .userEmail)
            
            currentUser = response.user
            isAuthenticated = true
            
            return true
        } catch let apiError as APIError {
            error = apiError.errorDescription
            return false
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Login
    
    func login(email: String, password: String) async -> Bool {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            // OAuth2 password flow uses form-encoded data
            let response: TokenResponse = try await APIClient.shared.postForm(
                "/auth/login",
                formData: [
                    "username": email,
                    "password": password
                ]
            )
            
            // Store token
            _ = KeychainService.save(response.access_token, for: .accessToken)
            _ = KeychainService.save(email, for: .userEmail)
            
            isAuthenticated = true
            
            // Fetch user data
            await fetchCurrentUser()
            
            return true
        } catch let apiError as APIError {
            error = apiError.errorDescription
            return false
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Fetch Current User
    
    func fetchCurrentUser() async {
        guard isAuthenticated else { return }
        
        do {
            let user: UserResponse = try await APIClient.shared.get(
                "/auth/me",
                authenticated: true
            )
            currentUser = user
        } catch APIError.unauthorized {
            // Token expired or invalid
            logout()
        } catch {
            // Don't log out on network errors, just log
            print("Failed to fetch user: \(error)")
        }
    }
    
    // MARK: - Logout
    
    func logout() {
        KeychainService.clearAll()
        currentUser = nil
        isAuthenticated = false
        error = nil
    }
    
    // MARK: - Update Profile
    
    func updateProfile(_ update: ProfileUpdateRequest) async -> Bool {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            let user: UserResponse = try await APIClient.shared.put(
                "/users/me",
                body: update
            )
            currentUser = user
            return true
        } catch let apiError as APIError {
            error = apiError.errorDescription
            return false
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
}

