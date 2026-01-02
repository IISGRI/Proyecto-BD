from datetime import datetime

# =========================================
# FASE 4.2 — TRANSFORMACIÓN DE DATOS
# =========================================

def transformar_jugadores(jugadores):
    print("\n🔄 Transformando DIM_JUGADOR...")
    resultado = []

    for j in jugadores:
        fila = {
            "id_jugador_nk": j["id_jugador"],
            "nombre_usuario": j["nombre_usuario"].strip(),
            "correo": j["correo_electronico"],
            "fecha_registro": j["fecha_registro"],
            "pais": None  # No existe en OLTP
        }
        resultado.append(fila)

    print(f"✅ DIM_JUGADOR transformada: {len(resultado)} registros")
    return resultado


def transformar_personajes(personajes):
    print("\n🔄 Transformando DIM_PERSONAJE...")
    resultado = []

    for p in personajes:
        fila = {
            "id_personaje_nk": p["id_personaje"],
            "clase": p["clase"],
            "nivel_inicial": p["nivel"],
            "raza": None
        }
        resultado.append(fila)

    print(f"✅ DIM_PERSONAJE transformada: {len(resultado)} registros")
    return resultado


def transformar_tiempo(fechas):
    print("\n🔄 Transformando DIM_TIEMPO...")
    resultado = {}

    for fecha in fechas:
        if fecha not in resultado:
            resultado[fecha] = {
                "fecha": fecha,
                "dia": fecha.day,
                "mes": fecha.month,
                "anio": fecha.year,
                "trimestre": (fecha.month - 1) // 3 + 1
            }

    print(f"✅ DIM_TIEMPO generada: {len(resultado)} registros")
    return list(resultado.values())


def transformar_eventos():
    print("\n🔄 Transformando DIM_EVENTO...")

    eventos = [
        {
            "tipo_evento": "Progreso de personaje",
            "descripcion": "Incremento de nivel y experiencia",
            "dificultad": "media"
        }
    ]

    print(f"✅ DIM_EVENTO generada: {len(eventos)} registros")
    return eventos


# =========================================
# PRUEBA LOCAL DE TRANSFORMACIÓN
# =========================================
if __name__ == "__main__":
    print("\n🧪 PRUEBA DE TRANSFORMACIÓN (mock)")

    jugadores_mock = [
        {
            "id_jugador": 1,
            "nombre_usuario": "LiamA",
            "correo_electronico": "liam@example.com",
            "fecha_registro": datetime.now().date()
        }
    ]

    personajes_mock = [
        {
            "id_personaje": 1,
            "clase": "Guerrero",
            "nivel": 5
        }
    ]

    fechas_mock = [datetime.now().date()]

    transformar_jugadores(jugadores_mock)
    transformar_personajes(personajes_mock)
    transformar_tiempo(fechas_mock)
    transformar_eventos()
