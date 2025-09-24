#!/bin/bash

# Backup script for Todo por un Alma application
# Creates backups of database and application data

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backups"
DATE=$(date +%Y%m%d_%H%M%S)

echo "💾 Starting backup process..."

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Navigate to project directory
cd "$SCRIPT_DIR"

# Check if containers are running
if ! docker-compose ps | grep -q "Up"; then
    echo "⚠️  No running containers found. Please start the application first."
    exit 1
fi

# Backup database
echo "🗄️  Backing up PostgreSQL database..."
docker-compose exec -T postgres pg_dump -U todoporunalma_user todoporunalma_db > "$BACKUP_DIR/database_backup_$DATE.sql"

# Backup docker volumes
echo "📦 Backing up Docker volumes..."
docker run --rm -v todoporunalma_postgres_data:/data -v "$BACKUP_DIR":/backup alpine tar czf /backup/postgres_volume_$DATE.tar.gz -C /data .

# Create application backup info
echo "📋 Creating backup information..."
cat > "$BACKUP_DIR/backup_info_$DATE.txt" << EOF
Backup Information
==================
Date: $(date)
Application: Todo por un Alma
Environment: $(grep SPRING_PROFILE .env 2>/dev/null || echo "Unknown")

Files included:
- database_backup_$DATE.sql (PostgreSQL dump)
- postgres_volume_$DATE.tar.gz (PostgreSQL data volume)

Restore instructions:
1. Stop the application: docker-compose down
2. Restore database: docker-compose exec -T postgres psql -U todoporunalma_user -d todoporunalma_db < database_backup_$DATE.sql
3. Or restore volume: docker run --rm -v todoporunalma_postgres_data:/data -v "$BACKUP_DIR":/backup alpine tar xzf /backup/postgres_volume_$DATE.tar.gz -C /data
EOF

# Cleanup old backups (keep last 7 days)
echo "🧹 Cleaning up old backups (keeping last 7 days)..."
find "$BACKUP_DIR" -name "database_backup_*.sql" -mtime +7 -delete 2>/dev/null || true
find "$BACKUP_DIR" -name "postgres_volume_*.tar.gz" -mtime +7 -delete 2>/dev/null || true
find "$BACKUP_DIR" -name "backup_info_*.txt" -mtime +7 -delete 2>/dev/null || true

echo "✅ Backup completed successfully!"
echo "📁 Backup files saved to: $BACKUP_DIR"
echo "   - database_backup_$DATE.sql"
echo "   - postgres_volume_$DATE.tar.gz"
echo "   - backup_info_$DATE.txt"
