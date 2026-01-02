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
# PARÁMETROS DE SIMULACIÓN
# =========================================
NUM_JUGADORES = 50
EVENTOS_POR_JUGADOR = 20

CLASES = ["Guerrero", "Mago", "Arquero", "Paladín"]
RAZAS = ["Humano", "Elfo", "Enano", "Orco"]
EVENTOS = ["Batalla", "Misión", "Mazmorra", "Jefe"]
DIFICULTADES = ["baja", "media", "alta"]

# =========================================
# SCRIPT PRINCIPAL
# =========================================
def main():
    print("\n🚀 Poblando Data Warehouse con datos simulados...")

    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    # =====================================
    # LIMPIEZA TOTAL
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
    print("✅ Data Warehouse limpio")

    # =====================================
    # DIM_JUGADOR
    # =====================================
    print("👤 Insertando jugadores...")
    for j in range(1, NUM_JUGADORES + 1):
        cur.execute("""
            INSERT INTO dw.dim_jugador (
                id_jugador_nk,
                nombre_usuario,
                correo,
                fecha_registro
            )
            VALUES (%s, %s, %s, %s)
        """, (
            j,
            f"Jugador_{j}",
            f"jugador{j}@dw.fake",
            date.today() - timedelta(days=random.randint(30, 700))
        ))
    conn.commit()
    print(f"✅ {NUM_JUGADORES} jugadores insertados")

    # =====================================
    # DIM_PERSONAJE
    # =====================================
    print("🧙 Insertando personajes...")
    for p in range(1, NUM_JUGADORES + 1):
        cur.execute("""
            INSERT INTO dw.dim_personaje (
                id_personaje_nk,
                clase,
                nivel_inicial,
                raza
            )
            VALUES (%s, %s, %s, %s)
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
            INSERT INTO dw.dim_evento (
                tipo_evento,
                descripcion,
                dificultad
            )
            VALUES (%s, %s, %s)
        """, (
            e,
            f"Evento tipo {e}",
            random.choice(DIFICULTADES)
        ))
    conn.commit()
    print("✅ Eventos insertados")

    # =====================================
    # FACT_PROGRESO + DIM_TIEMPO
    # =====================================
    print("📊 Insertando hechos...")
    for jugador_sk in range(1, NUM_JUGADORES + 1):
        for _ in range(EVENTOS_POR_JUGADOR):
            fecha = date.today() - timedelta(days=random.randint(0, 365))

            cur.execute("""
                INSERT INTO dw.dim_tiempo (
                    fecha, dia, mes, anio, trimestre
                )
                VALUES (%s,%s,%s,%s,%s)
                ON CONFLICT (fecha) DO NOTHING
            """, (
                fecha,
                fecha.day,
                fecha.month,
                fecha.year,
                (fecha.month - 1) // 3 + 1
            ))

            cur.execute("""
                SELECT id_tiempo_sk
                FROM dw.dim_tiempo
                WHERE fecha = %s
            """, (fecha,))
            id_tiempo_sk = cur.fetchone()[0]

            cur.execute("""
                SELECT id_evento_sk
                FROM dw.dim_evento
                ORDER BY RANDOM()
                LIMIT 1
            """)
            id_evento_sk = cur.fetchone()[0]

            cur.execute("""
                INSERT INTO dw.fact_progreso (
                    id_jugador_sk,
                    id_personaje_sk,
                    id_tiempo_sk,
                    id_evento_sk,
                    xp_ganada,
                    oro_ganado,
                    nivel_resultante,
                    duracion_evento
                )
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
            """, (
                jugador_sk,
                jugador_sk,
                id_tiempo_sk,
                id_evento_sk,
                random.randint(100, 500),
                random.randint(20, 200),
                random.randint(1, 60),
                random.randint(5, 60)
            ))

    conn.commit()
    print("✅ Hechos insertados")

    cur.close()
    conn.close()

    print("\n🎉 DW poblado correctamente")
    print("📈 Listo para OLAP")

# =========================================
if __name__ == "__main__":
    main()
