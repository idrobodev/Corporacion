-- Database initialization script for Todo por un Alma
-- This script will be executed when the PostgreSQL container starts for the first time

-- Create database if it doesn't exist (this is handled by POSTGRES_DB environment variable)
-- The database is automatically created by the postgres image

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Set timezone
SET timezone = 'America/Bogota';

-- Grant necessary permissions to the application user
GRANT ALL PRIVILEGES ON DATABASE todoporunalma_db TO todoporunalma_user;
GRANT ALL PRIVILEGES ON SCHEMA public TO todoporunalma_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO todoporunalma_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO todoporunalma_user;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO todoporunalma_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO todoporunalma_user;
