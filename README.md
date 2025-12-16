# 🎮 Sistema de Gestión para Videojuego Medieval — Flask + PostgreSQL + Supabase

Este proyecto es una aplicación web completa para gestionar jugadores, personajes, mascotas, inventarios, gremios, logros y elementos esenciales de un videojuego con temática medieval.

Incluye autenticación segura, panel de lobby dinámico, CRUDs completos, APIs JSON, arquitectura modular con SQLAlchemy ORM, protección contra inyección SQL y migración automática de contraseñas.

---

## 🛑 1. Problemática

Un estudio de videojuegos enfrentaba un problema serio: sus datos estaban desorganizados. No existía un sistema que:

- Gestionara jugadores de forma segura
- Permitiera crear/editar personajes y mascotas
- Manejara inventarios con diferentes tipos de objetos
- Administrara gremios y membresías
- Mostrara logros y progreso de jugadores
- Permitiera generar reportes de rendimiento

Esto producía:

- ❌ Pérdida de datos
- ❌ Errores en estadísticas del juego
- ❌ Problemas al gestionar eventos
- ❌ Fallas al iniciar sesión o consultar información
- ❌ Información inconsistente entre jugadores y personajes

Era necesario crear un sistema centralizado, seguro y escalable.

---

## 🎯 2. Objetivo del Proyecto

Desarrollar una plataforma web robusta que permita:

- ✔ Registro e inicio de sesión seguro con migración automática de contraseñas
- ✔ Manejo de contraseñas encriptadas (Werkzeug + PostgreSQL crypt)
- ✔ CRUD completo de personajes
- ✔ CRUD completo de mascotas
- ✔ Sistema de inventario multi-categoría (pociones, armas, armaduras)
- ✔ Gestión de gremios (crear, unirse, abandonar)
- ✔ Sistema de logros desbloqueables
- ✔ Selección de personaje y mascota activa
- ✔ Lobby dinámico con datos del jugador en tiempo real
- ✔ API REST para integraciones futuras del juego
- ✔ Seguridad contra SQL Injection mediante ORM
- ✔ Conexión optimizada con pool y auto-reconexión

---

## 🧱 3. Tecnologías Utilizadas

### 🔹 Flask (Backend Web)
Framework ligero y rápido. Maneja autenticación, rutas, sesiones y lógica de negocio. Perfecto para aplicaciones web con estructura modular.

### 🔹 SQLAlchemy ORM
Mapeo objeto-relacional que protege contra SQL Injection y simplifica las consultas a la base de datos. Proporciona relaciones automáticas entre modelos.

### 🔹 Flask-SQLAlchemy
Integración de SQLAlchemy con Flask, facilitando la configuración y uso del ORM.

### 🔹 Werkzeug Security
Sistema de hashing de contraseñas moderno (pbkdf2/scrypt) con migración automática desde PostgreSQL crypt.

### 🔹 Jinja2 (Motor de Plantillas)
Permite mezclar HTML con variables de Python, renderizando dinámicamente la interfaz del juego.

### 🔹 PostgreSQL
Base de datos relacional robusta, ideal para modelos con múltiples entidades relacionadas y consultas complejas.

### 🔹 Supabase
Hosting de PostgreSQL con funciones avanzadas de seguridad: `crypt()`, `gen_salt()`, hashing tipo Blowfish, etc.

### 🔹 Render.com
Alojamiento del backend Flask con despliegue automático desde GitHub y variables de entorno seguras.

### 🔹 Bootstrap + CSS personalizado
Utilizado para el diseño visual responsivo de todas las pantallas del juego.

---

## 📁 4. Estructura de Archivos del Proyecto

