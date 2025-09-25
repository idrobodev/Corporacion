-- ====================================================================================================
-- CORPORACIÓN TODO POR UN ALMA - CONFIGURACIÓN COMPLETA DE BASE DE DATOS PARA PRODUCCIÓN
-- ====================================================================================================
-- Este archivo contiene toda la configuración necesaria para inicializar la base de datos
-- del sistema de gestión de la Corporación Todo por un Alma.
--
-- FUNCIONALIDADES PRINCIPALES:
-- - Gestión de participantes en proceso de rehabilitación
-- - Control de mensualidades y pagos
-- - Administración de múltiples sedes
-- - Sistema de archivos y documentos
-- - Control de usuarios y permisos
--
-- VERSION: 1.0.0
-- FECHA: 2025
-- AUTOR: Sistema de Gestión Todo por un Alma
-- ====================================================================================================

-- ====================================================================================================
-- 1. CONFIGURACIÓN INICIAL DEL SISTEMA
-- ====================================================================================================

-- Crear extensión para generación de UUIDs (requerido para IDs únicos)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Crear extensión para funciones criptográficas (para hashing de contraseñas)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Establecer zona horaria de Colombia
SET timezone = 'America/Bogota';

-- ====================================================================================================
-- 2. FUNCIÓN PARA ACTUALIZACIÓN AUTOMÁTICA DE TIMESTAMPS
-- ====================================================================================================
-- Esta función se ejecuta automáticamente antes de cualquier UPDATE
-- para mantener actualizados los campos created_at y updated_at

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- ====================================================================================================
-- 3. CREACIÓN DE TABLAS - ESTRUCTURA BASE DE DATOS
-- ====================================================================================================

-- ====================================================================================================
-- TABLA: fundacion
-- Propósito: Información general de la corporación
-- Usos: Configuración global, información de contacto, misión/visión
-- ====================================================================================================
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

-- ====================================================================================================
-- TABLA: sedes
-- Propósito: Gestión de las diferentes sedes de rehabilitación
-- Usos: Asignación de participantes, reportes por sede, capacidad
-- Notas: Restricción única por ciudad y tipo de sede
-- ====================================================================================================
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

-- ====================================================================================================
-- TABLA: usuarios
-- Propósito: Sistema de autenticación y control de acceso
-- Usos: Login, control de permisos, auditoría de acciones
-- Roles: ADMINISTRADOR (acceso total), CONSULTA (solo lectura)
-- ====================================================================================================
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

-- ====================================================================================================
-- TABLA: participantes
-- Propósito: Registro de personas en proceso de rehabilitación
-- Usos: Seguimiento individual, reportes, asignación a sedes
-- Relaciones: FK a sedes, FK desde mensualidades y archivos
-- ====================================================================================================
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

-- ====================================================================================================
-- TABLA: mensualidades
-- Propósito: Control de pagos mensuales por participante
-- Usos: Seguimiento de pagos, reportes financieros, alertas de vencimiento
-- Restricción: Una mensualidad por participante/mes/año
-- ====================================================================================================
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

