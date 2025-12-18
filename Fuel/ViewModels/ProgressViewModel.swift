import Foundation

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published var dailySummary: DailySummary
    @Published var selectedSegmentIndex: Int = 0

    let segments = ["Daily", "Weekly", "Monthly", "Yearly"]
    
    // Dynamic insights based on actual data
    var keyVitaminsToday: [String] {
        // TODO: Wire to actual vitamin tracking when implemented
        return ["Vit D 85%", "Iron 92%", "B12 78%", "Calcium 88%"]
    }
    
    var dailyInsights: [String] {
        var insights: [String] = []
        
        let proteinPercent = dailySummary.proteinTarget > 0 
            ? (Double(dailySummary.proteinGrams) / Double(dailySummary.proteinTarget)) * 100 
            : 0
        
        if proteinPercent >= 80 {
            insights.append("Great protein intake today!")
        } else if proteinPercent >= 50 {
            insights.append("You're halfway to your protein goal.")
        } else if dailySummary.proteinGrams > 0 {
            insights.append("Try to add more protein-rich foods today.")
        }
        
        let caloriePercent = dailySummary.caloriesTarget > 0 
            ? (Double(dailySummary.caloriesToday) / Double(dailySummary.caloriesTarget)) * 100 
            : 0
        
        if caloriePercent >= 80 && caloriePercent <= 110 {
            insights.append("Calories are on track for your goals.")
        } else if caloriePercent < 50 && dailySummary.caloriesToday > 0 {
            insights.append("You have plenty of calories left today.")
        }
        
        if insights.isEmpty {
            insights.append("Start logging meals to track your progress!")
        }
        
        return insights
    }
    
    var dailyCoachTips: [String] {
        if dailySummary.caloriesToday == 0 {
            return ["Log your first meal to get personalized tips!"]
        }
        return ["Add leafy greens tonight for an iron boost."]
    }

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
    
    private var mealLog: MealLogService

    init() {
        let log = MealLogService.shared
        self.mealLog = log
        
        // Get targets from auth service if available
        let targets = Self.getTargetsFromAuth()
        let logged = log.todaysTotals
        
        self.dailySummary = DailySummary(
            caloriesToday: logged.calories,
            caloriesTarget: targets.calories,
            proteinGrams: logged.protein,
            proteinTarget: targets.protein,
            carbsGrams: logged.carbs,
            carbsTarget: targets.carbs,
            fatGrams: logged.fat,
            fatTarget: targets.fat
        )
    }
    
    func refresh() {
        let targets = Self.getTargetsFromAuth()
        let logged = mealLog.todaysTotals
        
        dailySummary = DailySummary(
            caloriesToday: logged.calories,
            caloriesTarget: targets.calories,
            proteinGrams: logged.protein,
            proteinTarget: targets.protein,
            carbsGrams: logged.carbs,
            carbsTarget: targets.carbs,
            fatGrams: logged.fat,
            fatTarget: targets.fat
        )
    }
    
    private static func getTargetsFromAuth() -> (calories: Int, protein: Int, carbs: Int, fat: Int) {
        if let profile = AuthService.shared.currentUser?.profile {
            return (
                calories: profile.calories_target,
                protein: profile.protein_target,
                carbs: profile.carbs_target,
                fat: profile.fat_target
            )
        }
        // Fallback to mock data
        return (
            calories: MockHomeData.dailySummary.caloriesTarget,
            protein: MockHomeData.dailySummary.proteinTarget,
            carbs: MockHomeData.dailySummary.carbsTarget,
            fat: MockHomeData.dailySummary.fatTarget
        )
    }
}
