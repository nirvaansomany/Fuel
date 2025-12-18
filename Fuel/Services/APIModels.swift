import Foundation

// MARK: - Auth Models

struct LoginRequest: Encodable {
    let username: String  // email
    let password: String
}

struct SignupRequest: Encodable {
    let email: String
    let name: String
    let password: String
    let profile: ProfileCreateRequest?
}

struct ProfileCreateRequest: Encodable {
    let age_years: Int
    let height_text: String
    let weight_lbs: Int
    let goal_weight_lbs: Int
    let is_male: Bool
    let activity_level_index: Int
    let goal_type_index: Int
    let selected_vitamins: [String]
    let dietary_restrictions: [String]
    let disliked_foods: [String]
    let selected_dining_halls: [String]
    let delivery_method_index: Int
    let appearance_index: Int
}

struct TokenResponse: Decodable {
    let access_token: String
    let token_type: String
}

struct UserWithTokenResponse: Decodable {
    let user: UserResponse
    let access_token: String
    let token_type: String
}

// MARK: - User Models

struct UserResponse: Decodable {
    let id: Int
    let email: String
    let name: String
    let initials: String
    let created_at: String
    let updated_at: String
    let profile: ProfileResponse?
}

struct ProfileResponse: Decodable {
    let id: Int
    let user_id: Int
    let age_years: Int
    let height_text: String
    let weight_lbs: Int
    let goal_weight_lbs: Int
    let is_male: Bool
    let activity_level_index: Int
    let goal_type_index: Int
    let calories_target: Int
    let protein_target: Int
    let carbs_target: Int
    let fat_target: Int
    let selected_vitamins: [String]
    let dietary_restrictions: [String]
    let disliked_foods: [String]
    let selected_dining_halls: [String]
    let delivery_method_index: Int
    let appearance_index: Int
    let created_at: String
    let updated_at: String
}

struct ProfileUpdateRequest: Encodable {
    var name: String?
    var age_years: Int?
    var height_text: String?
    var weight_lbs: Int?
    var goal_weight_lbs: Int?
    var is_male: Bool?
    var activity_level_index: Int?
    var goal_type_index: Int?
    var selected_vitamins: [String]?
    var dietary_restrictions: [String]?
    var disliked_foods: [String]?
    var selected_dining_halls: [String]?
    var delivery_method_index: Int?
    var appearance_index: Int?
}

// MARK: - Menu Models

struct DiningHallResponse: Decodable, Identifiable {
    let id: Int
    let code: String
    let name: String
    let short_name: String
    let location: String
    let description: String?
    let image_url: String?
    let is_active: Bool
}

struct DiningHallListResponse: Decodable {
    let dining_halls: [DiningHallResponse]
    let count: Int
}

struct MenuItemResponse: Decodable, Identifiable {
    let id: Int
    let dining_hall_id: Int
    let name: String
    let description: String?
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let meal_period: String
    let station: String?
    let menu_date: String
    let is_vegetarian: Bool
    let is_vegan: Bool
    let is_gluten_free: Bool
    let allergens: [String]?
}

struct MenuResponse: Decodable {
    let dining_hall: DiningHallResponse
    let date: String
    let breakfast: [MenuItemResponse]
    let lunch: [MenuItemResponse]
    let dinner: [MenuItemResponse]
}

// MARK: - Error Models

struct APIErrorResponse: Decodable {
    let detail: String
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int, String)
    case unauthorized
    case notFound
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .notFound:
            return "Resource not found"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

