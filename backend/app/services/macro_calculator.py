"""
Macro calculator service - matches frontend MacroCalculator.swift exactly.
"""
from typing import Tuple

# Activity multipliers for TDEE calculation (matches Swift)
ACTIVITY_MULTIPLIERS = [1.2, 1.375, 1.55, 1.725, 1.9]  # Sedentary, Light, Moderate, Active, Very Active

# Macro splits by goal type (protein%, carbs%, fat%) - matches Swift
GOAL_SPLITS = [
    (0.40, 0.30, 0.30),  # Lean Muscle Growth
    (0.30, 0.40, 0.30),  # Bulking
    (0.40, 0.30, 0.30),  # Fat Loss
    (0.30, 0.40, 0.30),  # Maintenance
]

# Calories per gram
CALORIES_PER_GRAM_PROTEIN = 4.0
CALORIES_PER_GRAM_CARBS = 4.0
CALORIES_PER_GRAM_FAT = 9.0


def height_to_cm(height_text: str) -> float:
    """
    Convert height from feet/inches string to centimeters.
    Format: "5'10\"" or "5'10"
    Matches MacroCalculator.heightToCm in Swift.
    """
    cleaned = height_text.replace('"', '').replace("'", ' ')
    parts = cleaned.split()
    
    if len(parts) < 2:
        return 0.0
    
    try:
        feet = float(parts[0])
        inches = float(parts[1])
        return (feet * 30.48) + (inches * 2.54)
    except (ValueError, IndexError):
        return 0.0


def lbs_to_kg(lbs: int) -> float:
    """Convert pounds to kilograms. Matches MacroCalculator.lbsToKg in Swift."""
    return float(lbs) * 0.453592


def calculate_bmr(weight_kg: float, height_cm: float, age_years: int, is_male: bool) -> float:
    """
    Calculate BMR using Mifflin-St Jeor equation (most accurate).
    Matches MacroCalculator.calculateBMR in Swift.
    """
    base = 10 * weight_kg + 6.25 * height_cm - 5 * age_years
    return base + 5 if is_male else base - 161


def calculate_tdee(bmr: float, activity_index: int) -> float:
    """
    Calculate TDEE (Total Daily Energy Expenditure).
    Matches MacroCalculator.calculateTDEE in Swift.
    """
    if 0 <= activity_index < len(ACTIVITY_MULTIPLIERS):
        multiplier = ACTIVITY_MULTIPLIERS[activity_index]
    else:
        multiplier = 1.2
    return bmr * multiplier


def calculate_target_calories(tdee: float, goal_index: int) -> int:
    """
    Calculate target calories based on goal type.
    Matches MacroCalculator.calculateTargetCalories in Swift.
    """
    adjustments = {
        0: 1.1,   # Lean Muscle Growth - slight surplus
        1: 1.2,   # Bulking - larger surplus
        2: 0.85,  # Fat Loss - deficit
        3: 1.0,   # Maintenance
    }
    adjustment = adjustments.get(goal_index, 1.0)
    return round(tdee * adjustment)


def calculate_macros(target_calories: int, goal_index: int) -> Tuple[int, int, int]:
    """
    Calculate macro targets in grams.
    Matches MacroCalculator.calculateMacros in Swift.
    
    Returns:
        Tuple of (protein, carbs, fat) in grams
    """
    if 0 <= goal_index < len(GOAL_SPLITS):
        split = GOAL_SPLITS[goal_index]
    else:
        split = GOAL_SPLITS[0]
    
    protein_calories = target_calories * split[0]
    carbs_calories = target_calories * split[1]
    fat_calories = target_calories * split[2]
    
    protein_grams = round(protein_calories / CALORIES_PER_GRAM_PROTEIN)
    carbs_grams = round(carbs_calories / CALORIES_PER_GRAM_CARBS)
    fat_grams = round(fat_calories / CALORIES_PER_GRAM_FAT)
    
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
        # Return defaults if invalid data
        return (2400, 180, 240, 70)
    
    bmr = calculate_bmr(weight_kg, height_cm, age_years, is_male)
    tdee = calculate_tdee(bmr, activity_level_index)
    target_calories = calculate_target_calories(tdee, goal_type_index)
    protein, carbs, fat = calculate_macros(target_calories, goal_type_index)
    
    return (target_calories, protein, carbs, fat)

