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
    # Datos de ejemplo — más adelante puedes traerlos desde Supabase
    jugador = {
        'nombre': 'Liam',
        'nivel': 12,
        'id': 42,
        'xp_porcentaje': 60
    }

    personaje = {
        'nombre': 'Aragorn',
        'nivel': 12,
        'clase': 'Guerrero',
        'imagen': url_for('static', filename='img/personaje01.png')
    }

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
