import Foundation

struct MenuItem: Identifiable, Hashable {
    let id = UUID()
    let emoji: String
    let name: String
    let servingDescription: String
}

struct RecommendedMeal: Identifiable, Hashable {
    let id = UUID()
    let diningHall: String
    let items: [MenuItem]
    let totalCalories: Int
    let proteinGrams: Int
    let carbsGrams: Int
    let fatGrams: Int
}

struct DailySummary {
    let caloriesToday: Int
    let caloriesTarget: Int
    let proteinGrams: Int
    let proteinTarget: Int
    let carbsGrams: Int
    let carbsTarget: Int
    let fatGrams: Int
    let fatTarget: Int
}


