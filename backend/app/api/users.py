"""
User profile API routes: GET/PUT /users/me
Matches frontend UserProfile.swift + MockProfileData.swift
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Annotated, Optional
from pydantic import BaseModel, Field, EmailStr
from datetime import datetime
from typing import List

from app.core.database import get_db
from app.models.user import User, Profile
from app.api.auth import get_current_user, get_initials, list_to_csv, csv_to_list, profile_to_response, user_to_response
from app.schemas.user import UserResponse, ProfileResponse
from app.services.macro_calculator import calculate_all_macros

router = APIRouter(prefix="/users", tags=["Users"])


class ProfileUpdateRequest(BaseModel):
    """
    Schema for updating user profile.
    All fields are optional - only provided fields will be updated.
    Matches frontend ProfileViewModel editable fields.
    """
    # User info
    name: Optional[str] = Field(default=None, min_length=1, max_length=255)
    
    # Biometrics (from UserProfile.swift)
    age_years: Optional[int] = Field(default=None, ge=1, le=150)
    height_text: Optional[str] = Field(default=None, max_length=20)  # Format: "5'10\""
    weight_lbs: Optional[int] = Field(default=None, ge=50, le=1000)
    goal_weight_lbs: Optional[int] = Field(default=None, ge=50, le=1000)
    is_male: Optional[bool] = None
    
    # Goals (indexes into frontend arrays)
    activity_level_index: Optional[int] = Field(default=None, ge=0, le=4)
    goal_type_index: Optional[int] = Field(default=None, ge=0, le=3)
    
    # Preferences (as lists)
    selected_vitamins: Optional[List[str]] = None
    dietary_restrictions: Optional[List[str]] = None
    disliked_foods: Optional[List[str]] = None
    selected_dining_halls: Optional[List[str]] = None
    
    # Settings (indexes into frontend arrays)
    delivery_method_index: Optional[int] = Field(default=None, ge=0, le=2)
    appearance_index: Optional[int] = Field(default=None, ge=0, le=2)


@router.get("/me", response_model=UserResponse)
async def get_user_profile(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Session = Depends(get_db)
):
    """
    Get current user's profile data.
    
    Returns complete user data including:
    - User info (name, email, initials)
    - Profile biometrics (age, height, weight, etc.)
    - Calculated macros (calories, protein, carbs, fat)
    - Preferences (vitamins, dietary restrictions, etc.)
    - Settings (delivery method, appearance)
    """
    return user_to_response(current_user)


@router.put("/me", response_model=UserResponse)
async def update_user_profile(
    update_data: ProfileUpdateRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Session = Depends(get_db)
):
    """
    Update current user's profile.
    
    Only provided fields will be updated.
    Macros (calories, protein, carbs, fat) are automatically recalculated
    when biometrics or goals change.
    
    Updatable fields:
    - name: User's display name
    - age_years, height_text, weight_lbs, goal_weight_lbs, is_male: Biometrics
    - activity_level_index (0-4), goal_type_index (0-3): Goals
    - selected_vitamins, dietary_restrictions, disliked_foods, selected_dining_halls: Preferences
    - delivery_method_index (0-2), appearance_index (0-2): Settings
    """
    # Track if we need to recalculate macros
    recalculate_macros = False
    
    # Update user name if provided
    if update_data.name is not None:
        current_user.name = update_data.name
    
    # Get or create profile
    profile = current_user.profile
    if profile is None:
        # This shouldn't happen if signup always creates a profile, but handle it
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="User profile not found"
        )
    
    # Update biometrics (these affect macro calculations)
    if update_data.age_years is not None:
        profile.age_years = update_data.age_years
        recalculate_macros = True
    
    if update_data.height_text is not None:
        profile.height_text = update_data.height_text
        recalculate_macros = True
    
    if update_data.weight_lbs is not None:
        profile.weight_lbs = update_data.weight_lbs
        recalculate_macros = True
    
    if update_data.goal_weight_lbs is not None:
        profile.goal_weight_lbs = update_data.goal_weight_lbs
        # goal_weight doesn't affect macro calculations
    
    if update_data.is_male is not None:
        profile.is_male = update_data.is_male
        recalculate_macros = True
    
    # Update goals (these affect macro calculations)
    if update_data.activity_level_index is not None:
        profile.activity_level_index = update_data.activity_level_index
        recalculate_macros = True
    
    if update_data.goal_type_index is not None:
        profile.goal_type_index = update_data.goal_type_index
        recalculate_macros = True
    
    # Update preferences (stored as CSV in DB)
    if update_data.selected_vitamins is not None:
        profile.selected_vitamins = list_to_csv(update_data.selected_vitamins)
    
    if update_data.dietary_restrictions is not None:
        profile.dietary_restrictions = list_to_csv(update_data.dietary_restrictions)
    
    if update_data.disliked_foods is not None:
        profile.disliked_foods = list_to_csv(update_data.disliked_foods)
    
    if update_data.selected_dining_halls is not None:
        profile.selected_dining_halls = list_to_csv(update_data.selected_dining_halls)
    
    # Update settings
    if update_data.delivery_method_index is not None:
        profile.delivery_method_index = update_data.delivery_method_index
    
    if update_data.appearance_index is not None:
        profile.appearance_index = update_data.appearance_index
    
    # Recalculate macros if needed (matches MacroCalculator.swift)
    if recalculate_macros:
        calories, protein, carbs, fat = calculate_all_macros(
            weight_lbs=profile.weight_lbs,
            height_text=profile.height_text,
            age_years=profile.age_years,
            is_male=profile.is_male,
            activity_level_index=profile.activity_level_index,
            goal_type_index=profile.goal_type_index,
        )
        profile.calories_target = calories
        profile.protein_target = protein
        profile.carbs_target = carbs
        profile.fat_target = fat
    
    # Commit changes
    db.commit()
    db.refresh(current_user)
    
    return user_to_response(current_user)

