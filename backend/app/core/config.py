from pydantic_settings import BaseSettings
from typing import Optional
import os


class Settings(BaseSettings):
    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    
    # Database - Render provides DATABASE_URL with postgres:// prefix
    # SQLAlchemy requires postgresql:// prefix
    DATABASE_URL: str = "sqlite:///./fuel.db"
    
    # JWT - MUST be changed in production via environment variable
    SECRET_KEY: str = "change-this-secret-key-in-production-min-32-characters"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days for mobile app convenience
    
    # App
    ENVIRONMENT: str = "development"
    API_V1_PREFIX: str = "/api/v1"
    
    # CORS - comma-separated list of allowed origins
    CORS_ORIGINS: str = "*"
    
    # Demo mode - seed data if DB is empty
    SEED_DEMO_DATA: bool = True
    
    @property
    def database_url_sync(self) -> str:
        """Get database URL with correct prefix for SQLAlchemy."""
        url = self.DATABASE_URL
        # Render uses postgres:// but SQLAlchemy needs postgresql://
        if url.startswith("postgres://"):
            url = url.replace("postgres://", "postgresql://", 1)
        return url
    
    @property
    def is_production(self) -> bool:
        return self.ENVIRONMENT == "production"
    
    def validate_production_settings(self) -> None:
        """Raise error if production settings are insecure."""
        if self.is_production:
            if self.SECRET_KEY == "change-this-secret-key-in-production-min-32-characters":
                raise ValueError("SECRET_KEY must be changed in production!")
            if len(self.SECRET_KEY) < 32:
                raise ValueError("SECRET_KEY must be at least 32 characters in production!")
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()

# Validate on import if in production
if settings.is_production:
    settings.validate_production_settings()
