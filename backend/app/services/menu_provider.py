"""
Menu Provider Interface and Implementations.

This module defines the abstract interface for menu data providers,
allowing pluggable implementations (seeded data, scrapers, APIs, etc.)
"""
from abc import ABC, abstractmethod
from datetime import date
from typing import List, Optional
from dataclasses import dataclass


@dataclass
class DiningHallData:
    """Data transfer object for dining hall information"""
    id: str  # Unique identifier (e.g., "bplate", "epicuria")
    name: str  # Display name (e.g., "Bruin Plate")
    short_name: str  # Short name for UI (e.g., "BPlate")
    location: str  # Campus location
    description: str  # Brief description
    image_url: Optional[str] = None


@dataclass
class MenuItemData:
    """Data transfer object for menu item information"""
    id: str  # Unique identifier
    dining_hall_id: str  # Reference to dining hall
    name: str  # Item name
    description: str  # Serving description
    calories: int
    protein: int  # grams
    carbs: int  # grams
    fat: int  # grams
    meal_period: str  # "breakfast", "lunch", "dinner"
    station: Optional[str] = None  # e.g., "Grill", "Pizza", "Salad Bar"
    is_vegetarian: bool = False
    is_vegan: bool = False
    is_gluten_free: bool = False
    allergens: Optional[List[str]] = None


class MenuProvider(ABC):
    """
    Abstract base class for menu data providers.
    
    Implementations can fetch menu data from various sources:
    - SeededMenuProvider: Hardcoded realistic data for development
    - UCLAScraperProvider: Live scraping from UCLA dining website (future)
    - APIProvider: Third-party API integration (future)
    """
    
    @abstractmethod
    def get_dining_halls(self) -> List[DiningHallData]:
        """
        Get all available dining halls.
        
        Returns:
            List of DiningHallData objects
        """
        pass
    
    @abstractmethod
    def get_menu_items(
        self, 
        dining_hall_id: str, 
        menu_date: date,
        meal_period: Optional[str] = None
    ) -> List[MenuItemData]:
        """
        Get menu items for a specific dining hall and date.
        
        Args:
            dining_hall_id: The dining hall identifier
            menu_date: The date to get the menu for
            meal_period: Optional filter for "breakfast", "lunch", or "dinner"
            
        Returns:
            List of MenuItemData objects
        """
        pass
    
    @abstractmethod
    def get_all_menu_items_for_date(self, menu_date: date) -> List[MenuItemData]:
        """
        Get all menu items across all dining halls for a date.
        
        Args:
            menu_date: The date to get menus for
            
        Returns:
            List of MenuItemData objects from all dining halls
        """
        pass


