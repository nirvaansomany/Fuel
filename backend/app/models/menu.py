"""
Dining hall and menu item database models.
"""
from datetime import datetime, date
from sqlalchemy import Boolean, Column, Date, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from app.core.database import Base


class DiningHall(Base):
    """UCLA Dining Hall"""
    __tablename__ = "dining_halls"
    
    id = Column(Integer, primary_key=True, index=True)
    code = Column(String(50), unique=True, index=True, nullable=False)  # e.g., "bplate"
    name = Column(String(255), nullable=False)  # e.g., "Bruin Plate"
    short_name = Column(String(50), nullable=False)  # e.g., "BPlate"
    location = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    image_url = Column(String(500), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship to menu items
    menu_items = relationship("MenuItem", back_populates="dining_hall", cascade="all, delete-orphan")


class MenuItem(Base):
    """Menu item served at a dining hall"""
    __tablename__ = "menu_items"
    
    id = Column(Integer, primary_key=True, index=True)
    dining_hall_id = Column(Integer, ForeignKey("dining_halls.id", ondelete="CASCADE"), nullable=False)
    
    # Item details
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    
    # Nutrition info
    calories = Column(Integer, nullable=False, default=0)
    protein = Column(Integer, nullable=False, default=0)  # grams
    carbs = Column(Integer, nullable=False, default=0)  # grams
    fat = Column(Integer, nullable=False, default=0)  # grams
    
    # Menu organization
    meal_period = Column(String(50), nullable=False)  # breakfast, lunch, dinner
    station = Column(String(100), nullable=True)  # e.g., "Grill", "Pizza"
    menu_date = Column(Date, nullable=False, index=True)
    
    # Dietary flags
    is_vegetarian = Column(Boolean, default=False)
    is_vegan = Column(Boolean, default=False)
    is_gluten_free = Column(Boolean, default=False)
    allergens = Column(Text, nullable=True)  # Comma-separated list
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship back to dining hall
    dining_hall = relationship("DiningHall", back_populates="menu_items")

