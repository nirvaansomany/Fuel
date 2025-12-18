"""
Authentication API routes: signup, login, /me
"""
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from typing import Annotated

from app.core.database import get_db
from app.core.security import verify_password, get_password_hash, create_access_token, decode_access_token
from app.models.user import User, Profile
from app.schemas.user import UserCreate, UserResponse, UserLogin, UserWithToken, ProfileResponse
from app.schemas.auth import Token
from app.services.macro_calculator import calculate_all_macros

router = APIRouter(prefix="/auth", tags=["Authentication"])

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")


def get_initials(name: str) -> str:
    """Get initials from a name (e.g., 'John Doe' -> 'JD')"""
    parts = name.strip().split()
    if len(parts) >= 2:
        return (parts[0][0] + parts[-1][0]).upper()
    elif len(parts) == 1 and len(parts[0]) >= 1:
        return parts[0][0].upper()
    return "?"


def list_to_csv(items: list) -> str:
    """Convert list to comma-separated string for DB storage"""
    return ",".join(items) if items else ""


def csv_to_list(csv_str: str) -> list:
    """Convert comma-separated string from DB to list"""
    return [x.strip() for x in csv_str.split(",") if x.strip()] if csv_str else []


def profile_to_response(profile: Profile, user_id: int) -> ProfileResponse:
    """Convert DB Profile model to ProfileResponse with lists instead of CSV strings"""
    return ProfileResponse(
        id=profile.id,
        user_id=user_id,
        age_years=profile.age_years,
        height_text=profile.height_text,
        weight_lbs=profile.weight_lbs,
        goal_weight_lbs=profile.goal_weight_lbs,
        is_male=profile.is_male,
        activity_level_index=profile.activity_level_index,
        goal_type_index=profile.goal_type_index,
        calories_target=profile.calories_target,
        protein_target=profile.protein_target,
        carbs_target=profile.carbs_target,
        fat_target=profile.fat_target,
        selected_vitamins=csv_to_list(profile.selected_vitamins),
        dietary_restrictions=csv_to_list(profile.dietary_restrictions),
        disliked_foods=csv_to_list(profile.disliked_foods),
        selected_dining_halls=csv_to_list(profile.selected_dining_halls),
        delivery_method_index=profile.delivery_method_index,
        appearance_index=profile.appearance_index,
        created_at=profile.created_at,
        updated_at=profile.updated_at,
    )


def user_to_response(user: User) -> UserResponse:
    """Convert DB User model to UserResponse"""
    profile_response = None
    if user.profile:
        profile_response = profile_to_response(user.profile, user.id)
    
    return UserResponse(
        id=user.id,
        email=user.email,
        name=user.name,
        initials=get_initials(user.name),
        created_at=user.created_at,
        updated_at=user.updated_at,
        profile=profile_response,
    )


async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    db: Session = Depends(get_db)
) -> User:
    """Dependency to get the current authenticated user from JWT token"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    payload = decode_access_token(token)
    if payload is None:
        raise credentials_exception
    
    user_id_str = payload.get("sub")
    if user_id_str is None:
        raise credentials_exception
    
    try:
        user_id = int(user_id_str)
    except (TypeError, ValueError):
        raise credentials_exception
    
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise credentials_exception
    
    return user


@router.post("/signup", response_model=UserWithToken, status_code=status.HTTP_201_CREATED)
async def signup(user_data: UserCreate, db: Session = Depends(get_db)):
    """
    Register a new user account.
    
    - Creates user with email and password
    - Optionally creates profile if provided
    - Returns user data + JWT token
    """
    # Check if email already exists
    existing_user = db.query(User).filter(User.email == user_data.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create user
    hashed_password = get_password_hash(user_data.password)
    user = User(
        email=user_data.email,
        name=user_data.name,
        hashed_password=hashed_password,
    )
    db.add(user)
    db.flush()  # Get user.id without committing
    
    # Create profile (with defaults or provided data)
    profile_data = user_data.profile
    if profile_data:
        # Calculate macros based on provided profile data
        calories, protein, carbs, fat = calculate_all_macros(
            weight_lbs=profile_data.weight_lbs,
            height_text=profile_data.height_text,
            age_years=profile_data.age_years,
            is_male=profile_data.is_male,
            activity_level_index=profile_data.activity_level_index,
            goal_type_index=profile_data.goal_type_index,
        )
        
        profile = Profile(
            user_id=user.id,
            age_years=profile_data.age_years,
            height_text=profile_data.height_text,
            weight_lbs=profile_data.weight_lbs,
            goal_weight_lbs=profile_data.goal_weight_lbs,
            is_male=profile_data.is_male,
            activity_level_index=profile_data.activity_level_index,
            goal_type_index=profile_data.goal_type_index,
            calories_target=calories,
            protein_target=protein,
            carbs_target=carbs,
            fat_target=fat,
            selected_vitamins=list_to_csv(profile_data.selected_vitamins),
            dietary_restrictions=list_to_csv(profile_data.dietary_restrictions),
            disliked_foods=list_to_csv(profile_data.disliked_foods),
            selected_dining_halls=list_to_csv(profile_data.selected_dining_halls),
            delivery_method_index=profile_data.delivery_method_index,
            appearance_index=profile_data.appearance_index,
        )
    else:
        # Create profile with defaults
        calories, protein, carbs, fat = calculate_all_macros(
            weight_lbs=165, height_text="5'10\"", age_years=21,
            is_male=True, activity_level_index=2, goal_type_index=0
        )
        profile = Profile(
            user_id=user.id,
            calories_target=calories,
            protein_target=protein,
            carbs_target=carbs,
            fat_target=fat,
        )
    
    db.add(profile)
    db.commit()
    db.refresh(user)
    
    # Create access token (sub must be a string for JWT)
    access_token = create_access_token(data={"sub": str(user.id), "email": user.email})
    
    return UserWithToken(
        user=user_to_response(user),
        access_token=access_token,
        token_type="bearer"
    )


@router.post("/login", response_model=Token)
async def login(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
    db: Session = Depends(get_db)
):
    """
    Login with email and password.
    
    Uses OAuth2 password flow (form data with 'username' and 'password' fields).
    The 'username' field should contain the user's email.
    
    Returns JWT access token.
    """
    user = db.query(User).filter(User.email == form_data.username).first()
    
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token = create_access_token(data={"sub": str(user.id), "email": user.email})
    return Token(access_token=access_token, token_type="bearer")


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: Annotated[User, Depends(get_current_user)]):
    """
    Get current authenticated user's data.
    
    Requires valid JWT token in Authorization header.
    Returns user data including profile.
    """
    return user_to_response(current_user)

