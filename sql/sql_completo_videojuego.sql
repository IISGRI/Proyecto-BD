-- ============================================================
-- PROYECTO: Sistema de Gestión de Videojuego Multijugador
-- SGBD: PostgreSQL
-- ORGANIZACIÓN: DDL, DML, DQL, DCL
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


-- ============================================================
-- SECCIÓN 2: DML (DATA MANIPULATION LANGUAGE)
-- Inserción, actualización y eliminación de datos
-- ============================================================

-- ---------- 2.1) Inserción de datos de prueba ----------

-- Insertar jugadores iniciales
INSERT INTO Jugador (id_jugador, nombre_usuario, correo_electronico, experiencia, nivel, direccion_ip)
VALUES
 (1, 'LiamA',  'liam@example.com',      1200, 5, '192.0.2.1'),
 (2, 'DiegoS', 'diego@example.org',      300, 2, '192.0.2.2'),
 (3, 'Alicia', 'alicia@mail.com',       0,   1, NULL),
 (4, 'Carlos', 'carlos@mail.net',     5000, 10, '2001:db8::1'),
 (5, 'Mariana','mariana@correo.mx',   250, 3, '203.0.113.5');

-- Insertar gremios
INSERT INTO Gremio (id_gremio, nombre, fecha_fundacion)
VALUES
 (1, 'HermanosDeAcero', '2020-03-01'),
 (2, 'LuzNocturna', '2021-10-12'),
 (3, 'Forja', '2019-06-25');

-- Insertar personajes (cada uno pertenece a un jugador)
INSERT INTO Personaje (id_personaje, id_jugador, nombre, clase, nivel)
VALUES
 (1, 1, 'Arthas', 'Guerrero', 5),
 (2, 1, 'Lumi', 'Mago', 4),
 (3, 2, 'Raven', 'Arquero', 2),
 (4, 3, 'Nyx', 'Asesino', 1),
 (5, 4, 'Titan', 'Tanque', 10),
 (6, 5, 'Beta', 'Clérigo', 3);

-- Insertar mascotas
INSERT INTO Mascota (id_mascota, id_personaje, nombre_mascota, tipo, nivel)
VALUES
 (1, 1, 'Fang', 'Lobo', 3),
 (2, 2, 'Spark', 'Fénix', 2),
 (3, 3, 'Wing', 'Águila', 1);

-- Insertar habilidades
INSERT INTO Habilidad (id_habilidad, nombre_habilidad, descripcion_habilidad)
VALUES
 (1, 'Golpe', 'Ataque físico básico'),
 (2, 'Bola de Fuego', 'Daño mágico de área'),
 (3, 'Curar', 'Recupera vida'),
 (4, 'Serpenteo', 'Evasión pasiva');

-- Asignar habilidades a personajes
INSERT INTO Habilidad_Personaje (id_personaje, id_habilidad, nivel)
VALUES
 (1,1,3), (1,2,1),
 (2,2,2), (6,3,1),
 (3,4,1);

-- Insertar objetos base
INSERT INTO Objeto (id_objeto, nombre, descripcion, valor, rareza)
VALUES
 (1, 'Poción Pequeña', 'Restaura 50 HP', 10, 'Comun'),
 (2, 'Espada Corta', 'Arma hecha de acero', 100, 'Comun'),
 (3, 'Coraza Ligera', 'Armadura de cuero', 80, 'Comun'),
 (4, 'Poción Mayor', 'Restaura 200 HP', 50, 'Rara'),
 (5, 'Espadón Épico', 'Espada legendaria', 2000, 'Epico'),
 (6, 'Casco Antiguo', 'Casco con historia', 150, 'Raro');

-- Insertar subtipos de objetos (Poción, Arma, Armadura)
INSERT INTO Pocion (id_objeto, efecto) VALUES (1, 'Restaura 50 puntos de HP');
INSERT INTO Arma  (id_objeto, dano_base) VALUES (2, 25);
INSERT INTO Armadura (id_objeto, valor_defensa) VALUES (3, 10);
INSERT INTO Pocion (id_objeto, efecto) VALUES (4, 'Restaura 200 puntos de HP');
INSERT INTO Arma (id_objeto, dano_base) VALUES (5, 120);
INSERT INTO Armadura (id_objeto, valor_defensa) VALUES (6, 30);

