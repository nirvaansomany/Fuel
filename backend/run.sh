#!/bin/bash
# Start script for Fuel backend
#
# Environment variables (all optional, have defaults):
#   PORT           - Server port (default: 8000)
#   HOST           - Server host (default: 0.0.0.0)
#   DATABASE_URL   - Database connection URL (default: sqlite:///./fuel.db)
#   SECRET_KEY     - JWT secret key (MUST change in production!)
#   ENVIRONMENT    - development|production (default: development)

echo "Starting Fuel API..."
echo ""
echo "Configuration:"
echo "  HOST: ${HOST:-0.0.0.0}"
echo "  PORT: ${PORT:-8000}"
echo "  ENVIRONMENT: ${ENVIRONMENT:-development}"
echo ""

# Use PORT from environment (for Railway, Render, Fly.io, etc.)
PORT=${PORT:-8000}
HOST=${HOST:-0.0.0.0}

# Start uvicorn
uvicorn app.main:app --host "$HOST" --port "$PORT" ${RELOAD:+--reload}
