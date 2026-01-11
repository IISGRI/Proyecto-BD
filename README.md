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
- **Bootstrap** 5.x
- **CSS** personalizado
- **JavaScript** vanilla
- **HTML5** + Jinja2

---

## 📁 5. Estructura del Proyecto

```
PROYECTO/
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
|
|
├── CuboDeDatos(VisualStudio)/
    │
    ├── 📁 Database/           # Scripts T-SQL de generación de datos
    ├── 📁 SSAS_Project/       # Solución completa de Visual Studio
    ├── 📁 Excel/         # Reporte final en Excel (.xlsx)
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
Este proyecto implementa una solución integral de **Business Intelligence (End-to-End)** diseñada para analizar el comportamiento de jugadores en un videojuego MMORPG masivo. A través de la simulación de **10,000 partidas**, el sistema transforma datos transaccionales en conocimiento estratégico.

Utilizando **Microsoft Analysis Services (SSAS)**, se construyó un Cubo OLAP que permite a los analistas cruzar variables complejas (Tiempo, Geografía, Clase de Personaje) con métricas de rendimiento (XP, Oro) en milisegundos, visualizando los hallazgos en un Dashboard interactivo.

---

## 📐 Diseño del Cubo OLAP (Metadatos)
El núcleo del proyecto es el cubo multidimensional **`[Videojuego DW]`**. A continuación se detalla su estructura interna:

### 1. Grupos de Medida (Facts)
Estas son las métricas numéricas que se calculan automáticamente:

| Medida (Measure) | Tipo de Agregación | Descripción |
| :--- | :--- | :--- |
| **XP Ganada** | `SUM` | Total de puntos de experiencia acumulados por los jugadores. |
| **Oro Ganado** | `SUM` | Cantidad total de moneda virtual generada en el juego. |
| **Recuento de Partidas** | `COUNT` | Número total de sesiones de juego registradas. |
| **Duración Evento** | `SUM` / `AVG` | Tiempo total invertido por los jugadores en misiones. |
| **Nivel Resultante** | `MAX` | El nivel máximo alcanzado en el periodo analizado. |

### 2. Dimensiones (Contexto)
El cubo permite "rebanar" (slice) la información a través de los siguientes ejes:

* **📅 Dimensión Tiempo:** Jerarquía completa `Año > Trimestre > Mes > Día`. Permite análisis de estacionalidad.
* **🌍 Dimensión Jugador:** Información demográfica (`País`) y de cuenta (`Fecha de Registro`, `Correo`).
* **🛡️ Dimensión Personaje:** Arquetipos de juego. Incluye atributos como `Clase` (Guerrero, Mago...), `Raza` y `Nivel Inicial`.
* **🔥 Dimensión Evento:** Contexto de la partida. Clasifica las sesiones por `Tipo` (Raid, PVP, Farming) y `Dificultad` (Alta, Media, Baja).

---

## 📊 Arquitectura de la Solución

El flujo de datos sigue una arquitectura ETL (Extract, Transform, Load) clásica:

```mermaid
graph LR
    A["Generador SQL (Script)"] -- 10k Registros --> B((Data Warehouse));
    B -- Proceso ETL --> C["Cubo SSAS (OLAP)"];
    C -- MDX Queries --> D[Excel Dashboard];
    D -- Insights --> E[Toma de Decisiones];
```
1. Fuente de Datos: Script SQL que simula un entorno transaccional, generando 10,000 registros con integridad referencial y distribución estadística aleatoria.
2. Data Warehouse: Base de datos Videojuego_DW modelada bajo un Esquema de Estrella (Star Schema).
3. Motor OLAP: Servidor Analysis Services que procesa y almacena las agregaciones para consultas instantáneas.
4. Frontend: Interfaz de usuario en Excel conectada en vivo al servidor.
## 🧠 Operaciones OLAP & Consultas MDX
Se implementaron consultas avanzadas utilizando el lenguaje MDX (Multidimensional Expressions) para demostrar la potencia del cubo:
1. 🔼 Roll-Up (Agregación)
Ver el total de XP agrupada por Año.
```
  SELECT { [Measures].[XP Ganada] } ON COLUMNS,
       { [Dim Tiempo].[Anio].MEMBERS } ON ROWS
FROM [Videojuego DW]
```
2. 🔽 Drill-Down (Desglose)
Profundizar en los meses del año 2024.
```
  SELECT { [Measures].[XP Ganada] } ON COLUMNS,
       { [Dim Tiempo].[Mes].MEMBERS } ON ROWS
FROM [Videojuego DW]
WHERE ( [Dim Tiempo].[Anio].&[2024] )
```
3. 🎲 Dice & Slice (Corte Multidimensional)
Filtrar: Clase 'Guerrero' + Dificultad 'Alta'.
```
  SELECT { [Measures].[Oro Ganado] } ON COLUMNS,
       { [Dim Personaje].[Clase].&[Guerrero] } ON ROWS
FROM [Videojuego DW]
WHERE ( [Dim Evento].[Dificultad].&[Alta] )
```
4. 🏆 Ranking (Top Count)
Los 5 jugadores más valiosos (MVP) por XP.
```
  SELECT { [Measures].[XP Ganada] } ON COLUMNS,
       TOPCOUNT( [Dim Jugador].[Nombre Usuario].MEMBERS, 5, [Measures].[XP Ganada] ) ON ROWS
FROM [Videojuego DW]
```
## 🛠️ Stack Tecnológico & Requisitos
| Componente | Tecnología | Rol en el proyecto |
| :--- | :--- | :--- |
| **Base de Datos** | SQL Server 2022 Developer | Almacén de datos (DW) |
| **IDE** | Visual Studio 2022 | Diseño y modelado del cubo |
| **Extensión** | SSAS Projects Extension | Plugin para modelos multidimensionales |
| **Gestión** | SSMS (Management Studio) | Ejecución de scripts y consultas MDX |
| **Visualización** | Microsoft Excel 365 | Dashboard interactivo y tablas dinámicas |
## ⚙️ Guía de Instalación y Ejecución
Sigue estos pasos para replicar el entorno de desarrollo:

Paso 1: Base de Datos
1. Abre SSMS y conecta a tu instancia local.
2. Abre el archivo /Database/scripts.sql
3. Ejecuta el script (F5). Esto creará la BD y poblará las tablas con 10,000 registros.

Paso 2: Servidor de Análisis
1. Abre el proyecto /SSAS_Project/CuboVideojuego_SQL.slnx en Visual Studio.
2. Abre el archivo Videojuego DW.ds (Data Source).
3. Edita la Información de Suplantación: Selecciona "Usar usuario y contraseña de Windows" e ingresa tus credenciales de Administrador.
4. Menú Proyecto -> Implementar (Deploy).
5. Menú Proyecto -> Procesar (Process) -> Ejecutar.

Paso 3: Dashboard
1. Abre el archivo /Excel/tablaDinamica(cuboDeDatos).xlsx.
2. Ve a la pestaña Datos -> Actualizar todo.
3. ¡Listo! El reporte ahora muestra datos en tiempo real desde tu PC.

## 🚀 Posibles Mejoras (Trabajo Futuro)
- Implementación de KPIs (Key Performance Indicators) visuales (semáforos) dentro del cubo.
- Migración del Frontend a Power BI para visualizaciones web.
- Automatización del proceso de carga (ETL) mediante SSIS (Integration Services).

