from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging

from app.core.config import settings
from app.core.database import create_tables, SessionLocal
from app.db.seed import run_seeds
from app.api.auth import router as auth_router
from app.api.users import router as users_router
from app.api.menus import router as menus_router

# Import models so Alembic can detect them
from app.models import User, Profile, DiningHall, MenuItem  # noqa: F401

# Configure logging
logging.basicConfig(
    level=logging.INFO if settings.is_production else logging.DEBUG,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan - runs on startup and shutdown."""
    # Startup
    logger.info(f"Starting Fuel API in {settings.ENVIRONMENT} mode")
    
    # Create tables if they don't exist
    logger.info("Creating database tables...")
    create_tables()
    
    # Seed demo data if enabled and DB is empty
    if settings.SEED_DEMO_DATA:
        logger.info("Checking if demo data seeding is needed...")
        db = SessionLocal()
        try:
            run_seeds(db)
        except Exception as e:
            logger.error(f"Error seeding database: {e}")
        finally:
            db.close()
    
    logger.info("Startup complete!")
    
    yield  # App is running
    
    # Shutdown
    logger.info("Shutting down Fuel API")


app = FastAPI(
    title="Fuel API",
    description="Backend API for Fuel iOS app - UCLA dining hall meal planning",
    version="1.0.0",
    lifespan=lifespan,
    # Disable docs in production for security (optional)
    docs_url="/docs" if not settings.is_production else None,
    redoc_url="/redoc" if not settings.is_production else None,
)

# CORS middleware - allow iOS app to connect
# Configure via CORS_ORIGINS env var (comma-separated) or defaults to "*"
cors_origins = settings.CORS_ORIGINS.split(",") if settings.CORS_ORIGINS != "*" else ["*"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth_router)
app.include_router(users_router)
app.include_router(menus_router)


@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring and load balancers."""
    return {
        "status": "healthy",
        "environment": settings.ENVIRONMENT,
        "version": "1.0.0"
    }


@app.get("/debug/db")
async def debug_database():
    """Debug endpoint to check database connectivity and tables."""
    from app.core.database import SessionLocal
    from app.models import User, DiningHall
    
    try:
        db = SessionLocal()
        user_count = db.query(User).count()
        hall_count = db.query(DiningHall).count()
        db.close()
        return {
            "status": "connected",
            "users": user_count,
            "dining_halls": hall_count,
            "database_url_prefix": settings.DATABASE_URL[:20] + "..." if len(settings.DATABASE_URL) > 20 else settings.DATABASE_URL
        }
    except Exception as e:
        return {
            "status": "error",
            "error": str(e),
            "type": type(e).__name__
        }


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "message": "Fuel API",
        "version": "1.0.0",
        "docs": "/docs" if not settings.is_production else "disabled",
        "health": "/health"
    }
