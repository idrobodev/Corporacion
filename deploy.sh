#!/bin/bash

# Deploy script for Todo por un Alma application
# Usage: ./deploy.sh [environment]
# Environment: development (default) or production

set -e

ENVIRONMENT=${1:-development}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting deployment for environment: $ENVIRONMENT"

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Navigate to project directory
cd "$SCRIPT_DIR"

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Creating from .env.example..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "📝 Please edit .env file with your production values before continuing."
        echo "   Especially change the database password and JWT secret!"
        read -p "Press Enter to continue after editing .env file..."
    else
        echo "❌ .env.example file not found. Cannot create .env file."
        exit 1
    fi
fi

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose down --remove-orphans

# Remove old images (optional)
read -p "🗑️  Do you want to remove old images to save space? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧹 Removing old images..."
    docker system prune -f
    docker image prune -f
fi

# Build and start services
if [ "$ENVIRONMENT" = "production" ]; then
    echo "🏗️  Building and starting services for production..."
    docker-compose --profile production up --build -d
    
    # Ask if user wants to enable monitoring
    read -p "🔍 Do you want to enable monitoring (Prometheus, Grafana, etc.)? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📊 Starting monitoring services..."
        docker-compose -f docker-compose.yml -f docker-compose.monitoring.yml --profile monitoring up -d
    fi
elif [ "$ENVIRONMENT" = "development" ]; then
    echo "🏗️  Building and starting services for development..."
    docker-compose -f docker-compose.dev.yml up --build -d
else
    echo "🏗️  Building and starting services..."
    docker-compose up --build -d
fi

# Wait for services to be healthy
echo "⏳ Waiting for services to be healthy..."
sleep 30

# Check service health
echo "🔍 Checking service health..."
docker-compose ps

# Show logs
echo "📋 Recent logs:"
docker-compose logs --tail=50

echo "✅ Deployment completed!"
echo ""
echo "🌐 Application URLs:"
echo "   Frontend: http://localhost"
echo "   API: http://localhost:8080/api"
echo "   API Documentation: http://localhost:8080/api/swagger-ui.html"
echo "   Database: localhost:5432"
echo ""
echo "📊 To view logs: docker-compose logs -f [service_name]"
echo "🛑 To stop: docker-compose down"
echo "🔄 To restart: docker-compose restart [service_name]"
