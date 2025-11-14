# 🎮 Sistema de Gestión para Videojuego Medieval — Flask + PostgreSQL + Supabase

Este proyecto es una aplicación web completa para gestionar jugadores, personajes, mascotas, inventarios, logros y elementos esenciales de un videojuego con temática medieval.

Incluye autenticación segura, panel de lobby dinámico, CRUDs completos, APIs JSON, arquitectura modular, protección contra inyección SQL y un cron que evita que la base de datos se "duerma".

---

## 🛑 1. Problemática

Un estudio de videojuegos enfrentaba un problema serio: sus datos estaban desorganizados. No existía un sistema que:

- Gestionara jugadores de forma segura
- Permitiera crear/editar personajes
- Manejara inventarios y mascotas
- Mostrara estadísticas confiables
- Identificara jugadores activos/inactivos
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

- ✔ Registro e inicio de sesión seguro
- ✔ Manejo de contraseñas encriptadas
- ✔ CRUD de personajes
- ✔ CRUD de mascotas
- ✔ Selección de personaje y mascota activa
- ✔ Lobby dinámico con datos del jugador
- ✔ API REST para integraciones futuras del juego
- ✔ Seguridad contra SQL Injection
- ✔ Conexión optimizada con pool
- ✔ Mantener la base despierta con cron-job

---

## 🧱 3. Tecnologías Utilizadas

### 🔹 Flask (Backend Web)
Framework ligero y rápido. Maneja autenticación, rutas, sesiones y lógica de negocio. Perfecto para aplicaciones web con estructura modular.

### 🔹 Jinja2 (Motor de Plantillas)
Permite mezclar HTML con variables de Python, renderizando la interfaz del juego.

### 🔹 PostgreSQL
Base de datos relacional robusta, ideal para modelos con múltiples entidades relacionadas.

### 🔹 Supabase
Hosting de PostgreSQL con funciones avanzadas de seguridad: `crypt()`, `gen_salt()`, hashing tipo Blowfish, etc.

### 🔹 Render.com
Alojamiento del backend Flask con despliegue automático desde GitHub.

### 🔹 Cron-job.org
Servicio que realiza peticiones a `/ping` cada pocos minutos para evitar que PostgreSQL se duerma.

### 🔹 Bootstrap / CSS personalizado
Utilizado para el diseño visual de pantallas del juego.

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

- `scripts.js` - Lógica JavaScript para interactividad

### 📂 `/templates`
Plantillas HTML renderizadas por Jinja2.

- `dashboard.html` - Panel de control principal
- `gremio.html` - Gestión de gremios
- `inventario.html` - Sistema de inventario
- `lobby.html` - Sala de espera/menú principal
- `login.html` - Página de inicio de sesión
- `logros.html` - Sistema de logros
- `mascotas.html` - CRUD de mascotas
- `personajes.html` - CRUD de personajes
- `registro.html` - Página de registro

### 📂 `/venv`
Entorno virtual de Python (no se sube a Git).

### 📄 Archivos raíz

- **`.dist/`** - Carpeta de distribución/build
- **`.env`** - Variables de entorno (DATABASE_URL, SECRET_KEY)
- **`.gitignore`** - Archivos ignorados por Git
- **`README.md`** - Documentación del proyecto
- **`requirements.txt`** - Dependencias de Python
- **`videojuego.py`** - Aplicación principal Flask (app.py)

### 📌 Flujo general

1. Usuario accede a `/login`
2. Inicia sesión → sesión segura iniciada
3. Accede al Lobby
4. Puede crear/editar personajes y mascotas
5. Se muestran los datos del jugador en tiempo real
6. APIs disponibles para integraciones futuras

---

## 🧬 5. Modelo Relacional de la Base de Datos

### 🧔 Tabla: Jugador
- `id_jugador` (PK)
- `nombre_usuario`
- `correo_electronico` (UNIQUE)
- `contrasena_hash`
- `experiencia`
- `nivel`
- `fecha_hora`
- `direccion_ip`
- `id_personaje_activo` (FK)
- `id_mascota_activa` (FK)

### ⚔ Tabla: Personaje
- `id_personaje` (PK)
- `id_jugador` (FK → Jugador)
- `nombre`
- `clase`
- `nivel`

### 🐾 Tabla: Mascota
- `id_mascota` (PK)
- `id_personaje` (FK → Personaje)
- `nombre_mascota`
- `tipo`
- `nivel`

### 🛡 Tabla: Objeto
- `id_objeto` (PK)
- `nombre`
- `descripcion`
- `valor`
- `rareza`

#### Subtipos (Herencia 1:1)

**Pocion**
- `id_objeto` (PK, FK)
- `efecto`

**Arma**
- `id_objeto` (PK, FK)
- `dano_base`

**Armadura**
- `id_objeto` (PK, FK)
- `valor_defensa`

### ✨ Tabla: Habilidad
- `id_habilidad` (PK)
- `nombre_habilidad`
- `descripcion_habilidad`

### 🏅 Tabla: Logro
- `id_logro` (PK)
- `nombre_logro`
- `descripcion_logro`

### 🏰 Tabla: Gremio
- `id_gremio` (PK)
- `nombre`
- `fecha_fundacion`

### 📘 Tabla: Partida
- `id_partida` (PK)
- `fecha_hora`
- `duracion`
- `resultado`

---

