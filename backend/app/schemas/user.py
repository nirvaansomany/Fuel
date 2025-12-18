"""
User and Profile Pydantic schemas.
Matches frontend data contract from UserProfile.swift + MockProfileData.swift
"""
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field
from typing import List, Optional


# --- Profile Schemas ---

class ProfileBase(BaseModel):
    """Base profile fields matching frontend UserProfile + preferences"""
    # Biometrics
    age_years: int = Field(default=21, ge=1, le=150)
    height_text: str = Field(default="5'10\"", max_length=20)  # Format: "5'10\""
    weight_lbs: int = Field(default=165, ge=50, le=1000)
    goal_weight_lbs: int = Field(default=175, ge=50, le=1000)
    is_male: bool = True
    
    # Goals (indexes into frontend arrays)
    activity_level_index: int = Field(default=2, ge=0, le=4)
    goal_type_index: int = Field(default=0, ge=0, le=3)
    
    # Preferences (as lists - will be converted to comma-separated strings in DB)
    selected_vitamins: List[str] = Field(default=["Vit D", "B12", "Iron", "Calcium"])
    dietary_restrictions: List[str] = Field(default=[])
    disliked_foods: List[str] = Field(default=[])
    selected_dining_halls: List[str] = Field(default=["BPlate", "De Neve", "Rendezvous"])
    
    # Settings (indexes into frontend arrays)
    delivery_method_index: int = Field(default=0, ge=0, le=2)
    appearance_index: int = Field(default=1, ge=0, le=2)


class ProfileCreate(ProfileBase):
    """Schema for creating a profile (during signup)"""
    pass


class ProfileUpdate(ProfileBase):
    """Schema for updating profile - all fields optional"""
    age_years: Optional[int] = Field(default=None, ge=1, le=150)
    height_text: Optional[str] = Field(default=None, max_length=20)
    weight_lbs: Optional[int] = Field(default=None, ge=50, le=1000)
    goal_weight_lbs: Optional[int] = Field(default=None, ge=50, le=1000)
    is_male: Optional[bool] = None
    activity_level_index: Optional[int] = Field(default=None, ge=0, le=4)
    goal_type_index: Optional[int] = Field(default=None, ge=0, le=3)
    selected_vitamins: Optional[List[str]] = None
    dietary_restrictions: Optional[List[str]] = None
    disliked_foods: Optional[List[str]] = None
    selected_dining_halls: Optional[List[str]] = None
    delivery_method_index: Optional[int] = Field(default=None, ge=0, le=2)
    appearance_index: Optional[int] = Field(default=None, ge=0, le=2)


class ProfileResponse(ProfileBase):
    """Profile response including calculated macros"""
    id: int
    user_id: int
    
    # Calculated macro targets
    calories_target: int
    protein_target: int
    carbs_target: int
    fat_target: int
    
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


# --- User Schemas ---

class UserBase(BaseModel):
    """Base user fields"""
    email: EmailStr
    name: str = Field(min_length=1, max_length=255)


class UserCreate(UserBase):
    """Schema for user signup"""
    password: str = Field(min_length=6, max_length=100)
    profile: Optional[ProfileCreate] = None  # Optional: create profile during signup


class UserLogin(BaseModel):
    """Schema for user login"""
    email: EmailStr
    password: str


class UserResponse(UserBase):
    """User response (without password)"""
    id: int
    initials: str  # Computed from name
    created_at: datetime
    updated_at: datetime
    profile: Optional[ProfileResponse] = None
    
    class Config:
        from_attributes = True


class UserWithToken(BaseModel):
    """User response with JWT token"""
    user: UserResponse
    access_token: str
    token_type: str = "bearer"

