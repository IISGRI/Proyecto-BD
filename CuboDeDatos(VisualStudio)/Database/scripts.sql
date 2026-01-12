-- DDL
USE master;
GO

-- 1. CREAMOS LA BASE DE DATOS (Si no existe)
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'Videojuego_DW')
BEGIN
    CREATE DATABASE Videojuego_DW;
END
GO

-- 2. ¡IMPORTANTE! NOS CAMBIAMOS A ESA BASE DE DATOS
USE Videojuego_DW;
GO

-- 3. CREAMOS EL ESQUEMA 'dw'
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'dw')
BEGIN
    EXEC('CREATE SCHEMA dw')
END
GO

-- 4. AHORA SÍ, TUS TABLAS (Pegadas tal cual las tenías)

-- DIMENSIÓN: JUGADOR
CREATE TABLE dw.dim_jugador (
    id_jugador_sk INT IDENTITY(1,1) PRIMARY KEY,
    id_jugador_nk INTEGER NOT NULL,
    nombre_usuario NVARCHAR(255) NOT NULL,
    correo NVARCHAR(255),
    fecha_registro DATE,
    pais NVARCHAR(100)
);

-- DIMENSIÓN: PERSONAJE
CREATE TABLE dw.dim_personaje (
    id_personaje_sk INT IDENTITY(1,1) PRIMARY KEY,
    id_personaje_nk INTEGER NOT NULL,
    clase NVARCHAR(100) NOT NULL,
    nivel_inicial INTEGER CHECK (nivel_inicial >= 1),
    raza NVARCHAR(100)
);

-- DIMENSIÓN: TIEMPO
CREATE TABLE dw.dim_tiempo (
    id_tiempo_sk INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE NOT NULL UNIQUE,
    dia INTEGER NOT NULL CHECK (dia BETWEEN 1 AND 31),
    mes INTEGER NOT NULL CHECK (mes BETWEEN 1 AND 12),
    anio INTEGER NOT NULL CHECK (anio >= 2000),
    trimestre INTEGER NOT NULL CHECK (trimestre BETWEEN 1 AND 4)
);

-- DIMENSIÓN: EVENTO
CREATE TABLE dw.dim_evento (
    id_evento_sk INT IDENTITY(1,1) PRIMARY KEY,
    tipo_evento NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(MAX),
    dificultad NVARCHAR(20) CHECK (dificultad IN ('baja', 'media', 'alta'))
);

-- TABLA DE HECHOS: PROGRESO
CREATE TABLE dw.fact_progreso (
    id_progreso INT IDENTITY(1,1) PRIMARY KEY,
    id_jugador_sk INTEGER NOT NULL FOREIGN KEY REFERENCES dw.dim_jugador(id_jugador_sk),
    id_personaje_sk INTEGER NOT NULL FOREIGN KEY REFERENCES dw.dim_personaje(id_personaje_sk),
    id_tiempo_sk INTEGER NOT NULL FOREIGN KEY REFERENCES dw.dim_tiempo(id_tiempo_sk),
    id_evento_sk INTEGER NOT NULL FOREIGN KEY REFERENCES dw.dim_evento(id_evento_sk),
    xp_ganada INTEGER NOT NULL CHECK (xp_ganada >= 0),
    oro_ganado INTEGER NOT NULL CHECK (oro_ganado >= 0),
    nivel_resultante INTEGER CHECK (nivel_resultante >= 1),
    duracion_evento INTEGER CHECK (duracion_evento >= 0)
);
PRINT '¡LISTO! Base de datos Videojuego_DW creada y tablas generadas.';


-- DML
USE Videojuego_DW;
GO

---------------------------------------------------
-- PASO 1: LIMPIEZA TOTAL (Para empezar de cero)
---------------------------------------------------
DELETE FROM dw.fact_progreso;
DELETE FROM dw.dim_jugador;
DELETE FROM dw.dim_personaje;
DELETE FROM dw.dim_evento;
DELETE FROM dw.dim_tiempo;

-- Reiniciamos los contadores para que empiecen en 1
DBCC CHECKIDENT ('dw.dim_jugador', RESEED, 0);
DBCC CHECKIDENT ('dw.dim_personaje', RESEED, 0);
DBCC CHECKIDENT ('dw.dim_evento', RESEED, 0);
DBCC CHECKIDENT ('dw.dim_tiempo', RESEED, 0);

