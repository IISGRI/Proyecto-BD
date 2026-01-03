-- =========================================
-- ESQUEMA DATA WAREHOUSE
-- =========================================
CREATE SCHEMA IF NOT EXISTS dw;

COMMENT ON SCHEMA dw IS
'Esquema del Data Warehouse para análisis del sistema de videojuego';

-- =========================================
-- DIMENSIÓN: JUGADOR
-- =========================================
CREATE TABLE dw.dim_jugador (
    id_jugador_sk SERIAL PRIMARY KEY,
    id_jugador_nk INTEGER NOT NULL,
    nombre_usuario TEXT NOT NULL,
    correo TEXT,
    fecha_registro DATE,
    pais TEXT
);

COMMENT ON TABLE dw.dim_jugador IS
'Dimensión Jugador con clave sustituta y atributos descriptivos';

-- =========================================
-- DIMENSIÓN: PERSONAJE
-- =========================================
CREATE TABLE dw.dim_personaje (
    id_personaje_sk SERIAL PRIMARY KEY,
    id_personaje_nk INTEGER NOT NULL,
    clase TEXT NOT NULL,
    nivel_inicial INTEGER CHECK (nivel_inicial >= 1),
    raza TEXT
);

COMMENT ON TABLE dw.dim_personaje IS
'Dimensión Personaje del jugador';

-- =========================================
-- DIMENSIÓN: TIEMPO
-- =========================================
CREATE TABLE dw.dim_tiempo (
    id_tiempo_sk SERIAL PRIMARY KEY,
    fecha DATE NOT NULL UNIQUE,
    dia INTEGER NOT NULL CHECK (dia BETWEEN 1 AND 31),
    mes INTEGER NOT NULL CHECK (mes BETWEEN 1 AND 12),
    anio INTEGER NOT NULL CHECK (anio >= 2000),
    trimestre INTEGER NOT NULL CHECK (trimestre BETWEEN 1 AND 4)
);

COMMENT ON TABLE dw.dim_tiempo IS
'Dimensión Tiempo para análisis temporal';

-- =========================================
-- DIMENSIÓN: EVENTO
-- =========================================
CREATE TABLE dw.dim_evento (
    id_evento_sk SERIAL PRIMARY KEY,
    tipo_evento TEXT NOT NULL,
    descripcion TEXT,
    dificultad TEXT CHECK (dificultad IN ('baja', 'media', 'alta'))
);

COMMENT ON TABLE dw.dim_evento IS
'Dimensión Evento del videojuego';

-- =========================================
-- TABLA DE HECHOS: PROGRESO
-- =========================================
CREATE TABLE dw.fact_progreso (
    id_progreso SERIAL PRIMARY KEY,

    id_jugador_sk INTEGER NOT NULL
        REFERENCES dw.dim_jugador(id_jugador_sk),

    id_personaje_sk INTEGER NOT NULL
        REFERENCES dw.dim_personaje(id_personaje_sk),

    id_tiempo_sk INTEGER NOT NULL
        REFERENCES dw.dim_tiempo(id_tiempo_sk),

    id_evento_sk INTEGER NOT NULL
        REFERENCES dw.dim_evento(id_evento_sk),

    xp_ganada INTEGER NOT NULL CHECK (xp_ganada >= 0),
    oro_ganado INTEGER NOT NULL CHECK (oro_ganado >= 0),
    nivel_resultante INTEGER CHECK (nivel_resultante >= 1),
    duracion_evento INTEGER CHECK (duracion_evento >= 0)
);

COMMENT ON TABLE dw.fact_progreso IS
'Tabla de hechos que almacena el progreso del jugador por evento y tiempo';

-- =========================================
-- ÍNDICES RECOMENDADOS
-- =========================================
CREATE INDEX idx_fact_jugador ON dw.fact_progreso(id_jugador_sk);
CREATE INDEX idx_fact_personaje ON dw.fact_progreso(id_personaje_sk);
CREATE INDEX idx_fact_tiempo ON dw.fact_progreso(id_tiempo_sk);
CREATE INDEX idx_fact_evento ON dw.fact_progreso(id_evento_sk);
