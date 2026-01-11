-- ============================================================
-- PROYECTO: Sistema de Gestión de Videojuego Multijugador
-- SGBD: PostgreSQL
-- ============================================================

-- ============================================================
-- SECCIÓN 1: DDL (DATA DEFINITION LANGUAGE)
-- Creación y modificación de estructuras de base de datos
-- ============================================================

-- ---------- 1.1) Eliminación segura de objetos existentes ----------
-- Desactiva temporalmente triggers de replicación para evitar errores por FK
SET session_replication_role = replica;

-- Elimina todas las tablas en orden inverso a sus dependencias
DROP TABLE IF EXISTS Obtiene CASCADE;
DROP TABLE IF EXISTS Participa CASCADE;
DROP TABLE IF EXISTS Inventario CASCADE;
DROP TABLE IF EXISTS Habilidad_Personaje CASCADE;
DROP TABLE IF EXISTS Pertenece CASCADE;
DROP TABLE IF EXISTS Mascota CASCADE;
DROP TABLE IF EXISTS Pocion CASCADE;
DROP TABLE IF EXISTS Arma CASCADE;
DROP TABLE IF EXISTS Armadura CASCADE;
DROP TABLE IF EXISTS Logro CASCADE;
DROP TABLE IF EXISTS Partida CASCADE;
DROP TABLE IF EXISTS Habilidad CASCADE;
DROP TABLE IF EXISTS Objeto CASCADE;
DROP TABLE IF EXISTS Personaje CASCADE;
DROP TABLE IF EXISTS Gremio CASCADE;
DROP TABLE IF EXISTS Jugador CASCADE;

-- Reactiva los triggers de replicación
SET session_replication_role = DEFAULT;

-- ---------- 1.2) Creación de tablas principales ----------

-- TABLA: Jugador (entidad principal del sistema)
CREATE TABLE IF NOT EXISTS Jugador (
    id_jugador SERIAL PRIMARY KEY,
    nombre_usuario VARCHAR(50) NOT NULL,
    correo_electronico VARCHAR(100) UNIQUE NOT NULL CHECK (correo_electronico LIKE '%@%.%'),
    experiencia INT NOT NULL DEFAULT 0 CHECK (experiencia >= 0),
    nivel INT NOT NULL DEFAULT 1 CHECK (nivel >= 1),
    fecha_hora TIMESTAMP NOT NULL DEFAULT NOW(),
    direccion_ip VARCHAR(45)
);
COMMENT ON TABLE Jugador IS 'Jugador registrado en el sistema';

-- TABLA: Gremio (clanes o grupos de jugadores)
CREATE TABLE IF NOT EXISTS Gremio (
    id_gremio SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    fecha_fundacion DATE
);
COMMENT ON TABLE Gremio IS 'Gremios o clanes';

-- TABLA: Personaje (avatar del jugador, relación 1:N con Jugador)
CREATE TABLE IF NOT EXISTS Personaje (
    id_personaje SERIAL PRIMARY KEY,
    id_jugador INT NOT NULL REFERENCES Jugador(id_jugador) ON DELETE CASCADE ON UPDATE CASCADE,
    nombre VARCHAR(50) NOT NULL,
    clase VARCHAR(50) NOT NULL,
    nivel INT NOT NULL DEFAULT 1 CHECK (nivel >= 1)
);
COMMENT ON TABLE Personaje IS 'Personajes pertenecientes a un jugador';

-- TABLA: Mascota (entidad débil, depende de Personaje)
CREATE TABLE IF NOT EXISTS Mascota (
    id_mascota SERIAL PRIMARY KEY,
    id_personaje INT NOT NULL REFERENCES Personaje(id_personaje) ON DELETE CASCADE ON UPDATE CASCADE,
    nombre_mascota VARCHAR(50) NOT NULL,
    tipo VARCHAR(50),
    nivel INT NOT NULL DEFAULT 1 CHECK (nivel >= 1)
);
COMMENT ON TABLE Mascota IS 'Mascotas asociadas a personajes';

