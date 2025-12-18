from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

# Get the properly formatted database URL
database_url = settings.database_url_sync

# Create engine with appropriate settings
if database_url.startswith("sqlite"):
    engine = create_engine(
        database_url,
        connect_args={"check_same_thread": False},
        echo=settings.ENVIRONMENT == "development"
    )
else:
    # PostgreSQL - use connection pooling for production
    engine = create_engine(
        database_url,
        echo=settings.ENVIRONMENT == "development",
        pool_pre_ping=True,  # Verify connections before use
        pool_size=5,
        max_overflow=10
    )

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    """Dependency for getting database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def create_tables():
    """Create all tables - called on startup."""
    Base.metadata.create_all(bind=engine)
