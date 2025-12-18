"""
Menu API routes: dining halls and menu items.
"""
from datetime import date
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from typing import List, Optional

from app.core.database import get_db
from app.models.menu import DiningHall, MenuItem
from app.schemas.menu import (
    DiningHallResponse, 
    DiningHallListResponse,
    MenuItemResponse, 
    MenuResponse
)
from app.services.menu_provider import get_menu_provider
from app.services.seed_data import seed_dining_halls, seed_menu_items

router = APIRouter(prefix="/menus", tags=["Menus"])


def _ensure_data_seeded(db: Session) -> None:
    """
    Ensure dining halls and today's menu are seeded.
    Called lazily on first API request.
    """
    # Check if we have any dining halls
    hall_count = db.query(DiningHall).count()
    if hall_count == 0:
        seed_dining_halls(db)
    
    # Check if we have menu items for today
    today = date.today()
    item_count = db.query(MenuItem).filter(MenuItem.menu_date == today).count()
    if item_count == 0:
        seed_menu_items(db, today)


def _allergens_to_list(allergens_str: Optional[str]) -> Optional[List[str]]:
    """Convert comma-separated allergens string to list"""
    if not allergens_str:
        return None
    return [a.strip() for a in allergens_str.split(",") if a.strip()]


def _menu_item_to_response(item: MenuItem) -> MenuItemResponse:
    """Convert MenuItem model to response schema"""
    return MenuItemResponse(
        id=item.id,
        dining_hall_id=item.dining_hall_id,
        name=item.name,
        description=item.description,
        calories=item.calories,
        protein=item.protein,
        carbs=item.carbs,
        fat=item.fat,
        meal_period=item.meal_period,
        station=item.station,
        menu_date=item.menu_date,
        is_vegetarian=item.is_vegetarian,
        is_vegan=item.is_vegan,
        is_gluten_free=item.is_gluten_free,
        allergens=_allergens_to_list(item.allergens),
    )


@router.get("/dining-halls", response_model=DiningHallListResponse)
async def get_dining_halls(db: Session = Depends(get_db)):
    """
    Get all available UCLA dining halls.
    
    Returns list of dining halls with their details.
    """
    _ensure_data_seeded(db)
    
    halls = db.query(DiningHall).filter(DiningHall.is_active == True).all()
    
    return DiningHallListResponse(
        dining_halls=[DiningHallResponse.model_validate(hall) for hall in halls],
        count=len(halls)
    )


@router.get("/dining-halls/{hall_id}", response_model=DiningHallResponse)
async def get_dining_hall(hall_id: int, db: Session = Depends(get_db)):
    """
    Get a specific dining hall by ID.
    """
    _ensure_data_seeded(db)
    
    hall = db.query(DiningHall).filter(DiningHall.id == hall_id).first()
    if not hall:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Dining hall not found"
        )
    
    return DiningHallResponse.model_validate(hall)


@router.get("", response_model=MenuResponse)
async def get_menu(
    dining_hall: int = Query(..., description="Dining hall ID"),
    menu_date: date = Query(default=None, description="Menu date (YYYY-MM-DD), defaults to today"),
    db: Session = Depends(get_db)
):
    """
    Get menu items for a specific dining hall and date.
    
    Returns menu items grouped by meal period (breakfast, lunch, dinner).
    
    Query parameters:
    - dining_hall: Required. The ID of the dining hall.
    - date: Optional. The date for the menu (defaults to today).
    """
    _ensure_data_seeded(db)
    
    if menu_date is None:
        menu_date = date.today()
    
    # Get dining hall
    hall = db.query(DiningHall).filter(DiningHall.id == dining_hall).first()
    if not hall:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Dining hall not found"
        )
    
    # Check if we have menu items for this date, if not seed them
    item_count = db.query(MenuItem).filter(
        MenuItem.dining_hall_id == dining_hall,
        MenuItem.menu_date == menu_date
    ).count()
    
    if item_count == 0:
        seed_menu_items(db, menu_date)
    
    # Get menu items
    items = db.query(MenuItem).filter(
        MenuItem.dining_hall_id == dining_hall,
        MenuItem.menu_date == menu_date
    ).all()
    
    # Group by meal period
    breakfast = [_menu_item_to_response(i) for i in items if i.meal_period == "breakfast"]
    lunch = [_menu_item_to_response(i) for i in items if i.meal_period == "lunch"]
    dinner = [_menu_item_to_response(i) for i in items if i.meal_period == "dinner"]
    
    return MenuResponse(
        dining_hall=DiningHallResponse.model_validate(hall),
        date=menu_date,
        breakfast=breakfast,
        lunch=lunch,
        dinner=dinner,
    )


@router.get("/items", response_model=List[MenuItemResponse])
async def get_menu_items(
    dining_hall: Optional[int] = Query(default=None, description="Filter by dining hall ID"),
    menu_date: date = Query(default=None, description="Menu date (YYYY-MM-DD), defaults to today"),
    meal_period: Optional[str] = Query(default=None, description="Filter by meal period: breakfast, lunch, dinner"),
    vegetarian: Optional[bool] = Query(default=None, description="Filter vegetarian items only"),
    vegan: Optional[bool] = Query(default=None, description="Filter vegan items only"),
    gluten_free: Optional[bool] = Query(default=None, description="Filter gluten-free items only"),
    min_protein: Optional[int] = Query(default=None, description="Minimum protein (grams)"),
    max_calories: Optional[int] = Query(default=None, description="Maximum calories"),
    db: Session = Depends(get_db)
):
    """
    Get menu items with optional filters.
    
    Useful for finding items that match dietary requirements or macro goals.
    """
    _ensure_data_seeded(db)
    
    if menu_date is None:
        menu_date = date.today()
    
    # Ensure data exists for this date
    item_count = db.query(MenuItem).filter(MenuItem.menu_date == menu_date).count()
    if item_count == 0:
        seed_menu_items(db, menu_date)
    
    # Build query
    query = db.query(MenuItem).filter(MenuItem.menu_date == menu_date)
    
    if dining_hall is not None:
        query = query.filter(MenuItem.dining_hall_id == dining_hall)
    
    if meal_period is not None:
        query = query.filter(MenuItem.meal_period == meal_period)
    
    if vegetarian:
        query = query.filter(MenuItem.is_vegetarian == True)
    
    if vegan:
        query = query.filter(MenuItem.is_vegan == True)
    
    if gluten_free:
        query = query.filter(MenuItem.is_gluten_free == True)
    
    if min_protein is not None:
        query = query.filter(MenuItem.protein >= min_protein)
    
    if max_calories is not None:
        query = query.filter(MenuItem.calories <= max_calories)
    
    items = query.all()
    
    return [_menu_item_to_response(item) for item in items]

