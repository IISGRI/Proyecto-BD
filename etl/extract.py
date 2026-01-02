import os
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv
from datetime import datetime

# =========================================
# CARGA DE VARIABLES DE ENTORNO
# =========================================
print("🔧 Cargando variables de entorno...")
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise Exception("❌ ERROR: DATABASE_URL no encontrada en el archivo .env")

# =========================================
# FUNCIÓN PRINCIPAL DE EXTRACCIÓN
# =========================================
def main():
    inicio = datetime.now()

    print("\n==========================================")
    print("🚀 FASE 4.1 — EXTRACCIÓN DE DATOS (ETL)")
    print("==========================================")

    try:
        # -------------------------------------
        # CONEXIÓN A BASE OLTP (Supabase)
        # -------------------------------------
        print("\n📡 Conectando a la base de datos OLTP...")
        conn = psycopg2.connect(DATABASE_URL)
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        print("✅ Conexión establecida correctamente")

        # =====================================
        # EXTRACCIÓN: JUGADORES
        # =====================================
        print("\n📥 Extrayendo datos de JUGADORES...")

        query_jugadores = """
        SELECT
            id_jugador,
            nombre_usuario,
            correo_electronico,
            DATE(fecha_hora) AS fecha_registro
        FROM Jugador;
        """

        cursor.execute(query_jugadores)
        jugadores = cursor.fetchall()

        print(f"✅ Jugadores extraídos: {len(jugadores)} registros")

        # =====================================
        # EXTRACCIÓN: PERSONAJES
        # =====================================
        print("\n📥 Extrayendo datos de PERSONAJES...")
        cursor.execute("""
            SELECT
                id_personaje,
                id_jugador,
                nombre,
                clase,
                nivel
            FROM personaje
            ORDER BY id_personaje
            LIMIT 10;
        """)
        personajes = cursor.fetchall()

        print(f"📦 Total de personajes extraídos: {len(personajes)}")
        for p in personajes:
            print(p)

        # =====================================
        # EXTRACCIÓN: EVENTOS (PROGRESO)
        # =====================================
        print("\n📥 Extrayendo datos de EVENTOS / PROGRESO...")
        cursor.execute("""
            SELECT
                p.id_personaje,
                p.nivel,
                CURRENT_DATE AS fecha_evento
            FROM personaje p
            LIMIT 10;
        """)
        eventos = cursor.fetchall()

        print(f"📦 Total de eventos extraídos: {len(eventos)}")
        for e in eventos:
            print(e)

        # -------------------------------------
        # CIERRE DE CONEXIÓN
        # -------------------------------------
        cursor.close()
        conn.close()
        print("\n🔒 Conexión cerrada correctamente")

        fin = datetime.now()
        print("\n==========================================")
        print("✅ EXTRACCIÓN FINALIZADA CON ÉXITO")
        print("⏱ Tiempo total:", fin - inicio)
        print("==========================================")

    except Exception as e:
        print("\n❌ ERROR DURANTE LA EXTRACCIÓN")
        print("Detalle:", e)


# =========================================
# EJECUCIÓN
# =========================================
if __name__ == "__main__":
    main()
