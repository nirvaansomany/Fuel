import Foundation

/// Service for fetching menu data from the backend
actor MenuService {
    static let shared = MenuService()
    
    private var cachedDiningHalls: [DiningHallResponse]?
    private var menuCache: [String: MenuResponse] = [:]
    
    private init() {}
    
    // MARK: - Dining Halls
    
    func fetchDiningHalls(forceRefresh: Bool = false) async throws -> [DiningHallResponse] {
        if !forceRefresh, let cached = cachedDiningHalls {
            return cached
        }
        
        let response: DiningHallListResponse = try await APIClient.shared.get(
            "/menus/dining-halls"
        )
        
        cachedDiningHalls = response.dining_halls
        return response.dining_halls
    }
    
    // MARK: - Menu for Dining Hall
    
    func fetchMenu(
        diningHallId: Int,
        date: Date = Date(),
        forceRefresh: Bool = false
    ) async throws -> MenuResponse {
        let dateString = formatDate(date)
        let cacheKey = "\(diningHallId)-\(dateString)"
        
        if !forceRefresh, let cached = menuCache[cacheKey] {
            return cached
        }
        
        let endpoint = "/menus?dining_hall=\(diningHallId)&date=\(dateString)"
        let response: MenuResponse = try await APIClient.shared.get(endpoint)
        
        menuCache[cacheKey] = response
        return response
    }
    
    // MARK: - All Menu Items with Filters
    
    func fetchMenuItems(
        diningHallId: Int? = nil,
        date: Date = Date(),
        mealPeriod: String? = nil,
        vegetarian: Bool? = nil,
        vegan: Bool? = nil,
        glutenFree: Bool? = nil,
        minProtein: Int? = nil,
        maxCalories: Int? = nil
    ) async throws -> [MenuItemResponse] {
        var queryParams: [String] = []
        
        if let hallId = diningHallId {
            queryParams.append("dining_hall=\(hallId)")
        }
        
        queryParams.append("date=\(formatDate(date))")
        
        if let period = mealPeriod {
            queryParams.append("meal_period=\(period)")
        }
        
        if let veg = vegetarian, veg {
            queryParams.append("vegetarian=true")
        }
        
        if let vgn = vegan, vgn {
            queryParams.append("vegan=true")
        }
        
        if let gf = glutenFree, gf {
            queryParams.append("gluten_free=true")
        }
        
        if let minP = minProtein {
            queryParams.append("min_protein=\(minP)")
        }
        
        if let maxC = maxCalories {
            queryParams.append("max_calories=\(maxC)")
        }
        
        let endpoint = "/menus/items?\(queryParams.joined(separator: "&"))"
        return try await APIClient.shared.get(endpoint)
    }
    
    // MARK: - Clear Cache
    
    func clearCache() {
        cachedDiningHalls = nil
        menuCache.removeAll()
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

