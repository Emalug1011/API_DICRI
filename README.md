# API DICRI – Backend (Gestión de Evidencias)

Este proyecto corresponde al **backend del sistema DICRI**, encargado de la gestión de expedientes, indicios, usuarios, autenticación y flujos de aprobación.  
Incluye documentación completa en **Swagger (OpenAPI 3.0.3)**, integración con **SQL Server**, seguridad con **JWT** , trazabilidad y obserbabilidad con **api google logging** y despliegue mediante **Docker**.

---

## 📌 Características principales

- Gestión completa de **expedientes** (creación, filtros, estados, auditoría).
- Administración de **indicios** asociados a cada expediente.
- Sistema de **usuarios** con roles y autenticación JWT.
- Flujos de aprobación con validación de estados permitidos.
- Resumen estadístico de expedientes por estado.
- Middleware de seguridad, logs y manejo de errores.
- Integración con **Google Cloud Logging**.
- Documentación auto-generada con **Swagger UI**.
- Contenerización con **Docker** y **docker-compose**.

---

# 🚀 Instalación y ejecución local

### 1. Clonar el repositorio

```bash
git clone <URL_DEL_REPO>
cd API_DICRI
```

---

## 2. Configurar variables de entorno

Crear archivo:

```
.env
```

Con:

```env
PORT=3001

# SQL Server
DB_SERVER=127.0.0.1
DB_USER=sa
DB_PASSWORD= 
DB_NAME=bd_dicri_evidencias

# JWT
JWT_SECRET= 

# Google Logging
GOOGLE_APPLICATION_CREDENTIALS= 
GCP_PROJECT_ID= 
```


---

# 🐳 Ejecución con Docker

### 1. Construir backend

```bash
docker build -t dicri-backend .
```

### 2. Levantar backend + SQL Server

```bash
docker compose up --build
```

### 3. Acceso a la API

```
http://localhost:3001/api
```

### 4. Swagger UI

```
http://localhost:3001/api-docs
```

---

# 📘 Documentación Swagger (OpenAPI)

La API cuenta con una definición completa basada en:

```
openapi: 3.0.3
title: API DICRI - Gestión de Evidencias
version: "1.0.0"
```

Incluye:

### ✔ Expedientes
- Crear expediente  
- Listar expedientes  
- Filtro avanzado  
- Obtener expediente completo  
- Cambiar estado  
- Auditoría  
- Resumen por estado  
- Expedientes del usuario autenticado  

### ✔ Indicios
- Crear indicio  
- Listar indicios  
- Cambiar estado  

### ✔ Usuarios
- Crear usuario  
- Listar usuarios  
- Obtener por ID  
- Actualizar  
- Cambiar contraseña  

### ✔ Autenticación
- Login de usuario  
- Emisión de token JWT  

---

# 📂 Estructura del proyecto

```
src/
 ├── config/
 ├── controllers/
 ├── middleware/
 ├── routes/
 ├── services/
 ├── utils/
app.js
server.js
Dockerfile
docker-compose.yml
swagger.yaml
```

---

# 🧪 Scripts útiles

### Ejecutar en modo desarrollo
```bash
npm run dev
```

### Ejecutar en modo producción
```bash
npm start
```

---

# 🛡 Seguridad

- Autenticación mediante **Bearer Token (JWT)**.
- Middleware que valida:
  - Token activo
  - Rol del usuario
  - Permisos sobre expedientes

---

# 📊 Integración con Google Logging

Para obtener el detalle de solicitudes al API y errores customizables:
 

---

# 📝 Notas importantes

- Este backend está diseñado para ser consumido por el **Frontend DICRI**.
- El sistema implementa flujos estrictos de aprobación.
- Los estados siguen las reglas definidas en la tabla `TC_FlujosPermitidos`.

---

# 👨‍💻 Autor
Desarrollado por **Emanuel Mazariegos** como parte del sistema DICRI (Gestión de Evidencias).


