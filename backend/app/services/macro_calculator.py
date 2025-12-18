"""
Macro calculator service - matches frontend MacroCalculator.swift exactly.
Uses evidence-based protein recommendations based on body weight.
"""
from typing import Tuple

# Activity multipliers for TDEE calculation
ACTIVITY_MULTIPLIERS = [1.2, 1.375, 1.55, 1.725, 1.9]  # Sedentary, Light, Moderate, Active, Very Active

# Calories per gram
CALORIES_PER_GRAM_PROTEIN = 4.0
CALORIES_PER_GRAM_CARBS = 4.0
CALORIES_PER_GRAM_FAT = 9.0

# Protein per lb of body weight by goal type
PROTEIN_PER_LB = {
    0: 0.9,   # Lean Muscle Growth
    1: 0.8,   # Bulking
    2: 1.0,   # Fat Loss (higher to preserve muscle)
    3: 0.7,   # Maintenance
}

# Fat percentage of calories by goal type
FAT_PERCENT = {
    0: 0.28,  # Lean Muscle Growth
    1: 0.28,  # Bulking
    2: 0.25,  # Fat Loss (slightly lower)
    3: 0.28,  # Maintenance
}


def height_to_cm(height_text: str) -> float:
    """
    Convert height from feet/inches string to centimeters.
    Format: "5'10\"" or "5'10" or "175 cm"
    """
    # Check if already in cm format
    cleaned_cm = height_text.replace(' cm', '').replace('cm', '')
    try:
        cm_value = float(cleaned_cm)
        if cm_value > 100:  # Likely centimeters
            return cm_value
    except ValueError:
        pass
    
    cleaned = height_text.replace('"', '').replace("'", ' ')
    parts = cleaned.split()
    
    if len(parts) < 2:
        # Try single number as feet
        try:
            feet = float(parts[0]) if parts else 0
            return feet * 30.48
        except (ValueError, IndexError):
            return 0.0
    
    try:
        feet = float(parts[0])
        inches = float(parts[1])
        return (feet * 30.48) + (inches * 2.54)
    except (ValueError, IndexError):
        return 0.0


def lbs_to_kg(lbs: int) -> float:
    """Convert pounds to kilograms."""
    return float(lbs) * 0.453592


def calculate_bmr(weight_kg: float, height_cm: float, age_years: int, is_male: bool) -> float:
    """Calculate BMR using Mifflin-St Jeor equation (most accurate)."""
    base = 10 * weight_kg + 6.25 * height_cm - 5 * age_years
    return base + 5 if is_male else base - 161


def calculate_tdee(bmr: float, activity_index: int) -> float:
    """Calculate TDEE (Total Daily Energy Expenditure)."""
    if 0 <= activity_index < len(ACTIVITY_MULTIPLIERS):
        multiplier = ACTIVITY_MULTIPLIERS[activity_index]
    else:
        multiplier = 1.2
    return bmr * multiplier


def calculate_target_calories(tdee: float, goal_index: int) -> int:
    """Calculate target calories based on goal type."""
    adjustments = {
        0: 1.1,   # Lean Muscle Growth - slight surplus
        1: 1.2,   # Bulking - larger surplus
        2: 0.8,   # Fat Loss - deficit
        3: 1.0,   # Maintenance
    }
    adjustment = adjustments.get(goal_index, 1.0)
    return round(tdee * adjustment)


def calculate_macros(target_calories: int, goal_index: int, weight_lbs: int) -> Tuple[int, int, int]:
    """
    Calculate macro targets in grams based on body weight.
    
    Uses evidence-based protein recommendations:
    - Muscle building: 0.7-1g per lb body weight
    - Fat loss: 0.8-1g per lb (higher to preserve muscle)
    - Maintenance: 0.6-0.8g per lb
    
    Returns:
        Tuple of (protein, carbs, fat) in grams
    """
    # Protein based on body weight
    protein_per_lb = PROTEIN_PER_LB.get(goal_index, 0.8)
    protein_grams = round(weight_lbs * protein_per_lb)
    protein_calories = protein_grams * CALORIES_PER_GRAM_PROTEIN
    
    # Fat: 25-30% of calories
    fat_percent = FAT_PERCENT.get(goal_index, 0.28)
    fat_calories = target_calories * fat_percent
    fat_grams = round(fat_calories / CALORIES_PER_GRAM_FAT)
    
    # Carbs: remaining calories
    carbs_calories = target_calories - protein_calories - fat_calories
    carbs_grams = max(0, round(carbs_calories / CALORIES_PER_GRAM_CARBS))
    
    return (protein_grams, carbs_grams, fat_grams)


def calculate_all_macros(
    weight_lbs: int,
    height_text: str,
    age_years: int,
    is_male: bool,
    activity_level_index: int,
    goal_type_index: int
) -> Tuple[int, int, int, int]:
    """
    Calculate all macro targets from profile data.
    
    Returns:
        Tuple of (calories, protein, carbs, fat)
    """
    weight_kg = lbs_to_kg(weight_lbs)
    height_cm = height_to_cm(height_text)
    
    if weight_kg <= 0 or height_cm <= 0 or age_years <= 0:
        # Return sensible defaults if invalid data
        return (2000, 120, 200, 65)
    
    bmr = calculate_bmr(weight_kg, height_cm, age_years, is_male)
    tdee = calculate_tdee(bmr, activity_level_index)
    target_calories = calculate_target_calories(tdee, goal_type_index)
    protein, carbs, fat = calculate_macros(target_calories, goal_type_index, weight_lbs)
    
    return (target_calories, protein, carbs, fat)