```
PROYECTO/
│
├── .dist/
│
├── static/
│   ├── css/
│   │   └── estilo.css
│   │
│   ├── img/
│   │   └── icons/
│   │       ├── icono.png
│   │       └── iconoSF.png
│   │
│   ├── fondolobby.jpg
│   ├── mascota01.png
│   └── personaje01.png
│
├── js/
│   └── scripts.js
│
├── templates/
│   ├── dashboard.html
│   ├── gremio.html
│   ├── inventario.html
│   ├── lobby.html
│   ├── login.html
│   ├── logros.html
│   ├── mascotas.html
│   ├── personajes.html
│   └── registro.html
│
├── venv/
│
├── .env
├── .gitignore
├── config.py
├── README.md
├── requirements.txt
└── videojuego.py
```

## 📝 Descripción de Carpetas y Archivos

### 📂 `/static`
Contiene todos los archivos estáticos del proyecto (CSS, imágenes, recursos).

- **`/css`** - Hojas de estilo
  - `estilo.css` - Estilos personalizados del proyecto

- **`/img`** - Imágenes y recursos visuales
  - **`/icons`** - Iconos de la aplicación
    - `icono.png` - Icono principal
    - `iconoSF.png` - Icono sin fondo
  - `fondolobby.jpg` - Imagen de fondo del lobby
  - `mascota01.png` - Imagen de mascota ejemplo
  - `personaje01.png` - Imagen de personaje ejemplo

### 📂 `/js`
Scripts JavaScript del cliente.

- `scripts.js` - Lógica JavaScript para interactividad (CRUD, fetch API)

### 📂 `/templates`
Plantillas HTML renderizadas por Jinja2.

- `dashboard.html` - Panel de control principal
- `gremio.html` - Gestión de gremios (crear, unirse, abandonar)
- `inventario.html` - Sistema de inventario multi-categoría
- `lobby.html` - Sala de espera/menú principal con personaje activo
- `login.html` - Página de inicio de sesión con migración de contraseñas
- `logros.html` - Sistema de logros desbloqueables
- `mascotas.html` - CRUD completo de mascotas
- `personajes.html` - CRUD completo de personajes
- `registro.html` - Página de registro con validación

### 📂 `/venv`
Entorno virtual de Python (no se sube a Git).

### 📄 Archivos raíz

- **`.dist/`** - Carpeta de distribución/build
- **`.env`** - Variables de entorno (DATABASE_URL, SECRET_KEY)
- **`.gitignore`** - Archivos ignorados por Git
- **`config.py`** - Configuración de la aplicación y base de datos
- **`README.md`** - Documentación del proyecto (este archivo)
- **`requirements.txt`** - Dependencias de Python
- **`videojuego.py`** - Aplicación principal Flask con todos los modelos y rutas

### 📌 Flujo general

1. Usuario accede a `/login` o `/registro`
2. Sistema valida credenciales y migra contraseñas antiguas automáticamente
3. Inicia sesión → sesión segura con Flask
4. Accede al Lobby → ve su personaje y mascota activa
5. Puede crear/editar personajes y mascotas
6. Gestiona inventario (pociones, armas, armaduras)
7. Se une o crea gremios
8. Desbloquea logros
9. APIs JSON disponibles para integraciones futuras

---

## 🧬 5. Modelo Relacional de la Base de Datos

### 🧔 Tabla: Jugador
- `id_jugador` (PK)
- `nombre_usuario`
- `correo_electronico` (UNIQUE)
- `contrasena_hash`
- `id_personaje_activo` (FK → Personaje)
- `id_mascota_activa` (FK → Mascota)

**Relaciones:**
- 1:N con Personaje
- N:M con Gremio (via Pertenece)
- N:M con Logro (via Obtiene)

### ⚔ Tabla: Personaje
- `id_personaje` (PK)
- `id_jugador` (FK → Jugador)
- `nombre`
- `clase` (Guerrero, Mago, Arquero, etc.)
- `nivel` (default: 1)

**Relaciones:**
- N:1 con Jugador
- 1:N con Mascota
- N:M con Objeto (via Inventario)

