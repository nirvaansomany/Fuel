"""
Database seeding service for UCLA dining data.

This service syncs data from the MenuProvider to the database,
allowing the API to serve data from either source.
"""
from datetime import date, timedelta
from sqlalchemy.orm import Session
from app.models.menu import DiningHall, MenuItem
from app.services.menu_provider import get_menu_provider, MenuProvider


def seed_dining_halls(db: Session, provider: MenuProvider = None) -> int:
    """
    Seed dining halls from the menu provider.
    
    Args:
        db: Database session
        provider: Optional custom provider (defaults to current provider)
        
    Returns:
        Number of dining halls seeded
    """
    if provider is None:
        provider = get_menu_provider()
    
    count = 0
    for hall_data in provider.get_dining_halls():
        # Check if already exists
        existing = db.query(DiningHall).filter(DiningHall.code == hall_data.id).first()
        
        if existing:
            # Update existing
            existing.name = hall_data.name
            existing.short_name = hall_data.short_name
            existing.location = hall_data.location
            existing.description = hall_data.description
            existing.image_url = hall_data.image_url
        else:
            # Create new
            hall = DiningHall(
                code=hall_data.id,
                name=hall_data.name,
                short_name=hall_data.short_name,
                location=hall_data.location,
                description=hall_data.description,
                image_url=hall_data.image_url,
            )
            db.add(hall)
            count += 1
    
    db.commit()
    return count


def seed_menu_items(
    db: Session, 
    menu_date: date = None, 
    provider: MenuProvider = None
) -> int:
    """
    Seed menu items from the menu provider for a specific date.
    
    Args:
        db: Database session
        menu_date: Date to seed menu for (defaults to today)
        provider: Optional custom provider
        
    Returns:
        Number of menu items seeded
    """
    if provider is None:
        provider = get_menu_provider()
    
    if menu_date is None:
        menu_date = date.today()
    
    # Get dining hall ID mapping (code -> db id)
    hall_map = {}
    for hall in db.query(DiningHall).all():
        hall_map[hall.code] = hall.id
    
    # Delete existing items for this date (to avoid duplicates)
    db.query(MenuItem).filter(MenuItem.menu_date == menu_date).delete()
    
    count = 0
    for item_data in provider.get_all_menu_items_for_date(menu_date):
        # Get the database ID for the dining hall
        dining_hall_db_id = hall_map.get(item_data.dining_hall_id)
        if dining_hall_db_id is None:
            continue  # Skip if dining hall not found
        
        item = MenuItem(
            dining_hall_id=dining_hall_db_id,
            name=item_data.name,
            description=item_data.description,
            calories=item_data.calories,
            protein=item_data.protein,
            carbs=item_data.carbs,
            fat=item_data.fat,
            meal_period=item_data.meal_period,
            station=item_data.station,
            menu_date=menu_date,
            is_vegetarian=item_data.is_vegetarian,
            is_vegan=item_data.is_vegan,
            is_gluten_free=item_data.is_gluten_free,
            allergens=",".join(item_data.allergens) if item_data.allergens else None,
        )
        db.add(item)
        count += 1
    
    db.commit()
    return count


def seed_menu_items_for_week(
    db: Session,
    start_date: date = None,
    provider: MenuProvider = None
) -> int:
    """
    Seed menu items for a full week.
    
    Args:
        db: Database session
        start_date: First day of the week (defaults to today)
        provider: Optional custom provider
        
    Returns:
        Total number of menu items seeded
    """
    if start_date is None:
        start_date = date.today()
    
    total = 0
    for i in range(7):
        menu_date = start_date + timedelta(days=i)
        total += seed_menu_items(db, menu_date, provider)
    
    return total


def seed_all(db: Session, provider: MenuProvider = None) -> dict:
    """
    Seed all dining data (halls + menu items for the week).
    
    Returns:
        Dict with counts of seeded data
    """
    halls_count = seed_dining_halls(db, provider)
    items_count = seed_menu_items_for_week(db, provider=provider)
    
    return {
        "dining_halls": halls_count,
        "menu_items": items_count,
    }

