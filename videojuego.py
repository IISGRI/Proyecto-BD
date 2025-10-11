from flask import Flask, render_template, jsonify
import psycopg2
import os
from dotenv import load_dotenv

# Cargar variables del archivo .env
load_dotenv()

app = Flask(__name__)

# Conexión a la base de datos Supabase/PostgreSQL
def get_db_connection():
    conn = psycopg2.connect(os.getenv("DATABASE_URL"))
    return conn

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/jugadores')
def jugadores():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT id_jugador, nombre_usuario, nivel FROM jugador ORDER BY id_jugador;')
    jugadores = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify(jugadores)

if __name__ == '__main__':
    app.run(debug=True)
