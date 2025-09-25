# Corporación Todo por un Alma — Monorepo Completo

**Sistema integral de gestión para fundaciones de rehabilitación y apoyo social**

Monorepo completo con API REST (Spring Boot), Frontend (React), base de datos PostgreSQL y configuración Docker para despliegue production-ready. Incluye gestión de participantes, mensualidades, archivos, sedes y sistema de usuarios con roles.

## 🏗️ Arquitectura del Sistema

### Componentes Principales

```
🏢 CORPORACIÓN TODO POR UN ALMA
├── 🔧 API Backend (Spring Boot 3 + Java 17)
│   ├── Arquitectura Hexagonal (Puertos y Adaptadores)
│   ├── Autenticación JWT con roles
│   ├── Gestión de participantes y mensualidades
│   ├── Sistema de archivos y documentos
│   └── API REST completa con Swagger
│
├── 🎨 Frontend (React + Nginx)
│   ├── Dashboard administrativo completo
│   ├── Gestión de archivos con drag & drop
│   ├── Interfaz responsive con Tailwind CSS
│   └── Integración completa con API
│
└── 🗄️ Base de Datos (PostgreSQL)
    ├── Esquema optimizado con índices
    ├── Triggers automáticos
    ├── Datos iniciales incluidos
    └── Configuración production-ready
```

### Tecnologías Utilizadas

- **Backend**: Spring Boot 3.5.6, Java 17, JPA/Hibernate, Spring Security, JWT
- **Frontend**: React 18, Create React App, Tailwind CSS, React Dropzone
- **Base de Datos**: PostgreSQL 15 con optimizaciones de rendimiento
- **Infraestructura**: Docker, Docker Compose, Nginx, Maven, Node.js
- **Documentación**: Swagger/OpenAPI, arquitectura hexagonal documentada

## 📊 Funcionalidades del Sistema

### 👥 Gestión de Participantes
- Registro completo de personas en rehabilitación
- Vinculación a sedes específicas
- Seguimiento de estado (Activo/Inactivo)
- Información personal y de contacto

### 💰 Control de Mensualidades
- Registro de pagos mensuales
- Estados: Pendiente, Pagada, Vencida
- Métodos de pago y observaciones
- Reportes y estadísticas

### 📁 Sistema de Archivos
- Subida de archivos con drag & drop (máx. 100MB)
- Organización por carpetas
- Metadatos completos (tipo, tamaño, fecha)
- Asociación con participantes

### 🏢 Administración de Sedes
- Múltiples centros de rehabilitación
- Tipos: Masculina, Femenina, Mixta
- Estados: Activa, Inactiva, Mantenimiento
- Información de directores y capacidad

### 👤 Sistema de Usuarios
- Autenticación JWT stateless
- Roles: Administrador, Consulta
- Control de permisos granular
- Gestión de sesiones seguras

## 📁 Estructura del Proyecto

```
corporacion/
├── 🗄️ database_setup.sql          # Configuración completa de BD (378 líneas)
├── 🐳 docker-compose.yml           # Orquestación de servicios
├── 🐳 Dockerfile.api               # Contenedor API
├── 🐳 Dockerfile.react             # Contenedor Frontend
├── 🌐 nginx.conf                   # Configuración Nginx
├── 🔧 .env.example                 # Variables de entorno template
├── 📋 README.md                    # Esta documentación
├── 📋 README-Docker.md             # Guía Docker detallada
│
├── 🔧 api/                         # Backend Spring Boot
│   ├── 📋 README.md                # Documentación API completa
│   ├── 📦 pom.xml                  # Dependencias Maven
│   └── 📁 src/main/java/org/todoporunalma/api/
│       ├── 🔐 domain/              # Núcleo del dominio
│       ├── ⚙️ application/         # Casos de uso
│       └── 🏗️ infrastructure/      # Adaptadores y configuración
│
└── 🎨 coptua_react/                # Frontend React
    ├── 📋 README.md                # Guía desarrollo local
    ├── 📦 package.json             # Dependencias Node.js
    └── 📁 src/
        ├── 🏠 pages/               # Páginas principales
        ├── 🧩 components/          # Componentes reutilizables
        ├── 🎣 hooks/               # Hooks personalizados
        └── 🌐 services/            # Servicios API
```

## Requisitos

- Docker y Docker Compose
- (Opcional para desarrollo local)
  - Java 17 (Temurin)
  - Node 22.x y npm 10+

## 🔐 Credenciales de Acceso

### Usuarios por Defecto

El sistema incluye usuarios pre-configurados para acceso inmediato:

| Usuario | Email | Contraseña | Rol | Permisos |
|---------|-------|------------|-----|----------|
| **Administrador** | `admin@todoporunalma.org` | `password` | ADMINISTRADOR | ✅ Lectura + Escritura + Gestión |
| **Consulta** | `consulta@todoporunalma.org` | `password` | CONSULTA | ✅ Solo Lectura |

### 🚀 Inicio Rápido con Docker

