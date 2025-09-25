# Corporación — Monorepo (API Spring Boot + Frontend React)

Monorepo listo para ejecución con Docker de la API (Spring Boot) y el Frontend (React + Nginx). Incluye orquestación con docker-compose, base de datos PostgreSQL y configuración para desarrollo local y despliegue sencillo.

## Estructura del proyecto

```
.
├── docker-compose.yml
├── docker-compose.dev.yml
├── Dockerfile.api
├── Dockerfile.react
├── nginx.conf
├── nginx-proxy.conf
├── .env.example
├── .env               # (no se versiona)
├── .env.production    # (no se versiona)
├── .gitignore
├── .gitattributes
├── api/               # API Spring Boot
│   ├── pom.xml
│   └── src/
└── coptua_react/      # Frontend React (Create React App + craco)
    ├── package.json
    ├── .env.production
    └── src/
```

- API: Spring Boot 3, Java 17, JPA/Hibernate, Security (JWT), Flyway (deshabilitado en Docker por seed externo).
- Frontend: React (CRA + craco), Nginx como servidor estático y reverse proxy para `/api`.
- DB: PostgreSQL 15-alpine con inicialización mediante scripts en `./init-db`.

## Requisitos

- Docker y Docker Compose
- (Opcional para desarrollo local)
  - Java 17 (Temurin)
  - Node 22.x y npm 10+

## Variables de entorno

Archivo `.env` (raíz) basado en `.env.example`:

```
# Base de datos
POSTGRES_DB=todoporunalma_db
POSTGRES_USER=todoporunalma_user
POSTGRES_PASSWORD=todoporunalma_pass

# JWT
JWT_SECRET=CAMBIA-ESTO-EN-PRODUCCION
JWT_EXPIRATION=86400000
JWT_REFRESH_EXPIRATION=604800000

# CORS
CORS_ALLOWED_ORIGINS=http://localhost, http://localhost:3000, http://localhost:3001, https://todoporunalma.org

# Perfil Spring Boot
SPRING_PROFILE=production
```

Frontend (`coptua_react/.env.production`):
```
REACT_APP_API_BASE_URL=/api
REACT_APP_SITE_URL=https://todoporunalma.org
```

Notas:
- En Docker, el Frontend usa Nginx y proxyea `/api` al contenedor de la API (servicio `api`).
- No se versionan `.env`, `.env.production` ni carpetas de IDE (ver `.gitignore`). Se mantiene `.env.example`.

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

## Base de datos e inicialización

- Los scripts de inicialización están en `./init-db/` y son ejecutados por el contenedor de Postgres en el primer arranque del volumen.
- Flyway en la API está deshabilitado para evitar conflictos con la inicialización externa. Si quieres usar Flyway en otro entorno (DB vacía), habilita:
  - En `api/src/main/resources/application-production.properties`
    ```
    spring.flyway.enabled=true
    ```
  - Retira `SPRING_FLYWAY_ENABLED=false` del `docker-compose.yml` y asegúrate de no tener datos conflictivos.

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
