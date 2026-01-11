CREATE DATABASE Videojuego_DW;
GO
USE Videojuego_DW;
GO

-- 1. CREACIÓN DE TABLAS (Esquema de Estrella)
CREATE TABLE dw.dim_tiempo (
    id_tiempo_sk INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE,
    dia INT, mes INT, anio INT, trimestre INT
);
CREATE TABLE dw.dim_personaje (
    id_personaje_sk INT IDENTITY(1,1) PRIMARY KEY,
    id_personaje_nk INT,
    clase VARCHAR(50),
    nivel_inicial INT,
    raza VARCHAR(50)
);
CREATE TABLE dw.dim_evento (
    id_evento_sk INT IDENTITY(1,1) PRIMARY KEY,
    tipo_evento VARCHAR(50),
    descripcion VARCHAR(100),
    dificultad VARCHAR(20)
);
CREATE TABLE dw.dim_jugador (
    id_jugador_sk INT IDENTITY(1,1) PRIMARY KEY,
    id_jugador_nk INT,
    nombre_usuario VARCHAR(100),
    correo VARCHAR(100),
    fecha_registro DATE,
    pais VARCHAR(50)
);
CREATE TABLE dw.fact_progreso (
    id_progreso_sk INT IDENTITY(1,1) PRIMARY KEY,
    id_jugador_sk INT FOREIGN KEY REFERENCES dw.dim_jugador(id_jugador_sk),
    id_personaje_sk INT FOREIGN KEY REFERENCES dw.dim_personaje(id_personaje_sk),
    id_tiempo_sk INT FOREIGN KEY REFERENCES dw.dim_tiempo(id_tiempo_sk),
    id_evento_sk INT FOREIGN KEY REFERENCES dw.dim_evento(id_evento_sk),
    xp_ganada INT,
    oro_ganado INT,
    nivel_resultante INT,
    duracion_evento INT
);

-- 2. CARGA DE DATOS (10,000 Registros)
SET NOCOUNT ON;
PRINT 'Generando dimensiones...'
-- Tiempo
DECLARE @FechaInicio DATE = '2024-01-01'; DECLARE @ContadorDias INT = 0;
WHILE @ContadorDias < 365 BEGIN
    INSERT INTO dw.dim_tiempo VALUES (DATEADD(DAY, @ContadorDias, @FechaInicio), DAY(DATEADD(DAY, @ContadorDias, @FechaInicio)), MONTH(DATEADD(DAY, @ContadorDias, @FechaInicio)), YEAR(DATEADD(DAY, @ContadorDias, @FechaInicio)), DATEPART(QUARTER, DATEADD(DAY, @ContadorDias, @FechaInicio)));
    SET @ContadorDias = @ContadorDias + 1;
END
-- Personajes y Eventos
INSERT INTO dw.dim_personaje VALUES (1,'Guerrero',1,'Humano'),(2,'Mago',1,'Elfo'),(3,'Arquero',1,'Orco'),(4,'Sanador',1,'Enano'),(5,'Asesino',1,'Elfo Oscuro');
INSERT INTO dw.dim_evento VALUES ('Raid','Grupo','Alta'),('PVP','Vs','Media'),('Farming','Solo','Baja'),('Dungeon','Mazmorra','Media');
-- Jugadores
DECLARE @i INT = 1; WHILE @i <= 100 BEGIN INSERT INTO dw.dim_jugador VALUES (@i, 'User_'+CAST(@i AS VARCHAR), 'mail', '2023-01-01', CASE (ABS(CHECKSUM(NEWID()))%5) WHEN 0 THEN 'Mexico' WHEN 1 THEN 'USA' WHEN 2 THEN 'España' WHEN 3 THEN 'Colombia' ELSE 'Chile' END); SET @i=@i+1; END

PRINT 'Generando 10,000 partidas (Esto tomará unos segundos)...'
DECLARE @p INT = 1; WHILE @p <= 10000 BEGIN
    INSERT INTO dw.fact_progreso VALUES ((ABS(CHECKSUM(NEWID()))%100)+1, (ABS(CHECKSUM(NEWID()))%5)+1, (ABS(CHECKSUM(NEWID()))%365)+1, (ABS(CHECKSUM(NEWID()))%4)+1, (ABS(CHECKSUM(NEWID()))%5000)+100, (ABS(CHECKSUM(NEWID()))%1000)+10, (ABS(CHECKSUM(NEWID()))%60)+1, (ABS(CHECKSUM(NEWID()))%120)+5);
    SET @p=@p+1;
END
PRINT '¡LISTO! Base de datos cargada correctamente.';
