import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile
    @Published var isLoading = false
    @Published var saveError: String?
    
    private var saveTask: Task<Void, Never>?
    private var authService: AuthService
    
    @Published var selectedActivityIndex: Int {
        didSet {
            recalculateMacros()
            scheduleProfileSave()
        }
    }
    
    @Published var selectedGoalIndex: Int {
        didSet {
            recalculateMacros()
            scheduleProfileSave()
        }
    }
    
    @Published var selectedDeliveryIndex: Int {
        didSet {
            scheduleProfileSave()
        }
    }
    
    @Published var selectedAppearanceIndex: Int {
        didSet {
            scheduleProfileSave()
        }
    }

    // Editable fields
    @Published var ageText: String {
        didSet {
            if let age = Int(ageText), age > 0, age < 150 {
                profile.ageYears = age
                recalculateMacros()
                scheduleProfileSave()
            }
        }
    }
    
    @Published var heightText: String {
        didSet {
            let heightCm = MacroCalculator.heightToCm(heightText)
            if heightCm > 0 {
                profile.heightText = heightText
                recalculateMacros()
                scheduleProfileSave()
            }
        }
    }
    
    @Published var weightText: String {
        didSet {
            if let weight = Int(weightText), weight > 0, weight < 1000 {
                profile.weightLbs = weight
                recalculateMacros()
                scheduleProfileSave()
            }
        }
    }
    
    @Published var goalWeightText: String {
        didSet {
            if let goalWeight = Int(goalWeightText), goalWeight > 0, goalWeight < 1000 {
                profile.goalWeightLbs = goalWeight
                scheduleProfileSave()
            }
        }
    }
    
    @Published var isMale: Bool {
        didSet {
            profile.isMale = isMale
            recalculateMacros()
            scheduleProfileSave()
        }
    }

    let activityLevels: [String]
    let goalTypes: [String]
    let vitaminsToTrack: [String]
    @Published var selectedVitamins: Set<String> {
        didSet {
            scheduleProfileSave()
        }
    }
    let dietaryRestrictions: [String]
    @Published var selectedDietaryRestrictions: Set<String> {
        didSet {
            scheduleProfileSave()
        }
    }
    let dislikedFoods: [String]
    @Published var selectedDislikedFoods: Set<String> {
        didSet {
            scheduleProfileSave()
        }
    }
    let diningHalls: [String]
    @Published var selectedDiningHalls: Set<String> {
        didSet {
            scheduleProfileSave()
        }
    }
    let notificationPreferences: [MockProfileData.NotificationPreference]
    let deliveryMethods: [String]
    let appearanceOptions: [String]

    init() {
        // Capture auth service first
        let service = AuthService.shared
        self.authService = service
        
        // Get initial profile data
        let initialProfile = Self.profileFromUser(service.currentUser) ?? MockProfileData.profile
        
        // Initialize ALL stored properties before using 'self'
        self.profile = initialProfile
        self.activityLevels = MockProfileData.activityLevels
        self.goalTypes = MockProfileData.goalTypes
        self.vitaminsToTrack = MockProfileData.vitaminsToTrack
        self.dietaryRestrictions = MockProfileData.dietaryRestrictions
        self.dislikedFoods = MockProfileData.dislikedFoods
        self.diningHalls = MockProfileData.diningHalls
        self.notificationPreferences = MockProfileData.notificationPreferences
        self.deliveryMethods = MockProfileData.deliveryMethods
        self.appearanceOptions = MockProfileData.appearanceOptions
        
        // Initialize from API user if available, else use mock
        if let user = service.currentUser, let apiProfile = user.profile {
            self.selectedActivityIndex = apiProfile.activity_level_index
            self.selectedGoalIndex = apiProfile.goal_type_index
            self.selectedVitamins = Set(apiProfile.selected_vitamins)
            self.selectedDietaryRestrictions = Set(apiProfile.dietary_restrictions)
            self.selectedDislikedFoods = Set(apiProfile.disliked_foods)
            self.selectedDiningHalls = Set(apiProfile.selected_dining_halls)
            self.selectedDeliveryIndex = apiProfile.delivery_method_index
            self.selectedAppearanceIndex = apiProfile.appearance_index
        } else {
            self.selectedActivityIndex = MockProfileData.selectedActivityIndex
            self.selectedGoalIndex = MockProfileData.selectedGoalIndex
            self.selectedVitamins = MockProfileData.selectedVitamins
            self.selectedDietaryRestrictions = MockProfileData.selectedDietaryRestrictions
            self.selectedDislikedFoods = MockProfileData.selectedDislikedFoods
            self.selectedDiningHalls = MockProfileData.selectedDiningHalls
            self.selectedDeliveryIndex = MockProfileData.selectedDeliveryIndex
            self.selectedAppearanceIndex = MockProfileData.selectedAppearanceIndex
        }
        
        // Initialize editable text fields (use initialProfile, not self.profile)
        self.ageText = "\(initialProfile.ageYears)"
        self.heightText = initialProfile.heightText
        self.weightText = "\(initialProfile.weightLbs)"
        self.goalWeightText = "\(initialProfile.goalWeightLbs)"
        self.isMale = initialProfile.isMale
        
        // Calculate macros with correct formula (don't use server values)
        recalculateMacros()
    }
    
    // MARK: - Convert API User to Local Profile
    
    private static func profileFromUser(_ user: UserResponse?) -> UserProfile? {
        guard let user = user, let apiProfile = user.profile else { return nil }
        
        // Create profile with placeholder macros - they'll be recalculated locally
        return UserProfile(
            name: user.name,
            email: user.email,
            initials: user.initials,
            ageYears: apiProfile.age_years,
            heightText: apiProfile.height_text,
            weightLbs: apiProfile.weight_lbs,
            goalWeightLbs: apiProfile.goal_weight_lbs,
            isMale: apiProfile.is_male,
            caloriesTarget: 0,  // Will be recalculated
            proteinTarget: 0,
            carbsTarget: 0,
            fatTarget: 0
        )
    }
    
    // MARK: - Refresh from API
    
    func refreshFromAPI() async {
        await authService.fetchCurrentUser()
        
        if let user = authService.currentUser, let apiProfile = user.profile {
            // Update profile fields (but NOT macros - we recalculate those locally)
            profile.ageYears = apiProfile.age_years
            profile.heightText = apiProfile.height_text
            profile.weightLbs = apiProfile.weight_lbs
            profile.goalWeightLbs = apiProfile.goal_weight_lbs
            profile.isMale = apiProfile.is_male
            
            // Update text fields without triggering didSet saves
            self.ageText = "\(apiProfile.age_years)"
            self.heightText = apiProfile.height_text
            self.weightText = "\(apiProfile.weight_lbs)"
            self.goalWeightText = "\(apiProfile.goal_weight_lbs)"
            self.isMale = apiProfile.is_male
            
            // Update preferences
            self.selectedActivityIndex = apiProfile.activity_level_index
            self.selectedGoalIndex = apiProfile.goal_type_index
            self.selectedVitamins = Set(apiProfile.selected_vitamins)
            self.selectedDietaryRestrictions = Set(apiProfile.dietary_restrictions)
            self.selectedDislikedFoods = Set(apiProfile.disliked_foods)
            self.selectedDiningHalls = Set(apiProfile.selected_dining_halls)
            self.selectedDeliveryIndex = apiProfile.delivery_method_index
            self.selectedAppearanceIndex = apiProfile.appearance_index
        }
        
        // Always recalculate macros locally with correct formula
        recalculateMacros()
    }
    
    // MARK: - Save to API (Debounced)
    
    private func scheduleProfileSave() {
        // Cancel any pending save
        saveTask?.cancel()
        
        // Don't save if not authenticated
        guard authService.isAuthenticated else { return }
        
        // Debounce: wait 1 second after last change before saving
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            guard !Task.isCancelled else { return }
            
            await saveProfileToAPI()
        }
    }
    
    private func saveProfileToAPI() async {
        let update = ProfileUpdateRequest(
            name: profile.name,
            age_years: profile.ageYears,
            height_text: profile.heightText,
            weight_lbs: profile.weightLbs,
            goal_weight_lbs: profile.goalWeightLbs,
            is_male: profile.isMale,
            activity_level_index: selectedActivityIndex,
            goal_type_index: selectedGoalIndex,
            selected_vitamins: Array(selectedVitamins),
            dietary_restrictions: Array(selectedDietaryRestrictions),
            disliked_foods: Array(selectedDislikedFoods),
            selected_dining_halls: Array(selectedDiningHalls),
            delivery_method_index: selectedDeliveryIndex,
            appearance_index: selectedAppearanceIndex
        )
        
        let success = await authService.updateProfile(update)
        
        if !success {
            saveError = authService.error
        } else {
            saveError = nil
            // Don't overwrite local macros - we use client-side calculation
            // for immediate feedback with the correct formula
        }
    }
    
    // MARK: - Local Macro Calculation (for immediate UI feedback)
    
    private func recalculateMacros() {
        let weightKg = MacroCalculator.lbsToKg(profile.weightLbs)
        let heightCm = MacroCalculator.heightToCm(profile.heightText)
        
        guard weightKg > 0, heightCm > 0, profile.ageYears > 0 else { return }
        
        let bmr = MacroCalculator.calculateBMR(
            weightKg: weightKg,
            heightCm: heightCm,
            ageYears: profile.ageYears,
            isMale: profile.isMale
        )
        
        let tdee = MacroCalculator.calculateTDEE(
            bmr: bmr,
            activityIndex: selectedActivityIndex
        )
        
        let targetCalories = MacroCalculator.calculateTargetCalories(
            tdee: tdee,
            goalIndex: selectedGoalIndex
        )
        
        // Pass weight for accurate protein calculation
        let macros = MacroCalculator.calculateMacros(
            targetCalories: targetCalories,
            goalIndex: selectedGoalIndex,
            weightLbs: profile.weightLbs
        )
        
        profile.caloriesTarget = targetCalories
        profile.proteinTarget = macros.protein
        profile.carbsTarget = macros.carbs
        profile.fatTarget = macros.fat
    }
    
    // MARK: - Logout
    
    func logout() {
        authService.logout()
    }
}
