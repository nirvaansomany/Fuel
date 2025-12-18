import Foundation

enum MockHomeData {
    static let dailySummary = DailySummary(
        caloriesToday: 1450,
        caloriesTarget: 2400,
        proteinGrams: 95,
        proteinTarget: 180,
        carbsGrams: 120,
        carbsTarget: 240,
        fatGrams: 40,
        fatTarget: 70
    )

    static let meals: [RecommendedMeal] = [
        RecommendedMeal(
            diningHall: "De Neve",
            items: [
                MenuItem(emoji: "🍳", name: "Scrambled Eggs", servingDescription: "2 eggs"),
                MenuItem(emoji: "🥓", name: "Turkey Bacon", servingDescription: "3 strips"),
                MenuItem(emoji: "🥞", name: "Whole Wheat Pancakes", servingDescription: "2 pancakes"),
                MenuItem(emoji: "🍓", name: "Fresh Berries", servingDescription: "1 cup")
            ],
            totalCalories: 620,
            proteinGrams: 42,
            carbsGrams: 68,
            fatGrams: 18
        ),
        RecommendedMeal(
            diningHall: "Feast",
            items: [
                MenuItem(emoji: "🍗", name: "Grilled Chicken Breast", servingDescription: "6 oz"),
                MenuItem(emoji: "🍚", name: "Brown Rice", servingDescription: "1 cup"),
                MenuItem(emoji: "🥦", name: "Steamed Broccoli", servingDescription: "1.5 cups"),
                MenuItem(emoji: "🥗", name: "Garden Salad", servingDescription: "1 bowl")
            ],
            totalCalories: 580,
            proteinGrams: 52,
            carbsGrams: 62,
            fatGrams: 12
        ),
        RecommendedMeal(
            diningHall: "Bruin Plate",
            items: [
                MenuItem(emoji: "🐟", name: "Baked Salmon", servingDescription: "5 oz"),
                MenuItem(emoji: "🥔", name: "Sweet Potato", servingDescription: "1 medium"),
                MenuItem(emoji: "🥬", name: "Sautéed Spinach", servingDescription: "2 cups"),
                MenuItem(emoji: "🥕", name: "Roasted Carrots", servingDescription: "1 cup")
            ],
            totalCalories: 540,
            proteinGrams: 46,
            carbsGrams: 54,
            fatGrams: 14
        )
    ]
}


