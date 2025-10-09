-- Create databases for each service
SELECT 'CREATE DATABASE auth_db'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'auth_db')\gexec

SELECT 'CREATE DATABASE dashboard_db'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'dashboard_db')\gexec

SELECT 'CREATE DATABASE formatos_db'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'formatos_db')\gexec

-- Grant permissions to postgres user on all databases
GRANT ALL PRIVILEGES ON DATABASE auth_db TO postgres;
GRANT ALL PRIVILEGES ON DATABASE dashboard_db TO postgres;
GRANT ALL PRIVILEGES ON DATABASE formatos_db TO postgres;

-- Connect to auth database and create tables
\c auth_db;

-- Create tables for auth service
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'CONSULTA',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Connect to dashboard database and create tables
\c dashboard_db;

-- Create tables for dashboard service
CREATE TABLE IF NOT EXISTS sedes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    telefono VARCHAR(20),
    capacidad_maxima INTEGER,
    estado VARCHAR(20) DEFAULT 'Activa',
    tipo VARCHAR(20) DEFAULT 'Principal',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS participantes (
    id SERIAL PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    tipo_documento VARCHAR(20) NOT NULL,
    numero_documento VARCHAR(50) UNIQUE NOT NULL,
    fecha_nacimiento VARCHAR(10) NOT NULL,
    genero VARCHAR(20) NOT NULL,
    fecha_ingreso VARCHAR(10) NOT NULL,
    estado VARCHAR(20) DEFAULT 'ACTIVO',
    id_sede INTEGER REFERENCES sedes(id),
    telefono VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS acudientes (
    id_acudiente SERIAL PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    tipo_documento VARCHAR(20) NOT NULL,
    numero_documento VARCHAR(50) UNIQUE NOT NULL,
    parentesco VARCHAR(50) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    id_participante INTEGER REFERENCES participantes(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS mensualidades (
    id SERIAL PRIMARY KEY,
    participant_id INTEGER REFERENCES participantes(id),
    id_acudiente INTEGER REFERENCES acudientes(id_acudiente),
    mes INTEGER NOT NULL,
    año INTEGER NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    estado VARCHAR(20) DEFAULT 'PENDIENTE',
    metodo_pago VARCHAR(20) DEFAULT 'TRANSFERENCIA',
    fecha_pago VARCHAR(10),
    observaciones TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(participant_id, mes, año)
);

-- Connect to formatos database and create tables
\c formatos_db;

-- Create tables for formatos service
CREATE TABLE IF NOT EXISTS files (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    ruta VARCHAR(1000),
    tamaño BIGINT NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    categoria VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS folders (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    ruta VARCHAR(1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default data for dashboard database
\c dashboard_db;

-- Insert default data for sedes
INSERT INTO sedes (id, nombre, direccion, telefono, capacidad_maxima, estado, tipo) VALUES
(1, 'Bello Principal', 'Calle 50 #45-30, Bello, Antioquia', '6044567890', 50, 'Activa', 'Principal'),
(2, 'Bello Campestre', 'Carrera 60 #30-15, Bello, Antioquia', '6044567891', 30, 'Activa', 'Secundaria'),
(3, 'Apartadó', 'Avenida Principal #20-10, Apartadó, Antioquia', '6048281234', 40, 'Activa', 'Principal')
ON CONFLICT (id) DO NOTHING;

-- Insert default data for participantes
INSERT INTO participantes (id, nombres, apellidos, tipo_documento, numero_documento, fecha_nacimiento, genero, fecha_ingreso, estado, id_sede, telefono) VALUES
(1, 'Juan Carlos', 'Pérez Gómez', 'CC', '1234567890', '2010-05-15', 'MASCULINO', '2023-01-10', 'ACTIVO', 1, '3001234567'),
(2, 'María Fernanda', 'López Martínez', 'TI', '1234567891', '2012-08-20', 'FEMENINO', '2023-02-15', 'ACTIVO', 1, '3001234568'),
(3, 'Carlos Andrés', 'Rodríguez Silva', 'CC', '1234567892', '2011-03-10', 'MASCULINO', '2023-03-20', 'ACTIVO', 2, '3001234569'),
(4, 'Ana Sofía', 'García Torres', 'TI', '1234567893', '2013-11-25', 'FEMENINO', '2023-04-05', 'ACTIVO', 2, '3001234570'),
(5, 'Luis Miguel', 'Hernández Ruiz', 'CC', '1234567894', '2010-07-18', 'MASCULINO', '2023-05-12', 'ACTIVO', 3, '3001234571'),
(6, 'Laura Valentina', 'Moreno Castro', 'TI', '1234567895', '2012-09-30', 'FEMENINO', '2023-06-18', 'ACTIVO', 3, '3001234572'),
(7, 'Diego Alejandro', 'Ramírez Vargas', 'CC', '1234567896', '2011-12-05', 'MASCULINO', '2023-07-22', 'INACTIVO', 1, '3001234573'),
(8, 'Camila Andrea', 'Sánchez Ortiz', 'TI', '1234567897', '2013-04-14', 'FEMENINO', '2023-08-10', 'ACTIVO', 2, '3001234574'),
(9, 'Santiago', 'Jiménez Parra', 'CC', '1234567898', '2010-10-22', 'MASCULINO', '2023-09-15', 'ACTIVO', 3, '3001234575'),
(10, 'Isabella', 'Cruz Mendoza', 'TI', '1234567899', '2012-06-08', 'FEMENINO', '2023-10-20', 'ACTIVO', 1, '3001234576')
ON CONFLICT (id) DO NOTHING;

-- Insert default data for acudientes
INSERT INTO acudientes (id_acudiente, nombres, apellidos, tipo_documento, numero_documento, parentesco, telefono, email, direccion, id_participante) VALUES
(1, 'Roberto', 'Pérez González', 'CC', '9876543210', 'Padre', '3101234567', 'roberto.perez@example.com', 'Calle 45 #30-20, Bello', 1),
(2, 'Patricia', 'López Ramírez', 'CC', '9876543211', 'Madre', '3101234568', 'patricia.lopez@example.com', 'Carrera 50 #25-15, Bello', 2),
(3, 'Jorge', 'Rodríguez Pérez', 'CC', '9876543212', 'Padre', '3101234569', 'jorge.rodriguez@example.com', 'Avenida 60 #40-30, Bello', 3),
(4, 'Sandra', 'García Morales', 'CC', '9876543213', 'Madre', '3101234570', 'sandra.garcia@example.com', 'Calle 55 #35-25, Bello', 4),
(5, 'Fernando', 'Hernández López', 'CC', '9876543214', 'Padre', '3101234571', 'fernando.hernandez@example.com', 'Carrera 70 #20-10, Apartadó', 5),
(6, 'Gloria', 'Moreno Díaz', 'CC', '9876543215', 'Madre', '3101234572', 'gloria.moreno@example.com', 'Avenida Principal #15-20, Apartadó', 6),
(7, 'Andrés', 'Ramírez Castro', 'CC', '9876543216', 'Tío', '3101234573', 'andres.ramirez@example.com', 'Calle 48 #32-18, Bello', 7),
(8, 'Claudia', 'Sánchez Vargas', 'CC', '9876543217', 'Madre', '3101234574', 'claudia.sanchez@example.com', 'Carrera 65 #28-12, Bello', 8)
ON CONFLICT (id_acudiente) DO NOTHING;

-- Insert default data for mensualidades
INSERT INTO mensualidades (id, participant_id, id_acudiente, mes, año, monto, estado, metodo_pago, fecha_pago, observaciones) VALUES
(1, 1, 1, 1, 2024, 50000.00, 'PAGADA', 'TRANSFERENCIA', '2024-01-05', 'Pago puntual'),
(2, 1, 1, 2, 2024, 50000.00, 'PAGADA', 'EFECTIVO', '2024-02-03', NULL),
(3, 2, 2, 1, 2024, 50000.00, 'PAGADA', 'TRANSFERENCIA', '2024-01-08', NULL),
(4, 2, 2, 2, 2024, 50000.00, 'PENDIENTE', 'TRANSFERENCIA', NULL, 'Pendiente de pago'),
(5, 3, 3, 1, 2024, 45000.00, 'PAGADA', 'EFECTIVO', '2024-01-10', NULL),
(6, 4, 4, 1, 2024, 50000.00, 'PAGADA', 'TRANSFERENCIA', '2024-01-12', NULL),
(7, 5, 5, 1, 2024, 55000.00, 'PAGADA', 'TRANSFERENCIA', '2024-01-15', NULL),
(8, 5, 5, 2, 2024, 55000.00, 'PENDIENTE', 'TRANSFERENCIA', NULL, NULL),
(9, 6, 6, 1, 2024, 50000.00, 'PAGADA', 'EFECTIVO', '2024-01-18', NULL),
(10, 8, 8, 1, 2024, 50000.00, 'PAGADA', 'TRANSFERENCIA', '2024-01-20', NULL),
(11, 9, NULL, 1, 2024, 50000.00, 'PAGADA', 'EFECTIVO', '2024-01-22', 'Pago directo'),
(12, 10, NULL, 1, 2024, 50000.00, 'PENDIENTE', 'TRANSFERENCIA', NULL, NULL),
(13, 3, 3, 2, 2024, 45000.00, 'PENDIENTE', 'EFECTIVO', NULL, NULL),
(14, 4, 4, 2, 2024, 50000.00, 'PENDIENTE', 'TRANSFERENCIA', NULL, NULL),
(15, 6, 6, 2, 2024, 50000.00, 'PAGADA', 'EFECTIVO', '2024-02-18', NULL)
ON CONFLICT (id) DO NOTHING;

-- Insert default data for formatos database
\c formatos_db;

-- Insert default data for folders
INSERT INTO folders (id, nombre, ruta, created_at) VALUES
(1, 'Documentos', '', '2024-01-15T10:00:00Z'),
(2, 'Imágenes', '', '2024-01-16T11:00:00Z'),
(3, 'Reportes', 'Documentos/', '2024-01-17T12:00:00Z')
ON CONFLICT (id) DO NOTHING;

-- Insert default data for files
INSERT INTO files (id, nombre, ruta, tamaño, tipo, categoria, created_at, updated_at) VALUES
(1, 'manual_usuario.pdf', 'Documentos/', 2048000, 'application/pdf', 'documento', '2024-01-15T10:30:00Z', '2024-01-15T10:30:00Z'),
(2, 'logo.png', 'Imágenes/', 512000, 'image/png', 'imagen', '2024-01-16T11:15:00Z', '2024-01-16T11:15:00Z'),
(3, 'datos.xlsx', 'Documentos/', 1024000, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'documento', '2024-01-17T12:30:00Z', '2024-01-17T12:30:00Z'),
(4, 'reporte_mensual.docx', 'Documentos/Reportes/', 1536000, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'documento', '2024-01-18T13:00:00Z', '2024-01-18T13:00:00Z'),
(5, 'banner.jpg', 'Imágenes/', 768000, 'image/jpeg', 'imagen', '2024-01-19T14:00:00Z', '2024-01-19T14:00:00Z')
ON CONFLICT (id) DO NOTHING;

-- Insert default users for auth database
\c auth_db;

-- Insert default users for auth
INSERT INTO users (id, email, password_hash, role) VALUES
(1, 'admin@example.com', '2cc658bba61a6053db1cf676a8ad0f78b0e82d7220d363ba2130c93b4cceff21', 'ADMINISTRADOR'),
(2, 'consulta@example.com', 'ec6af8148ba6c21a38ae66834072e1ec73c3d42049e94005154068cee4817fbd', 'CONSULTA')
ON CONFLICT (id) DO NOTHING;