### 🐾 Tabla: Mascota
- `id_mascota` (PK)
- `id_personaje` (FK → Personaje)
- `nombre_mascota`
- `tipo` (Dragón, Lobo, Fénix, etc.)
- `nivel` (default: 1)

**Relaciones:**
- N:1 con Personaje

### 🛡 Tabla: Objeto
- `id_objeto` (PK)
- `nombre`
- `descripcion`
- `valor` (precio en oro)
- `rareza` (Común, Rara, Épica, Legendaria)

**Relaciones:**
- 1:1 con Pocion, Arma o Armadura (herencia)
- N:M con Personaje (via Inventario)

#### Subtipos (Herencia 1:1)

**Pocion**
- `id_objeto` (PK, FK → Objeto)
- `efecto` (Restaurar vida, aumentar maná, etc.)

**Arma**
- `id_objeto` (PK, FK → Objeto)
- `dano_base` (daño base del arma)

**Armadura**
- `id_objeto` (PK, FK → Objeto)
- `valor_defensa` (puntos de defensa)

### 🏅 Tabla: Logro
- `id_logro` (PK)
- `nombre_logro`
- `descripcion_logro`

**Relaciones:**
- N:M con Jugador (via Obtiene)

### 🏰 Tabla: Gremio
- `id_gremio` (PK)
- `nombre`
- `fecha_fundacion`

**Relaciones:**
- N:M con Jugador (via Pertenece)

---

## 🔗 6. Tablas Asociativas

### 🔹 Pertenece (Jugador ↔ Gremio)
- `id_jugador` (PK, FK → Jugador)
- `id_gremio` (PK, FK → Gremio)

**Restricción:** Un jugador solo puede pertenecer a un gremio a la vez.

### 🔹 Inventario (Personaje ↔ Objeto)
- `id_personaje` (PK, FK → Personaje)
- `id_objeto` (PK, FK → Objeto)
- `cantidad` (número de unidades del objeto)

### 🔹 Obtiene (Jugador ↔ Logro)
- `id_jugador` (PK, FK → Jugador)
- `id_logro` (PK, FK → Logro)

---

## 🛡️ 7. Seguridad Implementada

El proyecto incluye medidas de seguridad esenciales para una aplicación en producción:

### ✔ 1. Prevención de Inyección SQL con ORM

Usamos SQLAlchemy ORM, que parametriza automáticamente todas las consultas:

```python
# ❌ NUNCA hagas esto (vulnerable)
query = f"SELECT * FROM jugador WHERE correo = '{correo}'"

# ✅ Usa ORM (seguro)
jugador = Jugador.query.filter_by(correo_electronico=correo).first()
```

- ✔ Variables separadas de la consulta
- ✔ SQLAlchemy protege automáticamente los parámetros
- ✔ No hay concatenación de strings en SQL

### ✔ 2. Sistema de Contraseñas Híbrido

**Migración automática de contraseñas:**

```python
# Hash nuevo (Werkzeug)
if jugador.contrasena_hash.startswith("pbkdf2:") or jugador.contrasena_hash.startswith("scrypt:"):
    if check_password_hash(jugador.contrasena_hash, contrasena):
        # Login exitoso
        
# Hash viejo (PostgreSQL crypt) - Migración automática
else:
    result = db.session.execute(
        text("SELECT id_jugador FROM jugador WHERE id_jugador = :id AND contrasena_hash = crypt(:pass, contrasena_hash)"),
        {"id": jugador.id_jugador, "pass": contrasena}
    ).fetchone()
    
    if result:
        # Rehashear con Werkzeug
        jugador.contrasena_hash = generate_password_hash(contrasena)
        db.session.commit()
```

**Nuevos registros:**
```python
hash_password = generate_password_hash(contrasena)
```

### ✔ 3. Sesiones seguras con secret key

```python
app.secret_key = os.getenv("SECRET_KEY", "clave_segura_para_sesiones")
```

- ✔ Cookies firmadas y encriptadas
- ✔ Secret key almacenada en variables de entorno

