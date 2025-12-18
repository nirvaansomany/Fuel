import Foundation

/// Simple meal logging service for tracking daily food intake
/// Stores data locally using UserDefaults (could be upgraded to backend later)
@MainActor
final class MealLogService: ObservableObject {
    static let shared = MealLogService()
    
    @Published private(set) var todaysLogs: [MealLogEntry] = []
    
    private let userDefaultsKey = "meal_logs"
    
    private init() {
        loadTodaysLogs()
    }
    
    // MARK: - Public Interface
    
    /// Log a meal from a recommended meal card
    func logMeal(_ meal: RecommendedMeal) {
        let entry = MealLogEntry(
            id: UUID(),
            date: Date(),
            mealName: "\(meal.diningHall) Meal",
            items: meal.items.map { $0.name },
            calories: meal.totalCalories,
            protein: meal.proteinGrams,
            carbs: meal.carbsGrams,
            fat: meal.fatGrams
        )
        addEntry(entry)
    }
    
    /// Log a single menu item
    func logMenuItem(_ item: MenuItemResponse, quantity: Int = 1) {
        let entry = MealLogEntry(
            id: UUID(),
            date: Date(),
            mealName: item.name,
            items: [item.name],
            calories: item.calories * quantity,
            protein: item.protein * quantity,
            carbs: item.carbs * quantity,
            fat: item.fat * quantity
        )
        addEntry(entry)
    }
    
    /// Log a custom meal
    func logCustomMeal(name: String, calories: Int, protein: Int, carbs: Int, fat: Int) {
        let entry = MealLogEntry(
            id: UUID(),
            date: Date(),
            mealName: name,
            items: [name],
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat
        )
        addEntry(entry)
    }
    
    /// Remove a logged meal
    func removeEntry(_ entry: MealLogEntry) {
        todaysLogs.removeAll { $0.id == entry.id }
        saveLogs()
    }
    
    /// Clear all today's logs
    func clearTodaysLogs() {
        todaysLogs.removeAll()
        saveLogs()
    }
    
    /// Get today's totals
    var todaysTotals: (calories: Int, protein: Int, carbs: Int, fat: Int) {
        let totals = todaysLogs.reduce((0, 0, 0, 0)) { result, entry in
            (
                result.0 + entry.calories,
                result.1 + entry.protein,
                result.2 + entry.carbs,
                result.3 + entry.fat
            )
        }
        return totals
    }
    
    // MARK: - Private Methods
    
    private func addEntry(_ entry: MealLogEntry) {
        todaysLogs.append(entry)
        saveLogs()
    }
    
    private func loadTodaysLogs() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let allLogs = try? JSONDecoder().decode([MealLogEntry].self, from: data) else {
            todaysLogs = []
            return
        }
        
        // Filter to only today's logs
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        todaysLogs = allLogs.filter { calendar.isDate($0.date, inSameDayAs: today) }
    }
    
    private func saveLogs() {
        // Load all existing logs first
        var allLogs: [MealLogEntry] = []
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let existing = try? JSONDecoder().decode([MealLogEntry].self, from: data) {
            // Keep logs from other days
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            allLogs = existing.filter { !calendar.isDate($0.date, inSameDayAs: today) }
        }
        
        // Add today's logs
        allLogs.append(contentsOf: todaysLogs)
        
        // Keep only last 30 days of logs
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        allLogs = allLogs.filter { $0.date >= thirtyDaysAgo }
        
        // Save
        if let data = try? JSONEncoder().encode(allLogs) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}

/// A logged meal entry
struct MealLogEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let mealName: String
    let items: [String]
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
}

