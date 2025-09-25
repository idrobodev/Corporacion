-- Database initialization script for Todo por un Alma
-- This script will be executed when the PostgreSQL container starts for the first time

-- Create database if it doesn't exist (this is handled by POSTGRES_DB environment variable)
-- The database is automatically created by the postgres image

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

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

-- ==========================================
-- CREACIÓN DE TABLAS
-- ==========================================

-- 1. FUNDACION
CREATE TABLE IF NOT EXISTS fundacion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(255) NOT NULL,
    nit VARCHAR(20) UNIQUE,
    direccion TEXT,
    telefono VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(255),
    mision TEXT,
    vision TEXT,
    valores TEXT,
    logo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. SEDES
CREATE TABLE IF NOT EXISTS sedes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(255) NOT NULL,
    direccion TEXT NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    ciudad VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL DEFAULT 'Antioquia',
    capacidad_maxima INTEGER DEFAULT 30,
    tipo_sede VARCHAR(20) DEFAULT 'MIXTA'
        CHECK (tipo_sede IN ('MASCULINA', 'FEMENINA', 'MIXTA')),
    estado VARCHAR(20) DEFAULT 'ACTIVA'
        CHECK (estado IN ('ACTIVA', 'INACTIVA', 'MANTENIMIENTO')),
    director_nombre VARCHAR(255),
    director_telefono VARCHAR(20),
    observaciones TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_ciudad_tipo_sede UNIQUE (ciudad, tipo_sede)
);

-- 3. USUARIOS
CREATE TABLE IF NOT EXISTS usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    nombre VARCHAR(255),
    password_hash VARCHAR(255) NOT NULL,
    rol VARCHAR(20) DEFAULT 'CONSULTA'
        CHECK (rol IN ('CONSULTA', 'ADMINISTRADOR')),
    activo BOOLEAN DEFAULT true,
    ultimo_acceso TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. PARTICIPANTES
CREATE TABLE IF NOT EXISTS participantes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    documento VARCHAR(20) UNIQUE NOT NULL,
    nombres VARCHAR(255) NOT NULL,
    apellidos VARCHAR(255) NOT NULL,
    fecha_nacimiento DATE,
    edad INTEGER,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion TEXT,
    estado VARCHAR(20) DEFAULT 'ACTIVO'
        CHECK (estado IN ('ACTIVO', 'INACTIVO')),
    sede_id UUID REFERENCES sedes(id),
    fecha_ingreso DATE DEFAULT CURRENT_DATE,
    observaciones TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. MENSUALIDADES
CREATE TABLE IF NOT EXISTS mensualidades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    participante_id UUID REFERENCES participantes(id) ON DELETE CASCADE,
    mes INTEGER NOT NULL CHECK (mes BETWEEN 1 AND 12),
    anio INTEGER NOT NULL,
    monto DECIMAL(10,2) NOT NULL DEFAULT 0,
    fecha_vencimiento DATE,
    fecha_pago DATE,
    estado VARCHAR(20) DEFAULT 'PENDIENTE'
        CHECK (estado IN ('PENDIENTE', 'PAGADA', 'VENCIDA')),
    metodo_pago VARCHAR(50),
    observaciones TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(participante_id, mes, anio)
);

-- ==========================================
-- CREACIÓN DE ÍNDICES
-- ==========================================

-- Índices para optimizar consultas frecuentes
CREATE INDEX IF NOT EXISTS idx_participantes_sede ON participantes(sede_id);
CREATE INDEX IF NOT EXISTS idx_participantes_estado ON participantes(estado);
CREATE INDEX IF NOT EXISTS idx_participantes_documento ON participantes(documento);
CREATE INDEX IF NOT EXISTS idx_mensualidades_participante ON mensualidades(participante_id);
CREATE INDEX IF NOT EXISTS idx_mensualidades_fecha ON mensualidades(mes, anio);
CREATE INDEX IF NOT EXISTS idx_mensualidades_estado ON mensualidades(estado);
CREATE UNIQUE INDEX IF NOT EXISTS uniq_usuarios_email ON usuarios(email);

-- ==========================================
-- CREACIÓN DE TRIGGERS
-- ==========================================

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Aplicar trigger a todas las tablas
DROP TRIGGER IF EXISTS update_fundacion_updated_at ON fundacion;
CREATE TRIGGER update_fundacion_updated_at
    BEFORE UPDATE ON fundacion
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_sedes_updated_at ON sedes;
CREATE TRIGGER update_sedes_updated_at
    BEFORE UPDATE ON sedes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_usuarios_updated_at ON usuarios;
CREATE TRIGGER update_usuarios_updated_at
    BEFORE UPDATE ON usuarios
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_participantes_updated_at ON participantes;
CREATE TRIGGER update_participantes_updated_at
    BEFORE UPDATE ON participantes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_mensualidades_updated_at ON mensualidades;
