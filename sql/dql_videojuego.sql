-- ============================================================
-- PROYECTO: Sistema de Gestión de Videojuego Multijugador
-- SGBD: PostgreSQL
-- ============================================================

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