class SeededMenuProvider(MenuProvider):
    """
    Menu provider with realistic seeded UCLA dining data.
    
    This provider returns hardcoded but realistic menu data for development
    and testing. The data is based on actual UCLA dining hall offerings.
    """
    
    def __init__(self):
        self._dining_halls = self._create_dining_halls()
        self._menu_items = self._create_menu_items()
    
    def _create_dining_halls(self) -> List[DiningHallData]:
        """Create UCLA dining hall data"""
        return [
            DiningHallData(
                id="bplate",
                name="Bruin Plate",
                short_name="BPlate",
                location="Sproul Landing",
                description="Health-conscious dining with fresh, sustainable options"
            ),
            DiningHallData(
                id="epicuria",
                name="Epicuria at Covel",
                short_name="Epicuria",
                location="Covel Commons",
                description="Mediterranean and Italian inspired cuisine"
            ),
            DiningHallData(
                id="de_neve",
                name="De Neve",
                short_name="De Neve",
                location="De Neve Plaza",
                description="Classic American comfort food and international options"
            ),
            DiningHallData(
                id="feast",
                name="Feast at Rieber",
                short_name="Feast",
                location="Rieber Hall",
                description="Asian fusion cuisine with diverse flavors"
            ),
            DiningHallData(
                id="rendezvous",
                name="Rendezvous",
                short_name="Rendezvous",
                location="Carnesale Commons",
                description="Quick-service dining with varied options"
            ),
            DiningHallData(
                id="bcafe",
                name="Bruin Café",
                short_name="BCafe",
                location="Ackerman Union",
                description="Café-style dining with grab-and-go options"
            ),
        ]
    
    def _create_menu_items(self) -> List[MenuItemData]:
        """Create realistic UCLA menu items by dining hall"""
        items = []
        
        # BPlate - Health-focused items
        items.extend([
            # Breakfast
            MenuItemData(
                id="bp_001", dining_hall_id="bplate", name="Egg White Veggie Scramble",
                description="Egg whites with spinach, tomatoes, and mushrooms",
                calories=180, protein=18, carbs=8, fat=9,
                meal_period="breakfast", station="Grill", is_vegetarian=True, is_gluten_free=True
            ),
            MenuItemData(
                id="bp_002", dining_hall_id="bplate", name="Steel Cut Oatmeal",
                description="Organic oats with fresh berries and honey",
                calories=220, protein=8, carbs=42, fat=4,
                meal_period="breakfast", station="Grains", is_vegan=True
            ),
            MenuItemData(
                id="bp_003", dining_hall_id="bplate", name="Avocado Toast",
                description="Multigrain toast with smashed avocado and everything seasoning",
                calories=280, protein=7, carbs=32, fat=15,
                meal_period="breakfast", station="Toast Bar", is_vegan=True
            ),
            MenuItemData(
                id="bp_004", dining_hall_id="bplate", name="Greek Yogurt Parfait",
                description="Non-fat Greek yogurt with granola and mixed berries",
                calories=240, protein=15, carbs=38, fat=4,
                meal_period="breakfast", station="Cold Bar", is_vegetarian=True
            ),
            # Lunch
            MenuItemData(
                id="bp_010", dining_hall_id="bplate", name="Grilled Salmon",
                description="Wild-caught salmon with lemon herb seasoning",
                calories=320, protein=34, carbs=2, fat=19,
                meal_period="lunch", station="Grill", is_gluten_free=True
            ),
            MenuItemData(
                id="bp_011", dining_hall_id="bplate", name="Quinoa Buddha Bowl",
                description="Quinoa with roasted vegetables, chickpeas, and tahini",
                calories=420, protein=14, carbs=58, fat=16,
                meal_period="lunch", station="Bowl Bar", is_vegan=True, is_gluten_free=True
            ),
            MenuItemData(
                id="bp_012", dining_hall_id="bplate", name="Grilled Chicken Breast",
                description="Herb-marinated chicken breast",
                calories=280, protein=42, carbs=0, fat=12,
                meal_period="lunch", station="Grill", is_gluten_free=True
            ),
            MenuItemData(
                id="bp_013", dining_hall_id="bplate", name="Kale Caesar Salad",
                description="Fresh kale with parmesan and light caesar dressing",
                calories=190, protein=8, carbs=14, fat=12,
                meal_period="lunch", station="Salad Bar", is_vegetarian=True, is_gluten_free=True
            ),
            # Dinner
            MenuItemData(
                id="bp_020", dining_hall_id="bplate", name="Herb Crusted Tilapia",
                description="Baked tilapia with herb breadcrumb crust",
                calories=260, protein=32, carbs=12, fat=10,
                meal_period="dinner", station="Grill"
            ),
            MenuItemData(
                id="bp_021", dining_hall_id="bplate", name="Turkey Meatballs",
                description="Lean turkey meatballs with marinara sauce",
                calories=290, protein=28, carbs=18, fat=12,
                meal_period="dinner", station="Entrée"
            ),
            MenuItemData(
                id="bp_022", dining_hall_id="bplate", name="Roasted Sweet Potato",
                description="Cubed sweet potatoes with cinnamon",
                calories=140, protein=2, carbs=32, fat=1,
                meal_period="dinner", station="Sides", is_vegan=True, is_gluten_free=True
            ),
            MenuItemData(
                id="bp_023", dining_hall_id="bplate", name="Steamed Broccoli",
                description="Fresh steamed broccoli florets",
                calories=55, protein=4, carbs=10, fat=1,
                meal_period="dinner", station="Sides", is_vegan=True, is_gluten_free=True
            ),
        ])
        
        # Epicuria - Mediterranean/Italian
        items.extend([
            # Breakfast
            MenuItemData(
                id="ep_001", dining_hall_id="epicuria", name="Mediterranean Omelette",
                description="Eggs with feta, olives, tomatoes, and spinach",
                calories=340, protein=22, carbs=8, fat=25,
                meal_period="breakfast", station="Grill", is_vegetarian=True, is_gluten_free=True
            ),
            MenuItemData(
                id="ep_002", dining_hall_id="epicuria", name="Shakshuka",
                description="Poached eggs in spiced tomato sauce",
                calories=280, protein=14, carbs=18, fat=18,
                meal_period="breakfast", station="Hot Bar", is_vegetarian=True, is_gluten_free=True
            ),
            # Lunch
            MenuItemData(
                id="ep_010", dining_hall_id="epicuria", name="Margherita Pizza",
                description="Fresh mozzarella, basil, and tomato sauce",
                calories=380, protein=16, carbs=48, fat=14,
                meal_period="lunch", station="Pizza", is_vegetarian=True
            ),
            MenuItemData(
                id="ep_011", dining_hall_id="epicuria", name="Chicken Pesto Pasta",
                description="Penne with grilled chicken and basil pesto",
                calories=520, protein=32, carbs=52, fat=22,
                meal_period="lunch", station="Pasta"
            ),
            MenuItemData(
                id="ep_012", dining_hall_id="epicuria", name="Greek Salad",
                description="Romaine, cucumber, tomato, olives, feta, and Greek dressing",
                calories=240, protein=8, carbs=12, fat=18,
                meal_period="lunch", station="Salad Bar", is_vegetarian=True, is_gluten_free=True
            ),
            MenuItemData(
                id="ep_013", dining_hall_id="epicuria", name="Falafel Wrap",
                description="Crispy falafel with hummus, vegetables, and tahini",
                calories=450, protein=14, carbs=52, fat=22,
                meal_period="lunch", station="Grill", is_vegan=True
            ),
            # Dinner
            MenuItemData(
                id="ep_020", dining_hall_id="epicuria", name="Chicken Parmesan",
                description="Breaded chicken breast with marinara and mozzarella",
                calories=580, protein=42, carbs=32, fat=32,
                meal_period="dinner", station="Entrée"
            ),
            MenuItemData(
                id="ep_021", dining_hall_id="epicuria", name="Eggplant Parmesan",
                description="Breaded eggplant with marinara and mozzarella",
                calories=420, protein=14, carbs=38, fat=26,
                meal_period="dinner", station="Entrée", is_vegetarian=True
            ),
            MenuItemData(
                id="ep_022", dining_hall_id="epicuria", name="Spaghetti Bolognese",
                description="Spaghetti with meat sauce",
                calories=480, protein=24, carbs=58, fat=18,
                meal_period="dinner", station="Pasta"
            ),
            MenuItemData(
                id="ep_023", dining_hall_id="epicuria", name="Garlic Bread",
                description="Toasted Italian bread with garlic butter",
                calories=180, protein=4, carbs=24, fat=8,
                meal_period="dinner", station="Sides", is_vegetarian=True
            ),
        ])
        
        # De Neve - American comfort food
        items.extend([
            # Breakfast
            MenuItemData(
                id="dn_001", dining_hall_id="de_neve", name="Classic Pancakes",
                description="Fluffy buttermilk pancakes with maple syrup",
                calories=420, protein=10, carbs=72, fat=10,
                meal_period="breakfast", station="Grill", is_vegetarian=True
            ),
            MenuItemData(
                id="dn_002", dining_hall_id="de_neve", name="Bacon and Eggs",
                description="Two eggs any style with crispy bacon strips",
                calories=380, protein=24, carbs=2, fat=30,
                meal_period="breakfast", station="Grill", is_gluten_free=True
            ),
            MenuItemData(
                id="dn_003", dining_hall_id="de_neve", name="Breakfast Burrito",
                description="Scrambled eggs, cheese, potatoes, and salsa in a flour tortilla",
                calories=520, protein=22, carbs=48, fat=28,
                meal_period="breakfast", station="Grill"
            ),
            # Lunch
            MenuItemData(
                id="dn_010", dining_hall_id="de_neve", name="Cheeseburger",
                description="Beef patty with American cheese, lettuce, tomato",
                calories=580, protein=32, carbs=42, fat=32,
                meal_period="lunch", station="Grill"
            ),
            MenuItemData(
                id="dn_011", dining_hall_id="de_neve", name="Crispy Chicken Sandwich",
                description="Breaded chicken breast with pickles and mayo",
                calories=620, protein=28, carbs=54, fat=34,
                meal_period="lunch", station="Grill"
            ),
            MenuItemData(
                id="dn_012", dining_hall_id="de_neve", name="French Fries",
                description="Crispy golden fries",
                calories=320, protein=4, carbs=42, fat=16,
                meal_period="lunch", station="Sides", is_vegan=True, is_gluten_free=True
            ),
            MenuItemData(
                id="dn_013", dining_hall_id="de_neve", name="Garden Salad",
                description="Mixed greens with tomato, cucumber, and ranch",
                calories=180, protein=4, carbs=12, fat=14,
                meal_period="lunch", station="Salad Bar", is_vegetarian=True, is_gluten_free=True
            ),
            # Dinner
            MenuItemData(
                id="dn_020", dining_hall_id="de_neve", name="BBQ Pulled Pork",
                description="Slow-cooked pulled pork with tangy BBQ sauce",
                calories=440, protein=32, carbs=28, fat=24,
                meal_period="dinner", station="Entrée", is_gluten_free=True
            ),
            MenuItemData(
                id="dn_021", dining_hall_id="de_neve", name="Mac and Cheese",
                description="Creamy three-cheese macaroni",
                calories=480, protein=16, carbs=52, fat=24,
                meal_period="dinner", station="Comfort", is_vegetarian=True
            ),
            MenuItemData(
                id="dn_022", dining_hall_id="de_neve", name="Mashed Potatoes",
                description="Creamy mashed potatoes with gravy",
                calories=220, protein=4, carbs=32, fat=9,
                meal_period="dinner", station="Sides", is_vegetarian=True, is_gluten_free=True
            ),
            MenuItemData(
                id="dn_023", dining_hall_id="de_neve", name="Cornbread",
                description="Sweet honey cornbread",
                calories=180, protein=4, carbs=28, fat=6,
                meal_period="dinner", station="Sides", is_vegetarian=True
            ),
        ])
        
        # Feast - Asian fusion
        items.extend([
            # Breakfast
            MenuItemData(
                id="ft_001", dining_hall_id="feast", name="Congee",
                description="Rice porridge with ginger and green onion",
                calories=180, protein=6, carbs=36, fat=2,
                meal_period="breakfast", station="Hot Bar", is_vegan=True, is_gluten_free=True
            ),
            MenuItemData(
                id="ft_002", dining_hall_id="feast", name="Steamed Pork Buns",
                description="Fluffy buns filled with seasoned pork",
                calories=280, protein=12, carbs=38, fat=10,
                meal_period="breakfast", station="Dim Sum"
            ),
            # Lunch
            MenuItemData(
                id="ft_010", dining_hall_id="feast", name="Orange Chicken",
                description="Crispy chicken in sweet orange sauce",
                calories=480, protein=26, carbs=52, fat=20,
                meal_period="lunch", station="Wok"
            ),
            MenuItemData(
                id="ft_011", dining_hall_id="feast", name="Beef Broccoli",
                description="Sliced beef with broccoli in garlic sauce",
                calories=380, protein=28, carbs=18, fat=22,
                meal_period="lunch", station="Wok", is_gluten_free=True
            ),
            MenuItemData(
                id="ft_012", dining_hall_id="feast", name="Vegetable Fried Rice",
                description="Wok-fried rice with mixed vegetables and egg",
                calories=340, protein=10, carbs=52, fat=12,
                meal_period="lunch", station="Rice", is_vegetarian=True
            ),
            MenuItemData(
                id="ft_013", dining_hall_id="feast", name="Miso Soup",
                description="Traditional miso soup with tofu and seaweed",
                calories=80, protein=6, carbs=8, fat=3,
                meal_period="lunch", station="Soup", is_vegetarian=True
            ),
            # Dinner
            MenuItemData(
                id="ft_020", dining_hall_id="feast", name="Korean BBQ Beef",
                description="Marinated bulgogi-style beef",
                calories=420, protein=32, carbs=22, fat=24,
                meal_period="dinner", station="Grill", is_gluten_free=True
            ),
            MenuItemData(
                id="ft_021", dining_hall_id="feast", name="Chicken Katsu",
                description="Breaded chicken cutlet with tonkatsu sauce",
                calories=520, protein=34, carbs=42, fat=26,
                meal_period="dinner", station="Entrée"
            ),
            MenuItemData(
                id="ft_022", dining_hall_id="feast", name="Vegetable Pad Thai",
                description="Rice noodles with tofu and vegetables in tamarind sauce",
                calories=380, protein=12, carbs=58, fat=14,
                meal_period="dinner", station="Noodles", is_vegan=True, is_gluten_free=True
            ),
            MenuItemData(
                id="ft_023", dining_hall_id="feast", name="Steamed Jasmine Rice",
                description="Fragrant jasmine rice",
                calories=200, protein=4, carbs=44, fat=0,
                meal_period="dinner", station="Rice", is_vegan=True, is_gluten_free=True
            ),
        ])
        
        # Rendezvous - Quick service
        items.extend([
            # Lunch
            MenuItemData(
                id="rv_010", dining_hall_id="rendezvous", name="Turkey Club Sandwich",
                description="Turkey, bacon, lettuce, tomato on toasted bread",
                calories=520, protein=32, carbs=42, fat=26,
                meal_period="lunch", station="Deli"
            ),
            MenuItemData(
                id="rv_011", dining_hall_id="rendezvous", name="Veggie Wrap",
                description="Hummus, roasted vegetables, and mixed greens",
                calories=380, protein=12, carbs=48, fat=18,
                meal_period="lunch", station="Deli", is_vegan=True
            ),
            MenuItemData(
                id="rv_012", dining_hall_id="rendezvous", name="Chicken Caesar Wrap",
                description="Grilled chicken, romaine, parmesan, caesar dressing",
                calories=480, protein=28, carbs=38, fat=24,
                meal_period="lunch", station="Deli"
            ),
            # Dinner
            MenuItemData(
                id="rv_020", dining_hall_id="rendezvous", name="Pepperoni Pizza Slice",
                description="Classic pepperoni pizza",
                calories=320, protein=14, carbs=36, fat=14,
                meal_period="dinner", station="Pizza"
            ),
            MenuItemData(
                id="rv_021", dining_hall_id="rendezvous", name="Cheese Pizza Slice",
                description="Classic cheese pizza",
                calories=280, protein=12, carbs=36, fat=10,
                meal_period="dinner", station="Pizza", is_vegetarian=True
            ),
            MenuItemData(
                id="rv_022", dining_hall_id="rendezvous", name="Buffalo Wings",
                description="Crispy wings with buffalo sauce",
                calories=420, protein=28, carbs=8, fat=32,
                meal_period="dinner", station="Grill", is_gluten_free=True
            ),
        ])
        
        # BCafe - Grab and go
        items.extend([
            # All day items (using lunch as default period)
            MenuItemData(
                id="bc_001", dining_hall_id="bcafe", name="Protein Box",
                description="Hard boiled eggs, cheese, almonds, and grapes",
                calories=320, protein=18, carbs=16, fat=22,
                meal_period="lunch", station="Grab & Go", is_vegetarian=True, is_gluten_free=True
            ),
            MenuItemData(
                id="bc_002", dining_hall_id="bcafe", name="Caesar Salad",
                description="Romaine, croutons, parmesan, caesar dressing",
                calories=340, protein=10, carbs=22, fat=26,
                meal_period="lunch", station="Salads", is_vegetarian=True
            ),
            MenuItemData(
                id="bc_003", dining_hall_id="bcafe", name="Chicken Wrap",
                description="Grilled chicken with lettuce and ranch",
                calories=420, protein=26, carbs=38, fat=20,
                meal_period="lunch", station="Grab & Go"
            ),
            MenuItemData(
                id="bc_004", dining_hall_id="bcafe", name="Fruit Cup",
                description="Fresh seasonal mixed fruit",
                calories=80, protein=1, carbs=20, fat=0,
                meal_period="lunch", station="Grab & Go", is_vegan=True, is_gluten_free=True
            ),
        ])
        
        return items
    
    def get_dining_halls(self) -> List[DiningHallData]:
        """Get all UCLA dining halls"""
        return self._dining_halls
    
    def get_menu_items(
        self, 
        dining_hall_id: str, 
        menu_date: date,
        meal_period: Optional[str] = None
    ) -> List[MenuItemData]:
        """
        Get menu items for a specific dining hall.
        
        Note: In the seeded provider, the same menu is returned for any date.
        A real scraper would return date-specific menus.
        """
        items = [item for item in self._menu_items if item.dining_hall_id == dining_hall_id]
        
        if meal_period:
            items = [item for item in items if item.meal_period == meal_period]
        
        return items
    
    def get_all_menu_items_for_date(self, menu_date: date) -> List[MenuItemData]:
        """Get all menu items across all dining halls"""
        return self._menu_items


# Global provider instance - can be swapped for different implementations
_current_provider: Optional[MenuProvider] = None


def get_menu_provider() -> MenuProvider:
    """
    Get the current menu provider instance.
    
    This function serves as a dependency injection point.
    By default, returns SeededMenuProvider.
    
    To swap providers (e.g., for live scraping):
        set_menu_provider(UCLAScraperProvider())
    """
    global _current_provider
    if _current_provider is None:
        _current_provider = SeededMenuProvider()
    return _current_provider


def set_menu_provider(provider: MenuProvider) -> None:
    """
    Set the menu provider to use.
    
    Args:
        provider: A MenuProvider implementation
    """
    global _current_provider
    _current_provider = provider