-- TABLA: Habilidad (habilidades disponibles en el juego)
CREATE TABLE IF NOT EXISTS Habilidad (
    id_habilidad SERIAL PRIMARY KEY,
    nombre_habilidad VARCHAR(50) NOT NULL,
    descripcion_habilidad TEXT
);
COMMENT ON TABLE Habilidad IS 'Habilidades disponibles en el juego';

-- TABLA: Objeto (clase padre para todos los objetos del juego)
CREATE TABLE IF NOT EXISTS Objeto (
    id_objeto SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    valor INT NOT NULL DEFAULT 0 CHECK (valor >= 0),
    rareza VARCHAR(20)
);
COMMENT ON TABLE Objeto IS 'Objetos genéricos del juego';

-- ---------- 1.3) Subtipos de Objeto (herencia 1:1) ----------
-- Cada subtipo comparte PK con Objeto mediante FK

-- SUBTIPO: Poción (objetos consumibles con efectos)
CREATE TABLE IF NOT EXISTS Pocion (
    id_objeto INT PRIMARY KEY REFERENCES Objeto(id_objeto) ON DELETE CASCADE ON UPDATE CASCADE,
    efecto TEXT NOT NULL CHECK (length(efecto) > 0)
);
COMMENT ON TABLE Pocion IS 'Pociones: efectos aplicables al usar';

-- SUBTIPO: Arma (objetos que infligen daño)
CREATE TABLE IF NOT EXISTS Arma (
    id_objeto INT PRIMARY KEY REFERENCES Objeto(id_objeto) ON DELETE CASCADE ON UPDATE CASCADE,
    dano_base INT NOT NULL CHECK (dano_base > 0)
);
COMMENT ON TABLE Arma IS 'Armas: infligen daño';

-- SUBTIPO: Armadura (objetos que proporcionan defensa)
CREATE TABLE IF NOT EXISTS Armadura (
    id_objeto INT PRIMARY KEY REFERENCES Objeto(id_objeto) ON DELETE CASCADE ON UPDATE CASCADE,
    valor_defensa INT NOT NULL CHECK (valor_defensa >= 0)
);
COMMENT ON TABLE Armadura IS 'Armaduras: proporcionan defensa';

-- ---------- 1.4) Tablas complementarias ----------

-- TABLA: Partida (sesiones de juego)
CREATE TABLE IF NOT EXISTS Partida (
    id_partida SERIAL PRIMARY KEY,
    fecha_hora TIMESTAMP NOT NULL DEFAULT NOW(),
    duracion INT CHECK (duracion >= 0),
    resultado VARCHAR(20)
);
COMMENT ON TABLE Partida IS 'Registro de sesiones/partidas';

-- TABLA: Logro (achievements del juego)
CREATE TABLE IF NOT EXISTS Logro (
    id_logro SERIAL PRIMARY KEY,
    nombre_logro VARCHAR(50) NOT NULL,
    descripcion_logro TEXT,
    CONSTRAINT chk_nombre_logro_len CHECK (length(nombre_logro) >= 3)
);
COMMENT ON TABLE Logro IS 'Logros desbloqueables';

-- ---------- 1.5) Tablas asociativas (relaciones N:M) ----------

-- TABLA ASOCIATIVA: Pertenece (Jugador <-> Gremio)
CREATE TABLE IF NOT EXISTS Pertenece (
    id_jugador INT NOT NULL REFERENCES Jugador(id_jugador) ON DELETE CASCADE ON UPDATE CASCADE,
    id_gremio INT NOT NULL REFERENCES Gremio(id_gremio) ON DELETE CASCADE ON UPDATE CASCADE,
    fecha_union DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY (id_jugador, id_gremio)
);
COMMENT ON TABLE Pertenece IS 'Asociación Jugador <-> Gremio';