CREATE TRIGGER update_mensualidades_updated_at
    BEFORE UPDATE ON mensualidades
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==========================================
-- INSERCIÓN DE DATOS INICIALES
-- ==========================================

-- 1. FUNDACIÓN
INSERT INTO fundacion (nombre, nit, direccion, telefono, email, website, mision, vision) VALUES
('Corporación Todo por un Alma', '900123456-7', 'Bello, Antioquia, Colombia',
 '3145702708', 'info@todoporunalma.org', 'https://todoporunalma.org',
 'Brindar apoyo integral a personas en proceso de rehabilitación por adicciones',
 'Ser referente nacional en rehabilitación y reinserción social')
ON CONFLICT (nit) DO NOTHING;

-- 2. SEDES (Las mismas que se usan en el archivo de participantes)
INSERT INTO sedes (nombre, direccion, ciudad, telefono, tipo_sede, director_nombre, director_telefono) VALUES
('Sede Masculina Bello Principal', 'Bello Principal, Antioquia', 'Bello Principal', '3145702708', 'MASCULINA',
   'Dr. Juan Camilo Machado', '3145702708'),
('Sede Femenina Bello Principal', 'Bello Principal, Antioquia', 'Bello Principal', '3216481687', 'FEMENINA',
   'Dra. Mildrey Leonel Melo', '3216481687'),
('Sede Masculina Bello Campestre', 'Bello Campestre, Antioquia', 'Bello Campestre', '3145702708', 'MASCULINA',
   'Dr. Juan Camilo Machado', '3145702708'),
('Sede Masculina Apartadó', 'Apartadó, Antioquia', 'Apartadó', '3104577835', 'MASCULINA',
 'Martín Muñoz Pino', '3104577835'),
('Sede Femenina Apartadó', 'Apartadó, Antioquia', 'Apartadó', '3104577835', 'FEMENINA',
 'Dra. Luz Yasmin Estrada', '3104577835')
ON CONFLICT (ciudad, tipo_sede) DO NOTHING;

-- 3. USUARIO ADMINISTRADOR
-- Crear usuario administrador (password debe ser hasheada con BCrypt)
INSERT INTO usuarios (email, nombre, password_hash, rol) VALUES
('admin@todoporunalma.org', 'Administrador',
 '$2a$10$ejemplo.hash.bcrypt.password', 'ADMINISTRADOR')
ON CONFLICT (email) DO NOTHING;

-- ==========================================
-- CONSULTAS DE VERIFICACIÓN
-- ==========================================

-- Verificar fundación creada
SELECT 'Fundación creada:' as info, nombre, email FROM fundacion;

-- Verificar sedes creadas
SELECT 'Sedes creadas:' as info, nombre, ciudad, tipo_sede FROM sedes ORDER BY ciudad, tipo_sede;

-- Verificar usuario administrador
SELECT 'Usuario admin creado:' as info, email, rol FROM usuarios WHERE rol = 'ADMINISTRADOR';

-- Verificar estructura de tablas
SELECT 'Tablas creadas:' as info, table_name
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;



-- Script para insertar participantes en las sedes de Todo por un Alma
-- Este script debe ejecutarse después de crear las tablas y sedes básicas

-- ==========================================
-- OBTENER LOS IDs REALES DE LAS SEDES
-- ==========================================

-- Ver los IDs reales de las sedes creadas
SELECT
    id,
    nombre,
    ciudad,
    tipo_sede
FROM sedes
ORDER BY ciudad, tipo_sede;

-- ==========================================
-- INSERTAR PARTICIPANTES
-- ==========================================






-- ==========================================

-- ==========================================












-- ==========================================
-- VERIFICACIÓN DE INSERCIÓN
-- ==========================================

-- Verificar la inserción por sede
SELECT
    s.nombre as sede,
    s.ciudad,
    s.tipo_sede,
    COUNT(p.id) as total_participantes
FROM participantes p
JOIN sedes s ON p.sede_id = s.id
GROUP BY s.id, s.nombre, s.ciudad, s.tipo_sede
ORDER BY s.ciudad, s.tipo_sede;

-- Verificar total general
SELECT
    'TOTAL GENERAL' as sede,
    COUNT(*) as total_participantes
FROM participantes;

-- Mostrar algunos participantes de ejemplo
SELECT
    p.documento,
    p.nombres,
    p.apellidos,
    s.nombre as sede,
    s.ciudad,
    p.fecha_ingreso,
    p.estado
FROM participantes p
JOIN sedes s ON p.sede_id = s.id
ORDER BY s.ciudad, s.tipo_sede, p.documento
LIMIT 10;