---------------------------------------------------
-- PASO 2: GENERAR DIMENSIONES (El "Menú")
---------------------------------------------------
PRINT 'Generando Tiempos...'
-- Generamos 365 días del año 2024 automáticamente
DECLARE @FechaInicio DATE = '2024-01-01';
DECLARE @ContadorDias INT = 0;

WHILE @ContadorDias < 365
BEGIN
    INSERT INTO dw.dim_tiempo (fecha, dia, mes, anio, trimestre)
    VALUES (
        DATEADD(DAY, @ContadorDias, @FechaInicio),
        DAY(DATEADD(DAY, @ContadorDias, @FechaInicio)),
        MONTH(DATEADD(DAY, @ContadorDias, @FechaInicio)),
        YEAR(DATEADD(DAY, @ContadorDias, @FechaInicio)),
        DATEPART(QUARTER, DATEADD(DAY, @ContadorDias, @FechaInicio))
    );
    SET @ContadorDias = @ContadorDias + 1;
END

PRINT 'Generando Personajes y Eventos...'
-- Insertamos 5 Clases de personajes
INSERT INTO dw.dim_personaje (id_personaje_nk, clase, nivel_inicial, raza) VALUES
(1, 'Guerrero', 1, 'Humano'), (2, 'Mago', 1, 'Elfo'), (3, 'Arquero', 1, 'Orco'),
(4, 'Asesino', 1, 'Elfo Oscuro'), (5, 'Sanador', 1, 'Enano');

-- Insertamos 4 Tipos de Eventos
INSERT INTO dw.dim_evento (tipo_evento, descripcion, dificultad) VALUES
('Raid', 'Mision de grupo grande', 'alta'), ('PVP', 'Jugador contra Jugador', 'media'),
('Farming', 'Recolectar oro', 'baja'), ('Dungeon', 'Mazmorra', 'media');

PRINT 'Generando 100 Jugadores...'
-- Generamos 100 Jugadores con nombres aleatorios y países variados
DECLARE @i INT = 1;
WHILE @i <= 100
BEGIN
    INSERT INTO dw.dim_jugador (id_jugador_nk, nombre_usuario, correo, fecha_registro, pais)
    VALUES (
        @i, 
        'Jugador_' + CAST(@i AS VARCHAR), 
        'user' + CAST(@i AS VARCHAR) + '@game.com', 
        '2023-01-01',
        CASE (ABS(CHECKSUM(NEWID())) % 5) -- Elige un país al azar
            WHEN 0 THEN 'Mexico' WHEN 1 THEN 'USA' WHEN 2 THEN 'España' 
            WHEN 3 THEN 'Argentina' ELSE 'Colombia' 
        END
    );
    SET @i = @i + 1;
END

---------------------------------------------------
-- PASO 3: LA GRAN SIMULACIÓN (Tabla de Hechos)
---------------------------------------------------
PRINT 'Generando 10,000 Partidas (Esto puede tardar un poco)...'

DECLARE @TotalPartidas INT = 10000; -- ¡Aquí definimos la cantidad!
DECLARE @p INT = 1;

WHILE @p <= @TotalPartidas
BEGIN
    INSERT INTO dw.fact_progreso (id_jugador_sk, id_personaje_sk, id_tiempo_sk, id_evento_sk, xp_ganada, oro_ganado, nivel_resultante, duracion_evento)
    VALUES (
        (ABS(CHECKSUM(NEWID())) % 100) + 1,  -- Jugador Aleatorio (1-100)
        (ABS(CHECKSUM(NEWID())) % 5) + 1,    -- Personaje Aleatorio (1-5)
        (ABS(CHECKSUM(NEWID())) % 365) + 1,  -- Día del año Aleatorio (1-365)
        (ABS(CHECKSUM(NEWID())) % 4) + 1,    -- Evento Aleatorio (1-4)
        (ABS(CHECKSUM(NEWID())) % 5000) + 100, -- XP entre 100 y 5100
        (ABS(CHECKSUM(NEWID())) % 1000) + 10,  -- Oro entre 10 y 1010
        (ABS(CHECKSUM(NEWID())) % 50) + 1,     -- Nivel final
        (ABS(CHECKSUM(NEWID())) % 120) + 5     -- Duración en minutos
    );
    SET @p = @p + 1;
END

PRINT '¡PROCESO TERMINADO! Ya tienes un Big Data de videojuegos.'
