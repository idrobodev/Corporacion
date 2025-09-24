# 🚀 Deployment Checklist - Todo por un Alma

## Pre-Deployment Setup

### 1. VPS Requirements
- [ ] Ubuntu 20.04+ or similar Linux distribution
- [ ] At least 2GB RAM (4GB recommended)
- [ ] At least 10GB free disk space
- [ ] Docker Engine 20.10+ installed
- [ ] Docker Compose 2.0+ installed
- [ ] Ports 80, 443, 8080, 5432 available

### 2. Domain Configuration
- [ ] Domain DNS pointing to VPS IP address
- [ ] Subdomain `api.yourdomain.com` pointing to VPS IP
- [ ] SSL certificates obtained (Let's Encrypt recommended)

### 3. Environment Configuration
- [ ] Copy `.env.example` to `.env`
- [ ] Update database credentials in `.env`
- [ ] Generate strong JWT secret (256+ bits)
- [ ] Configure CORS allowed origins
- [ ] Set production domain names

## Deployment Steps

### 1. Upload Files to VPS
```bash
# Upload the entire Corporacion folder to your VPS
scp -r /path/to/Corporacion user@your-vps-ip:/opt/
```

### 2. Set Permissions
```bash
ssh user@your-vps-ip
cd /opt/Corporacion
chmod +x deploy.sh backup.sh
```

### 3. Configure Environment
```bash
# Edit environment variables
nano .env

# Verify configuration
cat .env
```

### 4. Deploy Application
```bash
# For production deployment
./deploy.sh production

# For development deployment
./deploy.sh development
```

### 5. Verify Deployment
- [ ] Frontend accessible at http://your-domain.com
- [ ] API accessible at http://your-domain.com:8080/api
- [ ] API documentation at http://your-domain.com:8080/api/swagger-ui.html
- [ ] Database connection working
- [ ] Health checks passing

## Post-Deployment Configuration

### 1. SSL Setup (Production)
```bash
# Install Certbot
sudo apt install certbot

# Obtain SSL certificates
sudo certbot certonly --standalone -d yourdomain.com -d api.yourdomain.com

# Copy certificates to ssl directory
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/yourdomain.com.crt
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/yourdomain.com.key
sudo cp /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem ssl/api.yourdomain.com.crt
sudo cp /etc/letsencrypt/live/api.yourdomain.com/privkey.pem ssl/api.yourdomain.com.key

# Enable production profile with SSL
docker-compose --profile production up -d
```

### 2. Firewall Configuration
```bash
# Configure UFW firewall
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

### 3. Backup Setup
```bash
# Test backup
./backup.sh

# Setup automated backups (crontab)
crontab -e
# Add: 0 2 * * * /opt/Corporacion/backup.sh
```

### 4. Monitoring Setup (Optional)
```bash
# Enable monitoring services
docker-compose -f docker-compose.yml -f docker-compose.monitoring.yml --profile monitoring up -d

# Access Grafana at http://your-domain.com:3000
# Default credentials: admin/admin
```

## Maintenance Commands

### Service Management
```bash
# View service status
docker-compose ps

# View logs
docker-compose logs -f [service_name]

# Restart services
docker-compose restart [service_name]

# Update application
git pull origin main
docker-compose down
docker-compose up --build -d
```

### Database Management
```bash
# Access database
docker-compose exec postgres psql -U todoporunalma_user -d todoporunalma_db

# Create backup
./backup.sh

# Restore backup
docker-compose exec -T postgres psql -U todoporunalma_user -d todoporunalma_db < backups/database_backup_YYYYMMDD_HHMMSS.sql
```

## Troubleshooting

### Common Issues
1. **Port conflicts**: Check if ports are already in use
2. **Permission errors**: Ensure proper file permissions
3. **Database connection**: Verify database credentials and network
4. **SSL issues**: Check certificate paths and permissions
5. **Memory issues**: Monitor system resources

### Health Checks
```bash
# Check all services
docker-compose ps

# Check individual service health
docker inspect --format='{{.State.Health.Status}}' todoporunalma-api
docker inspect --format='{{.State.Health.Status}}' todoporunalma-frontend
docker inspect --format='{{.State.Health.Status}}' todoporunalma-postgres
```

### Log Analysis
```bash
# View recent logs
docker-compose logs --tail=100

# Follow logs in real-time
docker-compose logs -f

# Service-specific logs
docker-compose logs -f api
docker-compose logs -f frontend
docker-compose logs -f postgres
```

## Security Checklist

- [ ] Strong database passwords
- [ ] Secure JWT secrets
- [ ] SSL certificates configured
- [ ] Firewall properly configured
- [ ] Regular security updates
- [ ] Backup encryption (if needed)
- [ ] Access logs monitoring
- [ ] Rate limiting configured

## Performance Optimization

- [ ] Database connection pooling configured
- [ ] Nginx gzip compression enabled
- [ ] Static asset caching configured
- [ ] Database indexes optimized
- [ ] Monitoring alerts set up
- [ ] Log rotation configured

## Support

For issues during deployment:
1. Check the logs: `docker-compose logs`
2. Verify service health: `docker-compose ps`
3. Review configuration files
4. Check the main README-Docker.md for detailed information
