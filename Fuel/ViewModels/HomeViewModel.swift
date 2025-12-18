import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var dailySummary: DailySummary
    @Published var meals: [RecommendedMeal]
    @Published var selectedMealIndex: Int = 0
    @Published var isLoading = false
    @Published var error: String?
    @Published var showMealLoggedAlert = false
    
    @Published var diningHalls: [DiningHallResponse] = []
    
    private let authService: AuthService
    private let mealLog: MealLogService

    init() {
        let auth = AuthService.shared
        let log = MealLogService.shared
        self.authService = auth
        self.mealLog = log
        
        // Initialize with real logged data
        self.dailySummary = Self.makeDailySummary(from: auth.currentUser, mealLog: log)
        self.meals = MockHomeData.meals
        
        // Fetch real data
        Task {
            await loadMenuData()
        }
    }
    
    // MARK: - Computed Properties

    var selectedMeal: RecommendedMeal? {
        guard meals.indices.contains(selectedMealIndex) else { return nil }
        return meals[selectedMealIndex]
    }
    
    // MARK: - Meal Logging
    
    func logSelectedMeal() {
        guard let meal = selectedMeal else { return }
        mealLog.logMeal(meal)
        
        // Refresh summary to show updated totals
        dailySummary = Self.makeDailySummary(from: authService.currentUser, mealLog: mealLog)
        showMealLoggedAlert = true
    }
    
    // MARK: - Load Menu Data
    
    func loadMenuData() async {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            // Fetch dining halls
            let halls = try await MenuService.shared.fetchDiningHalls()
            diningHalls = halls
            
            // Fetch menus from first 3 dining halls and create recommended meals
            var recommendedMeals: [RecommendedMeal] = []
            
            for hall in halls.prefix(3) {
                let menu = try await MenuService.shared.fetchMenu(diningHallId: hall.id)
                
                // Create a recommended meal from lunch items (or dinner if no lunch)
                let items = !menu.lunch.isEmpty ? menu.lunch : menu.dinner
                
                if !items.isEmpty {
                    let meal = Self.createRecommendedMeal(
                        from: items.prefix(4),
                        diningHall: hall.short_name
                    )
                    recommendedMeals.append(meal)
                }
            }
            
            if !recommendedMeals.isEmpty {
                meals = recommendedMeals
            }
            
        } catch {
            self.error = error.localizedDescription
            // Keep mock data on error
        }
    }
    
    // MARK: - Refresh
    
    func refresh() async {
        // Update daily summary with current logged data
        dailySummary = Self.makeDailySummary(from: authService.currentUser, mealLog: mealLog)
        
        // Reload menu data
        await loadMenuData()
    }
    
    // MARK: - Helpers
    
    private static func makeDailySummary(from user: UserResponse?, mealLog: MealLogService) -> DailySummary {
        let logged = mealLog.todaysTotals
        
        if let profile = user?.profile {
            return DailySummary(
                caloriesToday: logged.calories,
                caloriesTarget: profile.calories_target,
                proteinGrams: logged.protein,
                proteinTarget: profile.protein_target,
                carbsGrams: logged.carbs,
                carbsTarget: profile.carbs_target,
                fatGrams: logged.fat,
                fatTarget: profile.fat_target
            )
        }
        
        // Fallback to mock targets with real logged data
        return DailySummary(
            caloriesToday: logged.calories,
            caloriesTarget: MockHomeData.dailySummary.caloriesTarget,
            proteinGrams: logged.protein,
            proteinTarget: MockHomeData.dailySummary.proteinTarget,
            carbsGrams: logged.carbs,
            carbsTarget: MockHomeData.dailySummary.carbsTarget,
            fatGrams: logged.fat,
            fatTarget: MockHomeData.dailySummary.fatTarget
        )
    }
    
    private static func createRecommendedMeal(
        from items: ArraySlice<MenuItemResponse>,
        diningHall: String
    ) -> RecommendedMeal {
        let menuItems = items.map { item in
            MenuItem(
                emoji: emojiForItem(item),
                name: item.name,
                servingDescription: item.description ?? "1 serving"
            )
        }
        
        let totalCalories = items.reduce(0) { $0 + $1.calories }
        let totalProtein = items.reduce(0) { $0 + $1.protein }
        let totalCarbs = items.reduce(0) { $0 + $1.carbs }
        let totalFat = items.reduce(0) { $0 + $1.fat }
        
        return RecommendedMeal(
            diningHall: diningHall,
            items: Array(menuItems),
            totalCalories: totalCalories,
            proteinGrams: totalProtein,
            carbsGrams: totalCarbs,
            fatGrams: totalFat
        )
    }
    
    private static func emojiForItem(_ item: MenuItemResponse) -> String {
        let name = item.name.lowercased()
        
        // Map common food items to emojis
        if name.contains("chicken") { return "🍗" }
        if name.contains("beef") || name.contains("steak") { return "🥩" }
        if name.contains("salmon") || name.contains("fish") || name.contains("tilapia") { return "🐟" }
        if name.contains("egg") { return "🍳" }
        if name.contains("bacon") { return "🥓" }
        if name.contains("pancake") || name.contains("waffle") { return "🥞" }
        if name.contains("oatmeal") || name.contains("cereal") { return "🥣" }
        if name.contains("toast") || name.contains("bread") { return "🍞" }
        if name.contains("rice") { return "🍚" }
        if name.contains("pasta") || name.contains("spaghetti") { return "🍝" }
        if name.contains("pizza") { return "🍕" }
        if name.contains("burger") { return "🍔" }
        if name.contains("sandwich") || name.contains("wrap") { return "🥪" }
        if name.contains("salad") { return "🥗" }
        if name.contains("soup") { return "🍲" }
        if name.contains("broccoli") { return "🥦" }
        if name.contains("carrot") { return "🥕" }
        if name.contains("potato") { return "🥔" }
        if name.contains("avocado") { return "🥑" }
        if name.contains("fruit") || name.contains("berry") { return "🍓" }
        if name.contains("yogurt") { return "🥛" }
        if name.contains("fries") { return "🍟" }
        if name.contains("wing") { return "🍗" }
        if name.contains("pork") { return "🐷" }
        if name.contains("turkey") { return "🦃" }
        if name.contains("meatball") { return "🧆" }
        if name.contains("falafel") { return "🧆" }
        if name.contains("tofu") { return "🫘" }
        if name.contains("noodle") || name.contains("ramen") || name.contains("pad thai") { return "🍜" }
        if name.contains("dumpling") || name.contains("bun") { return "🥟" }
        
        // Default emoji for food
        return "🍽️"
    }
}
