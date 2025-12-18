import Foundation

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published var dailySummary: DailySummary
    @Published var selectedSegmentIndex: Int = 0

    let segments = ["Daily", "Weekly", "Monthly", "Yearly"]
    let keyVitaminsToday = ["Vit D 85%", "Iron 92%", "B12 78%", "Calcium 88%"]
    let dailyInsights = [
        "Great protein intake today.",
        "Carbs are on track for your goals."
    ]
    let dailyCoachTips = [
        "Add leafy greens tonight for an iron boost."
    ]

    let weeklyInsights = [
        "Strong week so far.",
        "Protein intake is improving."
    ]
    let weeklyCoachTips = [
        "Try adding an extra high-protein snack before workouts."
    ]

    let monthlyInsights = [
        "Consistency is improving month over month.",
        "Your best performing week was Week 4."
    ]
    let monthlyCoachTips = [
        "Try adding an extra high-protein snack before workouts."
    ]

    let yearlyInsights = [
        "Remarkable progress this year.",
        "Protein goals met 78% of the time."
    ]
    let yearlyCoachTips = [
        "Try adding an extra high-protein snack before workouts."
    ]

    init(dailySummary: DailySummary = MockHomeData.dailySummary) {
        self.dailySummary = dailySummary
    }
}


