import Foundation

enum MacroCalculator {
    // Activity multipliers for TDEE calculation
    private static let activityMultipliers: [Double] = [1.2, 1.375, 1.55, 1.725, 1.9] // Sedentary, Light, Moderate, Active, Very Active
    
    // Macro splits by goal type (protein%, carbs%, fat%)
    private static let goalSplits: [(protein: Double, carbs: Double, fat: Double)] = [
        (0.40, 0.30, 0.30), // Lean Muscle Growth
        (0.30, 0.40, 0.30), // Bulking
        (0.40, 0.30, 0.30), // Fat Loss
        (0.30, 0.40, 0.30)  // Maintenance
    ]
    
    // Calories per gram
    private static let caloriesPerGramProtein = 4.0
    private static let caloriesPerGramCarbs = 4.0
    private static let caloriesPerGramFat = 9.0
    
    /// Calculate BMR using Mifflin-St Jeor equation (most accurate)
    /// - Parameters:
    ///   - weightKg: Weight in kilograms
    ///   - heightCm: Height in centimeters
    ///   - ageYears: Age in years
    ///   - isMale: true for male, false for female
    /// - Returns: Basal Metabolic Rate in calories
    static func calculateBMR(weightKg: Double, heightCm: Double, ageYears: Int, isMale: Bool) -> Double {
        let base = 10 * weightKg + 6.25 * heightCm - 5 * Double(ageYears)
        return isMale ? base + 5 : base - 161
    }
    
    /// Calculate TDEE (Total Daily Energy Expenditure)
    /// - Parameters:
    ///   - bmr: Basal Metabolic Rate
    ///   - activityIndex: Index into activityMultipliers array (0-4)
    /// - Returns: Total Daily Energy Expenditure in calories
    static func calculateTDEE(bmr: Double, activityIndex: Int) -> Double {
        let multiplier = activityMultipliers[safe: activityIndex] ?? 1.2
        return bmr * multiplier
    }
    
    /// Calculate target calories based on goal type
    /// - Parameters:
    ///   - tdee: Total Daily Energy Expenditure
    ///   - goalIndex: Index into goalTypes (0: Lean Muscle, 1: Bulking, 2: Fat Loss, 3: Maintenance)
    /// - Returns: Target calories per day
    static func calculateTargetCalories(tdee: Double, goalIndex: Int) -> Int {
        let adjustment: Double
        switch goalIndex {
        case 0: // Lean Muscle Growth - slight surplus
            adjustment = 1.1
        case 1: // Bulking - larger surplus
            adjustment = 1.2
        case 2: // Fat Loss - deficit
            adjustment = 0.85
        case 3: // Maintenance
            adjustment = 1.0
        default:
            adjustment = 1.0
        }
        return Int(round(tdee * adjustment))
    }
    
    /// Calculate macro targets in grams
    /// - Parameters:
    ///   - targetCalories: Target daily calories
    ///   - goalIndex: Index into goalTypes
    /// - Returns: Tuple of (protein, carbs, fat) in grams
    static func calculateMacros(targetCalories: Int, goalIndex: Int) -> (protein: Int, carbs: Int, fat: Int) {
        let split = goalSplits[safe: goalIndex] ?? goalSplits[0]
        
        let proteinCalories = Double(targetCalories) * split.protein
        let carbsCalories = Double(targetCalories) * split.carbs
        let fatCalories = Double(targetCalories) * split.fat
        
        let proteinGrams = Int(round(proteinCalories / caloriesPerGramProtein))
        let carbsGrams = Int(round(carbsCalories / caloriesPerGramCarbs))
        let fatGrams = Int(round(fatCalories / caloriesPerGramFat))
        
        return (protein: proteinGrams, carbs: carbsGrams, fat: fatGrams)
    }
    
    /// Convert height from feet/inches string to centimeters
    /// Format: "5'10\"" or "5'10"
    static func heightToCm(_ heightText: String) -> Double {
        let cleaned = heightText.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: " ")
        let parts = cleaned.split(separator: " ").compactMap { Int($0) }
        
        guard parts.count >= 2 else { return 0 }
        let feet = Double(parts[0])
        let inches = Double(parts[1])
        return (feet * 30.48) + (inches * 2.54)
    }
    
    /// Convert height from centimeters to feet/inches string
    static func cmToHeightText(_ cm: Double) -> String {
        let totalInches = cm / 2.54
        let feet = Int(totalInches / 12)
        let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
        return "\(feet)'\(inches)\""
    }
    
    /// Convert pounds to kilograms
    static func lbsToKg(_ lbs: Int) -> Double {
        return Double(lbs) * 0.453592
    }
}

// Array safe subscript extension
private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

