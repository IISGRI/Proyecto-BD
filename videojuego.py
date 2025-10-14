from flask import Flask, render_template, request, redirect, url_for,jsonify
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

@app.route('/personajes', methods=['GET', 'POST'])
def personajes():
    conn = get_db_connection()
    cur = conn.cursor()

    if request.method == 'POST':
        nombre = request.form['nombre']
        clase = request.form['clase']
        nivel = request.form['nivel']
        id_jugador = 1  # Ajusta esto según el jugador actual

        cur.execute("""
            INSERT INTO personaje (id_jugador, nombre, clase, nivel)
            VALUES (%s, %s, %s, %s)
        """, (id_jugador, nombre, clase, nivel))
        conn.commit()

    cur.execute("SELECT id_personaje, nombre, clase, nivel FROM personaje;")
    personajes = cur.fetchall()
    cur.close()
    conn.close()

    return render_template('personajes.html', personajes=personajes)


@app.route('/mascotas', methods=['GET', 'POST'])
def mascotas():
    conn = get_db_connection()
    cur = conn.cursor()

    if request.method == 'POST':
        nombre = request.form['nombre']
        tipo = request.form['tipo']
        nivel = request.form['nivel']
        id_jugador = 1  # Ajusta esto según el jugador actual

        cur.execute("""
            INSERT INTO mascota (id_jugador, nombre, tipo, nivel)
            VALUES (%s, %s, %s, %s)
        """, (id_jugador, nombre, tipo, nivel))
        conn.commit()

    cur.execute("SELECT id_mascota, nombre, tipo, nivel FROM mascota;")
    mascotas = cur.fetchall()
    cur.close()
    conn.close()

    return render_template('mascotas.html', mascotas=mascotas)

@app.route('/api/personaje/<int:id_personaje>')
def obtener_personaje(id_personaje):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT id_personaje, nombre, clase, nivel FROM personaje WHERE id_personaje = %s;", (id_personaje,))
    personaje = cur.fetchone()
    cur.close()
    conn.close()
    if personaje:
        return jsonify({
            "id_personaje": personaje[0],
            "nombre": personaje[1],
            "clase": personaje[2],
            "nivel": personaje[3]
        })
    else:
        return jsonify({"error": "Personaje no encontrado"}), 404


@app.route('/api/mascota/<int:id_mascota>')
def obtener_mascota(id_mascota):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT id_mascota, nombre, tipo, nivel FROM mascota WHERE id_mascota = %s;", (id_mascota,))
    mascota = cur.fetchone()
    cur.close()
    conn.close()
    if mascota:
        return jsonify({
            "id_mascota": mascota[0],
            "nombre": mascota[1],
            "tipo": mascota[2],
            "nivel": mascota[3]
        })
    else:
        return jsonify({"error": "Mascota no encontrada"}), 404

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
