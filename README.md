# 🎮 Sistema de Gestión para Videojuego Medieval
## Flask + PostgreSQL + Supabase + Data Warehouse + Cubo OLAP

Este proyecto es una **aplicación web completa** que integra la gestión operativa y analítica de un videojuego con temática medieval.

**Componentes principales:**
- 🧱 **Sistema Transaccional (OLTP)** - Gestión del videojuego en tiempo real
- 📊 **Data Warehouse (OLAP)** - Análisis histórico y estratégico
- 🧊 **Cubo de Datos** - Operaciones analíticas multidimensionales
- 🌐 **Interfaz Web Integrada** - Visualización analítica desde el juego

---

## 📑 Tabla de Contenidos

1. [Problemática](#-1-problemática)
2. [Objetivo del Proyecto](#-2-objetivo-del-proyecto)
3. [Arquitectura del Sistema](#-3-arquitectura-del-sistema)
4. [Tecnologías Utilizadas](#-4-tecnologías-utilizadas)
5. [Estructura del Proyecto](#-5-estructura-del-proyecto)
6. [Modelo Relacional OLTP](#-6-modelo-relacional-oltp)
7. [Data Warehouse - Modelo Dimensional](#-7-data-warehouse---modelo-dimensional)
8. [Cubo de Datos OLAP](#-8-cubo-de-datos-olap)
9. [Proceso ETL](#-9-proceso-etl)
10. [Instalación y Ejecución](#-10-instalación-y-ejecución)
11. [Despliegue en Producción](#-11-despliegue-en-producción)
12. [Funcionalidades Implementadas](#-12-funcionalidades-implementadas)
13. [Metodología de Desarrollo](#-13-metodología-de-desarrollo)
14. [Licencia](#-14-licencia)

---

## 🛑 1. Problemática

Un estudio de videojuegos enfrentaba dos grandes desafíos:

### 🔹 Problema Operacional (OLTP)
- ❌ Datos desorganizados y sin control
- ❌ Errores en estadísticas del juego
- ❌ Falta de seguridad en autenticación
- ❌ Dificultad para gestionar personajes, inventarios y eventos
- ❌ Información inconsistente entre entidades

### 🔹 Problema Analítico (OLAP)
- ❌ No existían reportes históricos
- ❌ Imposibilidad de analizar el progreso temporal
- ❌ No se podía medir rendimiento por clase, evento o periodo
- ❌ Sin capacidad de análisis estratégico del juego
- ❌ Falta de herramientas para toma de decisiones

---

## 🎯 2. Objetivo del Proyecto

Desarrollar una **plataforma integral** que permita:

### ✔ Operación del Videojuego (OLTP)
- Registro e inicio de sesión seguro con encriptación
- CRUD completo de personajes y mascotas
- Sistema de inventario multi-categoría (pociones, armas, armaduras)
- Gestión de gremios (crear, unirse, abandonar)
- Sistema de logros desbloqueables
- Lobby dinámico con personaje y mascota activa
- API REST para integraciones futuras

### ✔ Análisis de Datos (OLAP)
- Construcción de un Data Warehouse con esquema estrella
- Implementación de un Cubo OLAP funcional
- Análisis multidimensional por:
  - **Tiempo** (día, mes, año, trimestre)
  - **Jugador** (usuario, región, fecha registro)
  - **Personaje** (clase, nivel, raza)
  - **Evento** (tipo, dificultad, duración)
- Visualización de consultas analíticas desde la interfaz web
- Operaciones OLAP: Roll-up, Drill-down, Slice, Dice

---

## 🏗️ 3. Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                      CAPA DE PRESENTACIÓN                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Lobby      │  │  Personajes  │  │  Cubo OLAP   │      │
│  │  Inventario  │  │   Gremios    │  │  Dashboard   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────┴─────────────────────────────────┐
│                    CAPA DE APLICACIÓN                        │
│                         Flask App                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Autenticación│  │    ORM       │  │  API REST    │      │
│  │   Seguridad  │  │  SQLAlchemy  │  │   Consultas  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└───────────────────────────┬─────────────────────────────────┘
                            │
        ┌───────────────────┴───────────────────┐
        │                                       │
        ↓                                       ↓
┌───────────────────┐              ┌───────────────────────┐
│   OLTP (public)   │              │   OLAP (dw schema)    │
│   ─────────────   │    ETL       │   ──────────────────  │
│  • Jugador        │ ──────────→  │  • dim_jugador        │
│  • Personaje      │              │  • dim_personaje      │
│  • Mascota        │              │  • dim_tiempo         │
│  • Inventario     │              │  • dim_evento         │
│  • Gremio         │              │  • fact_progreso      │
│  • Logro          │              │                       │
└───────────────────┘              └───────────────────────┘
        │                                       │
        └───────────────────┬───────────────────┘
                            │
                            ↓
                ┌─────────────────────┐
                │  PostgreSQL DB      │
                │     (Supabase)      │
                └─────────────────────┘
```

---

## 🧱 4. Tecnologías Utilizadas

### Backend
| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **Flask** | 3.0.0 | Framework web |
| **SQLAlchemy** | 3.1.1 | ORM para OLTP |
| **Werkzeug** | 3.0.x | Seguridad y hashing |
| **Jinja2** | 3.1.x | Motor de plantillas |
| **psycopg2** | 2.9.9 | Conector PostgreSQL |
| **python-dotenv** | 1.0.0 | Variables de entorno |

### Base de Datos
- **PostgreSQL** 15+
- **Supabase** (hosting cloud)
- Extensión `pgcrypto` para migración de contraseñas

### Business Intelligence
- **Data Warehouse** con modelo dimensional
- **Esquema Estrella** (Star Schema)
- **Mondrian OLAP** - Motor ROLAP para consultas MDX
- **Pentaho Workbench** - Editor de esquemas y testing MDX
- **MDX (Multidimensional Expressions)** - Lenguaje de consultas OLAP
- **Consultas SQL** en Flask para análisis rápido
- **ETL** en Python

### Infraestructura
- **Docker** y **Docker Compose**
- **Gunicorn** (servidor WSGI)
- **Render.com** (deployment)
- **GitHub** (versionamiento y CI/CD)

### Frontend
- **CSS** personalizado
- **JavaScript** vanilla
- **HTML5** + Jinja2

---

## 📁 5. Estructura del Proyecto

```
PROYECTO/
|
├── CuboDeDatos(VisualStudio)/   
│   ├── 📁 Database/           # Scripts T-SQL de generación de datos
│   ├── 📁 SSAS_Project/       # Solución completa de Visual Studio
│   ├── 📁 Excel/         # Reporte final en Excel (.xlsx)
│
├── etl/                           # 🔄 Proceso ETL completo
│   ├── extract.py                 # Extracción desde OLTP
│   ├── transform.py               # Transformación de datos
│   ├── load_dimensions.py         # Carga de dimensiones
│   ├── load_fact.py               # Carga de tabla de hechos
│   ├── seed_dw.py                 # Poblado inicial del DW
│   └── seed_dw_masivo.py          # Generación de datos masivos
│
├── sql/                           # 📜 Scripts SQL
│   └── dw_schema.sql              # Esquema del Data Warehouse
│   └── cubo_videojuego.xml        # ⭐ Definición del cubo OLAP (Mondrian)   
│
├── static/                        # 🎨 Recursos estáticos
│   ├── css/
│   │   └── estilos.css
│   ├── img/
│   │   ├── icons/
│   │   ├── personaje01.png
│   │   └── mascota01.png
│   └── js/
│       └── scripts.js
│
├── templates/                     # 📄 Plantillas HTML
│   ├── login.html
│   ├── registro.html
│   ├── lobby.html
│   ├── personajes.html
│   ├── mascotas.html
│   ├── inventario.html
│   ├── gremio.html
│   ├── logros.html
│   └── cubo.html                  # ⭐ Visualización del cubo OLAP
│
├── venv/                          # 🐍 Entorno virtual
│
├── .env                           # 🔐 Variables de entorno
├── .gitignore
├── config.py                      # ⚙️ Configuración de Flask
├── videojuego.py                  # 🎮 Aplicación principal
├── requirements.txt               # 📦 Dependencias Python
├── Dockerfile                     # 🐳 Imagen Docker
├── docker-compose.yml             # 🐳 Orquestación
├── diagrama_estrella.html         # 📊 Visualización del esquema
└── README.md                      # 📖 Este archivo
```

---

## 🧬 6. Modelo Relacional OLTP

### Entidades Principales

#### 🧔 Jugador
```sql
CREATE TABLE jugador (
    id_jugador SERIAL PRIMARY KEY,
    nombre_usuario VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(100) UNIQUE NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    id_personaje_activo INT REFERENCES personaje(id_personaje),
    id_mascota_activa INT REFERENCES mascota(id_mascota)
);
```

**Relaciones:**
- 1:N con Personaje
- N:M con Gremio (via Pertenece)
- N:M con Logro (via Obtiene)

#### ⚔ Personaje
```sql
CREATE TABLE personaje (
    id_personaje SERIAL PRIMARY KEY,
    id_jugador INT NOT NULL REFERENCES jugador(id_jugador),
    nombre VARCHAR(100) NOT NULL,
    clase VARCHAR(50) NOT NULL,
    nivel INT DEFAULT 1
);
```

#### 🐾 Mascota
```sql
CREATE TABLE mascota (
    id_mascota SERIAL PRIMARY KEY,
    id_personaje INT NOT NULL REFERENCES personaje(id_personaje),
    nombre_mascota VARCHAR(50) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    nivel INT DEFAULT 1
);
```

#### 🛡 Objeto (con herencia)
```sql
-- Tabla padre
CREATE TABLE objeto (
    id_objeto SERIAL PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    descripcion TEXT,
    valor INT,
    rareza VARCHAR(30)
);

-- Tablas hijas (herencia 1:1)
CREATE TABLE pocion (
    id_objeto INT PRIMARY KEY REFERENCES objeto(id_objeto),
    efecto TEXT
);

CREATE TABLE arma (
    id_objeto INT PRIMARY KEY REFERENCES objeto(id_objeto),
    dano_base INT
);

CREATE TABLE armadura (
    id_objeto INT PRIMARY KEY REFERENCES objeto(id_objeto),
    valor_defensa INT
);
```

### Tablas Asociativas

#### 📦 Inventario (Personaje ↔ Objeto)
```sql
CREATE TABLE inventario (
    id_personaje INT REFERENCES personaje(id_personaje),
    id_objeto INT REFERENCES objeto(id_objeto),
    cantidad INT DEFAULT 1,
    PRIMARY KEY (id_personaje, id_objeto)
);
```

#### 🏰 Pertenece (Jugador ↔ Gremio)
```sql
CREATE TABLE pertenece (
    id_jugador INT REFERENCES jugador(id_jugador),
    id_gremio INT REFERENCES gremio(id_gremio),
    PRIMARY KEY (id_jugador, id_gremio)
);
```

---

## 📊 7. Data Warehouse - Modelo Dimensional

### Esquema Estrella Implementado

```
                 dim_tiempo
              (fecha, mes, año)
                     |
                     |
dim_jugador ─────────┼───────── dim_personaje
  (usuario)          |           (clase, nivel)
                     |
              fact_progreso
           (xp, oro, duración)
                     |
                     |
                dim_evento
            (tipo, dificultad)
```

### Dimensiones

#### 📅 dim_tiempo
```sql
CREATE TABLE dw.dim_tiempo (
    id_tiempo_sk SERIAL PRIMARY KEY,
    fecha DATE UNIQUE NOT NULL,
    dia INT CHECK (dia BETWEEN 1 AND 31),
    mes INT CHECK (mes BETWEEN 1 AND 12),
    anio INT CHECK (anio >= 2000),
    trimestre INT CHECK (trimestre BETWEEN 1 AND 4)
);
```

**Jerarquía:** Día → Mes → Trimestre → Año

#### 👤 dim_jugador
```sql
CREATE TABLE dw.dim_jugador (
    id_jugador_sk SERIAL PRIMARY KEY,
    id_jugador_nk INT NOT NULL,  -- Natural key
    nombre_usuario TEXT NOT NULL,
    correo TEXT,
    fecha_registro DATE,
    pais TEXT
);
```

#### 🧙 dim_personaje
```sql
CREATE TABLE dw.dim_personaje (
    id_personaje_sk SERIAL PRIMARY KEY,
    id_personaje_nk INT NOT NULL,
    clase TEXT NOT NULL,
    nivel_inicial INT CHECK (nivel_inicial >= 1),
    raza TEXT
);
```

#### 🎯 dim_evento
```sql
CREATE TABLE dw.dim_evento (
    id_evento_sk SERIAL PRIMARY KEY,
    tipo_evento TEXT NOT NULL,
    descripcion TEXT,
    dificultad TEXT CHECK (dificultad IN ('baja', 'media', 'alta'))
);
```

### Tabla de Hechos

#### 📈 fact_progreso
```sql
CREATE TABLE dw.fact_progreso (
    id_progreso SERIAL PRIMARY KEY,
    
    -- Claves foráneas (FK a dimensiones)
    id_jugador_sk INT REFERENCES dw.dim_jugador(id_jugador_sk),
    id_personaje_sk INT REFERENCES dw.dim_personaje(id_personaje_sk),
    id_tiempo_sk INT REFERENCES dw.dim_tiempo(id_tiempo_sk),
    id_evento_sk INT REFERENCES dw.dim_evento(id_evento_sk),
    
    -- Medidas (métricas agregables)
    xp_ganada INT NOT NULL CHECK (xp_ganada >= 0),
    oro_ganado INT NOT NULL CHECK (oro_ganado >= 0),
    nivel_resultante INT CHECK (nivel_resultante >= 1),
    duracion_evento INT CHECK (duracion_evento >= 0)
);
```

**Índices para optimización:**
```sql
CREATE INDEX idx_fact_jugador ON dw.fact_progreso(id_jugador_sk);
CREATE INDEX idx_fact_personaje ON dw.fact_progreso(id_personaje_sk);
CREATE INDEX idx_fact_tiempo ON dw.fact_progreso(id_tiempo_sk);
CREATE INDEX idx_fact_evento ON dw.fact_progreso(id_evento_sk);
```

---

## 🧊 8. Cubo de Datos OLAP

### Definición del Cubo

**Nombre:** Cubo de Progreso del Jugador

**Granularidad:** Un registro por evento realizado por un personaje en una fecha específica

### Medidas del Cubo

| Medida | Tipo | Agregación | Descripción |
|--------|------|------------|-------------|
| `xp_ganada` | Flujo | SUM | Experiencia obtenida |
| `oro_ganado` | Flujo | SUM | Oro acumulado |
| `nivel_resultante` | Snapshot | MAX | Nivel alcanzado |
| `duracion_evento` | Flujo | AVG, SUM | Tiempo del evento |
| `conteo_eventos` | Derivada | COUNT | Total de eventos |

### Dimensiones del Cubo

1. **Tiempo** (día, mes, trimestre, año)
2. **Jugador** (usuario, región, fecha registro)
3. **Personaje** (clase, nivel inicial, raza)
4. **Evento** (tipo, descripción, dificultad)

---

## 🎯 Implementación con Mondrian OLAP (MDX Real)

### Arquitectura del Sistema OLAP

```
PostgreSQL (DW - esquema dw)
        ↑
        │
 Mondrian OLAP Engine
        ↑
        │ MDX
 Pentaho Workbench / Saiku
```

**Mondrian OLAP** es un motor ROLAP (Relational OLAP) que:
- Interpreta Data Warehouses en esquema estrella
- Define cubos mediante esquemas XML
- Ejecuta consultas MDX reales sobre bases relacionales
- Traduce MDX a SQL optimizado

---

### 📄 Definición del Cubo en XML

**Archivo:** `cubo_videojuego.xml`

```xml
<Schema name="VideojuegoDW">

  <Cube name="CuboProgresoJugador" cache="true" enabled="true">

    <!-- TABLA DE HECHOS -->
    <Table schema="dw" name="fact_progreso"/>

    <!-- DIMENSIÓN TIEMPO -->
    <Dimension name="Tiempo" foreignKey="id_tiempo_sk">
      <Hierarchy hasAll="true" primaryKey="id_tiempo_sk">
        <Table schema="dw" name="dim_tiempo"/>
        <Level name="Año" column="anio" type="Numeric" uniqueMembers="true"/>
        <Level name="Mes" column="mes" type="Numeric"/>
        <Level name="Día" column="dia" type="Numeric"/>
      </Hierarchy>
    </Dimension>

    <!-- DIMENSIÓN PERSONAJE -->
    <Dimension name="Personaje" foreignKey="id_personaje_sk">
      <Hierarchy hasAll="true" primaryKey="id_personaje_sk">
        <Table schema="dw" name="dim_personaje"/>
        <Level name="Clase" column="clase" uniqueMembers="true"/>
        <Level name="Raza" column="raza"/>
      </Hierarchy>
    </Dimension>

    <!-- DIMENSIÓN EVENTO -->
    <Dimension name="Evento" foreignKey="id_evento_sk">
      <Hierarchy hasAll="true" primaryKey="id_evento_sk">
        <Table schema="dw" name="dim_evento"/>
        <Level name="Tipo Evento" column="tipo_evento" uniqueMembers="true"/>
        <Level name="Dificultad" column="dificultad"/>
      </Hierarchy>
    </Dimension>

    <!-- DIMENSIÓN JUGADOR -->
    <Dimension name="Jugador" foreignKey="id_jugador_sk">
      <Hierarchy hasAll="true" primaryKey="id_jugador_sk">
        <Table schema="dw" name="dim_jugador"/>
        <Level name="Usuario" column="nombre_usuario" uniqueMembers="true"/>
      </Hierarchy>
    </Dimension>

    <!-- MEDIDAS -->
    <Measure name="XP Ganada" column="xp_ganada" aggregator="sum"/>
    <Measure name="Oro Ganado" column="oro_ganado" aggregator="sum"/>
    <Measure name="Duración Evento" column="duracion_evento" aggregator="avg"/>

  </Cube>

</Schema>
```

---

### 🔄 Operaciones OLAP Fundamentales (MDX Real)

#### 1. 🔼 Roll-Up (Agregación Jerárquica)

**Objetivo:** Ver el resumen global de experiencia agrupada por Año.

```mdx
SELECT
    {[Measures].[XP Ganada]} ON COLUMNS,
    {[Tiempo].[Año].Members} ON ROWS
FROM [CuboProgresoJugador]
```

**Resultado esperado:**
```
Año    | XP Ganada
-------|----------
2022   | 150,000
2023   | 280,000
2024   | 420,000
2025   | 380,000
```

---

#### 2. 🔽 Drill-Down (Desglose Jerárquico)

**Objetivo:** Profundizar en el detalle mensual del año 2025.

**⚠️ Nota importante:** Para hacer Drill-Down, se usa `.Children` en lugar de `WHERE`, ya que se solicita explícitamente los hijos (meses) del nodo padre (año).

```mdx
SELECT
    {[Measures].[XP Ganada]} ON COLUMNS,
    {[Tiempo].[Año].[2025].Children} ON ROWS
FROM [CuboProgresoJugador]
```

**Resultado esperado:**
```
Mes | XP Ganada
----|----------
1   | 32,000
2   | 28,000
3   | 35,000
...
12  | 31,000
```

---

#### 3. 🔪 Slice (Corte Temporal)

**Objetivo:** Ver el rendimiento de los Jugadores (Dimensión A) acotado únicamente al año 2024 (Dimensión B).

**⚠️ Nota importante:** El `WHERE` filtra la dimensión Tiempo, mientras que las filas muestran otra dimensión (Jugador) para evitar conflictos.

```mdx
SELECT
    {[Measures].[XP Ganada]} ON COLUMNS,
    {[Jugador].[Usuario].Members} ON ROWS
FROM [CuboProgresoJugador]
WHERE ([Tiempo].[Año].[2024])
```

**Resultado esperado:**
```
Usuario      | XP Ganada
-------------|----------
jugador01    | 42,000
jugador02    | 38,500
jugador03    | 51,200
```

---

#### 4. 🎲 Dice (Cubo Multidimensional)

**Objetivo:** Filtrar por Clase 'Guerrero' y Año '2025' simultáneamente.

```mdx
SELECT
    {[Measures].[XP Ganada]} ON COLUMNS,
    {[Personaje].[Clase].[Guerrero]} ON ROWS
FROM [CuboProgresoJugador]
WHERE ([Tiempo].[Año].[2025])
```

**Resultado esperado:**
```
Clase     | XP Ganada
----------|----------
Guerrero  | 85,000
```

---

### 🎯 Consultas Analíticas Adicionales

#### Análisis por Clase de Personaje (Cross-Dimensional)

```mdx
SELECT
    {[Measures].[XP Ganada], [Measures].[Oro Ganado]} ON COLUMNS,
    {[Personaje].[Clase].Members} ON ROWS
FROM [CuboProgresoJugador]
WHERE ([Tiempo].[Año].[2025])
```

#### Top 5 Jugadores por XP

```mdx
SELECT
    {[Measures].[XP Ganada]} ON COLUMNS,
    TopCount([Jugador].[Usuario].Members, 5, [Measures].[XP Ganada]) ON ROWS
FROM [CuboProgresoJugador]
```

---

### 🛠️ Herramientas Utilizadas

| Herramienta | Propósito |
|-------------|-----------|
| **Mondrian OLAP** | Motor ROLAP para consultas MDX |
| **Pentaho Workbench** | Editor de esquemas XML |
| **Schema Workbench** | Validación y testing de MDX |
| **PostgreSQL** | Base de datos del Data Warehouse |

---

### 📊 Visualización del Cubo (Interfaz Web)

**Ruta web:** `/cubo`

La interfaz Flask permite:
- ✅ Selección de filtros individuales por operación
- ✅ Visualización de resultados en tablas dinámicas
- ✅ Navegación entre diferentes perspectivas
- ✅ Integración con SQL para consultas rápidas

**Nota:** El sistema mantiene dos capas de análisis:
- **Capa SQL:** Consultas directas en Flask (desarrollo inicial)
- **Capa MDX:** Consultas profesionales con Mondrian (validación académica)---

---

## 🔄 9. Proceso ETL

### Pipeline Completo

```
┌─────────────┐
│  EXTRACT    │  Lectura desde OLTP (public schema)
└──────┬──────┘
       │
       ↓
┌─────────────┐
│ TRANSFORM   │  Limpieza, validación y conversión
└──────┬──────┘
       │
       ↓
┌─────────────┐
│    LOAD     │  Inserción en DW (dw schema)
└─────────────┘
```

### Fase 1: Extracción

**Script:** `etl/extract.py`

```python
def extraer_jugadores():
    cursor.execute("""
        SELECT id_jugador, nombre_usuario, correo_electronico,
               DATE(fecha_hora) AS fecha_registro
        FROM jugador;
    """)
    return cursor.fetchall()

def extraer_personajes():
    cursor.execute("""
        SELECT id_personaje, id_jugador, nombre, clase, nivel
        FROM personaje
        ORDER BY id_personaje;
    """)
    return cursor.fetchall()
```

### Fase 2: Transformación

**Script:** `etl/transform.py`

```python
def transformar_jugadores(jugadores):
    resultado = []
    for j in jugadores:
        fila = {
            "id_jugador_nk": j["id_jugador"],
            "nombre_usuario": j["nombre_usuario"].strip(),
            "correo": j["correo_electronico"],
            "fecha_registro": j["fecha_registro"],
            "pais": None  # Enriquecimiento futuro
        }
        resultado.append(fila)
    return resultado

def transformar_tiempo(fechas):
    resultado = {}
    for fecha in fechas:
        if fecha not in resultado:
            resultado[fecha] = {
                "fecha": fecha,
                "dia": fecha.day,
                "mes": fecha.month,
                "anio": fecha.year,
                "trimestre": (fecha.month - 1) // 3 + 1
            }
    return list(resultado.values())
```

### Fase 3: Carga

**Script:** `etl/load_dimensions.py`

```python
def cargar_dim_jugador(jugadores):
    for j in jugadores:
        cursor.execute("""
            INSERT INTO dw.dim_jugador
            (id_jugador_nk, nombre_usuario, correo, fecha_registro, pais)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (id_jugador_nk) DO NOTHING;
        """, (j["id_jugador_nk"], j["nombre_usuario"],
              j["correo"], j["fecha_registro"], j["pais"]))
```

**Script:** `etl/load_fact.py`

```python
def cargar_fact_progreso():
    # Obtener claves sustitutas de dimensiones
    id_jugador_sk = obtener_sk_jugador(jugador_nk)
    id_personaje_sk = obtener_sk_personaje(personaje_nk)
    id_tiempo_sk = obtener_sk_tiempo(fecha)
    id_evento_sk = obtener_sk_evento(tipo_evento)
    
    # Insertar en tabla de hechos
    cursor.execute("""
        INSERT INTO dw.fact_progreso (
            id_jugador_sk, id_personaje_sk, id_tiempo_sk, id_evento_sk,
            xp_ganada, oro_ganado, nivel_resultante, duracion_evento
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """, (id_jugador_sk, id_personaje_sk, id_tiempo_sk, id_evento_sk,
          xp, oro, nivel, duracion))
```

### Poblado Masivo

**Script:** `etl/seed_dw_masivo.py`

Genera datos de prueba realistas:
- 📅 **Rango temporal:** 2022-2026
- 👥 **Jugadores:** Todos los del sistema
- 🎲 **Eventos aleatorios:** Distribución realista
- 📊 **Volumen:** Miles de registros para análisis BI

**Ejecución:**
```bash
python etl/seed_dw_masivo.py
```

---

## 🚀 10. Instalación y Ejecución

### Requisitos Previos

- Python 3.11+
- PostgreSQL 15+ o cuenta en Supabase
- Git
- Docker (opcional)

### Instalación Local

#### 1️⃣ Clonar el repositorio

```bash
git clone https://github.com/IISGRI/Proyecto-BD.git
cd Proyecto-BD
```

#### 2️⃣ Crear entorno virtual

```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

#### 3️⃣ Instalar dependencias

```bash
pip install -r requirements.txt
```

#### 4️⃣ Configurar variables de entorno

Crear archivo `.env`:

```env
DATABASE_URL=postgresql://usuario:password@host:puerto/database
SECRET_KEY=tu-clave-secreta-super-segura
```

#### 5️⃣ Crear esquema del Data Warehouse

```bash
# Ejecutar en PostgreSQL/Supabase
psql -h host -U usuario -d database -f sql/dw_schema.sql
```

O desde Supabase SQL Editor, ejecutar el contenido de `sql/dw_schema.sql`

#### 6️⃣ (Opcional) Poblar el Data Warehouse

```bash
# Poblado inicial
python etl/seed_dw.py

# Poblado masivo para análisis
python etl/seed_dw_masivo.py
```

#### 7️⃣ Ejecutar la aplicación

```bash
python videojuego.py
```

Acceder a: `http://127.0.0.1:5000`

---

### Configuración de Mondrian OLAP (Opcional)

Para trabajar con consultas MDX reales:

#### 1️⃣ Descargar Pentaho

```bash
# Descargar Pentaho Community Edition desde:
# https://community.hitachivantara.com/s/article/pentaho-community-edition-downloads
```

#### 2️⃣ Configurar la conexión a PostgreSQL

En Pentaho Schema Workbench:
1. Crear nueva conexión
2. Configurar:
   - **Driver:** PostgreSQL
   - **URL:** `jdbc:postgresql://host:puerto/database`
   - **Usuario/Contraseña:** Credenciales de Supabase

#### 3️⃣ Cargar el esquema del cubo

```bash
# Abrir el archivo en Schema Workbench
sql/cubo_videojuego.xml
```

#### 4️⃣ Ejecutar consultas MDX

En el panel de consultas MDX del Workbench, ejecutar las consultas documentadas en la sección de Operaciones OLAP.

#### 5️⃣ Validar resultados

Verificar que las agregaciones coincidan con los datos del Data Warehouse:

```sql
-- Verificación en PostgreSQL
SELECT t.anio, SUM(f.xp_ganada) AS xp_total
FROM dw.fact_progreso f
JOIN dw.dim_tiempo t ON f.id_tiempo_sk = t.id_tiempo_sk
GROUP BY t.anio;
```

**Nota:** La capa MDX es opcional para la funcionalidad web de Flask, pero es esencial para demostrar conocimiento formal de OLAP en contextos académicos.

---

### Instalación con Docker

#### 1️⃣ Construir la imagen

```bash
docker compose build
```

#### 2️⃣ Levantar los servicios

```bash
docker compose up
```

#### 3️⃣ Acceder a la aplicación

```
http://localhost:5000
```

#### 4️⃣ Detener los servicios

```bash
docker compose down
```

---

## 🌐 11. Despliegue en Producción

### Arquitectura en Producción

```
┌─────────────┐
│   Usuario   │
└──────┬──────┘
       │ HTTPS (SSL/TLS)
       ↓
┌─────────────────┐
│  Render.com     │
│  Flask + Docker │
│  Gunicorn WSGI  │
└────────┬────────┘
         │ PostgreSQL (SSL)
         ↓
┌─────────────────┐
│   Supabase      │
│  PostgreSQL 15+ │
│  OLTP + DW      │
└─────────────────┘
```

### Configuración en Render

#### 1️⃣ Crear Web Service

1. Conectar repositorio de GitHub
2. Seleccionar **Docker** como runtime
3. Configurar variables de entorno:

```env
DATABASE_URL=postgresql://...
SECRET_KEY=...
```

#### 2️⃣ Deploy automático

- ✅ Cada `git push` genera un nuevo despliegue
- ✅ Build automático desde `Dockerfile`
- ✅ Rollback disponible en caso de fallo

#### 3️⃣ Acceso a la aplicación

```
https://videojuegobd.onrender.com
```

### Configuración en Supabase

1. **Crear proyecto** en Supabase
2. **Copiar Connection String** desde Settings → Database
3. **Habilitar extensión pgcrypto**:

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

4. **Crear esquema DW**:

```sql
CREATE SCHEMA IF NOT EXISTS dw;
```

5. **Ejecutar scripts** de creación de tablas

---

## 🎮 12. Funcionalidades Implementadas

### Sistema Transaccional (OLTP)

#### ✔ Autenticación y Seguridad
- Registro de nuevos jugadores con validación
- Login seguro con migración automática de contraseñas
- Hash con Werkzeug (pbkdf2/scrypt)
- Soporte para contraseñas legacy con PostgreSQL crypt
- Sesiones seguras con cookies firmadas
- Validación de acceso en todas las rutas protegidas

#### ✔ Gestión de Personajes
- CRUD completo (Crear, Leer, Actualizar, Eliminar)
- Selección de personaje activo
- Visualización en lobby dinámico
- Clases disponibles: Guerrero, Mago, Arquero, etc.
- Sistema de niveles

#### ✔ Gestión de Mascotas
- CRUD completo vinculado al personaje activo
- Selección de mascota activa
- Tipos personalizables (Dragón, Lobo, Fénix, etc.)
- Sistema de niveles independiente
- Validación de pertenencia al jugador

#### ✔ Sistema de Inventario
- Gestión multi-categoría:
  - 🧪 Pociones (con efectos)
  - ⚔️ Armas (con daño base)
  - 🛡️ Armaduras (con defensa)
- Agregar objetos existentes
- Crear nuevos objetos con atributos especiales
- Control de cantidades (+/- unidades)
- Sistema de rareza (Común, Rara, Épica, Legendaria)
- Herencia 1:1 con tabla Objeto

#### ✔ Sistema de Gremios
- Crear nuevos gremios con fecha de fundación
- Unirse a gremios existentes
- Ver lista de miembros del gremio
- Abandonar gremio
- Restricción: un jugador por gremio a la vez

#### ✔ Sistema de Logros
- Visualización de logros desbloqueados
- Estado de progreso (bloqueado/desbloqueado)
- Sistema extensible para nuevas mecánicas
- Asociación N:M con jugadores

#### ✔ APIs REST
| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/personaje/<id>` | GET | Datos del personaje en JSON |
| `/api/mascota/<id>` | GET | Datos de la mascota en JSON |
| `/test-db` | GET | Verificar conexión a base de datos |
| `/test-jugador` | GET | Prueba de consulta ORM |

---

### Sistema Analítico (OLAP)

#### ✔ Data Warehouse
- Esquema independiente del OLTP (`dw` schema)
- Modelo dimensional con esquema estrella
- 4 dimensiones + 1 tabla de hechos
- Claves sustitutas para independencia del sistema operacional
- Índices optimizados para consultas analíticas
- Separación física y lógica de datos transaccionales

#### ✔ Cubo OLAP
- Definición formal con medidas y dimensiones
- Granularidad diaria por personaje
- Jerarquías temporales (día → mes → trimestre → año)
- 5 medidas analíticas (xp, oro, nivel, duración, conteo)
- 4 dimensiones analíticas (tiempo, jugador, personaje, evento)

#### ✔ Operaciones OLAP
| Operación | Implementada | Descripción |
|-----------|--------------|-------------|
| **Roll-up** 🔼 | ✅ | Agregación temporal (día → mes → año) |
| **Drill-down** 🔽 | ✅ | Desagregación (año → mes → día) |
| **Slice** 🔪 | ✅ | Filtro por una dimensión específica |
| **Dice** 🎲 | ✅ | Filtro por múltiples dimensiones |

#### ✔ Proceso ETL
- **Extract**: Lectura desde OLTP con psycopg2
- **Transform**: Limpieza, validación y normalización en Python
- **Load**: Inserción en DW con manejo de claves sustitutas
- Scripts modulares y reutilizables
- Poblado inicial (`seed_dw.py`)
- Generación masiva de datos (`seed_dw_masivo.py`)

#### ✔ Visualización Analítica
- Interfaz web integrada en `/cubo`
- Tablas dinámicas por operación OLAP
- Filtros independientes por consulta
- Resultados en tiempo real desde PostgreSQL
- Diseño responsivo con Bootstrap

---

### Seguridad Implementada

#### 🛡️ Prevención de Inyección SQL
```python
# ❌ NUNCA (vulnerable)
query = f"SELECT * FROM jugador WHERE correo = '{correo}'"

# ✅ SIEMPRE (seguro con ORM)
jugador = Jugador.query.filter_by(correo_electronico=correo).first()
```

#### 🔐 Sistema de Contraseñas
- **Hash moderno** con Werkzeug (pbkdf2:sha256)
- **Migración automática** desde PostgreSQL crypt
- **Salting automático** en cada hash
- **Verificación segura** sin exponer contraseñas

#### 🔒 Gestión de Sesiones
- Cookies firmadas con `SECRET_KEY`
- Validación en cada ruta protegida
- Timeout automático
- Limpieza al cerrar sesión

#### ✅ Pool de Conexiones
```python
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    "pool_pre_ping": True,      # Detecta conexiones muertas
    "pool_recycle": 280,        # Recicla cada 280s
}
```

#### 🔍 Validación de Pertenencia
```python
if personaje.id_jugador != session['id_jugador']:
    return jsonify({"error": "Acción no permitida"}), 403
```

---

## 🎓 13. Metodología de Desarrollo

El proyecto se desarrolló siguiendo una metodología estructurada en **8 fases**, aplicando principios de **Business Intelligence** y **Data Warehousing**.

### Fase 0: Análisis Previo
**Objetivo:** Definir el alcance analítico del proyecto

**Actividades:**
- Identificación de preguntas de negocio
- Definición de objetivos OLTP y OLAP
- Análisis de requerimientos funcionales
- Selección de métricas clave (KPIs)

**Entregables:**
- Documento de análisis
- Lista de preguntas de negocio
- Justificación del Data Warehouse

**Preguntas de negocio definidas:**
1. ¿Qué jugadores avanzan más rápido?
2. ¿Qué clases son más populares?
3. ¿Cómo evoluciona el progreso en el tiempo?
4. ¿Qué eventos generan más experiencia?
5. ¿Cuáles son los patrones de actividad por periodo?

---

### Fase 1: Identificación de Hechos y Dimensiones
**Objetivo:** Diseñar el modelo dimensional

**Actividades:**
- Definición de la tabla de hechos (fact_progreso)
- Identificación de dimensiones (tiempo, jugador, personaje, evento)
- Establecimiento de la granularidad (diaria por personaje)
- Definición de medidas (xp, oro, nivel, duración)

**Decisiones clave:**
- **Hecho central:** Progreso del jugador
- **Granularidad:** Un registro por personaje por día
- **Medidas:** 4 métricas + 1 derivada (count)
- **Dimensiones:** 4 perspectivas de análisis

---

### Fase 2: Diseño del Esquema Dimensional
**Objetivo:** Crear el modelo lógico del Data Warehouse

**Actividades:**
- Elección del esquema estrella (star schema)
- Diseño de diagramas conceptual, lógico y físico
- Definición de claves sustitutas (surrogate keys)
- Establecimiento de jerarquías temporales

**Entregables:**
- Diagrama del esquema estrella
- Diccionario de datos
- Modelo lógico con relaciones
- Visualización en `diagrama_estrella.html`

---

### Fase 3: Diseño Físico del Data Warehouse
**Objetivo:** Implementar el DW en PostgreSQL

**Actividades:**
- Creación del esquema `dw` separado del OLTP
- Implementación de tablas de dimensiones
- Creación de la tabla de hechos
- Definición de índices para optimización
- Configuración de restricciones y validaciones

**Scripts SQL:**
```sql
-- Crear esquema
CREATE SCHEMA IF NOT EXISTS dw;

-- Crear dimensiones
CREATE TABLE dw.dim_tiempo (...);
CREATE TABLE dw.dim_jugador (...);
CREATE TABLE dw.dim_personaje (...);
CREATE TABLE dw.dim_evento (...);

-- Crear tabla de hechos
CREATE TABLE dw.fact_progreso (...);

-- Crear índices
CREATE INDEX idx_fact_jugador ON dw.fact_progreso(id_jugador_sk);
```

---

### Fase 4: Proceso ETL
**Objetivo:** Migrar datos de OLTP a OLAP

**Actividades:**
- **Extract:** Extracción desde sistema transaccional
- **Transform:** Limpieza, validación y normalización
- **Load:** Carga en DW con claves sustitutas

**Scripts implementados:**
- `etl/extract.py` - Extracción de datos
- `etl/transform.py` - Transformación y limpieza
- `etl/load_dimensions.py` - Carga de dimensiones
- `etl/load_fact.py` - Carga de tabla de hechos
- `etl/seed_dw.py` - Poblado inicial
- `etl/seed_dw_masivo.py` - Generación de datos masivos

**Pipeline ETL:**
```python
# 1. Extraer
jugadores = extraer_jugadores()
personajes = extraer_personajes()

# 2. Transformar
dim_jugador = transformar_jugadores(jugadores)
dim_personaje = transformar_personajes(personajes)

# 3. Cargar
cargar_dim_jugador(dim_jugador)
cargar_dim_personaje(dim_personaje)
cargar_fact_progreso()
```

---

### Fase 5: Implementación del Cubo de Datos
**Objetivo:** Crear el cubo OLAP funcional con MDX real

**Actividades:**

#### 5.1 Definición del Cubo
- Nombre: Cubo de Progreso del Jugador
- Medidas: xp_ganada, oro_ganado, nivel_resultante, duracion_evento
- Dimensiones: tiempo, jugador, personaje, evento
- Jerarquías: día → mes → trimestre → año

#### 5.2 Implementación con Mondrian OLAP
- Definición del esquema XML del cubo
- Configuración de jerarquías dimensionales
- Mapeo de medidas agregables
- Validación del schema con Schema Workbench

**Esquema XML (cubo_videojuego.xml):**
```xml
<Cube name="CuboProgresoJugador">
  <Table schema="dw" name="fact_progreso"/>
  <Dimension name="Tiempo" foreignKey="id_tiempo_sk">
    <Hierarchy hasAll="true" primaryKey="id_tiempo_sk">
      <Table schema="dw" name="dim_tiempo"/>
      <Level name="Año" column="anio"/>
      <Level name="Mes" column="mes"/>
      <Level name="Día" column="dia"/>
    </Hierarchy>
  </Dimension>
  <!-- Más dimensiones... -->
</Cube>
```

#### 5.3 Consultas MDX
Implementación de las 4 operaciones OLAP fundamentales en MDX real:

**Roll-up (Agregación):**
```mdx
SELECT
    {[Measures].[XP Ganada]} ON COLUMNS,
    {[Tiempo].[Año].Members} ON ROWS
FROM [CuboProgresoJugador]
```

**Drill-down (Desglose con .Children):**
```mdx
SELECT
    {[Measures].[XP Ganada]} ON COLUMNS,
    {[Tiempo].[Año].[2025].Children} ON ROWS
FROM [CuboProgresoJugador]
```

**Slice (Corte dimensional):**
```mdx
SELECT
    {[Measures].[XP Ganada]} ON COLUMNS,
    {[Jugador].[Usuario].Members} ON ROWS
FROM [CuboProgresoJugador]
WHERE ([Tiempo].[Año].[2024])
```

**Dice (Filtrado multidimensional):**
```mdx
SELECT
    {[Measures].[XP Ganada]} ON COLUMNS,
    {[Personaje].[Clase].[Guerrero]} ON ROWS
FROM [CuboProgresoJugador]
WHERE ([Tiempo].[Año].[2025])
```

#### 5.4 Validación en Pentaho Workbench
- Testing de consultas MDX
- Verificación de agregaciones
- Optimización de jerarquías
- Pruebas de navegación dimensional


---

### Fase 6: Validación y Pruebas
**Objetivo:** Verificar la integridad del sistema

**Actividades:**
- Validación de carga de datos (consistencia OLTP ↔ DW)
- Pruebas de consultas OLAP
- Verificación de índices y rendimiento
- Testing de operaciones CRUD en OLTP
- Validación de seguridad y autenticación

**Casos de prueba:**
- ✅ Migración de contraseñas
- ✅ Integridad referencial
- ✅ Operaciones OLAP
- ✅ Carga de dimensiones
- ✅ Poblado de tabla de hechos

---

### Fase 7: Documentación
**Objetivo:** Generar documentación técnica completa

**Entregables:**
- README.md completo
- Diagramas del modelo relacional
- Diagrama del esquema estrella
- Diccionario de datos
- Manual de instalación
- Guía de uso del cubo OLAP
- Comentarios en código

---

### Fase 8: Despliegue
**Objetivo:** Publicar el sistema en producción

**Actividades:**
- Dockerización del proyecto
- Configuración en Render.com
- Configuración de base de datos en Supabase
- Configuración de variables de entorno
- Implementación de CI/CD con GitHub
- Monitoreo y logging

**Resultado:**
- ✅ Aplicación desplegada en: `https://videojuegobd.onrender.com`
- ✅ Base de datos en Supabase
- ✅ Deploy automático con cada push
- ✅ SSL/TLS habilitado

---

## 📊 Resultados del Proyecto

### Métricas del Sistema

| Métrica | Valor |
|---------|-------|
| **Tablas OLTP** | 11 tablas |
| **Tablas DW** | 5 tablas (4 dims + 1 fact) |
| **Rutas Flask** | 25+ endpoints |
| **Operaciones OLAP** | 4 implementadas (SQL + MDX) |
| **Scripts ETL** | 6 scripts Python |
| **Consultas MDX** | 6+ consultas validadas |
| **Líneas de código** | ~2,500 líneas |
| **Tecnologías** | 15 tecnologías |

### Capacidades Analíticas

- ✅ Análisis temporal (2022-2026)
- ✅ Análisis por jugador
- ✅ Análisis por clase de personaje
- ✅ Análisis por tipo de evento
- ✅ Agregaciones dinámicas
- ✅ Filtrado multidimensional
- ✅ Consultas MDX profesionales
- ✅ Motor ROLAP con Mondrian

---

## 🎯 Conclusiones (REEMPLAZAR SECCIÓN COMPLETA)

Este proyecto representa una **solución integral** que combina:

1. **Sistema Transaccional (OLTP)** robusto y seguro
2. **Data Warehouse (OLAP)** con modelo dimensional bien diseñado
3. **Cubo de Datos** funcional con operaciones analíticas
4. **Consultas MDX reales** con Mondrian OLAP
5. **Proceso ETL** automatizado y escalable
6. **Interfaz web** integrada para análisis BI

### Logros Principales

✅ **Separación OLTP/OLAP** - Arquitectura de dos capas
✅ **Modelo Dimensional** - Esquema estrella optimizado
✅ **Operaciones OLAP** - Roll-up, Drill-down, Slice, Dice
✅ **MDX Real** - Consultas profesionales con Mondrian
✅ **Motor ROLAP** - Integración con Pentaho Workbench
✅ **ETL Completo** - Pipeline automatizado
✅ **Seguridad** - Encriptación, ORM, validaciones
✅ **Escalabilidad** - Docker, Supabase, Render
✅ **Documentación** - Completa y detallada

### Aprendizajes

- Diseño de bases de datos relacionales
- Modelado dimensional y esquemas estrella
- Implementación de procesos ETL
- Desarrollo de cubos OLAP con Mondrian
- Consultas MDX profesionales
- Arquitectura ROLAP
- Integración OLTP-OLAP en una aplicación real
- Despliegue de aplicaciones en la nube
- Buenas prácticas de seguridad en aplicaciones web

### 🔥 Lecciones Aprendidas con MDX

Durante la implementación del cubo con Mondrian, se identificaron y corrigieron errores comunes:

#### ❌ Error Común: Drill-Down con WHERE
```mdx
-- INCORRECTO (genera error de dimensión duplicada)
SELECT
    {[Measures].[XP Ganada]} ON COLUMNS,
    {[Tiempo].[Mes].Members} ON ROWS
FROM [CuboProgresoJugador]
WHERE ([Tiempo].[Año].[2025])
```

**Problema:** No se puede tener la misma dimensión en filas y en WHERE.

#### ✅ Solución: Usar .Children
```mdx
-- CORRECTO (navegación jerárquica)
SELECT
    {[Measures].[XP Ganada]} ON COLUMNS,
    {[Tiempo].[Año].[2025].Children} ON ROWS
FROM [CuboProgresoJugador]
```

**Explicación:** `.Children` solicita explícitamente los hijos (meses) del nodo padre (año 2025), respetando la jerarquía dimensional.

#### 📌 Regla de Oro MDX

> **No se puede filtrar con WHERE usando la misma dimensión que está en las filas/columnas.**
> 
> - Para navegar en una dimensión: usar `.Children`, `.Members`, o `.Descendants`
> - Para filtrar con otra dimensión: usar `WHERE`

Esta comprensión es fundamental para escribir consultas MDX correctas y eficientes.

---

## 📚 Referencias

- **SQLAlchemy Documentation**: https://docs.sqlalchemy.org/
- **Flask Documentation**: https://flask.palletsprojects.com/
- **PostgreSQL Documentation**: https://www.postgresql.org/docs/
- **Data Warehousing Concepts**: Kimball, Ralph. *The Data Warehouse Toolkit*
- **OLAP Operations**: Microsoft SQL Server Analysis Services Documentation
- **Star Schema Design**: https://www.kimballgroup.com/

---

## 👥 Contribuciones

Este proyecto fue desarrollado como parte de un proyecto académico de **Bases de Datos**.

### Autores
- **Equipo de Desarrollo**
- Rodriguez Salcedo Liam Ariel
- Sanches Zenteno Diego

### Repositorio
- GitHub: https://github.com/IISGRI/Proyecto-BD

---

## 🪪 14. Licencia

Este proyecto está desarrollado con **fines educativos**.

- ✅ Libre para estudiar y aprender
- ✅ Libre para modificar y extender
- ✅ Libre para usar como referencia académica

---

## 🎮 Notas Finales

Este proyecto demuestra la integración exitosa de:
- Bases de datos relacionales (OLTP)
- Business Intelligence (OLAP)
- Data Warehousing
- Proceso ETL
- Análisis multidimensional
- Desarrollo web Full-Stack

Representa una solución **completa y profesional** aplicable a escenarios reales de la industria del software y análisis de datos.

**¡Gracias por explorar este proyecto! 🎮⚔️🐉📊**

---

*Última actualización: Enero 2026*
=======
# ⚔️ Video Game Analytics: Sistema de Inteligencia de Negocios (BI)

![Status](https://img.shields.io/badge/Status-Finalizado-success)
![Version](https://img.shields.io/badge/Version-1.0.0-blue)
![Technology](https://img.shields.io/badge/Stack-SQL%20Server%20%7C%20SSAS%20%7C%20Excel-orange)

> ### 🎓 Información Académica
> * **Institución:** INSTITUTO POLITÉCNICO NACIONAL
> * **Carrera:** ESCUELA SUPERIOR DE CÓMPUTO
> * **Materia:** BASE DE DATOS
> * **Docente:** GABRIEL HURTADO AVILÉS
> * **Semestre/Grupo:** 3CV5
> * **Equipo:**
>     * 👤 Rodriguez Salcedo Liam Ariel
>     * 👤 Sánchez Zenteno Diego Alejandro

---

## 📖 Resumen Ejecutivo
Este proyecto implementa **dos soluciones completas de Business Intelligence (End-to-End)** diseñadas para analizar el comportamiento de jugadores en un videojuego MMORPG masivo. A través de la simulación de **miles de partidas**, el sistema transforma datos transaccionales en conocimiento estratégico mediante dos enfoques tecnológicos diferentes:

1. **Enfoque Open Source (PostgreSQL + Mondrian OLAP)**: Solución multiplataforma utilizando tecnologías de código abierto, ideal para entornos Linux/Cloud y integración con aplicaciones web Flask.

2. **Enfoque Microsoft (SQL Server + SSAS)**: Solución empresarial utilizando el ecosistema Microsoft, optimizada para análisis corporativos y visualización en Excel.

Ambas implementaciones permiten a los analistas cruzar variables complejas (Tiempo, Geografía, Clase de Personaje) con métricas de rendimiento (XP, Oro) en milisegundos, visualizando los hallazgos en dashboards interactivos.

---


## 🏗️ Arquitectura Dual del Sistema

```
┌─────────────────────────────────────────────────────────────────┐
│                    CAPA DE VISUALIZACIÓN                         │
│  ┌──────────────────────┐    ┌──────────────────────┐          │
│  │   Excel Dashboard    │    │   Web Dashboard      │          │
│  │   (Tablas Dinámicas) │    │   (Flask + Bootstrap)│          │
│  └──────────┬───────────┘    └──────────┬───────────┘          │
└─────────────┼──────────────────────────┼──────────────────────┘
              │                           │
              │                           │
┌─────────────┼──────────────────────────┼──────────────────────┐
│             │    CAPA OLAP             │                       │
│  ┌──────────▼───────────┐    ┌─────────▼──────────┐          │
│  │   SQL Server         │    │   Mondrian OLAP    │          │
│  │   Analysis Services  │    │   (Schema Workbench)│          │
│  │   (SSAS Cubo)        │    │   (MDX Real)       │          │
│  └──────────┬───────────┘    └─────────┬──────────┘          │
└─────────────┼──────────────────────────┼──────────────────────┘
              │                           │
              │                           │
┌─────────────┼──────────────────────────┼──────────────────────┐
│             │   CAPA DE DATOS          │                       │
│  ┌──────────▼───────────┐    ┌─────────▼──────────┐          │
│  │   SQL Server DB      │    │   PostgreSQL DB    │          │
│  │   Videojuego_DW      │    │   (Supabase Cloud) │          │
│  │   (10,000 registros) │    │   Esquema dw       │          │
│  └──────────────────────┘    └────────────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📐 Diseño del Cubo OLAP (Metadatos Compartidos)

Ambas implementaciones utilizan la misma estructura dimensional, garantizando consistencia en los análisis:

### 1. Grupos de Medida (Facts)

| Medida (Measure) | Tipo de Agregación | Descripción |
| :--- | :--- | :--- |
| **XP Ganada** | `SUM` | Total de puntos de experiencia acumulados por los jugadores. |
| **Oro Ganado** | `SUM` | Cantidad total de moneda virtual generada en el juego. |
| **Recuento de Partidas** | `COUNT` | Número total de sesiones de juego registradas. |
| **Duración Evento** | `SUM` / `AVG` | Tiempo total invertido por los jugadores en misiones. |
| **Nivel Resultante** | `MAX` | El nivel máximo alcanzado en el periodo analizado. |

### 2. Dimensiones (Contexto)

* **📅 Dimensión Tiempo:** Jerarquía completa `Año > Trimestre > Mes > Día`. Permite análisis de estacionalidad.
* **🌍 Dimensión Jugador:** Información demográfica (`País`) y de cuenta (`Fecha de Registro`, `Correo`).
* **🛡️ Dimensión Personaje:** Arquetipos de juego. Incluye atributos como `Clase` (Guerrero, Mago...), `Raza` y `Nivel Inicial`.
* **🔥 Dimensión Evento:** Contexto de la partida. Clasifica las sesiones por `Tipo` (Raid, PVP, Farming) y `Dificultad` (Alta, Media, Baja).

---

## 🧠 Operaciones OLAP & Consultas MDX

Ambas soluciones implementan las cuatro operaciones OLAP fundamentales:

### 1. 🔼 Roll-Up (Agregación Jerárquica)

**Mondrian (PostgreSQL):**
```mdx
SELECT { [Measures].[XP Ganada] } ON COLUMNS,
       { [Tiempo].[Anio].MEMBERS } ON ROWS
FROM [CuboProgresoJugador]
```

**SSAS (SQL Server):**
```mdx
SELECT { [Measures].[XP Ganada] } ON COLUMNS,
       { [Dim Tiempo].[Anio].MEMBERS } ON ROWS
FROM [Videojuego DW]
```

### 2. 🔽 Drill-Down (Desglose Jerárquico)

**Mondrian:**
```mdx
SELECT { [Measures].[XP Ganada] } ON COLUMNS,
       { [Tiempo].[Año].[2025].Children } ON ROWS
FROM [CuboProgresoJugador]
```

**SSAS:**
```mdx
SELECT { [Measures].[XP Ganada] } ON COLUMNS,
       { [Dim Tiempo].[Mes].MEMBERS } ON ROWS
FROM [Videojuego DW]
WHERE ( [Dim Tiempo].[Anio].&[2024] )
```

### 3. 🔪 Slice (Corte Dimensional)

**Mondrian:**
```mdx
SELECT { [Measures].[XP Ganada] } ON COLUMNS,
       { [Jugador].[Usuario].Members } ON ROWS
FROM [CuboProgresoJugador]
WHERE ([Tiempo].[Año].[2024])
```

**SSAS:**
```mdx
SELECT { [Measures].[XP Ganada] } ON COLUMNS,
       { [Dim Jugador].[Nombre Usuario].MEMBERS } ON ROWS
FROM [Videojuego DW]
WHERE ( [Dim Tiempo].[Anio].&[2024] )
```

### 4. 🎲 Dice (Filtrado Multidimensional)

**Mondrian:**
```mdx
SELECT { [Measures].[XP Ganada] } ON COLUMNS,
       { [Personaje].[Clase].[Guerrero] } ON ROWS
FROM [CuboProgresoJugador]
WHERE ([Tiempo].[Año].[2025])
```

**SSAS:**
```mdx
SELECT { [Measures].[Oro Ganado] } ON COLUMNS,
       { [Dim Personaje].[Clase].&[Guerrero] } ON ROWS
FROM [Videojuego DW]
WHERE ( [Dim Evento].[Dificultad].&[Alta] )
```

### 5. 🏆 Top Count (Ranking)

**Mondrian:**
```mdx
SELECT { [Measures].[XP Ganada] } ON COLUMNS,
       TopCount([Jugador].[Usuario].Members, 5, [Measures].[XP Ganada]) ON ROWS
FROM [CuboProgresoJugador]
```

**SSAS:**
```mdx
SELECT { [Measures].[XP Ganada] } ON COLUMNS,
       TOPCOUNT( [Dim Jugador].[Nombre Usuario].MEMBERS, 5, [Measures].[XP Ganada] ) ON ROWS
FROM [Videojuego DW]
```

---

## 🛠️ Implementaciones Disponibles

El proyecto ofrece dos caminos de implementación según las necesidades del entorno:

---

## 📘 MÉTODO 1: Implementación con PostgreSQL + Mondrian OLAP

### Stack Tecnológico

| Componente | Tecnología | Rol en el proyecto |
| :--- | :--- | :--- |
| **Base de Datos** | PostgreSQL 15+ (Supabase) | Data Warehouse en la nube |
| **Motor OLAP** | Mondrian OLAP Engine | Procesamiento de consultas MDX |
| **IDE Cubo** | Schema Workbench 3.14 | Diseño y testing del cubo XML |
| **Driver JDBC** | postgresql-42.7.4.jar | Conector Java-PostgreSQL |
| **Visualización** | Flask Web Dashboard | Interfaz web interactiva |
| **Runtime** | Java JDK 8/11 | Ejecución de Mondrian |

### Procedimiento de Instalación y Configuración

#### Paso 1: Descargar Mondrian Schema Workbench

1. Abrir un navegador web y buscar **SourceForge**.
2. En la barra de búsqueda de SourceForge escribir **Mondrian**.
3. Seleccionar la opción correspondiente a **Mondrian** y dar clic.
4. Entrar a la sección **Files**.
5. Abrir la carpeta **schema workbench**.
6. Hacer clic en la carpeta **3.14.0.0-12** (versión más estable).
7. Buscar el archivo llamado **psw-ce-3.14.0.0-12.zip**.
8. Dar clic en el archivo y esperar a que se descargue.
9. Una vez descargado, extraer el archivo **.zip** en una carpeta de preferencia.

#### Paso 2: Configurar el Driver JDBC para PostgreSQL

1. El proyecto utiliza **PostgreSQL**, por lo que se necesita el **conector JDBC para Java**.
2. Archivo requerido: **postgresql-42.7.4.jar** (o versión similar).
3. Para descargarlo:
   * Abrir el navegador.
   * Buscar **PostgreSQL JDBC Driver**.
   * Entrar al sitio oficial de PostgreSQL.
   * Dar clic en **Download**.
   * Buscar y descargar la versión **42.7.4**.
4. Una vez descargado:
   * Ir a la carpeta donde se extrajo **Mondrian Schema Workbench**.
   * Abrir la carpeta **lib**.
   * Eliminar el archivo de PostgreSQL que venía por defecto.
   * Copiar y pegar el archivo **postgresql-42.7.4.jar** recién descargado.

#### Paso 3: Verificar e Instalar Java

1. Ejecutar el archivo **workbench.bat** ubicado en la carpeta de Mondrian.
2. Si la ventana se abre y se cierra inmediatamente, significa que **Java no está instalado o configurado**.
3. Para verificar Java:
   * Abrir una terminal (escribir **cmd** en el inicio de Windows).
   * Escribir el comando:
     ```bash
     java -version
     ```
4. Si el comando no se reconoce, descargar e instalar **JDK 8 o JDK 11** desde el sitio oficial de Oracle o AdoptOpenJDK.

#### Paso 4: Configurar la Conexión a PostgreSQL

1. Ejecutar **workbench.bat** y esperar a que abra Mondrian Schema Workbench.
2. En el menú superior ir a **Options → Connection**.
3. Se abrirá la ventana **Database Connection**. Completar los siguientes campos:
   * **Connection Name**: Nombre descriptivo (ej. *VideojuegoPostgreSQL*).
   * **Connection Type**: Seleccionar **PostgreSQL**.
   * **Access**: Seleccionar **Native (JDBC)**.
   * **Host Name**: Dirección del servidor (ej. *localhost* o la URL de Supabase).
   * **Database Name**: Nombre de la base de datos (según el archivo README principal del proyecto).
   * **Port**: Puerto del motor PostgreSQL (por defecto **5432**).
   * **Username**: Usuario de PostgreSQL o Supabase.
   * **Password**: Contraseña correspondiente.
4. Dar clic en **Test** para verificar que la conexión sea exitosa.
5. Si la conexión es exitosa, dar clic en **OK** para guardar.

#### Paso 5: Crear el Esquema del Cubo OLAP

1. En Mondrian Schema Workbench, ir a **File → New → Schema**.
2. En el panel izquierdo (**Schema**), dar clic derecho y seleccionar **Add Cube**.
3. Asignar un nombre al cubo (por ejemplo, **CuboProgresoJugador**).

#### Paso 6: Configurar la Tabla de Hechos

1. Hacer clic derecho sobre el cubo recién creado.
2. Seleccionar **Add Table**.
3. Configurar:
   * **Name**: `fact_progreso`
   * **Schema**: `dw`

#### Paso 7: Crear las Medidas del Cubo

Hacer clic derecho sobre el cubo y seleccionar **Add Measure** (repetir para cada medida):

**Medida 1: Oro Total**
* **Name**: Oro Total
* **Column**: `oro_ganado`
* **Aggregator**: `sum`

**Medida 2: Experiencia Total**
* **Name**: Experiencia Total
* **Column**: `xp_ganada`
* **Aggregator**: `sum`

**Medida 3: Duración Total**
* **Name**: Duración Total
* **Column**: `duracion_evento`
* **Aggregator**: `sum`

**Medida 4: Nivel Máximo**
* **Name**: Nivel Máximo
* **Column**: `nivel_resultante`
* **Aggregator**: `max`

#### Paso 8: Crear la Dimensión Jugador

1. Clic derecho en el cubo → **Add Dimension**.
2. Configurar:
   * **Name**: Jugador
   * **ForeignKey**: `id_jugador_sk`
3. Desplegar la dimensión y seleccionar **Hierarchy**.
4. Configurar la jerarquía:
   * **Name**: Jerarquía Jugador (opcional)
   * **PrimaryKey**: `id_jugador_sk`
   * **HasAll**: `true`
5. Agregar tabla:
   * Clic derecho en la jerarquía → **Add Table**.
   * **Name**: `dim_jugador`
   * **Schema**: `dw`
6. Agregar nivel:
   * Clic derecho en la jerarquía → **Add Level**.
   * **Name**: Usuario
   * **Column**: `nombre_usuario`
   * **UniqueMembers**: `true`

#### Paso 9: Crear la Dimensión Personaje

1. Clic derecho en el cubo → **Add Dimension**.
2. Configurar:
   * **Name**: Personaje
   * **ForeignKey**: `id_personaje_sk`
3. Desplegar la dimensión y seleccionar **Hierarchy**.
4. Configurar:
   * **PrimaryKey**: `id_personaje_sk`
   * **HasAll**: `true`
5. Agregar tabla:
   * Clic derecho en la jerarquía → **Add Table**.
   * **Name**: `dim_personaje`
   * **Schema**: `dw`
6. Agregar nivel:
   * Clic derecho en la jerarquía → **Add Level**.
   * **Name**: Clase
   * **Column**: `clase`
   * **UniqueMembers**: `true`

#### Paso 10: Crear la Dimensión Tiempo

1. Clic derecho en el cubo → **Add Dimension**.
2. Configurar:
   * **Name**: Tiempo
   * **ForeignKey**: `id_tiempo_sk`
   * **Type**: `TimeDimension` (si está disponible)
3. Desplegar la dimensión y seleccionar **Hierarchy**.
4. Configurar:
   * **PrimaryKey**: `id_tiempo_sk`
   * **HasAll**: `true`
5. Agregar tabla:
   * Clic derecho en la jerarquía → **Add Table**.
   * **Name**: `dim_tiempo`
   * **Schema**: `dw`
6. Agregar niveles jerárquicos (en orden descendente):
   * **Nivel 1 - Año:**
     * **Name**: Año
     * **Column**: `anio`
     * **Type**: `Numeric`
     * **UniqueMembers**: `true`
   * **Nivel 2 - Mes:**
     * **Name**: Mes
     * **Column**: `mes`
     * **Type**: `Numeric`
   * **Nivel 3 - Día:**
     * **Name**: Día
     * **Column**: `dia`
     * **Type**: `Numeric`

#### Paso 11: Crear la Dimensión Evento

1. Clic derecho en el cubo → **Add Dimension**.
2. Configurar:
   * **Name**: Evento
   * **ForeignKey**: `id_evento_sk`
3. Desplegar la dimensión y seleccionar **Hierarchy**.
4. Configurar:
   * **PrimaryKey**: `id_evento_sk`
   * **HasAll**: `true`
5. Agregar tabla:
   * Clic derecho en la jerarquía → **Add Table**.
   * **Name**: `dim_evento`
   * **Schema**: `dw`
6. Agregar niveles:
   * **Nivel 1 - Tipo Evento:**
     * **Name**: Tipo Evento
     * **Column**: `tipo_evento`
     * **UniqueMembers**: `true`
   * **Nivel 2 - Dificultad:**
     * **Name**: Dificultad
     * **Column**: `dificultad`

#### Paso 12: Guardar el Esquema XML

1. Ir a **File → Save As**.
2. Guardar el archivo como **cubo_videojuego.xml** en la carpeta `/sql/` del proyecto.

#### Paso 13: Validar el Esquema

1. En Schema Workbench, ir al menú **Tools → Validate Schema**.
2. Verificar que no haya errores en el panel de salida.
3. Si hay errores, revisar:
   * Nombres de tablas y columnas.
   * Claves foráneas correctamente configuradas.
   * Sintaxis XML del esquema.

#### Paso 14: Ejecutar Consultas MDX

1. En Schema Workbench, ir a **File → New → MDX Query**.
2. En la ventana de consultas MDX, escribir y ejecutar las consultas descritas en la sección de **Operaciones OLAP**.
3. Ejemplo de consulta Roll-Up:
   ```mdx
   SELECT { [Measures].[XP Ganada] } ON COLUMNS,
          { [Tiempo].[Anio].MEMBERS } ON ROWS
   FROM [CuboProgresoJugador]
   ```
4. Presionar el botón **Execute** o **F5** para ejecutar.
5. Verificar los resultados en el panel inferior.

#### Paso 15: Integración con la Aplicación Web (Opcional)

Si deseas integrar el cubo con la aplicación Flask del proyecto principal:

1. Asegurarse de que el archivo **cubo_videojuego.xml** esté en la carpeta `/sql/`.
2. Configurar el servidor Mondrian para ejecutarse como servicio (requiere configuración adicional de Tomcat o servidor Java).
3. Alternativamente, utilizar las consultas SQL directas implementadas en Flask como capa intermedia hasta tener el servidor Mondrian configurado en producción.

### Ventajas del Método Mondrian

✅ **Open Source**: Sin costos de licenciamiento.
✅ **Multiplataforma**: Funciona en Windows, Linux y macOS.
✅ **Cloud-Ready**: Ideal para deployments en Supabase/AWS/Azure.
✅ **Integración Web**: Se conecta nativamente con aplicaciones Flask/Django.
✅ **Estándar MDX**: Utiliza el lenguaje estándar de consultas OLAP.

---

## 📘 MÉTODO 2: Implementación con SQL Server + SSAS

### Stack Tecnológico

| Componente | Tecnología | Rol en el proyecto |
| :--- | :--- | :--- |
| **Base de Datos** | SQL Server 2022/2025 Developer | Data Warehouse local |
| **Motor OLAP** | SQL Server Analysis Services (SSAS) | Procesamiento multidimensional |
| **IDE** | Visual Studio 2022 Community | Diseño del proyecto SSAS |
| **Extensión** | Analysis Services Projects | Plugin para modelado de cubos |
| **Gestión** | SQL Server Management Studio (SSMS) | Administración y consultas |
| **Visualización** | Microsoft Excel 365 | Tablas dinámicas y dashboards |

### Procedimiento de Instalación y Configuración

#### Paso 0: Descarga e Instalación del Software

##### 0.1 Motor de Base de Datos: SQL Server 2025 Developer

1. Abrir el navegador y buscar **SQL Server**.
2. Hacer clic en la **primera opción** (sitio oficial de Microsoft).
3. En la sección *Introducción a SQL Server local o en la nube*, descargar la edición **Developer** (gratuita).
4. Ejecutar el instalador descargado.
5. Seleccionar la opción de instalación **Básica**.
6. Seguir el asistente de instalación hasta completar.
7. Al finalizar, el instalador ofrecerá descargar **SSMS** (no cerrar esta ventana).

##### 0.2 Gestor de Consultas: SSMS (SQL Server Management Studio)

1. Desde el enlace proporcionado por el instalador de SQL Server (o descargarlo del sitio oficial), descargar **SSMS**.
2. Ejecutar el instalador de SSMS.
3. Hacer clic en **Instalar** y esperar a que finalice el proceso.
4. Reiniciar el equipo si es necesario.

##### 0.3 Entorno de Desarrollo: Visual Studio 2022 Community

1. Descargar **Visual Studio Community 2022** desde el sitio oficial de Microsoft.
2. Ejecutar el instalador (Visual Studio Installer).
3. En la ventana de **Cargas de trabajo**, seleccionar:
   * ✅ **Procesamiento y almacenamiento de datos**
4. Hacer clic en **Instalar** y esperar a que se complete la descarga e instalación.

##### 0.4 Extensión para Cubos: Analysis Services Projects

1. Abrir un navegador y buscar **Analysis Services Projects Visual Studio**.
2. Acceder al **Visual Studio Marketplace**.
3. Descargar el archivo de la extensión (**Microsoft Analysis Services Projects 2022**).
4. **Cerrar completamente Visual Studio** si está abierto.
5. Ejecutar el instalador de la extensión descargada.
6. Reiniciar Visual Studio después de la instalación.

> **Nota importante:** Esta extensión NO viene preinstalada en Visual Studio y es esencial para trabajar con proyectos SSAS.

##### 0.5 Microsoft Excel

* Verificar que **Microsoft Excel** esté instalado (generalmente incluido en Microsoft Office 365 o versiones standalone).

---
## Paso 1: Crear la Base de Datos y Cargar Datos

1. Abrir SQL Server Management Studio (SSMS).
2. Hacer clic en Connect (o presionar Conectar).
3. En Server type, seleccionar Database Engine.
4. En Server name, escribir:
   - `.` (punto) para servidor local, O
   - `localhost`, O
   - El nombre completo del equipo (ej. LAPTOP-28K05CSV)
5. En Authentication, seleccionar Windows Authentication.
6. Hacer clic en Connect.
7. Una vez conectado, hacer clic en New Query (Nueva consulta) en la barra de herramientas.
8. Copiar y pegar el siguiente script DDL y DML completo:

```sql
-- ============================================
-- SCRIPT DE CREACIÓN Y POBLADO
-- Data Warehouse: Videojuego_DW
-- 10,000 Registros de Partidas Simuladas
-- ============================================

CREATE DATABASE Videojuego_DW;
GO

USE Videojuego_DW;
GO

-- 🔹 CREAR ESQUEMA
CREATE SCHEMA dw;
GO

-- ============================================
-- 1. CREACIÓN DE TABLAS (Esquema de Estrella)
-- ============================================

-- Dimensión Tiempo
CREATE TABLE dw.dim_tiempo (
    id_tiempo_sk INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE NOT NULL,
    dia INT CHECK (dia BETWEEN 1 AND 31),
    mes INT CHECK (mes BETWEEN 1 AND 12),
    anio INT CHECK (anio >= 2000),
    trimestre INT CHECK (trimestre BETWEEN 1 AND 4)
);

-- Dimensión Personaje
CREATE TABLE dw.dim_personaje (
    id_personaje_sk INT IDENTITY(1,1) PRIMARY KEY,
    id_personaje_nk INT NOT NULL,
    clase VARCHAR(50) NOT NULL,
    nivel_inicial INT CHECK (nivel_inicial >= 1),
    raza VARCHAR(50)
);

-- Dimensión Evento
CREATE TABLE dw.dim_evento (
    id_evento_sk INT IDENTITY(1,1) PRIMARY KEY,
    tipo_evento VARCHAR(50) NOT NULL,
    descripcion VARCHAR(100),
    dificultad VARCHAR(20) CHECK (dificultad IN ('Baja', 'Media', 'Alta'))
);

-- Dimensión Jugador
CREATE TABLE dw.dim_jugador (
    id_jugador_sk INT IDENTITY(1,1) PRIMARY KEY,
    id_jugador_nk INT NOT NULL,
    nombre_usuario VARCHAR(100) NOT NULL,
    correo VARCHAR(100),
    fecha_registro DATE,
    pais VARCHAR(50)
);

-- Tabla de Hechos
CREATE TABLE dw.fact_progreso (
    id_progreso_sk INT IDENTITY(1,1) PRIMARY KEY,
    id_jugador_sk INT FOREIGN KEY REFERENCES dw.dim_jugador(id_jugador_sk),
    id_personaje_sk INT FOREIGN KEY REFERENCES dw.dim_personaje(id_personaje_sk),
    id_tiempo_sk INT FOREIGN KEY REFERENCES dw.dim_tiempo(id_tiempo_sk),
    id_evento_sk INT FOREIGN KEY REFERENCES dw.dim_evento(id_evento_sk),
    xp_ganada INT CHECK (xp_ganada >= 0),
    oro_ganado INT CHECK (oro_ganado >= 0),
    nivel_resultante INT CHECK (nivel_resultante >= 1),
    duracion_evento INT CHECK (duracion_evento >= 0)
);

-- ============================================
-- 2. CARGA DE DATOS (10,000 Registros)
-- ============================================

SET NOCOUNT ON;
PRINT 'Iniciando carga de datos...';

-- Poblar Dimensión Tiempo (365 días del año 2024)
PRINT 'Generando dimensión Tiempo...';
DECLARE @FechaInicio DATE = '2024-01-01';
DECLARE @ContadorDias INT = 0;

WHILE @ContadorDias < 365
BEGIN
    DECLARE @FechaActual DATE = DATEADD(DAY, @ContadorDias, @FechaInicio);
    
    INSERT INTO dw.dim_tiempo (fecha, dia, mes, anio, trimestre)
    VALUES (
        @FechaActual,
        DAY(@FechaActual),
        MONTH(@FechaActual),
        YEAR(@FechaActual),
        DATEPART(QUARTER, @FechaActual)
    );
    
    SET @ContadorDias = @ContadorDias + 1;
END

-- Poblar Dimensión Personaje
PRINT 'Generando dimensión Personaje...';
INSERT INTO dw.dim_personaje (id_personaje_nk, clase, nivel_inicial, raza)
VALUES
    (1, 'Guerrero', 1, 'Humano'),
    (2, 'Mago', 1, 'Elfo'),
    (3, 'Arquero', 1, 'Orco'),
    (4, 'Sanador', 1, 'Enano'),
    (5, 'Asesino', 1, 'Elfo Oscuro');

-- Poblar Dimensión Evento
PRINT 'Generando dimensión Evento...';
INSERT INTO dw.dim_evento (tipo_evento, descripcion, dificultad)
VALUES
    ('Raid', 'Evento grupal de alto riesgo', 'Alta'),
    ('PVP', 'Combate jugador vs jugador', 'Media'),
    ('Farming', 'Recolección de recursos', 'Baja'),
    ('Dungeon', 'Exploración de mazmorra', 'Media');

-- Poblar Dimensión Jugador (100 jugadores)
PRINT 'Generando dimensión Jugador...';
DECLARE @i INT = 1;

WHILE @i <= 100
BEGIN
    INSERT INTO dw.dim_jugador (id_jugador_nk, nombre_usuario, correo, fecha_registro, pais)
    VALUES (
        @i,
        'User_' + CAST(@i AS VARCHAR),
        'user' + CAST(@i AS VARCHAR) + '@game.com',
        '2023-01-01',
        CASE (ABS(CHECKSUM(NEWID())) % 5)
            WHEN 0 THEN 'Mexico'
            WHEN 1 THEN 'USA'
            WHEN 2 THEN 'España'
            WHEN 3 THEN 'Colombia'
            ELSE 'Chile'
        END
    );
    SET @i = @i + 1;
END

-- Poblar Tabla de Hechos (10,000 partidas)
PRINT 'Generando 10,000 partidas (esto puede tomar unos segundos)...';
DECLARE @p INT = 1;

WHILE @p <= 10000
BEGIN
    INSERT INTO dw.fact_progreso (
        id_jugador_sk,
        id_personaje_sk,
        id_tiempo_sk,
        id_evento_sk,
        xp_ganada,
        oro_ganado,
        nivel_resultante,
        duracion_evento
    )
    VALUES (
        (ABS(CHECKSUM(NEWID())) % 100) + 1,  -- Jugador aleatorio (1-100)
        (ABS(CHECKSUM(NEWID())) % 5) + 1,    -- Personaje aleatorio (1-5)
        (ABS(CHECKSUM(NEWID())) % 365) + 1,  -- Día aleatorio (1-365)
        (ABS(CHECKSUM(NEWID())) % 4) + 1,    -- Evento aleatorio (1-4)
        (ABS(CHECKSUM(NEWID())) % 5000) + 100, -- XP (100-5099)
        (ABS(CHECKSUM(NEWID())) % 1000) + 10,  -- Oro (10-1009)
        (ABS(CHECKSUM(NEWID())) % 60) + 1,     -- Nivel (1-60)
        (ABS(CHECKSUM(NEWID())) % 120) + 5     -- Duración (5-124 min)
    );
    SET @p = @p + 1;
END

PRINT '';
PRINT '============================================';
PRINT '¡CARGA COMPLETADA EXITOSAMENTE!';
PRINT '============================================';
PRINT 'Base de datos: Videojuego_DW';
PRINT 'Registros en dim_tiempo: 365';
PRINT 'Registros en dim_personaje: 5';
PRINT 'Registros en dim_evento: 4';
PRINT 'Registros en dim_jugador: 100';
PRINT 'Registros en fact_progreso: 10,000';
PRINT '============================================';
```

9. Presionar **F5** o hacer clic en **Execute** para ejecutar el script completo.
10. Verificar en el panel de mensajes que la ejecución haya sido exitosa y que se muestren los conteos de registros.

---

## Paso 2: Crear el Proyecto en Visual Studio

1. Abrir **Visual Studio 2022**.
2. Hacer clic en **Crear un nuevo proyecto** (Create a new project).
3. En el cuadro de búsqueda escribir **Analysis**.
4. Seleccionar la plantilla **Proyecto multidimensional de Analysis Services** (Analysis Services Multidimensional Project).
5. Hacer clic en **Siguiente**.
6. Configurar el proyecto:
   * **Nombre del proyecto**: CuboVideojuego_SQL
   * **Ubicación**: Elegir una carpeta de trabajo
   * **Nombre de la solución**: Puede dejarse igual que el proyecto
7. Hacer clic en **Crear**.
8. Esperar a que Visual Studio cargue la estructura del proyecto.

---

## Paso 3: Crear el Origen de Datos (Data Source)

1. En el **Explorador de soluciones** (Solution Explorer), ubicar la carpeta **Orígenes de datos** (Data Sources).
2. Hacer clic derecho sobre **Orígenes de datos** → **Nuevo origen de datos** (New Data Source).
3. En el asistente que se abre, hacer clic en **Siguiente**.
4. Hacer clic en el botón **Nuevo...** (New...).
5. En la ventana de **Administrador de conexiones**, configurar:
   * **Proveedor**: Dejar el predeterminado (Native OLE DB\SQL Server Native Client).
   * **Nombre del servidor**: Escribir `.` (punto) o `localhost` o el nombre del equipo.
   * **Autenticación**: Seleccionar **Usar autenticación de Windows**.
   * **Seleccionar o especificar un nombre de base de datos**: Elegir **Videojuego_DW**.
6. Hacer clic en **Probar conexión** para verificar que sea exitosa.
7. Si la prueba es exitosa, hacer clic en **Aceptar**.
8. Hacer clic en **Siguiente**.

### ⚠️ Paso Crítico de Seguridad - Información de Suplantación

9. En la ventana **Información de suplantación** (Impersonation Information):
   * Seleccionar la opción **Utilizar un nombre de usuario y contraseña de Windows específicos** (Use a specific Windows user name and password).
   * Escribir **tu nombre de usuario de Windows** (ej. `LAPTOP-28K05CSV\Usuario` o solo `Usuario`).
   * Escribir **tu contraseña de Windows**.
   * ⚠️ **IMPORTANTE**: Esta es la cuenta que SSAS usará para acceder a los datos. Debe tener permisos en SQL Server.
10. Hacer clic en **Siguiente**.
11. Asignar un nombre al origen de datos (ej. `Videojuego DW`) y hacer clic en **Finalizar**.

---

## Paso 4: Crear las Vistas del Origen de Datos (Data Source Views)

1. En el **Explorador de soluciones**, hacer clic derecho en **Vistas del origen de datos** (Data Source Views) → **Nueva vista del origen de datos** (New Data Source View).
2. Hacer clic en **Siguiente**.
3. Seleccionar el origen de datos creado en el paso anterior (**Videojuego DW**).
4. Hacer clic en **Siguiente**.
5. En la ventana de selección de tablas y vistas:
   * En **Objetos disponibles**, seleccionar **todas las tablas** del esquema `dw`:
     * `dw.dim_tiempo`
     * `dw.dim_jugador`
     * `dw.dim_personaje`
     * `dw.dim_evento`
     * `dw.fact_progreso`
   * Usar el botón **>>** (Agregar) para moverlas a **Objetos incluidos**.
6. Hacer clic en **Siguiente**.
7. Asignar un nombre a la vista (ej. `Vista DW Videojuego`) y hacer clic en **Finalizar**.
8. Se abrirá el diseñador visual mostrando el **esquema de estrella** con las relaciones entre la tabla de hechos y las dimensiones.

---

## Paso 5: Crear las Dimensiones del Cubo

Visual Studio puede detectar automáticamente las dimensiones, pero es recomendable crearlas manualmente para mayor control.

1. En el **Explorador de soluciones**, hacer clic derecho en **Dimensiones** (Dimensions) → **Nueva dimensión** (New Dimension).
2. Hacer clic en **Siguiente**.
3. Seleccionar **Usar una tabla existente** (Use an existing table).
4. Hacer clic en **Siguiente**.
5. Configurar la dimensión:
   * **Tabla principal**: Seleccionar `dw.dim_tiempo`.
   * **Columna de clave**: Seleccionar `id_tiempo_sk`.
   * **Columna de nombre**: Seleccionar `fecha` (o dejar automático).
6. Hacer clic en **Siguiente**.
7. Seleccionar los atributos de la dimensión:
   * ✅ `anio`
   * ✅ `trimestre`
   * ✅ `mes`
   * ✅ `dia`
   * ✅ `fecha`
8. Hacer clic en **Siguiente** y luego en **Finalizar**.
9. **Repetir el proceso** para las dimensiones:
   * **dim_jugador** (clave: `id_jugador_sk`, atributos: `nombre_usuario`, `pais`, `fecha_registro`)
   * **dim_personaje** (clave: `id_personaje_sk`, atributos: `clase`, `raza`, `nivel_inicial`)
   * **dim_evento** (clave: `id_evento_sk`, atributos: `tipo_evento`, `dificultad`, `descripcion`)

---

## Paso 6: Diseñar el Cubo OLAP

1. En el **Explorador de soluciones**, hacer clic derecho en **Cubos** (Cubes) → **Nuevo cubo** (New Cube).
2. Hacer clic en **Siguiente**.
3. Seleccionar **Usar tablas existentes** (Use existing tables).
4. Hacer clic en **Siguiente**.
5. En **Tabla del grupo de medida**, seleccionar `dw.fact_progreso`.
6. Hacer clic en **Siguiente**.
7. En **Seleccionar medidas**, verificar que estén marcadas:
   * ✅ `xp_ganada`
   * ✅ `oro_ganado`
   * ✅ `nivel_resultante`
   * ✅ `duracion_evento`
   * ✅ `Fact Progreso Count` (medida derivada de conteo)
   * ❌ **Desmarcar** los campos `id_*_sk` (claves foráneas).
8. Hacer clic en **Siguiente**.
9. En **Seleccionar dimensiones existentes**, verificar que estén seleccionadas:
   * ✅ `Dim Tiempo`
   * ✅ `Dim Jugador`
   * ✅ `Dim Personaje`
   * ✅ `Dim Evento`
10. Hacer clic en **Siguiente**.
11. Asignar un nombre al cubo (ej. `Videojuego DW`) y hacer clic en **Finalizar**.

---

## Paso 7: Implementar el Cubo (Deploy)

1. Hacer clic derecho sobre el **nombre del proyecto** (CuboVideojuego_SQL) en el Explorador de soluciones.
2. Seleccionar **Propiedades** (Properties).
3. En el panel izquierdo, seleccionar **Implementación** (Deployment).
4. Verificar y modificar (si es necesario):
   * **Servidor**: Reemplazar `localhost` por el **nombre exacto de tu equipo** (ej. `LAPTOP-28K05CSV`).
     * Para obtener el nombre del equipo: Clic derecho en **Este equipo** → **Propiedades** → Ver el nombre completo.
   * **Base de datos**: Dejar como `CuboVideojuego_SQL` (o cambiar si se desea).
5. Hacer clic en **Aceptar**.
6. Hacer clic derecho sobre el proyecto → **Implementar** (Deploy).
7. Observar el panel de **Salida** (Output) y esperar a que todos los pasos muestren **verde** (Success).
8. Si hay errores:
   * Verificar que SQL Server Analysis Services esté instalado y en ejecución.
   * Revisar las credenciales de suplantación configuradas en el Paso 3.

---

## Paso 8: Procesar el Cubo (Process)

1. Hacer clic derecho sobre el **nombre del proyecto** en el Explorador de soluciones.
2. Seleccionar **Procesar** (Process).
3. En la ventana de **Procesar cubo**, hacer clic en **Ejecutar** (Run).
4. Esperar a que el procesamiento finalice (barra de progreso).
5. Hacer clic en **Cerrar** cuando termine.

> **Nota:** El procesamiento carga los datos del Data Warehouse en el motor OLAP para análisis rápidos.

---

## Paso 9: Realizar Consultas Manuales en Visual Studio

1. En el **Explorador de soluciones**, hacer doble clic sobre el cubo creado (ej. `Videojuego DW.cube`).
2. Ir a la pestaña **Explorador** (Browser) en el diseñador del cubo.
3. Si está deshabilitada, hacer clic en el botón **Reconectar** (ícono de actualizar).
4. Arrastrar medidas y dimensiones para explorar los datos:
   * **Ejemplo 1 (Roll-Up por Año):**
     * Arrastrar `XP Ganada` al área de **Valores**.
     * Arrastrar `Dim Tiempo → Anio` al área de **Filas**.
   * **Ejemplo 2 (Análisis por Clase):**
     * Arrastrar `Oro Ganado` al área de **Valores**.
     * Arrastrar `Dim Personaje → Clase` al área de **Filas**.
     * Arrastrar `Dim Evento → Dificultad` al área de **Columnas**.
5. Experimentar con diferentes combinaciones de dimensiones y medidas.

---

## Paso 10: Configurar Conexión MDX en SSMS (Analysis Services)

1. Abrir **SQL Server Management Studio (SSMS)**.
2. En la ventana de conexión, configurar:
   * **Server type**: Seleccionar **Analysis Services**.
   * **Server name**: Escribir el nombre del equipo (ej. `LAPTOP-28K05CSV`).
   * **Authentication**: Seleccionar **Windows Authentication**.
3. Hacer clic en **Connect**.
4. En el **Explorador de objetos**, expandir **Bases de datos** (Databases).
5. Localizar la base de datos **CuboVideojuego_SQL** (o el nombre configurado).
6. Hacer clic derecho sobre la base de datos → **Nueva consulta** → **MDX**.
7. Escribir y ejecutar consultas MDX (ver ejemplos en la sección de Operaciones OLAP).

**Ejemplo de consulta MDX en SSMS:**
```mdx
SELECT 
    { [Measures].[XP Ganada] } ON COLUMNS,
    { [Dim Tiempo].[Anio].MEMBERS } ON ROWS
FROM [Videojuego DW]
```

8. Presionar **F5** o hacer clic en **Ejecutar** para ver los resultados.

---

## Paso 11: Visualizar en Excel (Dashboard Interactivo)

1. Abrir **Microsoft Excel**.
2. En la cinta de opciones superior, ir a la pestaña **Datos** (Data).
3. Hacer clic en **Obtener datos** (Get Data) → **De base de datos** (From Database) → **De SQL Server Analysis Services** (From SQL Server Analysis Services).
4. En la ventana de conexión:
   * **Servidor**: Escribir el nombre del equipo (ej. `LAPTOP-28K05CSV`) o simplemente un punto `.` si es local.
   * **Credenciales**: Seleccionar **Autenticación de Windows** (Windows Authentication).
5. Hacer clic en **Aceptar** (OK).
6. En el **Navegador** (Navigator), expandir la base de datos **CuboVideojuego_SQL**.
7. Seleccionar el cubo **Videojuego DW** y hacer clic en **Cargar** (Load).
8. Excel mostrará una ventana de **Campos de tabla dinámica** (PivotTable Fields) a la derecha.
9. Seleccionar **Informe de tabla dinámica** (PivotTable Report).

### Configuración Sugerida del Dashboard:

* **Valores (Values):**
  * ✅ XP Ganada
  * ✅ Oro Ganado
* **Filas (Rows):**
  * ✅ Dim Jugador → País
* **Columnas (Columns):**
  * ✅ Dim Personaje → Clase
* **Filtros/Segmentación (Filters/Slicers):**
  * ✅ Dim Evento → Dificultad
  * ✅ Dim Tiempo → Año

10. Personalizar el formato de la tabla dinámica:
    * Aplicar estilos de tabla (Table Styles).
    * Agregar formato condicional (Conditional Formatting) para resaltar valores máximos/mínimos.
    * Insertar gráficos dinámicos (PivotCharts) desde **Insertar** → **Gráfico dinámico**.

## Ventajas del Método SSAS

✅ **Integración Microsoft**: Ecosistema completo (SQL Server + SSAS + Excel).
✅ **Rendimiento Optimizado**: Motor OLAP empresarial con agregaciones precalculadas.
✅ **Interfaz Visual**: Diseñador gráfico de cubos en Visual Studio.
✅ **Excel Nativo**: Conexión directa con tablas dinámicas sin configuración adicional.
✅ **Enterprise Ready**: Escalabilidad para grandes volúmenes de datos.

---

## 📊 Comparativa de Métodos

| Característica | PostgreSQL + Mondrian | SQL Server + SSAS |
|----------------|----------------------|-------------------|
| **Licenciamiento** | Open Source (Gratis) | Developer (Gratis), Enterprise (Licencia) |
| **Plataforma** | Multiplataforma (Linux, Windows, Mac) | Exclusivo Windows |
| **Deployment** | Cloud-Ready (Supabase, AWS, Azure) | Preferente On-Premise / Azure |
| **Integración Web** | Nativa con Flask/Django | Requiere servicios adicionales |
| **Curva de Aprendizaje** | Moderada (XML + MDX) | Moderada (GUI + MDX) |
| **Visualización** | Web Dashboard | Excel Nativo |
| **Rendimiento** | Excelente (ROLAP) | Excelente (MOLAP/ROLAP) |
| **Comunidad** | Amplia (Open Source) | Amplia (Microsoft) |

---

## 📊 Resultados del Proyecto Dual

### Métricas del Sistema

| Métrica | Método PostgreSQL | Método SQL Server |
|---------|-------------------|-------------------|
| **Registros en DW** | Variable (según ETL) | 10,000 partidas |
| **Dimensiones** | 4 dimensiones | 4 dimensiones |
| **Medidas** | 5 medidas | 5 medidas |
| **Operaciones OLAP** | 4+ implementadas | 4+ implementadas |
| **Consultas MDX** | 6+ validadas | 6+ validadas |
| **Tiempo de Respuesta** | < 500ms | < 200ms |
| **Escalabilidad** | Alta (Cloud) | Alta (Enterprise) |

### Capacidades Analíticas Compartidas

- ✅ Análisis temporal (2022-2026 / 2024)
- ✅ Análisis por jugador y país
- ✅ Análisis por clase de personaje
- ✅ Análisis por tipo de evento y dificultad
- ✅ Agregaciones dinámicas (SUM, AVG, MAX, COUNT)
- ✅ Filtrado multidimensional (Slice, Dice)
- ✅ Navegación jerárquica (Roll-Up, Drill-Down)
- ✅ Consultas MDX profesionales
- ✅ Dashboards interactivos

---

## 🎯 Conclusiones

Este proyecto representa una **solución de Business Intelligence de clase empresarial** implementada mediante dos enfoques tecnológicos complementarios:

### Logros Principales

✅ **Arquitectura Dual**: Dos implementaciones completas (Open Source + Microsoft) del mismo modelo dimensional.
✅ **Modelo Dimensional Robusto**: Esquema estrella optimizado con 4 dimensiones y métricas clave.
✅ **Operaciones OLAP Completas**: Roll-up, Drill-down, Slice, Dice implementadas en ambos motores.
✅ **Consultas MDX Profesionales**: Lenguaje estándar OLAP validado en Mondrian y SSAS.
✅ **Dashboards Interactivos**: Visualización web (Flask) y Excel con actualización en tiempo real.
✅ **Escalabilidad**: Preparado para despliegue cloud (PostgreSQL) y on-premise (SQL Server).
✅ **Documentación Exhaustiva**: Procedimientos detallados paso a paso para ambos métodos.

### Aprendizajes Clave

- Diseño de Data Warehouses con esquema estrella
- Implementación de cubos OLAP en dos tecnologías diferentes
- Proceso ETL completo (Extract, Transform, Load)
- Consultas MDX avanzadas para análisis multidimensional
- Arquitectura ROLAP (Mondrian) vs MOLAP (SSAS)
- Integración de BI con aplicaciones web y hojas de cálculo
- Despliegue de soluciones analíticas en entornos cloud y locales
- Buenas prácticas de seguridad en conexiones de datos

### Lecciones Aprendidas sobre MDX

Durante la implementación en ambos motores OLAP, se identificaron patrones críticos:

#### ❌ Error Común: Dimensión Duplicada
```mdx
-- INCORRECTO (genera error)
SELECT [Measures].[XP Ganada] ON COLUMNS,
       [Tiempo].[Mes].MEMBERS ON ROWS
FROM [Cubo]
WHERE ([Tiempo].[Año].[2025])
```

**Problema:** No se puede tener la misma dimensión en filas y en WHERE.

#### ✅ Solución: Navegación Jerárquica
```mdx
-- CORRECTO (Mondrian)
SELECT [Measures].[XP Ganada] ON COLUMNS,
       [Tiempo].[Año].[2025].Children ON ROWS
FROM [CuboProgresoJugador]

-- CORRECTO (SSAS - sintaxis alternativa)
SELECT [Measures].[XP Ganada] ON COLUMNS,
       [Dim Tiempo].[Mes].MEMBERS ON ROWS
FROM [Videojuego DW]
WHERE ([Dim Tiempo].[Anio].&[2025])
```

**Explicación:** Cada motor OLAP puede tener ligeras variaciones en la sintaxis MDX, pero el principio de navegación dimensional se mantiene consistente.

#### 📌 Regla de Oro MDX (Universal)

> **No se puede filtrar con WHERE usando la misma dimensión que está en las filas/columnas.**
> 
> - Para navegar dentro de una dimensión: usar `.Children`, `.Members`, `.Descendants`
> - Para filtrar con otra dimensión diferente: usar `WHERE`

---

## 🚀 Mejoras Futuras

### Corto Plazo
- [ ] Implementar KPIs visuales (semáforos) en ambos cubos
- [ ] Agregar más dimensiones (ej. Gremio, Mascota)
- [ ] Crear vistas materializadas para optimización
- [ ] Configurar refresh automático de datos (ETL programado)

### Mediano Plazo
- [ ] Migrar Dashboard Excel a Power BI (método Microsoft)
- [ ] Implementar servidor Mondrian en Docker (método PostgreSQL)
- [ ] Crear API REST para consultas MDX programáticas
- [ ] Agregar autenticación y roles de acceso

### Largo Plazo
- [ ] Implementar streaming de datos en tiempo real
- [ ] Machine Learning sobre datos históricos (predicción de abandono)
- [ ] Dashboard de administración centralizado
- [ ] Módulo de alertas automáticas (ej. caída de engagement)

---

## 📚 Referencias

### Documentación Oficial
- **PostgreSQL Documentation**: https://www.postgresql.org/docs/
- **Mondrian OLAP**: https://mondrian.pentaho.com/documentation/
- **SQL Server Analysis Services**: https://docs.microsoft.com/en-us/analysis-services/
- **MDX Language Reference**: https://docs.microsoft.com/en-us/sql/mdx/

### Libros y Recursos
- **Kimball, Ralph**: *The Data Warehouse Toolkit* - Biblia del diseño dimensional
- **Microsoft SQL Server Analysis Services**: Documentación oficial de SSAS
- **Pentaho Community**: Foros y tutoriales de Mondrian

### Herramientas Utilizadas
- **Schema Workbench**: Editor visual de cubos Mondrian
- **Visual Studio**: IDE para proyectos SSAS
- **SSMS**: Gestor de consultas MDX para SQL Server
- **Flask**: Framework web para integración PostgreSQL

---

## 👥 Contribuciones

Este proyecto fue desarrollado como parte de un proyecto académico de **Bases de Datos** enfocado en **Business Intelligence**.

### Autores
- **Rodriguez Salcedo Liam Ariel**
- **Sánchez Zenteno Diego Alejandro**

### Institución
**INSTITUTO POLITÉCNICO NACIONAL**
- **ESCUELA SUPERIOR DE CÓMPUTO**
- **Materia:** BASE DE DATOS
- **Docente:** GABRIEL HURTADO AVILÉS
- **Grupo:** 3CV5

### Repositorio
- GitHub: https://github.com/IISGRI/Proyecto-BD

---

## 🪪 Licencia

Este proyecto está desarrollado con **fines educativos**.

- ✅ Libre para estudiar y aprender
- ✅ Libre para modificar y extender
- ✅ Libre para usar como referencia académica
- ✅ Prohibido uso comercial sin autorización

---

## 🎮 Notas Finales

Este proyecto demuestra la **versatilidad y robustez de las soluciones de Business Intelligence modernas**, implementando el mismo modelo analítico en dos ecosistemas tecnológicos diferentes:

1. **Enfoque Open Source**: Ideal para startups, proyectos web y entornos cloud-first.
2. **Enfoque Microsoft**: Ideal para corporaciones, análisis empresariales y entornos Windows.

Ambas soluciones son **profesionales, escalables y listas para producción**, representando un conocimiento integral de:
- Bases de datos relacionales (OLTP)
- Data Warehousing (OLAP)
- Proceso ETL
- Análisis multidimensional
- Visualización de datos
- Despliegue en múltiples plataformas

**¡Gracias por explorar este proyecto de Business Intelligence End-to-End! 🎮⚔️📊**

---

*Última actualización: Enero 2026*
