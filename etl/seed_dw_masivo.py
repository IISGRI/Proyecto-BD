import os
import random
from datetime import date, timedelta
import psycopg2
from dotenv import load_dotenv

# =========================================
# CONFIGURACIÓN
# =========================================
print("🔧 Cargando variables de entorno...")
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise Exception("❌ ERROR: DATABASE_URL no encontrada")

# =========================================
# PARÁMETROS MASIVOS
# =========================================
NUM_JUGADORES = 50
NUM_PERSONAJES = 100
ANIO_INICIO = 2022
ANIO_FIN = 2026
EVENTOS_POR_DIA = 5   # densidad de hechos

CLASES = ["Guerrero", "Mago", "Arquero", "Paladín"]
RAZAS = ["Humano", "Elfo", "Enano", "Orco"]

EVENTOS = [
    ("Batalla", "Combate contra enemigos", "alta"),
    ("Misión", "Misión principal", "media"),
    ("Exploración", "Explorar zonas", "baja"),
    ("Mazmorra", "Mazmorra peligrosa", "alta"),
]

# =========================================
# SCRIPT PRINCIPAL
# =========================================
def main():
    print("\n🚀 Poblando Data Warehouse MASIVAMENTE...")

    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    # =====================================
    # LIMPIEZA
    # =====================================
    print("🧹 Limpiando tablas DW...")
    cur.execute("""
        TRUNCATE TABLE
            dw.fact_progreso,
            dw.dim_evento,
            dw.dim_tiempo,
            dw.dim_personaje,
            dw.dim_jugador
        RESTART IDENTITY CASCADE;
    """)
    conn.commit()
    print("✅ DW limpio")

    # =====================================
    # DIM_JUGADOR
    # =====================================
    print("👤 Insertando jugadores...")
    for j in range(1, NUM_JUGADORES + 1):
        cur.execute("""
            INSERT INTO dw.dim_jugador
            (id_jugador_nk, nombre_usuario, correo, pais, fecha_registro)
            VALUES (%s,%s,%s,%s,%s)
        """, (
            j,
            f"Jugador_{j}",
            f"jugador{j}@dw.fake",
            "México",
            date.today() - timedelta(days=random.randint(200, 1200))
        ))
    conn.commit()
    print("✅ Jugadores insertados")

    # =====================================
    # DIM_PERSONAJE
    # =====================================
    print("🧙 Insertando personajes...")
    for p in range(1, NUM_PERSONAJES + 1):
        cur.execute("""
            INSERT INTO dw.dim_personaje
            (id_personaje_nk, clase, nivel_inicial, raza)
            VALUES (%s,%s,%s,%s)
        """, (
            p,
            random.choice(CLASES),
            random.randint(1, 10),
            random.choice(RAZAS)
        ))
    conn.commit()
    print("✅ Personajes insertados")

    # =====================================
    # DIM_EVENTO
    # =====================================
    print("📌 Insertando eventos...")
    for e in EVENTOS:
        cur.execute("""
            INSERT INTO dw.dim_evento
            (tipo_evento, descripcion, dificultad)
            VALUES (%s,%s,%s)
        """, e)
    conn.commit()
    print("✅ Eventos insertados")

    # =====================================
    # DIM_TIEMPO (AÑOS COMPLETOS)
    # =====================================
    print("📅 Insertando dimensión tiempo...")
    fecha_inicio = date(ANIO_INICIO, 1, 1)
    fecha_fin = date(ANIO_FIN, 12, 31)

    f = fecha_inicio
    while f <= fecha_fin:
        cur.execute("""
            INSERT INTO dw.dim_tiempo
            (fecha, dia, mes, anio, trimestre)
            VALUES (%s,%s,%s,%s,%s)
            ON CONFLICT (fecha) DO NOTHING
        """, (
            f,
            f.day,
            f.month,
            f.year,
            (f.month - 1) // 3 + 1
        ))
        f += timedelta(days=1)

    conn.commit()
    print("✅ Dimensión tiempo lista")

    # =====================================
    # FACT_PROGRESO MASIVO
    # =====================================
    print("📊 Insertando hechos OLAP...")

    cur.execute("SELECT id_jugador_sk FROM dw.dim_jugador")
    jugadores = [j[0] for j in cur.fetchall()]

    cur.execute("SELECT id_personaje_sk FROM dw.dim_personaje")
    personajes = [p[0] for p in cur.fetchall()]

    cur.execute("SELECT id_evento_sk FROM dw.dim_evento")
    eventos = [e[0] for e in cur.fetchall()]

    cur.execute("SELECT id_tiempo_sk FROM dw.dim_tiempo")
    tiempos = [t[0] for t in cur.fetchall()]

    inserts = 0

    for t in tiempos:
        for _ in range(EVENTOS_POR_DIA):
            cur.execute("""
                INSERT INTO dw.fact_progreso
                (id_jugador_sk, id_personaje_sk, id_tiempo_sk, id_evento_sk,
                 xp_ganada, oro_ganado, nivel_resultante, duracion_evento)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
            """, (
                random.choice(jugadores),
                random.choice(personajes),
                t,
                random.choice(eventos),
                random.randint(50, 800),
                random.randint(10, 500),
                random.randint(1, 60),
                random.randint(5, 180)
            ))
            inserts += 1

    conn.commit()
    print(f"✅ {inserts:,} hechos insertados")

    cur.close()
    conn.close()

    print("\n🎉 POBLADO MASIVO COMPLETADO")
    print("📈 Cubo OLAP listo para análisis")

# =========================================
if __name__ == "__main__":
    main()