```bash
# 1. Clonar y configurar
git clone <repository-url>
cd corporacion
cp .env.example .env

# 2. Ejecutar aplicación completa
docker compose up -d --build

# 3. Acceder al sistema
# Frontend: http://localhost
# API Docs: http://localhost/api/swagger-ui.html
# Login con: admin@todoporunalma.org / password
```

## ⚙️ Variables de Entorno

### Archivo `.env` (Producción)

```bash
# Base de datos PostgreSQL
POSTGRES_DB=todoporunalma_db
POSTGRES_USER=todoporunalma_user
POSTGRES_PASSWORD=tu_password_seguro_aqui

# JWT - ¡IMPORTANTE: Cambiar en producción!
JWT_SECRET=tu_clave_jwt_muy_segura_de_al_menos_256_bits
JWT_EXPIRATION=86400000
JWT_REFRESH_EXPIRATION=604800000

# CORS - Configurar dominios permitidos
CORS_ALLOWED_ORIGINS=https://tudominio.com,https://api.tudominio.com

# Perfil de Spring Boot
SPRING_PROFILE=production
```

### Frontend (`.env.production`)

```bash
# URL base de la API (relativa para proxy Nginx)
REACT_APP_API_BASE_URL=/api

# URL del sitio (para metadatos y SEO)
REACT_APP_SITE_URL=https://tudominio.com
```

### 📝 Notas de Configuración

- **Seguridad**: Las claves JWT por defecto son solo para desarrollo
- **Base de datos**: Se inicializa automáticamente desde `database_setup.sql`
- **Archivos**: Límite de subida: 100MB por archivo
- **Variables**: Los archivos `.env` no se versionan por seguridad

## Inicio rápido (Docker)

1) Construir e iniciar servicios:
```
docker compose up -d --build
```

2) Ver estado:
```
docker compose ps
```

3) Endpoints de verificación rápida:
- Frontend: http://localhost/
- Health Frontend: http://localhost/health
- API (vía proxy del frontend): http://localhost/api/health
- API (directo al puerto): http://localhost:8080/api/health

4) Detener:
```
docker compose down
```

## Servicios y puertos

- Frontend (Nginx): puerto 80 (host) → `todoporunalma-frontend`
- API (Spring Boot): puerto 8080 (host) → `todoporunalma-api` (context-path `/api`)
- PostgreSQL: puerto 5432 (host) → `todoporunalma-postgres`

## Desarrollo local (opcional, sin Docker)

API:
```
cd api
./mvnw spring-boot:run
# o con Maven instalado:
mvn spring-boot:run
```

Asegúrate de que la API apunte a tu instancia de Postgres (por ejemplo, la del contenedor) y ajusta variables si es necesario:
- `spring.datasource.url=jdbc:postgresql://localhost:5432/todoporunalma_db`
- Usuario/clave según tu `.env`.

Frontend:
```
cd coptua_react
npm install
npm start
# Corre en http://localhost:3001
```

Para que el Frontend apunte a tu API local:
- Usar `REACT_APP_API_BASE_URL=http://localhost:8080/api` en entorno local.
- En producción/contendor, el valor por defecto `/api` funciona vía Nginx.

## 🗄️ Base de Datos

### Inicialización Automática

La base de datos se configura automáticamente al iniciar los contenedores:

- **Archivo principal**: `database_setup.sql` (378 líneas completas)
- **Contenido incluye**:
  - ✅ Creación de todas las tablas
  - ✅ Índices optimizados para rendimiento
  - ✅ Triggers automáticos para timestamps
  - ✅ Usuarios administrador y consulta
  - ✅ Datos de ejemplo (sedes, participantes)
  - ✅ Permisos y configuración de seguridad

### Características del Esquema

```sql
-- Arquitectura optimizada con:
-- • 6 tablas principales con relaciones FK
-- • Índices estratégicos en campos de búsqueda
-- • Triggers para auditoría automática
-- • Constraints de integridad referencial
-- • Datos iniciales para testing inmediato
```

### Configuración Flyway

- **Estado**: Deshabilitado en producción
- **Razón**: Inicialización directa desde SQL para mayor control
- **Alternativa**: Para desarrollo con Flyway, modificar `application-production.properties`

## Comandos útiles

- Logs:
```
docker compose logs -f api
docker compose logs -f frontend
docker compose logs -f postgres
```

- Reconstruir solo un servicio:
```
docker compose up -d --build api
docker compose up -d --build frontend
```

- Eliminar todo (contenedores y volumenes) — cuidado:
```
docker compose down -v
```

## Despliegue

- La configuración incluida permite ejecución local con Docker.
- Para producción con dominio/SSL, revisar/elaborar configuración en `nginx-proxy.conf` y montar certificados en `./ssl` (no versionados).

## Salud y documentación

- API Health: `GET /api/health`
- Swagger UI: `GET /api/swagger-ui.html`
- OpenAPI JSON: `GET /api/api-docs`

## Estructura de ramas

- Rama por defecto: `main`.

## Licencia

Sin licencia (a solicitud). Puedes añadirla más adelante si lo deseas.

---
