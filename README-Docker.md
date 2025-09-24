# Docker Deployment Guide - Todo por un Alma

This guide explains how to deploy the Todo por un Alma application using Docker containers on a VPS.

## 🏗️ Architecture

The application consists of three main services:

- **Frontend**: React application served by Nginx
- **API**: Spring Boot REST API
- **Database**: PostgreSQL database

## 📋 Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 2GB RAM
- At least 10GB disk space

## 🚀 Quick Start

1. **Clone and navigate to the project:**
   ```bash
   cd /path/to/Corporacion
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your production values
   nano .env
   ```

3. **Deploy the application:**
   ```bash
   ./deploy.sh production
   ```

## ⚙️ Configuration

### Environment Variables

Copy `.env.example` to `.env` and modify the following variables:

```bash
# Database Configuration
POSTGRES_DB=todoporunalma_db
POSTGRES_USER=todoporunalma_user
POSTGRES_PASSWORD=your_secure_password_here

# JWT Configuration (IMPORTANT: Change in production)
JWT_SECRET=your_very_long_and_secure_jwt_secret_key_here

# CORS Configuration
CORS_ALLOWED_ORIGINS=https://yourdomain.com

# Domain Configuration (for production)
DOMAIN=yourdomain.com
API_DOMAIN=api.yourdomain.com
```

### SSL Configuration (Production)

For production deployment with SSL:

1. Place your SSL certificates in the `ssl/` directory:
   ```
   ssl/
   ├── yourdomain.com.crt
   ├── yourdomain.com.key
   ├── api.yourdomain.com.crt
   └── api.yourdomain.com.key
   ```

2. Deploy with production profile:
   ```bash
   ./deploy.sh production
   ```

## 🐳 Docker Services

### Frontend Service
- **Port**: 80
- **Technology**: React + Nginx
- **Health Check**: HTTP GET /health

### API Service
- **Port**: 8080
- **Technology**: Spring Boot + Java 17
- **Health Check**: HTTP GET /api/actuator/health
- **Dependencies**: PostgreSQL

### Database Service
- **Port**: 5432
- **Technology**: PostgreSQL 15
- **Volume**: `postgres_data`
- **Health Check**: pg_isready

### Nginx Proxy (Production)
- **Port**: 443
- **Technology**: Nginx with SSL
- **Features**: Rate limiting, security headers, SSL termination

## 📝 Management Commands

### Deployment
```bash
# Development deployment
./deploy.sh

# Production deployment
./deploy.sh production
```

### Service Management
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Restart a service
docker-compose restart api

# View logs
docker-compose logs -f api

# View all service status
docker-compose ps
```

### Database Management
```bash
# Access database
docker-compose exec postgres psql -U todoporunalma_user -d todoporunalma_db

# Create backup
./backup.sh

# Restore from backup
docker-compose exec -T postgres psql -U todoporunalma_user -d todoporunalma_db < backups/database_backup_YYYYMMDD_HHMMSS.sql
```

## 🔧 Troubleshooting

### Common Issues

1. **Port already in use:**
   ```bash
   # Check what's using the port
   sudo lsof -i :80
   sudo lsof -i :8080
   
   # Stop conflicting services
   sudo systemctl stop apache2  # or nginx
   ```

2. **Database connection issues:**
   ```bash
   # Check database logs
   docker-compose logs postgres
   
   # Verify database is healthy
   docker-compose exec postgres pg_isready -U todoporunalma_user
   ```

3. **API not starting:**
   ```bash
   # Check API logs
   docker-compose logs api
   
   # Verify Java version and dependencies
   docker-compose exec api java -version
   ```

4. **Frontend not loading:**
   ```bash
   # Check frontend logs
   docker-compose logs frontend
   
   # Verify Nginx configuration
   docker-compose exec frontend nginx -t
   ```

### Health Checks

All services include health checks. Check service health:

```bash
# Overall status
docker-compose ps

# Detailed health check
docker inspect --format='{{.State.Health.Status}}' todoporunalma-api
docker inspect --format='{{.State.Health.Status}}' todoporunalma-frontend
docker inspect --format='{{.State.Health.Status}}' todoporunalma-postgres
```

## 🔒 Security Considerations

1. **Change default passwords** in `.env` file
2. **Use strong JWT secrets** (at least 256 bits)
3. **Configure firewall** to only allow necessary ports
4. **Use SSL certificates** for production
5. **Regular backups** using the provided backup script
6. **Keep Docker images updated**

## 📊 Monitoring

### Application URLs
- **Frontend**: http://localhost (or https://yourdomain.com)
- **API**: http://localhost:8080/api
- **API Documentation**: http://localhost:8080/api/swagger-ui.html
- **Health Checks**: 
  - Frontend: http://localhost/health
  - API: http://localhost:8080/api/actuator/health

### Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f api
docker-compose logs -f frontend
docker-compose logs -f postgres
```

## 🔄 Updates and Maintenance

### Updating the Application
```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose down
docker-compose up --build -d
```

### Database Migrations
The API automatically runs Flyway migrations on startup. Migration files are located in `api/src/main/resources/db/migration/`.

### Backup Schedule
Set up automated backups using cron:

```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /path/to/Corporacion/backup.sh
```

## 🆘 Support

For issues and questions:
1. Check the logs using `docker-compose logs`
2. Verify service health using `docker-compose ps`
3. Review this documentation
4. Check the application-specific README files in `api/` and `coptua_react/` directories

## 📁 File Structure

```
Corporacion/
├── api/                     # Spring Boot API project
├── coptua_react/           # React frontend project
├── docker-compose.yml     # Main orchestration file
├── Dockerfile.api         # API container definition
├── Dockerfile.react       # Frontend container definition
├── nginx.conf             # Nginx configuration for frontend
├── nginx-proxy.conf       # Production proxy configuration
├── .env.example           # Environment variables template
├── .env.production        # Production environment template
├── deploy.sh              # Deployment script
├── backup.sh              # Backup script
└── README-Docker.md       # This file
```