-- TABLA ASOCIATIVA: Habilidad_Personaje (Personaje <-> Habilidad)
CREATE TABLE IF NOT EXISTS Habilidad_Personaje (
    id_personaje INT NOT NULL REFERENCES Personaje(id_personaje) ON DELETE CASCADE ON UPDATE CASCADE,
    id_habilidad INT NOT NULL REFERENCES Habilidad(id_habilidad) ON DELETE CASCADE ON UPDATE CASCADE,
    nivel INT NOT NULL DEFAULT 1 CHECK (nivel >= 1),
    PRIMARY KEY (id_personaje, id_habilidad)
);
COMMENT ON TABLE Habilidad_Personaje IS 'Habilidades asignadas a personajes';

-- TABLA ASOCIATIVA: Inventario (Personaje <-> Objeto)
CREATE TABLE IF NOT EXISTS Inventario (
    id_personaje INT NOT NULL REFERENCES Personaje(id_personaje) ON DELETE CASCADE ON UPDATE CASCADE,
    id_objeto INT NOT NULL REFERENCES Objeto(id_objeto) ON DELETE CASCADE ON UPDATE CASCADE,
    cantidad INT NOT NULL DEFAULT 1 CHECK (cantidad > 0),
    PRIMARY KEY (id_personaje, id_objeto)
);
COMMENT ON TABLE Inventario IS 'Objetos poseídos por personajes';

-- TABLA ASOCIATIVA: Participa (Personaje <-> Partida)
CREATE TABLE IF NOT EXISTS Participa (
    id_personaje INT NOT NULL REFERENCES Personaje(id_personaje) ON DELETE CASCADE ON UPDATE CASCADE,
    id_partida INT NOT NULL REFERENCES Partida(id_partida) ON DELETE CASCADE ON UPDATE CASCADE,
    puntuacion INT NOT NULL DEFAULT 0 CHECK (puntuacion >= 0),
    PRIMARY KEY (id_personaje, id_partida)
);
COMMENT ON TABLE Participa IS 'Registro de participación de personajes en partidas';

-- TABLA ASOCIATIVA: Obtiene (Jugador <-> Logro)
CREATE TABLE IF NOT EXISTS Obtiene (
    id_jugador INT NOT NULL REFERENCES Jugador(id_jugador) ON DELETE CASCADE ON UPDATE CASCADE,
    id_logro INT NOT NULL REFERENCES Logro(id_logro) ON DELETE CASCADE ON UPDATE CASCADE,
    fecha_desbloqueo DATE NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (id_jugador, id_logro)
);
COMMENT ON TABLE Obtiene IS 'Relación Jugador <-> Logro';

-- ---------- 1.6) Índices para optimización de consultas ----------
-- PostgreSQL crea índices automáticamente para PK y UNIQUE
-- Creamos índices adicionales para columnas frecuentemente consultadas

CREATE INDEX IF NOT EXISTS idx_jugador_nombre ON Jugador(nombre_usuario);
CREATE INDEX IF NOT EXISTS idx_personaje_nombre ON Personaje(nombre);
CREATE INDEX IF NOT EXISTS idx_objeto_nombre ON Objeto(nombre);

-- ---------- 1.7) Modificaciones posteriores de estructura ----------

-- Habilitar extensión de cifrado (para contraseñas)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Agregar columna de contraseña cifrada a Jugador
ALTER TABLE Jugador
ADD COLUMN contrasena_hash VARCHAR(200) NOT NULL DEFAULT 'TEMP_HASH';

-- Validar que el hash no esté vacío
ALTER TABLE Jugador
ADD CONSTRAINT chk_contrasena_hash CHECK (length(contrasena_hash) >= 8);

-- Agregar columna para personaje activo del jugador
ALTER TABLE jugador
ADD COLUMN IF NOT EXISTS id_personaje_activo INT NULL,
ADD CONSTRAINT fk_personaje_activo
FOREIGN KEY (id_personaje_activo)
REFERENCES personaje(id_personaje)
ON DELETE SET NULL;

-- Agregar columna para mascota activa del jugador
ALTER TABLE jugador
ADD COLUMN IF NOT EXISTS id_mascota_activa INT NULL,
ADD CONSTRAINT fk_mascota_activa
FOREIGN KEY (id_mascota_activa)
REFERENCES mascota(id_mascota)
ON DELETE SET NULL;