-- Objetos adicionales
INSERT INTO Objeto (nombre, descripcion, valor, rareza)
VALUES 
('Poción de Curación', 'Restaura 50 HP', 30, 'Común'),
('Poción de Maná', 'Restaura 30 MP', 25, 'Común'),
('Elixir Supremo', 'Restaura HP y MP completamente', 150, 'Raro'),
('Espada de Hierro', 'Una espada básica pero confiable', 80, 'Común'),
('Arco Élfico', 'Arma ligera y precisa', 120, 'Raro'),
('Hacha de Guerra', 'Hacha pesada con gran daño', 160, 'Épico'),
('Armadura de Cuero', 'Ligera, básica', 50, 'Común'),
('Armadura de Acero', 'Proporciona buena protección', 150, 'Raro'),
('Armadura Dragón', 'Increíblemente resistente', 500, 'Legendaria');

-- Poblar inventario (personaje-objeto)
INSERT INTO Inventario (id_personaje, id_objeto, cantidad)
VALUES
 (1,1,2), -- Arthas tiene 2 pociones pequeñas
 (1,2,1), -- Arthas tiene espada corta
 (2,4,1), -- Lumi tiene pocion mayor
 (3,3,1),
 (5,5,1);

-- Insertar partidas
INSERT INTO Partida (id_partida, fecha_hora, duracion, resultado)
VALUES
 (1, '2025-10-20 20:00:00', 35, 'Ganada'),
 (2, '2025-10-21 21:30:00', 40, 'Perdida'),
 (3, '2025-10-22 18:00:00', 20, 'Empate');

-- Registrar participación en partidas
INSERT INTO Participa (id_personaje, id_partida, puntuacion)
VALUES
 (1,1, 150),
 (2,1, 120),
 (3,1, 90),
 (1,2, 200),
 (5,3, 300);

-- Insertar logros
INSERT INTO Logro (id_logro, nombre_logro, descripcion_logro)
VALUES
 (1, 'Primeros Pasos', 'Completa la primera partida'),
 (2, 'Coleccionista', 'Consigue 10 objetos distintos'),
 (3, 'Asesino', 'Derrota 100 enemigos');

-- Registrar logros obtenidos
INSERT INTO Obtiene (id_jugador, id_logro, fecha_desbloqueo)
VALUES
 (1,1,'2025-10-20'),
 (4,1,'2025-09-15'),
 (1,2,'2025-10-21');

-- Registrar membresías a gremios
INSERT INTO Pertenece (id_jugador, id_gremio, fecha_union)
VALUES
 (1,1,'2021-01-01'),
 (2,1,'2022-02-02'),
 (4,2,'2020-05-05');

-- Ejemplo: Insertar jugador con contraseña cifrada
INSERT INTO Jugador (nombre_usuario, correo_electronico, contrasena_hash)
VALUES ('NuevoJugador', 'nuevojugador@example.com', crypt('MiContraseñaSegura', gen_salt('bf')));

-- Ejemplo: Insertar jugador con fecha automática
INSERT INTO Jugador (nombre_usuario, correo_electronico) 
VALUES ('AutoFecha','auto@mail.com');

-- Ejemplo: Insertar mascota adicional
INSERT INTO Mascota (id_personaje, nombre_mascota, tipo) 
VALUES (1, 'MiniFang', 'Lobo');

-- ---------- 2.2) Ajuste de secuencias ----------
-- Evita conflictos cuando se insertan IDs explícitos

SELECT setval(pg_get_serial_sequence('Jugador','id_jugador'), COALESCE(MAX(id_jugador),1)) FROM Jugador;
SELECT setval(pg_get_serial_sequence('Gremio','id_gremio'), COALESCE(MAX(id_gremio),1)) FROM Gremio;
SELECT setval(pg_get_serial_sequence('Personaje','id_personaje'), COALESCE(MAX(id_personaje),1)) FROM Personaje;
SELECT setval(pg_get_serial_sequence('Objeto','id_objeto'), COALESCE(MAX(id_objeto),1)) FROM Objeto;
SELECT setval(pg_get_serial_sequence('Partida','id_partida'), COALESCE(MAX(id_partida),1)) FROM Partida;
SELECT setval(pg_get_serial_sequence('Logro','id_logro'), COALESCE(MAX(id_logro),1)) FROM Logro;


-- ============================================================
-- SECCIÓN 3: DQL (DATA QUERY LANGUAGE)
-- Consultas y verificación de datos
-- ============================================================

-- ---------- 3.1) Verificaciones de integridad ----------

