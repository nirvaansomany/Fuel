"""
User and Profile database models.
Matches frontend data contract from UserProfile.swift + MockProfileData.swift
"""
from datetime import datetime
from sqlalchemy import Boolean, Column, DateTime, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from app.core.database import Base


class User(Base):
    """User account for authentication"""
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    name = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship to profile
    profile = relationship("Profile", back_populates="user", uselist=False, cascade="all, delete-orphan")


class Profile(Base):
    """
    User profile with biometrics, goals, and preferences.
    Maps to frontend UserProfile + ProfileViewModel data.
    """
    __tablename__ = "profiles"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    
    # Biometrics (from UserProfile.swift)
    age_years = Column(Integer, nullable=False, default=21)
    height_text = Column(String(20), nullable=False, default="5'10\"")  # Format: "5'10\""
    weight_lbs = Column(Integer, nullable=False, default=165)
    goal_weight_lbs = Column(Integer, nullable=False, default=175)
    is_male = Column(Boolean, nullable=False, default=True)
    
    # Goals (indexes into frontend arrays)
    activity_level_index = Column(Integer, nullable=False, default=2)  # 0-4: Sedentary to Very Active
    goal_type_index = Column(Integer, nullable=False, default=0)       # 0-3: Lean Muscle, Bulking, Fat Loss, Maintenance
    
    # Calculated macro targets (will be calculated server-side to match MacroCalculator.swift)
    calories_target = Column(Integer, nullable=False, default=2400)
    protein_target = Column(Integer, nullable=False, default=180)
    carbs_target = Column(Integer, nullable=False, default=240)
    fat_target = Column(Integer, nullable=False, default=70)
    
    # Preferences (stored as JSON-like comma-separated strings for SQLite compatibility)
    selected_vitamins = Column(Text, nullable=False, default="Vit D,B12,Iron,Calcium")
    dietary_restrictions = Column(Text, nullable=False, default="")
    disliked_foods = Column(Text, nullable=False, default="")
    selected_dining_halls = Column(Text, nullable=False, default="BPlate,De Neve,Rendezvous")
    
    # Notification/Display settings (indexes into frontend arrays)
    delivery_method_index = Column(Integer, nullable=False, default=0)  # 0-2: Push, iMessage, Widget
    appearance_index = Column(Integer, nullable=False, default=1)        # 0-2: Light, Dark, Auto
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship back to user
    user = relationship("User", back_populates="profile")