### ✔ 4. Validación de acceso en cada ruta

Cada ruta protegida verifica la sesión activa:

```python
if 'id_jugador' not in session:
    flash("Debes iniciar sesión primero.", "warning")
    return redirect(url_for('login'))
```

### ✔ 5. Pool de conexiones con auto-reconexión

```python
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    "pool_pre_ping": True,      # 🔥 detecta conexiones muertas
    "pool_recycle": 280,        # 🔁 recicla conexiones cada 280s
}
```

- ✔ Detecta conexiones muertas antes de usarlas
- ✔ Recicla conexiones automáticamente
- ✔ Evita errores por timeout de Supabase

### ✔ 6. Validación de pertenencia de recursos

Antes de editar/eliminar, se valida que el recurso pertenezca al usuario:

```python
if personaje.id_jugador != session['id_jugador']:
    return jsonify({"error": "Acción no permitida"}), 403
```

---

## 🚦 8. Rutas Principales

### 🔐 Autenticación

| Ruta | Método | Descripción |
|------|--------|-------------|
| `/` | GET | Redirige a login |
| `/login` | GET/POST | Iniciar sesión con migración de contraseñas |
| `/registro` | GET/POST | Registrar nuevo jugador |
| `/logout` | GET | Cerrar sesión y limpiar datos |

### 🏠 Lobby y Dashboard

| Ruta | Método | Descripción |
|------|--------|-------------|
| `/lobby` | GET | Panel principal con personaje y mascota activa |

### 🧙 Personajes

| Ruta | Método | Descripción |
|------|--------|-------------|
| `/personajes` | GET/POST | Listar, crear y editar personajes |
| `/eliminar_personaje/<id>` | DELETE | Eliminar personaje (AJAX) |
| `/seleccionar_personaje/<id>` | POST | Activar personaje seleccionado |

### 🐾 Mascotas

| Ruta | Método | Descripción |
|------|--------|-------------|
| `/mascotas` | GET/POST | Listar, crear y editar mascotas |
| `/eliminar_mascota/<id>` | DELETE | Eliminar mascota (AJAX) |
| `/seleccionar_mascota/<id>` | POST | Activar mascota seleccionada |

### 🎒 Inventario

| Ruta | Método | Descripción |
|------|--------|-------------|
| `/inventario/pociones` | GET/POST | Gestionar pociones |
| `/inventario/armas` | GET/POST | Gestionar armas |
| `/inventario/armaduras` | GET/POST | Gestionar armaduras |

**Acciones disponibles:**
- ➕ Agregar objeto existente
- 🆕 Crear nuevo objeto
- ➕ Aumentar cantidad
- ➖ Disminuir cantidad
- 🗑️ Eliminar del inventario

### 🏰 Gremios

| Ruta | Método | Descripción |
|------|--------|-------------|
| `/gremio` | GET | Ver gremio actual o lista de gremios |
| `/crear_gremio` | POST | Crear nuevo gremio |
| `/unirse_gremio/<id>` | POST | Unirse a un gremio |
| `/abandonar_gremio` | POST | Salir del gremio actual |

### 🏅 Logros

| Ruta | Método | Descripción |
|------|--------|-------------|
| `/logros` | GET | Ver logros desbloqueados y bloqueados |

### 🔧 API JSON

| Ruta | Descripción |
|------|-------------|
| `/api/personaje/<id>` | Retorna datos del personaje en JSON |
| `/api/mascota/<id>` | Retorna datos de la mascota en JSON |

### 🛠 Pruebas y Mantenimiento

| Ruta | Descripción |
|------|-------------|
| `/test-db` | Verifica conexión con la base de datos |
| `/test-jugador` | Prueba consulta ORM de jugador |

---

## 🧪 9. Cómo Ejecutar el Proyecto Localmente

### 1️⃣ Clonar repositorio

```bash
git clone https://github.com/usuario/proyecto-videojuego.git
cd proyecto-videojuego
```

