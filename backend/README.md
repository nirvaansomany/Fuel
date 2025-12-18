# Fuel Backend API

Backend API for the Fuel iOS app - UCLA dining hall meal planning and nutrition tracking.

## Tech Stack

- **FastAPI** - Modern Python web framework
- **SQLAlchemy** - ORM for database operations
- **Alembic** - Database migrations
- **PostgreSQL** - Production database (SQLite for local dev)
- **Pydantic** - Data validation and settings management
- **JWT** - Authentication

## Setup

### Prerequisites

- Python 3.9+
- PostgreSQL (optional, SQLite works for local dev)
- pip

### Installation

1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Copy environment file:
```bash
cp .env.example .env
```

4. Edit `.env` with your settings (optional for local dev with SQLite)

5. Run database migrations:
```bash
alembic upgrade head
```

6. Start the server:
```bash
uvicorn app.main:app --reload
```

The API will be available at:
- API: http://localhost:8000
- Docs: http://localhost:8000/docs
- Health: http://localhost:8000/health

## Project Structure

```
backend/
├── app/
│   ├── api/          # API route handlers
│   ├── core/         # Core config, database, security
│   ├── models/       # SQLAlchemy database models
│   ├── services/     # Business logic
│   └── main.py       # FastAPI app entry point
├── alembic/          # Database migrations
├── requirements.txt  # Python dependencies
└── README.md
```

## Development

### Running Migrations

Create a new migration:
```bash
alembic revision --autogenerate -m "description"
```

Apply migrations:
```bash
alembic upgrade head
```

Rollback:
```bash
alembic downgrade -1
```

### Environment Variables

Key variables in `.env`:
- `DATABASE_URL` - Database connection string
- `SECRET_KEY` - JWT secret (change in production!)
- `ENVIRONMENT` - development/production

## API Endpoints

### Health Check
- `GET /health` - Health check endpoint

### Documentation
- `GET /docs` - Interactive API documentation (Swagger UI)
- `GET /redoc` - Alternative API documentation

## Next Steps

This is Phase 1 - basic scaffold. Next phases will add:
- Authentication (Phase 2)
- User profiles (Phase 3)
- Dining halls & menus (Phase 4)
- Meal recommendations (Phase 5)
- Consumption tracking (Phase 6)
- iOS integration (Phase 7)
- Deployment (Phase 8)

