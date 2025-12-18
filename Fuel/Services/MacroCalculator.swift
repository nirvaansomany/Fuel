import Foundation

enum MacroCalculator {
    // Activity multipliers for TDEE calculation
    private static let activityMultipliers: [Double] = [1.2, 1.375, 1.55, 1.725, 1.9] // Sedentary, Light, Moderate, Active, Very Active
    
    // Calories per gram
    private static let caloriesPerGramProtein = 4.0
    private static let caloriesPerGramCarbs = 4.0
    private static let caloriesPerGramFat = 9.0
    
    /// Calculate BMR using Mifflin-St Jeor equation (most accurate)
    static func calculateBMR(weightKg: Double, heightCm: Double, ageYears: Int, isMale: Bool) -> Double {
        let base = 10 * weightKg + 6.25 * heightCm - 5 * Double(ageYears)
        return isMale ? base + 5 : base - 161
    }
    
    /// Calculate TDEE (Total Daily Energy Expenditure)
    static func calculateTDEE(bmr: Double, activityIndex: Int) -> Double {
        let multiplier = activityMultipliers[safe: activityIndex] ?? 1.2
        return bmr * multiplier
    }
    
    /// Calculate target calories based on goal type
    static func calculateTargetCalories(tdee: Double, goalIndex: Int) -> Int {
        let adjustment: Double
        switch goalIndex {
        case 0: // Lean Muscle Growth - slight surplus
            adjustment = 1.1
        case 1: // Bulking - larger surplus
            adjustment = 1.2
        case 2: // Fat Loss - deficit
            adjustment = 0.8
        case 3: // Maintenance
            adjustment = 1.0
        default:
            adjustment = 1.0
        }
        return Int(round(tdee * adjustment))
    }
    
    /// Calculate macro targets in grams based on body weight and goal
    /// Uses evidence-based protein recommendations:
    /// - Muscle building: 0.7-1g per lb body weight
    /// - Fat loss: 0.8-1g per lb (higher to preserve muscle)
    /// - Maintenance: 0.6-0.8g per lb
    static func calculateMacros(targetCalories: Int, goalIndex: Int, weightLbs: Int) -> (protein: Int, carbs: Int, fat: Int) {
        // Protein based on body weight (grams per lb)
        let proteinPerLb: Double
        switch goalIndex {
        case 0: // Lean Muscle Growth
            proteinPerLb = 0.9
        case 1: // Bulking
            proteinPerLb = 0.8
        case 2: // Fat Loss (higher protein to preserve muscle)
            proteinPerLb = 1.0
        case 3: // Maintenance
            proteinPerLb = 0.7
        default:
            proteinPerLb = 0.8
        }
        
        let proteinGrams = Int(round(Double(weightLbs) * proteinPerLb))
        let proteinCalories = Double(proteinGrams) * caloriesPerGramProtein
        
        // Fat: 25-30% of calories (essential for hormones)
        let fatPercent: Double
        switch goalIndex {
        case 2: // Fat Loss - slightly lower fat
            fatPercent = 0.25
        default:
            fatPercent = 0.28
        }
        let fatCalories = Double(targetCalories) * fatPercent
        let fatGrams = Int(round(fatCalories / caloriesPerGramFat))
        
        // Carbs: remaining calories
        let carbsCalories = Double(targetCalories) - proteinCalories - fatCalories
        let carbsGrams = max(0, Int(round(carbsCalories / caloriesPerGramCarbs)))
        
        return (protein: proteinGrams, carbs: carbsGrams, fat: fatGrams)
    }
    
    /// Legacy method for backward compatibility (without weight parameter)
    static func calculateMacros(targetCalories: Int, goalIndex: Int) -> (protein: Int, carbs: Int, fat: Int) {
        // Fallback: assume 165 lb person
        return calculateMacros(targetCalories: targetCalories, goalIndex: goalIndex, weightLbs: 165)
    }
    
    /// Convert height from feet/inches string to centimeters
    /// Format: "5'10\"" or "5'10"
    static func heightToCm(_ heightText: String) -> Double {
        // Check if already in cm format (just a number)
        if let cm = Double(heightText.replacingOccurrences(of: " cm", with: "")) {
            if cm > 100 { // Likely centimeters
                return cm
            }
        }
        
        let cleaned = heightText.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: " ")
        let parts = cleaned.split(separator: " ").compactMap { Int($0) }
        
        guard parts.count >= 2 else {
            // Try single number as feet
            if let feet = parts.first {
                return Double(feet) * 30.48
            }
            return 0
        }
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
    
    /// Convert kilograms to pounds
    static func kgToLbs(_ kg: Double) -> Int {
        return Int(round(kg / 0.453592))
    }
    
    /// Convert centimeters to height text based on unit preference
    static func formatHeight(_ cm: Double, useMetric: Bool) -> String {
        if useMetric {
            return "\(Int(round(cm))) cm"
        } else {
            return cmToHeightText(cm)
        }
    }
    
    /// Convert weight based on unit preference
    static func formatWeight(_ lbs: Int, useMetric: Bool) -> String {
        if useMetric {
            let kg = Double(lbs) * 0.453592
            return "\(Int(round(kg))) kg"
        } else {
            return "\(lbs) lbs"
        }
    }
}

// Array safe subscript extension
private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
