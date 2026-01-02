import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")

def main():
    print("\n🚀 CARGA DE TABLA DE HECHOS")

    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    print("📥 Extrayendo eventos OLTP...")
    cur.execute("""
        SELECT
            j.id_jugador,
            p.id_personaje,
            DATE(pa.fecha_hora),
            pa.resultado,
            pa.duracion,
            pr.puntuacion,
            p.nivel
        FROM participa pr
        JOIN personaje p ON pr.id_personaje = p.id_personaje
        JOIN jugador j ON p.id_jugador = j.id_jugador
        JOIN partida pa ON pr.id_partida = pa.id_partida;
    """)

    eventos = cur.fetchall()
    print(f"📦 Eventos encontrados: {len(eventos)}")

    for e in eventos:
        jugador_nk, personaje_nk, fecha, evento, duracion, xp, nivel = e

        # JUGADOR
        cur.execute("""
            SELECT id_jugador_sk
            FROM dw.dim_jugador
            WHERE id_jugador_nk = %s
        """, (jugador_nk,))

        row = cur.fetchone()
        if row is None:
            print(f"⚠️ Jugador {jugador_nk} no encontrado en DIM_JUGADOR. Evento omitido.")
            continue

        id_jugador_sk = row[0]

        # PERSONAJE
        cur.execute("""
            SELECT id_personaje_sk
            FROM dw.dim_personaje
            WHERE id_personaje_nk = %s
        """, (personaje_nk,))

        row = cur.fetchone()
        if row is None:
            print(f"⚠️ Personaje {personaje_nk} no encontrado en DIM_PERSONAJE. Evento omitido.")
            continue

        id_personaje_sk = row[0]

        # TIEMPO
        cur.execute("""
            SELECT id_tiempo_sk
            FROM dw.dim_tiempo
            WHERE fecha = %s
        """, (fecha,))

        row = cur.fetchone()
        if row is None:
            print(f"⚠️ Fecha {fecha} no encontrada en DIM_TIEMPO.")
            continue

        id_tiempo_sk = row[0]

        # EVENTO
        cur.execute("""
            SELECT id_evento_sk
            FROM dw.dim_evento
            WHERE tipo_evento = %s
        """, (evento,))

        row = cur.fetchone()
        if row is None:
            print(f"⚠️ Evento '{evento}' no encontrado en DIM_EVENTO.")
            continue

        id_evento_sk = row[0]

        # FACT
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
            VALUES (%s,%s,%s,%s,%s,0,%s,%s)
        """, (
            id_jugador_sk,
            id_personaje_sk,
            id_tiempo_sk,
            id_evento_sk,
            xp,
            nivel,
            duracion
        ))

    conn.commit()
    cur.close()
    conn.close()

    print("🎉 TABLA DE HECHOS CARGADA CORRECTAMENTE")

if __name__ == "__main__":
    main()