### 2️⃣ Crear entorno virtual

```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

### 3️⃣ Instalar dependencias

```bash
pip install -r requirements.txt
```

### 4️⃣ Crear archivo `.env`

```env
DATABASE_URL=postgresql://usuario:password@host:puerto/database
SECRET_KEY=tu-clave-secreta-super-segura
```

### 5️⃣ Configurar la base de datos

Asegúrate de que las tablas estén creadas en PostgreSQL/Supabase. Puedes usar:

```python
from videojuego import db, app

with app.app_context():
    db.create_all()
```

### 6️⃣ Ejecutar la aplicación

```bash
python videojuego.py
```

La aplicación estará disponible en: `http://127.0.0.1:5000`

---

## 🌐 10. Despliegue en Render + Supabase

### 📘 Configuración de Supabase

1. **Crear proyecto en Supabase**
2. **Copiar la cadena de conexión:** Settings → Database → Connection String
3. **Habilitar extensión pgcrypto** (para migración de contraseñas antiguas):
   ```sql
   CREATE EXTENSION IF NOT EXISTS pgcrypto;
   ```
4. **Crear las tablas** usando el esquema del modelo relacional

### 🚀 Configuración de Render

1. **Crear nuevo Web Service**
2. **Conectar repositorio de GitHub**
3. **Configurar variables de entorno:**
   ```
   DATABASE_URL=postgresql://...
   SECRET_KEY=clave-super-segura
   ```
4. **Configurar Build Command:**
   ```bash
   pip install -r requirements.txt
   ```
5. **Configurar Start Command:**
   ```bash
   gunicorn videojuego:app
   ```

### 📦 Agregar `gunicorn` a requirements.txt

```txt
Flask==3.0.0
Flask-SQLAlchemy==3.1.1
psycopg2-binary==2.9.9
python-dotenv==1.0.0
gunicorn==21.2.0
```

### ✅ Verificar despliegue

Una vez desplegado, accede a:
```
https://tu-proyecto.onrender.com
```

---

## 🎮 11. Funcionalidades Implementadas

### ✔ Sistema de Autenticación
- Login seguro con migración automática de contraseñas
- Registro con validación de correo único
- Hash de contraseñas con Werkzeug (pbkdf2/scrypt)
- Soporte para contraseñas antiguas con PostgreSQL crypt
- Sesiones seguras con Flask

### ✔ Gestión de Personajes
- CRUD completo (Crear, Leer, Actualizar, Eliminar)
- Selección de personaje activo
- Visualización en lobby
- API JSON para consultas

### ✔ Gestión de Mascotas
- CRUD completo vinculado al personaje activo
- Selección de mascota activa
- Validación de pertenencia
- Tipos personalizables (Dragón, Lobo, Fénix, etc.)

### ✔ Sistema de Inventario
- Gestión multi-categoría (Pociones, Armas, Armaduras)
- Agregar objetos existentes
- Crear nuevos objetos con atributos especiales
- Control de cantidades
- Sistema de rareza (Común, Rara, Épica, Legendaria)

### ✔ Sistema de Gremios
- Crear nuevos gremios
- Unirse a gremios existentes
- Ver miembros del gremio
- Abandonar gremio
- Restricción: un jugador por gremio

### ✔ Sistema de Logros
- Visualización de logros desbloqueados
- Estado de progreso
- Sistema extensible para nuevas mecánicas

### ✔ Arquitectura y Seguridad
- SQLAlchemy ORM (prevención de SQL Injection)
- Pool de conexiones con auto-reconexión
- Validación de sesiones en todas las rutas protegidas
- Validación de pertenencia de recursos
- Manejo de errores con rollback automático
- Flash messages para feedback al usuario

### ✔ APIs REST
- `/api/personaje/<id>` - Datos del personaje
- `/api/mascota/<id>` - Datos de la mascota
- Respuestas en formato JSON

