import SwiftUI

struct RootTabView: View {
    @EnvironmentObject var authService: AuthService
    @State private var selectedTab = 0
    @AppStorage("appearancePreferenceIndex") private var appearanceIndex: Int = MockProfileData.selectedAppearanceIndex

    private var preferredColorScheme: ColorScheme? {
        switch appearanceIndex {
        case 0:
            return .light
        case 1:
            return .dark
        default:
            return nil // follow system
        }
    }

    var body: some View {
        ZStack {
            FuelBackground()

            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tag(0)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                ProgressView()
                    .tag(1)
                    .tabItem {
                        Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                    }

                ProfileView()
                    .tag(2)
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
            }
            .tint(FuelColor.accent)
        }
        .preferredColorScheme(preferredColorScheme)
    }
}
