import SwiftUI

@main
struct FuelApp: App {
    @StateObject private var authService = AuthService.shared
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                RootTabView()
                    .environmentObject(authService)
            } else {
                LoginView(authService: authService)
            }
        }
    }
}