---
# 🐳 12. Contenerización con Docker

El proyecto fue dockerizado para garantizar **portabilidad, consistencia entre entornos y facilidad de despliegue en producción**.

La aplicación se ejecuta dentro de un contenedor Docker que incluye:

- ✔ Entorno Python aislado
- ✔ Instalación automática de dependencias
- ✔ Servidor de producción Gunicorn
- ✔ Configuración mediante variables de entorno

---

## 📦 Dockerfile

El contenedor utiliza una imagen ligera de Python y ejecuta la aplicación con Gunicorn:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["gunicorn", "-b", "0.0.0.0:5000", "videojuego:app"]
```

### 🔍 Explicación del Dockerfile

| Línea | Descripción |
|-------|-------------|
| `FROM python:3.11-slim` | Imagen base ligera de Python 3.11 |
| `WORKDIR /app` | Establece `/app` como directorio de trabajo |
| `ENV PYTHONDONTWRITEBYTECODE=1` | Evita crear archivos `.pyc` (optimización) |
| `ENV PYTHONUNBUFFERED=1` | Logs en tiempo real sin buffering |
| `COPY requirements.txt .` | Copia el archivo de dependencias |
| `RUN pip install --no-cache-dir -r requirements.txt` | Instala dependencias sin cache |
| `COPY . .` | Copia todo el código de la aplicación |
| `CMD ["gunicorn", "-b", "0.0.0.0:5000", "videojuego:app"]` | Ejecuta Gunicorn en puerto 5000 |

---

## 🧩 docker-compose.yml (entorno local)

Para desarrollo local se utiliza **Docker Compose**, permitiendo levantar el proyecto con un solo comando:

```yaml
services:
  web:
    build: .
    container_name: videojuego_flask
    ports:
      - "5000:5000"
    env_file:
      - .env
    volumes:
      - .:/app
```

### 🔍 Explicación del docker-compose.yml

| Parámetro | Descripción |
|-----------|-------------|
| `build: .` | Construye la imagen desde el Dockerfile local |
| `container_name: videojuego_flask` | Nombre del contenedor |
| `ports: "5000:5000"` | Mapea el puerto 5000 del contenedor al host |
| `env_file: .env` | Carga variables de entorno desde `.env` |
| `volumes: .:/app` | Sincroniza cambios del código en tiempo real |

---

## ▶️ Ejecución local con Docker

### 1️⃣ Construir la imagen

```bash
docker compose build
```

### 2️⃣ Levantar el contenedor

```bash
docker compose up
```

### 3️⃣ Acceder a la aplicación

La aplicación queda disponible en:

```
http://localhost:5000
```

### 🛑 Detener el contenedor

```bash
docker compose down
```

---

## 🎯 Ventajas de Docker en este proyecto

| Ventaja | Descripción |
|---------|-------------|
| ✔ **Portabilidad** | Funciona igual en Windows, Mac y Linux |
| ✔ **Consistencia** | Mismo entorno en desarrollo y producción |
| ✔ **Aislamiento** | No interfiere con otras instalaciones de Python |
| ✔ **Despliegue rápido** | Se despliega en segundos en cualquier servidor |
| ✔ **Escalabilidad** | Fácil de replicar en múltiples instancias |

---

# 🌐 12. Despliegue en Producción (Render + Supabase)

El sistema fue desplegado exitosamente en la nube utilizando **Render**, conectándose a una base de datos PostgreSQL alojada en **Supabase**.

---

## 🚀 Flujo de despliegue

```mermaid
graph LR
    A[GitHub Repository] --> B[Render detecta Dockerfile]
    B --> C[Build automático]
    C --> D[Deploy con Gunicorn]
    D --> E[Conexión a Supabase]
    E --> F[Aplicación en producción]