-- Verificar NULLs indebidos en columnas NOT NULL
SELECT 'Jugador.nombre_usuario NULL' AS test, COUNT(*) FROM Jugador WHERE nombre_usuario IS NULL;
SELECT 'Jugador.correo_electronico NULL' AS test, COUNT(*) FROM Jugador WHERE correo_electronico IS NULL;
SELECT 'Personaje.id_jugador NULL' AS test, COUNT(*) FROM Personaje WHERE id_jugador IS NULL;

-- Verificar valores fuera de rango (CHECK constraints)
SELECT 'Jugador.experiencia < 0' AS test, COUNT(*) FROM Jugador WHERE experiencia < 0;
SELECT 'Inventario.cantidad <= 0' AS test, COUNT(*) FROM Inventario WHERE cantidad <= 0;
SELECT 'Arma.dano_base <= 0' AS test, COUNT(*) FROM Arma WHERE dano_base <= 0;

-- Verificar integridad referencial: FKs huérfanas
SELECT ip.* FROM Personaje p
LEFT JOIN Jugador j ON p.id_jugador = j.id_jugador
JOIN LATERAL (SELECT p.id_personaje, p.id_jugador) ip ON true
WHERE j.id_jugador IS NULL;

SELECT i.* FROM Inventario i
LEFT JOIN Personaje p ON i.id_personaje = p.id_personaje
LEFT JOIN Objeto o ON i.id_objeto = o.id_objeto
WHERE p.id_personaje IS NULL OR o.id_objeto IS NULL;

-- Detectar duplicados en restricciones UNIQUE
SELECT correo_electronico, COUNT(*) FROM Jugador GROUP BY correo_electronico HAVING COUNT(*) > 1;
SELECT id_personaje, id_objeto, COUNT(*) FROM Inventario GROUP BY id_personaje, id_objeto HAVING COUNT(*) > 1;

-- Buscar filas huérfanas en tablas de subtipo
SELECT p.* FROM Pocion p LEFT JOIN Objeto o ON p.id_objeto = o.id_objeto WHERE o.id_objeto IS NULL;
SELECT a.* FROM Arma a LEFT JOIN Objeto o ON a.id_objeto = o.id_objeto WHERE o.id_objeto IS NULL;
SELECT ar.* FROM Armadura ar LEFT JOIN Objeto o ON ar.id_objeto = o.id_objeto WHERE o.id_objeto IS NULL;

-- Verificar constraints CHECK personalizados
SELECT * FROM Jugador WHERE correo_electronico NOT LIKE '%@%.%';
SELECT * FROM Logro WHERE length(nombre_logro) < 3;

-- ---------- 3.2) Consultas de verificación general ----------

-- Chequeo de integridad referencial en Inventario
WITH refs AS (
  SELECT 'Inventario' AS tabla, i.id_personaje AS id_p, i.id_objeto AS id_o
  FROM Inventario i
)
SELECT * FROM refs
LEFT JOIN Personaje p ON refs.id_p = p.id_personaje
LEFT JOIN Objeto o ON refs.id_o = o.id_objeto
WHERE p.id_personaje IS NULL OR o.id_objeto IS NULL;

-- Reporte general de tamaños de tablas
SELECT
  (SELECT COUNT(*) FROM Jugador) AS total_jugadores,
  (SELECT COUNT(*) FROM Personaje) AS total_personajes,
  (SELECT COUNT(*) FROM Objeto) AS total_objetos,
  (SELECT COUNT(*) FROM Inventario) AS total_inventario,
  (SELECT COUNT(*) FROM Partida) AS total_partidas;

-- ---------- 3.3) Consultas funcionales ----------

-- Ejemplo: Autenticación de jugador con contraseña cifrada
SELECT id_jugador, nombre_usuario
FROM Jugador
WHERE correo_electronico = 'nuevojugador@example.com'
    AND contrasena_hash = crypt('MiContraseñaSegura', contrasena_hash);

-- Consulta simple de objetos
SELECT *
FROM objeto
LIMIT 5;


-- ============================================================
-- SECCIÓN 4: DCL (DATA CONTROL LANGUAGE)
-- Control de acceso y permisos
-- ============================================================

-- ---------- 4.1) Creación de roles/usuarios ----------

-- Rol: Administrador general (acceso total)
CREATE ROLE admin_bd LOGIN PASSWORD 'AdminPW';
COMMENT ON ROLE admin_bd IS 'Administrador general del sistema con acceso total.';

