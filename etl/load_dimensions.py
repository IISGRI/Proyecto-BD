import os
import psycopg2
from dotenv import load_dotenv
from datetime import datetime

# =========================================
# CARGA DE VARIABLES DE ENTORNO
# =========================================
print("🔧 Cargando variables de entorno...")
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise Exception("❌ ERROR: DATABASE_URL no encontrada")

# =========================================
# FUNCIÓN PRINCIPAL DE CARGA
# =========================================
def main(dim_jugador, dim_personaje, dim_tiempo, dim_evento):
    inicio = datetime.now()

    print("\n==========================================")
    print("🚀 FASE 4.3 — CARGA DE DATOS (ETL)")
    print("==========================================")

    try:
        print("\n📡 Conectando al Data Warehouse...")
        conn = psycopg2.connect(DATABASE_URL)
        cursor = conn.cursor()
        print("✅ Conexión establecida")

        # =====================================
        # CARGA DIM_JUGADOR
        # =====================================
        print("\n📤 Cargando DIM_JUGADOR...")
        for j in dim_jugador:
            cursor.execute("""
                INSERT INTO dw.dim_jugador
                (id_jugador_nk, nombre_usuario, correo, fecha_registro, pais)
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (id_jugador_nk) DO NOTHING;
            """, (
                j["id_jugador_nk"],
                j["nombre_usuario"],
                j["correo"],
                j["fecha_registro"],
                j["pais"]
            ))
        print(f"✅ DIM_JUGADOR cargada: {len(dim_jugador)} registros")

        # =====================================
        # CARGA DIM_PERSONAJE
        # =====================================
        print("\n📤 Cargando DIM_PERSONAJE...")
        for p in dim_personaje:
            cursor.execute("""
                INSERT INTO dw.dim_personaje
                (id_personaje_nk, clase, nivel_inicial, raza)
                VALUES (%s, %s, %s, %s)
                ON CONFLICT (id_personaje_nk) DO NOTHING;
            """, (
                p["id_personaje_nk"],
                p["clase"],
                p["nivel_inicial"],
                p["raza"]
            ))
        print(f"✅ DIM_PERSONAJE cargada: {len(dim_personaje)} registros")

        # =====================================
        # CARGA DIM_TIEMPO
        # =====================================
        print("\n📤 Cargando DIM_TIEMPO...")
        for t in dim_tiempo:
            cursor.execute("""
                INSERT INTO dw.dim_tiempo
                (fecha, dia, mes, anio, trimestre)
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (fecha) DO NOTHING;
            """, (
                t["fecha"],
                t["dia"],
                t["mes"],
                t["anio"],
                t["trimestre"]
            ))
        print(f"✅ DIM_TIEMPO cargada: {len(dim_tiempo)} registros")

        # =====================================
        # CARGA DIM_EVENTO
        # =====================================
        print("\n📤 Cargando DIM_EVENTO...")
        for e in dim_evento:
            cursor.execute("""
                INSERT INTO dw.dim_evento
                (tipo_evento, descripcion, dificultad)
                VALUES (%s, %s, %s);
            """, (
                e["tipo_evento"],
                e["descripcion"],
                e["dificultad"]
            ))
        print(f"✅ DIM_EVENTO cargada: {len(dim_evento)} registros")

        # -------------------------------------
        conn.commit()
        cursor.close()
        conn.close()

        fin = datetime.now()
        print("\n==========================================")
        print("🎉 CARGA FINALIZADA CORRECTAMENTE")
        print("⏱ Tiempo total:", fin - inicio)
        print("==========================================")

    except Exception as e:
        print("\n❌ ERROR DURANTE LA CARGA")
        print("Detalle:", e)


# =========================================
# EJECUCIÓN DE PRUEBA
# =========================================
if __name__ == "__main__":
    print("\n🧪 Ejecución de prueba de LOAD")

    # MOCK mínimo para probar
    dim_jugador = [{
        "id_jugador_nk": 1,
        "nombre_usuario": "LiamA",
        "correo": "liam@example.com",
        "fecha_registro": datetime.now().date(),
        "pais": None
    }]

    dim_personaje = [{
        "id_personaje_nk": 1,
        "clase": "Guerrero",
        "nivel_inicial": 5,
        "raza": None
    }]

    dim_tiempo = [{
        "fecha": datetime.now().date(),
        "dia": datetime.now().day,
        "mes": datetime.now().month,
        "anio": datetime.now().year,
        "trimestre": (datetime.now().month - 1) // 3 + 1
    }]

    dim_evento = [{
        "tipo_evento": "Progreso de personaje",
        "descripcion": "Incremento de nivel",
        "dificultad": "media"
    }]

    main(dim_jugador, dim_personaje, dim_tiempo, dim_evento)
