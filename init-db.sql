-- Tabla de usuarios para autenticación
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'CONSULTA',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar usuario administrador por defecto
INSERT INTO users (email, password_hash, role) VALUES
('admin@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LeCt1uB0Y4M5YXIKi', 'ADMINISTRADOR'),
('consulta@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LeCt1uB0Y4M5YXIKi', 'CONSULTA');

-- Tabla de sedes
CREATE TABLE sedes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    telefono VARCHAR(20),
    capacidad_maxima INTEGER,
    estado VARCHAR(20) NOT NULL DEFAULT 'Activa',
    tipo VARCHAR(20) DEFAULT 'Principal',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de participantes
CREATE TABLE participantes (
    id SERIAL PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    tipo_documento VARCHAR(20) NOT NULL,
    numero_documento VARCHAR(50) UNIQUE NOT NULL,
    fecha_nacimiento VARCHAR(10) NOT NULL,
    genero VARCHAR(20) NOT NULL,
    fecha_ingreso VARCHAR(10) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    id_sede INTEGER NOT NULL REFERENCES sedes(id),
    telefono VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de acudientes
CREATE TABLE acudientes (
    id_acudiente SERIAL PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    tipo_documento VARCHAR(20) NOT NULL,
    numero_documento VARCHAR(50) UNIQUE NOT NULL,
    parentesco VARCHAR(50) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    id_participante INTEGER NOT NULL REFERENCES participantes(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de usuarios
CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    rol VARCHAR(20) NOT NULL DEFAULT 'CONSULTA',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de mensualidades
CREATE TABLE mensualidades (
    id SERIAL PRIMARY KEY,
    participant_id INTEGER NOT NULL REFERENCES participantes(id),
    id_acudiente INTEGER REFERENCES acudientes(id_acudiente),
    mes INTEGER NOT NULL,
    año INTEGER NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    metodo_pago VARCHAR(20) NOT NULL DEFAULT 'TRANSFERENCIA',
    fecha_pago VARCHAR(10),
    observaciones TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos de ejemplo
INSERT INTO sedes (id, nombre, direccion, telefono, capacidad_maxima, estado, tipo) VALUES
(1, 'Bello Principal', 'Calle 50 #45-30, Bello, Antioquia', '6044567890', 50, 'Activa', 'Principal'),
(2, 'Bello Campestre', 'Carrera 60 #30-15, Bello, Antioquia', '6044567891', 30, 'Activa', 'Secundaria'),
(3, 'Apartadó', 'Avenida Principal #20-10, Apartadó, Antioquia', '6048281234', 40, 'Activa', 'Principal');

INSERT INTO usuarios (id_usuario, email, rol) VALUES
(1, 'admin@example.com', 'ADMINISTRADOR'),
(2, 'consulta@example.com', 'CONSULTA');

INSERT INTO participantes (id, nombres, apellidos, tipo_documento, numero_documento, fecha_nacimiento, genero, fecha_ingreso, estado, id_sede, telefono) VALUES
(1, 'María José', 'García López', 'CC', '12345678', '2010-05-15', 'Femenino', '2023-01-15', 'ACTIVO', 1, '3001234567'),
(2, 'Carlos Andrés', 'Martínez Rodríguez', 'CC', '87654321', '2009-08-22', 'Masculino', '2023-02-01', 'ACTIVO', 1, '3007654321'),
(3, 'Ana Sofía', 'Hernández Gómez', 'CC', '11223344', '2011-03-10', 'Femenino', '2023-03-15', 'ACTIVO', 2, '3012345678'),
(4, 'Juan Pablo', 'Torres Sánchez', 'CC', '44332211', '2008-11-05', 'Masculino', '2023-01-20', 'ACTIVO', 3, '3023456789'),
(5, 'Valentina', 'Ramírez Castro', 'CC', '55667788', '2012-07-18', 'Femenino', '2023-04-01', 'ACTIVO', 1, '3034567890'),
(6, 'Santiago', 'Morales Vargas', 'CC', '88776655', '2007-12-03', 'Masculino', '2023-02-15', 'ACTIVO', 2, '3045678901'),
(7, 'Isabella', 'Jiménez Peña', 'CC', '99887766', '2010-09-25', 'Femenino', '2023-03-01', 'ACTIVO', 3, '3056789012'),
(8, 'Mateo', 'Ortiz Díaz', 'CC', '66554433', '2009-04-12', 'Masculino', '2023-01-10', 'ACTIVO', 1, '3067890123'),
(9, 'Lucía', 'Gutiérrez Silva', 'CC', '33445566', '2011-01-28', 'Femenino', '2023-04-15', 'ACTIVO', 2, '3078901234'),
(10, 'Daniel', 'Ruiz Mendoza', 'CC', '77889900', '2008-06-30', 'Masculino', '2023-02-20', 'ACTIVO', 3, '3089012345');

INSERT INTO acudientes (id_acudiente, nombres, apellidos, tipo_documento, numero_documento, parentesco, telefono, email, direccion, id_participante) VALUES
(1, 'Carmen', 'García', 'CC', '11111111', 'Madre', '3001111111', 'carmen.garcia@email.com', 'Calle 50 #45-30, Bello', 1),
(2, 'Roberto', 'Martínez', 'CC', '22222222', 'Padre', '3002222222', 'roberto.martinez@email.com', 'Carrera 60 #30-15, Bello', 2),
(3, 'Patricia', 'Hernández', 'CC', '33333333', 'Madre', '3003333333', 'patricia.hernandez@email.com', 'Avenida Principal #20-10, Apartadó', 3),
(4, 'Luis', 'Torres', 'CC', '44444444', 'Padre', '3004444444', 'luis.torres@email.com', 'Calle 50 #45-30, Bello', 4),
(5, 'Sandra', 'Ramírez', 'CC', '55555555', 'Madre', '3005555555', 'sandra.ramirez@email.com', 'Carrera 60 #30-15, Bello', 5),
(6, 'Miguel', 'Morales', 'CC', '66666666', 'Padre', '3006666666', 'miguel.morales@email.com', 'Avenida Principal #20-10, Apartadó', 6),
(7, 'Claudia', 'Jiménez', 'CC', '77777777', 'Madre', '3007777777', 'claudia.jimenez@email.com', 'Calle 50 #45-30, Bello', 7),
(8, 'Fernando', 'Ortiz', 'CC', '88888888', 'Padre', '3008888888', 'fernando.ortiz@email.com', 'Carrera 60 #30-15, Bello', 8),
(9, 'Diana', 'Gutiérrez', 'CC', '99999999', 'Madre', '3009999999', 'diana.gutierrez@email.com', 'Avenida Principal #20-10, Apartadó', 9),
(10, 'Andrés', 'Ruiz', 'CC', '10101010', 'Padre', '3010101010', 'andres.ruiz@email.com', 'Calle 50 #45-30, Bello', 10);

INSERT INTO mensualidades (participant_id, id_acudiente, mes, año, monto, estado, metodo_pago, fecha_pago, observaciones) VALUES
(1, 1, 1, 2024, 150000, 'PAGADO', 'TRANSFERENCIA', '2024-01-15', 'Pago completo'),
(1, 1, 2, 2024, 150000, 'PAGADO', 'EFECTIVO', '2024-02-15', 'Pago en efectivo'),
(1, 1, 3, 2024, 150000, 'PENDIENTE', 'TRANSFERENCIA', NULL, 'Pendiente de pago'),
(2, 2, 1, 2024, 150000, 'PAGADO', 'TRANSFERENCIA', '2024-01-20', 'Pago completo'),
(2, 2, 2, 2024, 150000, 'PAGADO', 'CHEQUE', '2024-02-20', 'Pago con cheque'),
(2, 2, 3, 2024, 150000, 'PENDIENTE', 'TRANSFERENCIA', NULL, 'Pendiente de pago'),
(3, 3, 1, 2024, 140000, 'PAGADO', 'TRANSFERENCIA', '2024-01-18', 'Pago completo'),
(3, 3, 2, 2024, 140000, 'PENDIENTE', 'TRANSFERENCIA', NULL, 'Pendiente de pago'),
(4, 4, 1, 2024, 160000, 'PAGADO', 'EFECTIVO', '2024-01-22', 'Pago en efectivo'),
(4, 4, 2, 2024, 160000, 'PAGADO', 'TRANSFERENCIA', '2024-02-22', 'Pago completo'),
(5, 5, 1, 2024, 130000, 'PENDIENTE', 'TRANSFERENCIA', NULL, 'Pendiente de pago'),
(6, 6, 1, 2024, 170000, 'PAGADO', 'TRANSFERENCIA', '2024-01-25', 'Pago completo'),
(7, 7, 1, 2024, 145000, 'PAGADO', 'CHEQUE', '2024-01-28', 'Pago con cheque'),
(8, 8, 1, 2024, 155000, 'PENDIENTE', 'TRANSFERENCIA', NULL, 'Pendiente de pago'),
(9, 9, 1, 2024, 135000, 'PAGADO', 'EFECTIVO', '2024-01-30', 'Pago en efectivo'),
(10, 10, 1, 2024, 165000, 'PAGADO', 'TRANSFERENCIA', '2024-01-31', 'Pago completo');

-- Tabla de archivos
CREATE TABLE files (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    ruta VARCHAR(1000),
    tamaño BIGINT NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    categoria VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de carpetas
CREATE TABLE folders (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    ruta VARCHAR(1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar carpetas por defecto
INSERT INTO folders (id, nombre, ruta, created_at) VALUES
(1, 'Documentos', '', '2024-01-15T10:00:00'),
(2, 'Imágenes', '', '2024-01-16T11:00:00'),
(3, 'Reportes', 'Documentos/', '2024-01-17T12:00:00');

-- Insertar archivos de ejemplo
INSERT INTO files (id, nombre, ruta, tamaño, tipo, categoria, created_at, updated_at) VALUES
(1, 'manual_usuario.pdf', 'Documentos/', 2048000, 'application/pdf', 'documento', '2024-01-15T10:30:00', '2024-01-15T10:30:00'),
(2, 'logo.png', 'Imágenes/', 512000, 'image/png', 'imagen', '2024-01-16T11:15:00', '2024-01-16T11:15:00'),
(3, 'datos.xlsx', 'Documentos/', 1024000, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'documento', '2024-01-17T12:30:00', '2024-01-17T12:30:00'),
(4, 'reporte_mensual.docx', 'Documentos/Reportes/', 1536000, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'documento', '2024-01-18T13:00:00', '2024-01-18T13:00:00'),
(5, 'banner.jpg', 'Imágenes/', 768000, 'image/jpeg', 'imagen', '2024-01-19T14:00:00', '2024-01-19T14:00:00');