-- Rol: Usuario operativo (CRUD en tablas específicas)
CREATE ROLE operativo LOGIN PASSWORD 'OperativoPW';
COMMENT ON ROLE operativo IS 'Usuario encargado de registrar y actualizar datos del videojuego.';

-- Rol: Usuario de solo consulta (solo lectura)
CREATE ROLE consulta LOGIN PASSWORD 'LecturaPW';
COMMENT ON ROLE consulta IS 'Usuario de lectura general del sistema.';

-- Rol: Usuario de reportes (consultas + crear vistas)
CREATE ROLE reportes LOGIN PASSWORD 'ReportesPW';
COMMENT ON ROLE reportes IS 'Usuario con permisos para generar vistas y reportes.';

-- Rol base para permisos comunes (agrupador de lectura)
CREATE ROLE lectura_base;

-- ---------- 4.2) Asignación de privilegios (GRANT) ----------

-- 🔹 Administrador: acceso total
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_bd;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin_bd;
ALTER ROLE admin_bd CREATEDB CREATEROLE;

-- 🔹 Usuario Operativo: puede modificar datos de juego
GRANT SELECT, INSERT, UPDATE ON
    Jugador, Personaje, Mascota, Inventario, Participa, Obtiene, Partida
TO operativo;

GRANT SELECT ON
    Objeto, Pocion, Arma, Armadura, Logro, Gremio
TO operativo;

-- 🔹 Usuario de Consulta: solo lectura
GRANT SELECT ON ALL TABLES IN SCHEMA public TO consulta;

-- 🔹 Usuario de Reportes: lectura + crear vistas
GRANT SELECT ON
    Jugador, Personaje, Partida, Logro, Gremio
TO reportes;

GRANT CREATE ON SCHEMA public TO reportes;

-- 🔹 Rol agrupador de lectura
GRANT SELECT ON ALL TABLES IN SCHEMA public TO lectura_base;

-- Asignar rol base a usuarios
GRANT lectura_base TO consulta;
GRANT lectura_base TO reportes;
GRANT lectura_base TO operativo;

-- ---------- 4.3) Revocación de privilegios (REVOKE) ----------

-- Revocar privilegios peligrosos (DELETE)
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM operativo, consulta, reportes;

-- Revocar modificación en usuarios de lectura
REVOKE INSERT, UPDATE ON ALL TABLES IN SCHEMA public FROM consulta, reportes;

-- Revocar todos los privilegios de un usuario
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM consulta;

-- Revocar rol agrupador
REVOKE lectura_base FROM consulta;

-- Eliminar usuario (si ya no se usa)
-- DROP ROLE consulta;


-- ============================================================
-- SECCIÓN 5: PRUEBAS DE RESTRICCIONES Y SEGURIDAD
-- ============================================================

-- ---------- 5.1) Pruebas de restricciones (deben fallar) ----------
-- (Comentadas para evitar ejecución accidental - descomentar para probar)

-- 1) INSERT con experiencia negativa (debe fallar por CHECK)
-- INSERT INTO Jugador (nombre_usuario, correo_electronico, experiencia) 
-- VALUES ('Test1', 't1@mail.com', -5);

-- 2) INSERT con nivel 0 en personaje (debe fallar por CHECK)
-- INSERT INTO Personaje (id_jugador, nombre, clase, nivel) 
-- VALUES (1,'Bug','Mago',0);

-- 3) INSERT con correo duplicado (debe fallar por UNIQUE)
-- INSERT INTO Jugador (nombre_usuario, correo_electronico) 
-- VALUES ('Dup','liam@example.com');

-- 4) INSERT sin nombre_usuario (debe fallar por NOT NULL)
-- INSERT INTO Jugador (correo_electronico) 
-- VALUES ('anon@mail.com');

-- 5) INSERT con fecha automática (debe funcionar)
INSERT INTO Jugador (nombre_usuario, correo_electronico) 
VALUES ('AutoFecha','auto@mail.com');

-- 6) INSERT con correo sin @ (debe fallar por CHECK)
-- INSERT INTO Jugador (nombre_usuario, correo_electronico) 
-- VALUES ('SinArroba','correo_invalido');

-- 7) INSERT con cantidad 0 en inventario (debe fallar por CHECK)
-- INSERT INTO Inventario (id_personaje, id_objeto, cantidad) 
-- VALUES (1,1,0);

