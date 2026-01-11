-- ============================================================
-- PROYECTO: Sistema de Gestión de Videojuego Multijugador
-- SGBD: PostgreSQL
-- ============================================================

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