## 🔗 6. Tablas Asociativas

### 🔹 Pertenece (Jugador ↔ Gremio)
- `id_jugador` (FK)
- `id_gremio` (FK)
- `fecha_union`
- **PK compuesto:** `(id_jugador, id_gremio)`

### 🔹 Habilidad_Personaje (N:M)
- `id_personaje` (FK)
- `id_habilidad` (FK)
- `nivel`
- **PK:** `(id_personaje, id_habilidad)`

### 🔹 Inventario (Personaje ↔ Objeto)
- `id_personaje`
- `id_objeto`
- `cantidad`
- **PK:** `(id_personaje, id_objeto)`

### 🔹 Participa (Personaje ↔ Partida)
- `id_personaje`
- `id_partida`
- `puntuacion`
- **PK:** `(id_personaje, id_partida)`

### 🔹 Obtiene (Jugador ↔ Logro)
- `id_jugador`
- `id_logro`
- `fecha_desbloqueo`
- **PK:** `(id_jugador, id_logro)`

---

## 🛡️ 7. Seguridad Implementada

El proyecto incluye medidas de seguridad esenciales para una aplicación real:

### ✔ 1. Prevención de Inyección SQL

Usamos consultas parametrizadas, nunca concatenación:

```python
cur.execute("""
    SELECT id_jugador
    FROM jugador
    WHERE correo_electronico = %s
    AND contrasena_hash = crypt(%s, contrasena_hash);
""", (correo, contrasena))
```

- ✔ Variables separadas de la consulta
- ✔ PostgreSQL protege automáticamente los parámetros

### ✔ 2. Contraseñas Hasheadas

Se usa Blowfish con:

```sql
crypt(%s, gen_salt('bf'))
```

Las contraseñas nunca se guardan en texto plano.

### ✔ 3. Sesiones seguras con secret key

```python
app.secret_key = os.getenv("SECRET_KEY")
```

### ✔ 4. Validación de acceso

Cada ruta protegida verifica:

```python
if 'id_jugador' not in session:
    return redirect(url_for('login'))
```

### ✔ 5. Pool de conexiones

Se usa para evitar fallas si Supabase se duerme:

```python
psycopg2.pool.SimpleConnectionPool()
```

### ✔ 6. Ping con Cron para evitar "base dormida"

Cron-job.org llama a:

```
https://tu-proyecto.onrender.com/ping
```

cada 5 minutos.

Si la base está dormida, Flask la despierta automáticamente.

---

## 🚦 8. Rutas Principales

### 🔐 Autenticación

| Ruta | Método | Descripción |
|------|--------|-------------|
| `/login` | GET/POST | Iniciar sesión |
| `/registro` | GET/POST | Registrar jugador |
| `/logout` | GET | Cerrar sesión |

### 🧙 Personajes

| Ruta | Método | Descripción |
|------|--------|-------------|
| `/personajes` | GET/POST | Crear/editar |
| `/eliminar_personaje/<id>` | DELETE | Eliminar |
| `/seleccionar_personaje/<id>` | POST | Activar personaje |

### 🐾 Mascotas

| Ruta | Método | Descripción |
|------|--------|-------------|
| `/mascotas` | GET/POST | Crear/editar |
| `/eliminar_mascota/<id>` | DELETE | Eliminar |
| `/seleccionar_mascota/<id>` | POST | Activar mascota |

### 🔧 API JSON

| Ruta | Descripción |
|------|-------------|
| `/api/personaje/<id>` | Retorna personaje |
| `/api/mascota/<id>` | Retorna mascota |

### 🛠 Mantenimiento

| Ruta | Descripción |
|------|-------------|
| `/ping` | Mantiene despierta la base |

---

## 🧪 9. Cómo Ejecutar el Proyecto Localmente

### 1️⃣ Clonar repo

```bash
git clone https://github.com/usuario/proyecto-videojuego.git
cd proyecto-videojuego
```

### 2️⃣ Crear entorno virtual

```bash
python -m venv venv
venv\Scripts\activate       # Windows
source venv/bin/activate    # Linux/Mac
```

### 3️⃣ Instalar dependencias

```bash
pip install -r requirements.txt
```

### 4️⃣ Crear archivo .env

```
DATABASE_URL=postgresql://...
SECRET_KEY=clave-segura
```

### 5️⃣ Ejecutar

```bash
python app.py
```

---

## 🌐 10. Despliegue en Render + Supabase

### Supabase
- ✔ Crear tablas
- ✔ Añadir funciones `crypt()`
- ✔ Habilitar conexiones externas

### Render
- ✔ Crear servicio web
- ✔ Configurar variables de entorno
- ✔ Comando de inicio:

```bash
gunicorn app:app
```

### Cron-job.org

Llamar a:

```
https://tu-proyecto.onrender.com/ping
```

cada 5 minutos.

---

## 🎮 11. Funcionalidades Implementadas

- ✔ Login seguro
- ✔ Registro con hashing
- ✔ Lobby dinámico
- ✔ CRUD personajes
- ✔ CRUD mascotas
- ✔ APIs JSON
- ✔ Sistema de sesiones
- ✔ Seguridad anti SQL Injection
- ✔ Pool de conexiones
- ✔ Ping automático para DB

---

## 🪪 12. Licencia

Proyecto desarrollado con fines educativos.  
Libre para estudiar, modificar y mejorar.