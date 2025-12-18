import Foundation

enum MockProfileData {
    static let profile = UserProfile(
        name: "John Doe",
        email: "john.doe@ucla.edu",
        initials: "JD",
        ageYears: 21,
        heightText: "5'10\"",
        weightLbs: 165,
        goalWeightLbs: 175,
        isMale: true,
        caloriesTarget: 2400,
        proteinTarget: 180,
        carbsTarget: 240,
        fatTarget: 70
    )

    static let activityLevels = ["Sedentary", "Light", "Moderate", "Active", "Very Active"]
    static let selectedActivityIndex = 2

    static let goalTypes = ["Lean Muscle Growth", "Bulking", "Fat Loss", "Maintenance"]
    static let selectedGoalIndex = 0

    static let vitaminsToTrack = ["Vit D", "B12", "Iron", "Calcium", "Magnesium", "Omega-3", "Folate", "Zinc"]
    static let selectedVitamins: Set<String> = ["Vit D", "B12", "Iron", "Calcium"]

    static let dietaryRestrictions = ["Vegetarian", "Vegan", "Halal", "Gluten-free", "Dairy-free", "Nut-free", "None", "+ Add Custom"]
    static let selectedDietaryRestrictions: Set<String> = ["Vegetarian", "Halal", "None"]

    static let dislikedFoods = ["Mushrooms", "Olives", "Tomatoes", "Onions", "Peppers", "Eggplant", "Seafood", "Tofu", "+ Add Custom"]
    static let selectedDislikedFoods: Set<String> = ["Mushrooms", "Olives"]

    static let diningHalls = ["BPlate", "De Neve", "Rendezvous", "Cafe 1919", "Epicuria", "BCafe"]
    static let selectedDiningHalls: Set<String> = ["BPlate", "De Neve", "Rendezvous"]

    struct NotificationPreference: Identifiable {
        let id = UUID()
        let title: String
        let time: String
    }

    static let notificationPreferences: [NotificationPreference] = [
        NotificationPreference(title: "Breakfast Reminder", time: "8:00 AM"),
        NotificationPreference(title: "Lunch Reminder", time: "12:00 PM"),
        NotificationPreference(title: "Dinner Reminder", time: "6:00 PM"),
        NotificationPreference(title: "Daily Summary", time: "9:00 PM"),
        NotificationPreference(title: "Weekly Summary", time: "Sunday 7:00 PM")
    ]

    static let deliveryMethods = ["Push", "iMessage", "Widget"]
    static let selectedDeliveryIndex = 0

    static let appearanceOptions = ["Light", "Dark", "Auto"]
    static let selectedAppearanceIndex = 1
}


