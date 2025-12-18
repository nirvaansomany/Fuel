"""
Pydantic schemas for dining halls and menu items.
"""
from datetime import date, datetime
from pydantic import BaseModel, Field
from typing import List, Optional


class DiningHallResponse(BaseModel):
    """Dining hall response"""
    id: int
    code: str
    name: str
    short_name: str
    location: str
    description: Optional[str] = None
    image_url: Optional[str] = None
    is_active: bool = True
    
    class Config:
        from_attributes = True


class MenuItemResponse(BaseModel):
    """Menu item response"""
    id: int
    dining_hall_id: int
    name: str
    description: Optional[str] = None
    
    # Nutrition
    calories: int
    protein: int
    carbs: int
    fat: int
    
    # Menu organization
    meal_period: str
    station: Optional[str] = None
    menu_date: date
    
    # Dietary info
    is_vegetarian: bool = False
    is_vegan: bool = False
    is_gluten_free: bool = False
    allergens: Optional[List[str]] = None
    
    class Config:
        from_attributes = True


class MenuItemWithHall(MenuItemResponse):
    """Menu item response with dining hall info"""
    dining_hall: DiningHallResponse


class MenuResponse(BaseModel):
    """Response containing menu items grouped by meal period"""
    dining_hall: DiningHallResponse
    date: date
    breakfast: List[MenuItemResponse] = []
    lunch: List[MenuItemResponse] = []
    dinner: List[MenuItemResponse] = []


class DiningHallListResponse(BaseModel):
    """List of dining halls"""
    dining_halls: List[DiningHallResponse]
    count: int

