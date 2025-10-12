from flask import Flask, render_template, url_for
import psycopg2
import os
from dotenv import load_dotenv

# Cargar variables del archivo .env
load_dotenv()

app = Flask(__name__)

# ==========================================
# Conexión a la base de datos Supabase/PostgreSQL
# ==========================================
def get_db_connection():
    conn = psycopg2.connect(os.getenv("DATABASE_URL"))
    return conn

# ==========================================
# Rutas de la aplicación
# ==========================================

@app.route('/')
def index():
    # Redirige directamente al lobby
    return lobby()

@app.route('/lobby')
def lobby():
    conn = get_db_connection()
    cur = conn.cursor()

    # ⚙️ Aquí seleccionamos al primer jugador como ejemplo
    cur.execute("""
        SELECT id_jugador, nombre_usuario, experiencia, nivel
        FROM jugador
        LIMIT 1;
    """)
    jugador_data = cur.fetchone()

    if jugador_data:
        jugador = {
            'id': jugador_data[0],
            'nombre': jugador_data[1],
            'experiencia': jugador_data[2],
            'nivel': jugador_data[3],
            'xp_porcentaje': jugador_data[2] % 100  # solo para ejemplo visual
        }
    else:
        jugador = {
            'id': 0,
            'nombre': 'Desconocido',
            'experiencia': 0,
            'nivel': 1,
            'xp_porcentaje': 0
        }

    # Ejemplo: obtener personaje asociado al jugador
    cur.execute("""
        SELECT nombre, nivel, clase
        FROM personaje
        WHERE id_jugador = %s
        LIMIT 1;
    """, (jugador['id'],))
    personaje_data = cur.fetchone()

    if personaje_data:
        personaje = {
            'nombre': personaje_data[0],
            'nivel': personaje_data[1],
            'clase': personaje_data[2],
            'imagen': url_for('static', filename='img/personaje01.png')
        }
    else:
        personaje = {
            'nombre': 'Sin personaje',
            'nivel': 0,
            'clase': 'N/A',
            'imagen': url_for('static', filename='img/personaje01.png')
        }

    cur.close()
    conn.close()

    return render_template('lobby.html', jugador=jugador, personaje=personaje)

@app.route('/personajes')
def personajes():
    return render_template('personajes.html')

@app.route('/inventario')
def inventario():
    return render_template('inventario.html')

@app.route('/gremio')
def gremio():
    return render_template('gremio.html')

@app.route('/logros')
def logros():
    return render_template('logros.html')

if __name__ == '__main__':
    app.run(debug=True)
