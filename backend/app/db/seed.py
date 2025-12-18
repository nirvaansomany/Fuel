"""
Demo data seeder for Fuel backend.
Seeds realistic UCLA dining hall data if the database is empty.
"""
from sqlalchemy.orm import Session
from app.models.user import User, Profile
from app.models.menu import DiningHall, MenuItem
from app.core.security import get_password_hash
from datetime import date, timedelta
import logging

logger = logging.getLogger(__name__)


def seed_dining_halls(db: Session) -> list[DiningHall]:
    """Seed UCLA dining halls."""
    existing = db.query(DiningHall).first()
    if existing:
        logger.info("Dining halls already seeded, skipping...")
        return db.query(DiningHall).all()
    
    halls = [
        DiningHall(
            code="bplate",
            name="Bruin Plate",
            short_name="BPlate",
            location="Sproul Landing",
            description="Health-conscious dining with fresh, sustainable options",
            is_active=True
        ),
        DiningHall(
            code="epicuria",
            name="Epicuria at Covel",
            short_name="Epicuria",
            location="Covel Commons",
            description="Mediterranean and Italian inspired cuisine",
            is_active=True
        ),
        DiningHall(
            code="de_neve",
            name="De Neve",
            short_name="De Neve",
            location="De Neve Plaza",
            description="Classic American comfort food and international options",
            is_active=True
        ),
        DiningHall(
            code="feast",
            name="Feast at Rieber",
            short_name="Feast",
            location="Rieber Hall",
            description="Asian fusion cuisine with diverse flavors",
            is_active=True
        ),
        DiningHall(
            code="rendezvous",
            name="Rendezvous",
            short_name="Rendezvous",
            location="Carnesale Commons",
            description="Quick-service dining with varied options",
            is_active=True
        ),
        DiningHall(
            code="bcafe",
            name="Bruin Café",
            short_name="BCafe",
            location="Ackerman Union",
            description="Café-style dining with grab-and-go options",
            is_active=True
        ),
    ]
    
    db.add_all(halls)
    db.commit()
    
    for hall in halls:
        db.refresh(hall)
    
    logger.info(f"Seeded {len(halls)} dining halls")
    return halls


