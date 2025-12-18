from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    
    # Database
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
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
