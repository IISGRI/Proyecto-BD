-- ============================================================
-- PROYECTO: Sistema de Gestión de Videojuego Multijugador
-- SGBD: PostgreSQL
-- ============================================================

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