def seed_menu_items(db: Session, halls: list[DiningHall]) -> None:
    """Seed menu items for dining halls."""
    existing = db.query(MenuItem).first()
    if existing:
        logger.info("Menu items already seeded, skipping...")
        return
    
    today = date.today()
    
    # Menu items organized by dining hall code
    menu_data = {
        "bplate": [
            # Breakfast
            {"name": "Egg White Veggie Scramble", "description": "Egg whites with spinach, tomatoes, and mushrooms", "calories": 180, "protein": 18, "carbs": 8, "fat": 9, "meal_period": "breakfast", "station": "Grill", "is_vegetarian": True, "is_vegan": False, "is_gluten_free": True},
            {"name": "Steel Cut Oatmeal", "description": "Organic oats with fresh berries and honey", "calories": 220, "protein": 8, "carbs": 42, "fat": 4, "meal_period": "breakfast", "station": "Grains", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": False},
            {"name": "Avocado Toast", "description": "Whole grain bread with smashed avocado and everything seasoning", "calories": 280, "protein": 8, "carbs": 32, "fat": 16, "meal_period": "breakfast", "station": "Grill", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": False},
            {"name": "Greek Yogurt Parfait", "description": "Greek yogurt with granola and mixed berries", "calories": 250, "protein": 15, "carbs": 38, "fat": 6, "meal_period": "breakfast", "station": "Cold Bar", "is_vegetarian": True, "is_vegan": False, "is_gluten_free": False},
            # Lunch
            {"name": "Grilled Salmon", "description": "Atlantic salmon with lemon herb seasoning", "calories": 320, "protein": 34, "carbs": 2, "fat": 18, "meal_period": "lunch", "station": "Grill", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": True},
            {"name": "Quinoa Buddha Bowl", "description": "Quinoa with roasted vegetables and tahini dressing", "calories": 420, "protein": 14, "carbs": 58, "fat": 16, "meal_period": "lunch", "station": "Bowls", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": True},
            {"name": "Grilled Chicken Breast", "description": "Herb-marinated chicken breast", "calories": 280, "protein": 42, "carbs": 0, "fat": 12, "meal_period": "lunch", "station": "Grill", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": True},
            {"name": "Kale Caesar Salad", "description": "Fresh kale with parmesan and caesar dressing", "calories": 240, "protein": 8, "carbs": 18, "fat": 16, "meal_period": "lunch", "station": "Salad Bar", "is_vegetarian": True, "is_vegan": False, "is_gluten_free": True},
            # Dinner
            {"name": "Baked Salmon", "description": "Wild-caught salmon with herbs", "calories": 340, "protein": 36, "carbs": 4, "fat": 20, "meal_period": "dinner", "station": "Grill", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": True},
            {"name": "Roasted Sweet Potato", "description": "Organic sweet potato with cinnamon", "calories": 180, "protein": 4, "carbs": 42, "fat": 0, "meal_period": "dinner", "station": "Sides", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": True},
            {"name": "Steamed Broccoli", "description": "Fresh broccoli florets", "calories": 55, "protein": 4, "carbs": 10, "fat": 0, "meal_period": "dinner", "station": "Sides", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": True},
            {"name": "Brown Rice", "description": "Steamed brown rice", "calories": 220, "protein": 5, "carbs": 45, "fat": 2, "meal_period": "dinner", "station": "Grains", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": True},
        ],
        "epicuria": [
            # Breakfast
            {"name": "Frittata", "description": "Italian-style egg dish with vegetables", "calories": 240, "protein": 16, "carbs": 8, "fat": 18, "meal_period": "breakfast", "station": "Hot Bar", "is_vegetarian": True, "is_vegan": False, "is_gluten_free": True},
            {"name": "Fresh Fruit Bowl", "description": "Seasonal fresh fruits", "calories": 120, "protein": 2, "carbs": 30, "fat": 0, "meal_period": "breakfast", "station": "Cold Bar", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": True},
            # Lunch
            {"name": "Margherita Pizza", "description": "Fresh mozzarella, tomatoes, and basil", "calories": 380, "protein": 16, "carbs": 42, "fat": 18, "meal_period": "lunch", "station": "Pizza", "is_vegetarian": True, "is_vegan": False, "is_gluten_free": False},
            {"name": "Pasta Primavera", "description": "Penne with seasonal vegetables in marinara", "calories": 420, "protein": 14, "carbs": 68, "fat": 12, "meal_period": "lunch", "station": "Pasta", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": False},
            {"name": "Chicken Parmesan", "description": "Breaded chicken with marinara and mozzarella", "calories": 520, "protein": 38, "carbs": 32, "fat": 28, "meal_period": "lunch", "station": "Hot Bar", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": False},
            # Dinner
            {"name": "Grilled Mediterranean Chicken", "description": "Chicken with olive oil and herbs", "calories": 340, "protein": 40, "carbs": 4, "fat": 18, "meal_period": "dinner", "station": "Grill", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": True},
            {"name": "Eggplant Parmesan", "description": "Breaded eggplant with marinara", "calories": 380, "protein": 14, "carbs": 36, "fat": 22, "meal_period": "dinner", "station": "Hot Bar", "is_vegetarian": True, "is_vegan": False, "is_gluten_free": False},
            {"name": "Caprese Salad", "description": "Fresh mozzarella, tomatoes, basil, balsamic", "calories": 280, "protein": 14, "carbs": 8, "fat": 22, "meal_period": "dinner", "station": "Salad Bar", "is_vegetarian": True, "is_vegan": False, "is_gluten_free": True},
        ],
        "de_neve": [
            # Breakfast
            {"name": "Classic Eggs", "description": "Scrambled or fried eggs", "calories": 180, "protein": 14, "carbs": 2, "fat": 14, "meal_period": "breakfast", "station": "Grill", "is_vegetarian": True, "is_vegan": False, "is_gluten_free": True},
            {"name": "Turkey Bacon", "description": "Crispy turkey bacon strips", "calories": 120, "protein": 12, "carbs": 0, "fat": 8, "meal_period": "breakfast", "station": "Grill", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": True},
            {"name": "Pancakes", "description": "Fluffy buttermilk pancakes", "calories": 320, "protein": 8, "carbs": 58, "fat": 8, "meal_period": "breakfast", "station": "Grill", "is_vegetarian": True, "is_vegan": False, "is_gluten_free": False},
            # Lunch
            {"name": "Cheeseburger", "description": "Angus beef patty with cheese", "calories": 580, "protein": 32, "carbs": 42, "fat": 32, "meal_period": "lunch", "station": "Grill", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": False},
            {"name": "Veggie Burger", "description": "Plant-based patty with fixings", "calories": 420, "protein": 22, "carbs": 48, "fat": 18, "meal_period": "lunch", "station": "Grill", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": False},
            {"name": "Chicken Tenders", "description": "Crispy breaded chicken strips", "calories": 380, "protein": 28, "carbs": 24, "fat": 20, "meal_period": "lunch", "station": "Hot Bar", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": False},
            {"name": "French Fries", "description": "Golden crispy fries", "calories": 280, "protein": 4, "carbs": 38, "fat": 14, "meal_period": "lunch", "station": "Sides", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": True},
            # Dinner
            {"name": "BBQ Ribs", "description": "Slow-cooked ribs with BBQ sauce", "calories": 620, "protein": 42, "carbs": 28, "fat": 38, "meal_period": "dinner", "station": "Hot Bar", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": True},
            {"name": "Mac and Cheese", "description": "Creamy macaroni and cheese", "calories": 420, "protein": 16, "carbs": 48, "fat": 20, "meal_period": "dinner", "station": "Hot Bar", "is_vegetarian": True, "is_vegan": False, "is_gluten_free": False},
            {"name": "Coleslaw", "description": "Creamy cabbage slaw", "calories": 160, "protein": 2, "carbs": 12, "fat": 12, "meal_period": "dinner", "station": "Sides", "is_vegetarian": True, "is_vegan": False, "is_gluten_free": True},
        ],
        "feast": [
            # Breakfast
            {"name": "Congee", "description": "Rice porridge with toppings", "calories": 180, "protein": 6, "carbs": 36, "fat": 2, "meal_period": "breakfast", "station": "Asian", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": True},
            {"name": "Dim Sum Assortment", "description": "Steamed dumplings variety", "calories": 280, "protein": 14, "carbs": 32, "fat": 12, "meal_period": "breakfast", "station": "Asian", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": False},
            # Lunch
            {"name": "Teriyaki Chicken", "description": "Grilled chicken with teriyaki glaze", "calories": 380, "protein": 36, "carbs": 28, "fat": 14, "meal_period": "lunch", "station": "Grill", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": False},
            {"name": "Vegetable Stir Fry", "description": "Mixed vegetables in garlic sauce", "calories": 220, "protein": 8, "carbs": 28, "fat": 10, "meal_period": "lunch", "station": "Wok", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": True},
            {"name": "Beef and Broccoli", "description": "Tender beef with broccoli in sauce", "calories": 420, "protein": 32, "carbs": 24, "fat": 22, "meal_period": "lunch", "station": "Wok", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": False},
            {"name": "Steamed Rice", "description": "White jasmine rice", "calories": 200, "protein": 4, "carbs": 44, "fat": 0, "meal_period": "lunch", "station": "Sides", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": True},
            # Dinner
            {"name": "Kung Pao Tofu", "description": "Crispy tofu with peanuts and peppers", "calories": 340, "protein": 18, "carbs": 28, "fat": 20, "meal_period": "dinner", "station": "Wok", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": False},
            {"name": "Orange Chicken", "description": "Crispy chicken in orange sauce", "calories": 480, "protein": 28, "carbs": 52, "fat": 18, "meal_period": "dinner", "station": "Wok", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": False},
            {"name": "Miso Soup", "description": "Traditional miso with tofu and seaweed", "calories": 80, "protein": 6, "carbs": 8, "fat": 3, "meal_period": "dinner", "station": "Soup", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": False},
            {"name": "Edamame", "description": "Steamed soybeans with sea salt", "calories": 120, "protein": 12, "carbs": 10, "fat": 5, "meal_period": "dinner", "station": "Sides", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": True},
        ],
        "rendezvous": [
            # Breakfast
            {"name": "Breakfast Burrito", "description": "Eggs, cheese, and salsa in a tortilla", "calories": 420, "protein": 22, "carbs": 38, "fat": 22, "meal_period": "breakfast", "station": "Grill", "is_vegetarian": True, "is_vegan": False, "is_gluten_free": False},
            {"name": "Hash Browns", "description": "Crispy shredded potatoes", "calories": 180, "protein": 2, "carbs": 24, "fat": 10, "meal_period": "breakfast", "station": "Grill", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": True},
            # Lunch
            {"name": "Chicken Quesadilla", "description": "Grilled tortilla with chicken and cheese", "calories": 520, "protein": 32, "carbs": 42, "fat": 26, "meal_period": "lunch", "station": "Grill", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": False},
            {"name": "Fish Tacos", "description": "Grilled fish with cabbage slaw", "calories": 380, "protein": 24, "carbs": 36, "fat": 16, "meal_period": "lunch", "station": "Grill", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": False},
            {"name": "Bean and Rice Bowl", "description": "Black beans, rice, and fresh salsa", "calories": 380, "protein": 14, "carbs": 68, "fat": 6, "meal_period": "lunch", "station": "Bowls", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": True},
            # Dinner
            {"name": "Carne Asada", "description": "Grilled marinated steak", "calories": 380, "protein": 38, "carbs": 4, "fat": 24, "meal_period": "dinner", "station": "Grill", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": True},
            {"name": "Chicken Burrito Bowl", "description": "Chicken, rice, beans, and toppings", "calories": 580, "protein": 38, "carbs": 62, "fat": 20, "meal_period": "dinner", "station": "Bowls", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": True},
            {"name": "Guacamole", "description": "Fresh avocado dip", "calories": 120, "protein": 2, "carbs": 8, "fat": 10, "meal_period": "dinner", "station": "Sides", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": True},
        ],
        "bcafe": [
            # Breakfast
            {"name": "Bagel with Cream Cheese", "description": "Fresh bagel with cream cheese spread", "calories": 340, "protein": 10, "carbs": 52, "fat": 12, "meal_period": "breakfast", "station": "Bakery", "is_vegetarian": True, "is_vegan": False, "is_gluten_free": False},
            {"name": "Croissant", "description": "Buttery French croissant", "calories": 280, "protein": 6, "carbs": 32, "fat": 16, "meal_period": "breakfast", "station": "Bakery", "is_vegetarian": True, "is_vegan": False, "is_gluten_free": False},
            # Lunch
            {"name": "Turkey Club Sandwich", "description": "Turkey, bacon, lettuce, tomato", "calories": 480, "protein": 32, "carbs": 38, "fat": 24, "meal_period": "lunch", "station": "Deli", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": False},
            {"name": "Caesar Wrap", "description": "Chicken caesar in a spinach wrap", "calories": 420, "protein": 28, "carbs": 36, "fat": 20, "meal_period": "lunch", "station": "Deli", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": False},
            {"name": "Garden Salad", "description": "Mixed greens with vegetables", "calories": 180, "protein": 4, "carbs": 18, "fat": 10, "meal_period": "lunch", "station": "Salad Bar", "is_vegetarian": True, "is_vegan": True, "is_gluten_free": True},
            # Dinner
            {"name": "Chicken Soup", "description": "Hearty chicken noodle soup", "calories": 180, "protein": 14, "carbs": 18, "fat": 6, "meal_period": "dinner", "station": "Soup", "is_vegetarian": False, "is_vegan": False, "is_gluten_free": False},
            {"name": "Grilled Cheese", "description": "Classic grilled cheese sandwich", "calories": 380, "protein": 14, "carbs": 36, "fat": 22, "meal_period": "dinner", "station": "Grill", "is_vegetarian": True, "is_vegan": False, "is_gluten_free": False},
        ],
    }
    
    items_created = 0
    hall_map = {h.code: h for h in halls}
    
    # Create items for today and next 6 days
    for day_offset in range(7):
        menu_date = today + timedelta(days=day_offset)
        
        for hall_code, items in menu_data.items():
            hall = hall_map.get(hall_code)
            if not hall:
                continue
                
            for item_data in items:
                item = MenuItem(
                    dining_hall_id=hall.id,
                    menu_date=menu_date,
                    **item_data
                )
                db.add(item)
                items_created += 1
    
    db.commit()
    logger.info(f"Seeded {items_created} menu items for 7 days")


def seed_demo_user(db: Session) -> None:
    """Seed a demo user for testing."""
    existing = db.query(User).filter(User.email == "demo@ucla.edu").first()
    if existing:
        logger.info("Demo user already exists, skipping...")
        return
    
    # Create demo user
    demo_user = User(
        email="demo@ucla.edu",
        name="Demo User",
        hashed_password=get_password_hash("demopass123")
    )
    db.add(demo_user)
    db.commit()
    db.refresh(demo_user)
    
    # Create demo profile
    demo_profile = Profile(
        user_id=demo_user.id,
        age_years=21,
        height_text="5'10\"",
        weight_lbs=165,
        goal_weight_lbs=175,
        is_male=True,
        activity_level_index=2,
        goal_type_index=0,
        calories_target=2800,
        protein_target=180,
        carbs_target=280,
        fat_target=93,
        selected_vitamins="Vit D,B12,Iron,Calcium",
        dietary_restrictions="",
        disliked_foods="",
        selected_dining_halls="BPlate,De Neve,Rendezvous",
        delivery_method_index=0,
        appearance_index=1
    )
    db.add(demo_profile)
    db.commit()
    
    logger.info("Seeded demo user: demo@ucla.edu / demopass123")


def run_seeds(db: Session) -> None:
    """Run all seed functions."""
    logger.info("Starting database seeding...")
    
    halls = seed_dining_halls(db)
    seed_menu_items(db, halls)
    seed_demo_user(db)
    
    logger.info("Database seeding complete!")