-- ====================================================================================================
-- TABLA: archivos
-- Propósito: Gestión de documentos y archivos de participantes
-- Usos: Almacenamiento de documentos, organización por carpetas
-- Mejoras posibles: Integración con storage cloud (S3, etc.)
-- ====================================================================================================
CREATE TABLE IF NOT EXISTS archivos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(255) NOT NULL,
    ruta VARCHAR(500) NOT NULL,
    url VARCHAR(500),
    mime_type VARCHAR(100),
    tamaño BIGINT,
    carpeta VARCHAR(255),
    participante_id UUID REFERENCES participantes(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ====================================================================================================
-- 4. CREACIÓN DE ÍNDICES - OPTIMIZACIÓN DE CONSULTAS
-- ====================================================================================================
-- Índices para mejorar rendimiento en consultas frecuentes

-- Índices para participantes
CREATE INDEX IF NOT EXISTS idx_participantes_sede ON participantes(sede_id);
CREATE INDEX IF NOT EXISTS idx_participantes_estado ON participantes(estado);
CREATE INDEX IF NOT EXISTS idx_participantes_documento ON participantes(documento);

-- Índices para mensualidades
CREATE INDEX IF NOT EXISTS idx_mensualidades_participante ON mensualidades(participante_id);
CREATE INDEX IF NOT EXISTS idx_mensualidades_fecha ON mensualidades(mes, anio);
CREATE INDEX IF NOT EXISTS idx_mensualidades_estado ON mensualidades(estado);

-- Índices para usuarios
CREATE UNIQUE INDEX IF NOT EXISTS uniq_usuarios_email ON usuarios(email);

-- Índices para archivos
CREATE INDEX IF NOT EXISTS idx_archivos_participante ON archivos(participante_id);

-- ====================================================================================================
-- 5. CREACIÓN DE TRIGGERS - AUTOMATIZACIÓN
-- ====================================================================================================
-- Triggers para actualización automática de timestamps

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
    FOR EACH ROW EXECUTE FUNCTION update_participantes_updated_at();

DROP TRIGGER IF EXISTS update_mensualidades_updated_at ON mensualidades;
CREATE TRIGGER update_mensualidades_updated_at
    BEFORE UPDATE ON mensualidades
    FOR EACH ROW EXECUTE FUNCTION update_mensualidades_updated_at();

DROP TRIGGER IF EXISTS update_archivos_updated_at ON archivos;
CREATE TRIGGER update_archivos_updated_at
    BEFORE UPDATE ON archivos
    FOR EACH ROW EXECUTE FUNCTION update_archivos_updated_at();

-- ====================================================================================================
-- 6. INSERCIÓN DE DATOS INICIALES
-- ====================================================================================================

-- ====================================================================================================
-- DATOS DE LA FUNDACIÓN
-- ====================================================================================================
INSERT INTO fundacion (nombre, nit, direccion, telefono, email, website, mision, vision) VALUES
('Corporación Todo por un Alma', '900123456-7', 'Bello, Antioquia, Colombia',
 '3145702708', 'info@todoporunalma.org', 'https://todoporunalma.org',
 'Brindar apoyo integral a personas en proceso de rehabilitación por adicciones, ofreciendo un entorno seguro y profesional que promueva la recuperación física, mental y espiritual.',
 'Ser referente nacional en rehabilitación y reinserción social, reconocido por nuestra excelencia en el tratamiento integral de adicciones y nuestro compromiso con la transformación de vidas.')
ON CONFLICT (nit) DO NOTHING;

-- ====================================================================================================
-- SEDES DE REHABILITACIÓN
-- Notas: Cada sede tiene capacidad máxima y director asignado
-- Mejora posible: Agregar coordenadas GPS para mapas
-- ====================================================================================================
INSERT INTO sedes (nombre, direccion, ciudad, telefono, tipo_sede, director_nombre, director_telefono, capacidad_maxima) VALUES
('Sede Masculina Bello Principal', 'Bello Principal, Antioquia', 'Bello Principal', '3145702708', 'MASCULINA', 'Dr. Juan Camilo Machado', '3145702708', 35),
('Sede Femenina Bello Principal', 'Bello Principal, Antioquia', 'Bello Principal', '3216481687', 'FEMENINA', 'Dra. Mildrey Leonel Melo', '3216481687', 30),
('Sede Masculina Bello Campestre', 'Bello Campestre, Antioquia', 'Bello Campestre', '3145702708', 'MASCULINA', 'Dr. Juan Camilo Machado', '3145702708', 40),
('Sede Masculina Apartadó', 'Apartadó, Antioquia', 'Apartadó', '3104577835', 'MASCULINA', 'Martín Muñoz Pino', '3104577835', 25),
('Sede Femenina Apartadó', 'Apartadó, Antioquia', 'Apartadó', '3104577835', 'FEMENINA', 'Dra. Luz Yasmin Estrada', '3104577835', 25)
ON CONFLICT (ciudad, tipo_sede) DO NOTHING;

-- ====================================================================================================
-- USUARIOS DEL SISTEMA
-- Notas: Contraseñas hasheadas con BCrypt (cost=10)
-- Usuario admin: password = "password"
-- Usuario consulta: password = "password"
-- Mejora posible: Implementar política de contraseñas, 2FA
-- ====================================================================================================
INSERT INTO usuarios (email, nombre, password_hash, rol) VALUES
('admin@todoporunalma.org', 'Administrador del Sistema', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', 'ADMINISTRADOR'),
('consulta@todoporunalma.org', 'Usuario de Consulta', '$2a$10$8K1p/a0dURdOFNfAOcXOOOxNfhkP5Le9Bb1GlVb5ttj.SA3/TS/jC', 'CONSULTA')
ON CONFLICT (email) DO NOTHING;

-- ====================================================================================================
-- PARTICIPANTES DE EJEMPLO
-- Notas: Datos ficticios para testing y demostración
-- Mejora posible: Implementar importación masiva desde Excel/CSV
-- ====================================================================================================
INSERT INTO participantes (documento, nombres, apellidos, fecha_nacimiento, telefono, email, direccion, sede_id, fecha_ingreso, observaciones)
SELECT
    '12345678',
    'Juan Carlos',
    'Pérez García',
    '1990-05-15',
    '3001234567',
    'juan.perez@email.com',
    'Calle 123 #45-67, Bello',
    s.id,
    '2024-01-15',
    'Participante en fase inicial de tratamiento. Buen progreso en terapia grupal.'
FROM sedes s WHERE s.nombre = 'Sede Masculina Bello Principal' LIMIT 1
ON CONFLICT (documento) DO NOTHING;

INSERT INTO participantes (documento, nombres, apellidos, fecha_nacimiento, telefono, email, direccion, sede_id, fecha_ingreso, observaciones)
SELECT
    '87654321',
    'María Elena',
    'González López',
    '1985-08-22',
    '3009876543',
    'maria.gonzalez@email.com',
    'Carrera 45 #12-34, Bello',
    s.id,
    '2024-01-20',
    'Participante con 2 meses en tratamiento. Excelente compromiso con el programa.'
FROM sedes s WHERE s.nombre = 'Sede Femenina Bello Principal' LIMIT 1
ON CONFLICT (documento) DO NOTHING;

-- ====================================================================================================
-- MENSUALIDADES DE EJEMPLO
-- Notas: Configuración de pagos mensuales
-- Mejora posible: Sistema de recordatorios automáticos, integración con pasarelas de pago
-- ====================================================================================================
INSERT INTO mensualidades (participante_id, mes, anio, monto, fecha_vencimiento, estado, metodo_pago)
SELECT
    p.id,
    1, -- Enero
    2025,
    150000.00,
    '2025-01-31',
    'PENDIENTE',
    NULL
FROM participantes p WHERE p.documento = '12345678'
ON CONFLICT (participante_id, mes, anio) DO NOTHING;

INSERT INTO mensualidades (participante_id, mes, anio, monto, fecha_vencimiento, fecha_pago, estado, metodo_pago)
SELECT
    p.id,
    12, -- Diciembre 2024
    2024,
    150000.00,
    '2024-12-31',
    '2024-12-28',
    'PAGADA',
    'Transferencia bancaria'
FROM participantes p WHERE p.documento = '87654321'
ON CONFLICT (participante_id, mes, anio) DO NOTHING;

-- ====================================================================================================
-- 7. PERMISOS Y CONFIGURACIÓN DE SEGURIDAD
-- ====================================================================================================

-- Otorgar permisos al usuario de la aplicación
-- Nota: Ajustar 'todoporunalma_user' según configuración de Docker
GRANT ALL PRIVILEGES ON DATABASE todoporunalma_db TO todoporunalma_user;
GRANT ALL PRIVILEGES ON SCHEMA public TO todoporunalma_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO todoporunalma_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO todoporunalma_user;

-- Permisos para futuras tablas
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO todoporunalma_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO todoporunalma_user;

-- ====================================================================================================
-- 8. CONSULTAS DE VERIFICACIÓN
-- ====================================================================================================

-- Verificar fundación
SELECT '✅ Fundación creada:' as status, nombre, email FROM fundacion;

-- Verificar sedes
SELECT '✅ Sedes activas:' as status, COUNT(*) as total, ciudad, tipo_sede
FROM sedes
WHERE estado = 'ACTIVA'
GROUP BY ciudad, tipo_sede
ORDER BY ciudad, tipo_sede;

-- Verificar usuarios
SELECT '✅ Usuarios del sistema:' as status, email, rol, activo
FROM usuarios
ORDER BY rol, email;

-- Verificar participantes
SELECT '✅ Participantes activos:' as status, COUNT(*) as total
FROM participantes
WHERE estado = 'ACTIVO';

-- Verificar mensualidades
SELECT '✅ Estado de mensualidades:' as status, estado, COUNT(*) as cantidad
FROM mensualidades
GROUP BY estado
ORDER BY estado;

-- Verificar estructura de tablas
SELECT '✅ Tablas del sistema:' as status, table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- ====================================================================================================
-- 9. POSIBLES MEJORAS Y OPTIMIZACIONES FUTURAS
-- ====================================================================================================

/*
MEJORAS SUGERIDAS PARA VERSIONES FUTURAS:

1. **SEGURIDAD Y AUTENTICACIÓN:**
   - Implementar JWT con refresh tokens
   - Agregar 2FA (autenticación de dos factores)
   - Política de contraseñas robusta
   - Auditoría de accesos y cambios

2. **GESTIÓN DE ARCHIVOS:**
   - Integración con servicios cloud (AWS S3, Google Cloud Storage)
   - Compresión automática de imágenes
   - Antivirus para archivos subidos
   - Versionado de documentos

3. **FINANZAS Y REPORTES:**
   - Integración con pasarelas de pago
   - Sistema de facturación automática
   - Reportes avanzados con gráficos
   - Exportación a PDF/Excel

4. **ESCALABILIDAD:**
   - Particionamiento de tablas grandes
   - Caché Redis para consultas frecuentes
   - Replicación de base de datos
   - Balanceo de carga

5. **FUNCIONALIDADES ADICIONALES:**
   - API REST completa
   - Aplicación móvil
   - Sistema de notificaciones
   - Integración con redes sociales

6. **MONITOREO Y LOGGING:**
   - Métricas de rendimiento
   - Alertas automáticas
   - Logs centralizados
   - Health checks avanzados

7. **BACKUP Y RECUPERACIÓN:**
   - Estrategias de backup automáticas
   - Point-in-time recovery
   - Replicación geográfica

INSTRUCCIONES DE DEPLOYMENT:

1. Ejecutar este script en una base de datos PostgreSQL vacía
2. Verificar que las extensiones uuid-ossp y pgcrypto estén disponibles
3. Configurar las credenciales de usuario de aplicación
4. Ejecutar las consultas de verificación al final
5. Probar el login con las credenciales de administrador

*/

-- ====================================================================================================
-- FIN DEL ARCHIVO DE CONFIGURACIÓN
-- ====================================================================================================