```

### Pasos del despliegue:

1. **El código fuente se aloja en GitHub**
2. **Render detecta automáticamente el `Dockerfile`**
3. **Cada `git push` ejecuta un nuevo despliegue (CI/CD)**
4. **Las variables sensibles se configuran en Render**
5. **Supabase actúa como base de datos externa segura**

---

## 🔐 Variables de entorno en producción

Configuradas directamente en el panel de Render:

```env
DATABASE_URL=postgresql://user:password@host:port/database
SECRET_KEY=clave-super-segura-generada-aleatoriamente
```

⚠️ **Importante:** El archivo `.env` **NO se sube al repositorio** por motivos de seguridad (incluido en `.gitignore`).

---

## 🏗️ Configuración en Render

### 1️⃣ Crear nuevo Web Service

1. Inicia sesión en [Render](https://render.com)
2. Haz clic en **"New +"** → **"Web Service"**
3. Conecta tu repositorio de GitHub

### 2️⃣ Configurar el servicio

| Campo | Valor |
|-------|-------|
| **Name** | `videojuego-medieval` |
| **Region** | Selecciona la más cercana |
| **Branch** | `main` |
| **Root Directory** | (dejar vacío) |
| **Runtime** | `Docker` |
| **Build Command** | (automático) |
| **Start Command** | (automático desde Dockerfile) |

### 3️⃣ Agregar variables de entorno

En la sección **"Environment"** agrega:

```
DATABASE_URL = postgresql://...
SECRET_KEY = tu-clave-secreta
```

### 4️⃣ Deploy

Haz clic en **"Create Web Service"** y espera el despliegue automático.

---

## 📊 Arquitectura en producción

```
┌─────────────┐
│   Usuario   │
└──────┬──────┘
       │ HTTPS
       ↓
┌─────────────────┐
│  Render (Web)   │
│   Flask App     │
│   + Gunicorn    │
└────────┬────────┘
         │ PostgreSQL
         ↓
┌─────────────────┐
│    Supabase     │
│   PostgreSQL    │
│  (Base de datos)│
└─────────────────┘
```

---

## 🌍 Acceso a la aplicación

Una vez desplegado, el sistema es accesible desde una **URL pública proporcionada por Render**, permitiendo su uso en un entorno real de producción.

Ejemplo de URL:
```
https://videojuego-medieval.onrender.com
```

---

## 🔄 CI/CD Automático

Render ofrece **integración continua** sin configuración adicional:

- ✔ Cada `git push` a la rama principal desencadena un nuevo build
- ✔ Se construye la imagen Docker automáticamente
- ✔ Se despliega la nueva versión sin downtime
- ✔ Rollback automático si falla el despliegue

---

## 📈 Monitoreo y Logs

Render proporciona herramientas de monitoreo integradas:

- **Logs en tiempo real** desde el dashboard
- **Métricas de CPU y memoria**
- **Alertas de disponibilidad**
- **Historial de despliegues**

Acceso a logs:
```bash
# Desde el dashboard de Render
Logs → Ver logs en tiempo real
```

---

## 🛡️ Seguridad en producción

| Medida | Implementación |
|--------|----------------|
| ✔ **HTTPS** | Certificado SSL gratuito por defecto |
| ✔ **Variables de entorno** | Almacenadas de forma segura en Render |
| ✔ **Conexión a BD** | Cifrada con SSL/TLS (Supabase) |
| ✔ **Firewall** | Solo puertos necesarios expuestos |
| ✔ **Hashing de contraseñas** | Werkzeug + migración automática |
| ✔ **Prevención SQL Injection** | SQLAlchemy ORM |

---

## 🚦 Estado del servicio

Puedes verificar el estado del servicio en:

```
https://videojuegobd.onrender.com/test-db
```

Respuesta esperada:
```json
{
  "status": "ok",
  "database": "connected"
}
```

---
## 🪪 12. Licencia

Este proyecto está desarrollado con fines educativos.  
Libre para estudiar, modificar y mejorar.
---

**¡Gracias por explorar este proyecto! 🎮⚔️🐉**