-- 8) INSERT de mascota (debe funcionar)
INSERT INTO Mascota (id_personaje, nombre_mascota, tipo) 
VALUES (1, 'MiniFang', 'Lobo');

-- 9) INSERT con valor negativo en objeto (debe fallar por CHECK)
-- INSERT INTO Objeto (nombre, descripcion, valor) 
-- VALUES ('BugItem', 'Objeto inválido', -10);

-- 10) INSERT con logro de nombre corto (debe fallar por CHECK)
-- INSERT INTO Logro (nombre_logro, descripcion_logro) 
-- VALUES ('AB', 'Muy corto');

-- ---------- 5.2) Pruebas de CASCADE (eliminaciones y actualizaciones) ----------
-- (Comentadas para evitar pérdida de datos - descomentar para probar)

-- 1) DELETE jugador (cascada elimina personajes, inventarios, etc.)
-- DELETE FROM Jugador WHERE id_jugador = 1;

-- 2) DELETE personaje (cascada elimina inventario, participaciones, habilidades)
-- DELETE FROM Personaje WHERE id_personaje = 2;

-- 3) DELETE gremio (cascada elimina membresías)
-- DELETE FROM Gremio WHERE id_gremio = 1;

-- 4) DELETE objeto (cascada elimina de inventarios)
-- DELETE FROM Objeto WHERE id_objeto = 2;

-- 5) DELETE personaje con mascota
-- DELETE FROM Personaje WHERE id_personaje = 3;

-- 6) DELETE logro (cascada elimina registros en Obtiene)
-- DELETE FROM Logro WHERE id_logro = 1;

-- 7) DELETE objeto (debe eliminar subtipo también)
-- DELETE FROM Objeto WHERE id_objeto = 5;

-- 8) UPDATE ID de jugador (cascada actualiza FKs en personajes)
-- UPDATE Jugador SET id_jugador = 10 WHERE id_jugador = 2;

-- ---------- 5.3) Pruebas de permisos de roles DCL ----------
-- (Comentadas - descomentar para probar seguridad)

-- 1) Usuario operativo intenta DELETE (debe fallar - no tiene permiso)
-- SET ROLE operativo;
-- DELETE FROM Jugador WHERE id_jugador = 3;

-- 2) Usuario consulta intenta INSERT (debe fallar - solo tiene SELECT)
-- SET ROLE consulta;
-- INSERT INTO Jugador (nombre_usuario, correo_electronico) 
-- VALUES ('Invalido', 'lectura@mail.com');

-- 3) Usuario reportes hace SELECT en Inventario (debe funcionar)
-- SET ROLE reportes;
-- SELECT * FROM Inventario;

-- 4) Asignar roles a admin para pruebas
GRANT operativo TO admin_bd;
GRANT consulta TO admin_bd;
GRANT reportes TO admin_bd;

-- Usuario operativo hace INSERT (debe funcionar)
SET ROLE operativo;
INSERT INTO Jugador (nombre_usuario, correo_electronico) 
VALUES ('NuevoUser', 'nuevo@mail.com');

-- 5) Usuario reportes crea vista (debe funcionar)
SET ROLE reportes;
CREATE VIEW vista_top AS
SELECT nombre_usuario, nivel, experiencia 
FROM Jugador 
ORDER BY experiencia DESC 
LIMIT 5;

-- 6) Revocar SELECT de Jugador a consulta y verificar
REVOKE SELECT ON Jugador FROM consulta;
SET ROLE consulta;
-- SELECT * FROM Jugador; -- Debe fallar

-- 7) Revocar lectura_base de operativo y verificar
REVOKE lectura_base FROM operativo;
SET ROLE operativo;
-- SELECT * FROM Logro; -- Debe fallar

-- 8) Revocar roles de admin y probar creación de rol
REVOKE operativo FROM admin_bd;
REVOKE consulta FROM admin_bd;
REVOKE reportes FROM admin_bd;

SET ROLE operativo;
-- CREATE ROLE prueba LOGIN PASSWORD '1234'; -- Debe fallar

-- 9) Usuario operativo intenta DROP TABLE (debe fallar)
-- SET ROLE operativo;
-- DROP TABLE Jugador; -- Debe fallar

-- 10) Admin elimina datos (debe funcionar)
SET ROLE admin_bd;
DELETE FROM Jugador WHERE id_jugador = 5;


-- ============================================================
-- FIN DEL SCRIPT SQL
-- ============================================================