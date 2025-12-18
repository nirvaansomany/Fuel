from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.auth import router as auth_router
from app.api.users import router as users_router
from app.api.menus import router as menus_router

# Import models so Alembic can detect them
from app.models import User, Profile, DiningHall, MenuItem  # noqa: F401

app = FastAPI(
    title="Fuel API",
    description="Backend API for Fuel iOS app - UCLA dining hall meal planning",
    version="1.0.0",
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
    """Health check endpoint"""
    return {
        "status": "healthy",
        "environment": settings.ENVIRONMENT,
        "version": "1.0.0"
    }


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Fuel API",
        "version": "1.0.0",
        "docs": "/docs"
    }

