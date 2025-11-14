from flask import Flask, render_template, request, redirect, url_for, jsonify, session, flash
import psycopg2
import os
from dotenv import load_dotenv
import threading, time, requests
from psycopg2 import pool

# ==========================================
# MARK: CONFIGURACIÓN INICIAL
# ==========================================
# Se cargan las variables del archivo .env (credenciales, claves, URL de la DB, etc.)
load_dotenv()

# Se crea la aplicación Flask
app = Flask(__name__)

# Clave para manejar sesiones seguras (cookies firmadas)
app.secret_key = os.getenv("SECRET_KEY", "clave_segura_para_sesiones")


# ==========================================
# MARK: CONEXIÓN A LA BASE DE DATOS (POOL CONNECTION)
# ==========================================
# Esta función administra la conexión con Supabase usando un POOL de conexiones.
# Motivo: evitar que Render duerma la app, reducir latencia y prevenir caídas por reconexión constante.
def get_db_connection(max_retries=12, wait_time=10):
    import psycopg2, os, time

    for attempt in range(max_retries):
        try:
            # Si el pool no existe, se crea
            if not hasattr(app, 'db_pool') or app.db_pool is None:
                app.db_pool = psycopg2.pool.SimpleConnectionPool(
                    minconn=1,        # Conexión mínima
                    maxconn=5,        # Máximo de conexiones simultáneas
                    dsn=os.getenv("DATABASE_URL"),
                    sslmode='require' # Requerido para Supabase
                )
                print("✅ Pool de conexiones creado correctamente.")

            # Se obtiene una conexión activa del pool
            conn = app.db_pool.getconn()
            return conn

        except Exception as e:
            # Error al conectar → se informa y se reintenta tras esperar
            print(f"⚠️ Intento {attempt+1}/{max_retries} fallido para conectar: {e}")

            # Se reinicia el pool para evitar errores de estado corrupto
            if hasattr(app, 'db_pool'):
                app.db_pool = None

            # Identificación de Supabase dormida
            if "Connection refused" in str(e):
                print("💤 Supabase parece dormida, esperando que despierte...")

            time.sleep(wait_time)

    # Luego de varios intentos fallidos:
    print("❌ No se pudo conectar a la base después de varios intentos prolongados.")
    raise Exception("Error persistente al conectar a la base de datos.")


# ==========================================
# MARK: LOGIN / REGISTRO / SESIÓN
# ==========================================
@app.route('/login', methods=['GET', 'POST'])
def login():
    # Si el usuario envía credenciales
    if request.method == 'POST':
        correo = request.form['correo']
        contrasena = request.form['contrasena']

        # Conexión segura usando parámetros (previene SQL Injection)
        conn = get_db_connection()
        cur = conn.cursor()

        # Se usa crypt() para validar contraseña en PostgreSQL
        cur.execute("""
            SELECT id_jugador, nombre_usuario
            FROM jugador
            WHERE correo_electronico = %s
            AND contrasena_hash = crypt(%s, contrasena_hash);
        """, (correo, contrasena))

        user = cur.fetchone()
        cur.close()
        app.db_pool.putconn(conn)

        if user:
            # Se guardan datos mínimos en sesión (NO información sensible)
            session['usuario'] = user[1]
            session['id_jugador'] = user[0]
            flash(f'Bienvenido, {user[1]}', 'success')
            return redirect(url_for('lobby'))
        else:
            flash('Correo o contraseña incorrectos', 'error')

    # Si es GET, muestra el formulario
    return render_template('login.html')


@app.route('/registro', methods=['GET', 'POST'])
def registro():
    if request.method == 'POST':
        usuario = request.form['usuario']
        correo = request.form['correo']
        contrasena = request.form['contrasena']

        try:
            conn = get_db_connection()
            cur = conn.cursor()

            # crypt() + gen_salt('bf') → Hash seguro con Blowfish (similar a bcrypt)
            cur.execute("""
                INSERT INTO jugador (nombre_usuario, correo_electronico, contrasena_hash)
                VALUES (%s, %s, crypt(%s, gen_salt('bf')));
            """, (usuario, correo, contrasena))

            conn.commit()
            cur.close()
            app.db_pool.putconn(conn)

            flash('Registro exitoso. Ahora puedes iniciar sesión.', 'success')
            return redirect(url_for('login'))

        except Exception as e:
            print("Error al registrar:", e)
            flash('Error: correo duplicado o datos inválidos.', 'error')

    return render_template('registro.html')


@app.route('/logout')
def logout():
    # Limpia todos los datos de sesión
    session.clear()
    flash('Sesión cerrada correctamente.', 'info')
    return redirect(url_for('login'))


# ==========================================
# MARK: LOBBY PRINCIPAL
# ==========================================
@app.route('/')
def index():
    return redirect(url_for('login'))


@app.route('/lobby')
def lobby():
    # Si no hay sesión → no se permite acceder
    if 'id_jugador' not in session:
        flash('Debes iniciar sesión primero.', 'warning')
        return redirect(url_for('login'))

    conn = get_db_connection()
    cur = conn.cursor()

    # Se cargan datos esenciales del jugador
    cur.execute("""
        SELECT id_jugador, nombre_usuario, experiencia, nivel, id_personaje_activo, id_mascota_activa
        FROM jugador
        WHERE id_jugador = %s;
    """, (session['id_jugador'],))

    jugador_data = cur.fetchone()

    # Si por alguna razón el usuario no existe (inconsistencia)
    if not jugador_data:
        flash("Error al cargar datos del jugador.", "error")
        return redirect(url_for('logout'))

    # Diccionario para enviar al HTML
    jugador = {
        'id': jugador_data[0],
        'nombre': jugador_data[1],
        'experiencia': jugador_data[2],
        'nivel': jugador_data[3],
        'xp_porcentaje': jugador_data[2] % 100  # Se simula barra de XP
    }

    # ==== PERSONAJE ACTIVO ====
    cur.execute("""
        SELECT nombre, nivel, clase
        FROM personaje
        WHERE id_personaje = %s;
    """, (jugador_data[4],))

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
            'nombre': 'Sin personaje activo',
            'nivel': 0,
            'clase': 'N/A',
            'imagen': url_for('static', filename='img/personaje01.png')
        }

    # ==== MASCOTA ACTIVA ====
    cur.execute("""
        SELECT nombre_mascota, tipo, nivel
        FROM mascota
        WHERE id_mascota = %s;
    """, (jugador_data[5],))

    mascota_data = cur.fetchone()

    if mascota_data:
        mascota = {
            'nombre': mascota_data[0],
            'tipo': mascota_data[1],
            'nivel': mascota_data[2],
            'imagen': url_for('static', filename='img/mascota01.png')
        }
    else:
        mascota = {
            'nombre': 'Sin mascota activa',
            'tipo': 'N/A',
            'nivel': 0,
            'imagen': url_for('static', filename='img/mascota01.png')
        }

    cur.close()
    app.db_pool.putconn(conn)

    # Se envían los datos al Lobby
    return render_template('lobby.html', jugador=jugador, personaje=personaje, mascota=mascota)


# ==========================================
# MARK: PERSONAJES — CRUD COMPLETO
# ==========================================
@app.route('/personajes', methods=['GET', 'POST'])
def personajes():
    # Verificación de sesión
    if 'id_jugador' not in session:
        flash('Debes iniciar sesión primero.', 'warning')
        return redirect(url_for('login'))

    conn = get_db_connection()
    cur = conn.cursor()

    # *** CREAR O EDITAR PERSONAJE ***
    if request.method == 'POST':
        id_personaje = request.form.get('id_personaje')
        nombre = request.form['nombre']
        clase = request.form['clase']
        id_jugador = session['id_jugador']

        try:
            if id_personaje:
                # Modificar personaje existente
                cur.execute("""
                    UPDATE personaje
                    SET nombre = %s, clase = %s
                    WHERE id_personaje = %s AND id_jugador = %s;
                """, (nombre, clase, id_personaje, id_jugador))

                flash('✅ Personaje modificado correctamente.', 'success')

            else:
                # Crear personaje nuevo
                cur.execute("""
                    INSERT INTO personaje (id_jugador, nombre, clase, nivel)
                    VALUES (%s, %s, %s, 1);
                """, (id_jugador, nombre, clase))

                flash('🆕 Personaje creado correctamente.', 'success')

            conn.commit()

        except Exception as e:
            conn.rollback()
            flash(f'⚠️ Error al guardar personaje: {e}', 'error')

    # Obtener personajes del jugador
    cur.execute("""
        SELECT id_personaje, nombre, clase, nivel
        FROM personaje
        WHERE id_jugador = %s
        ORDER BY id_personaje;
    """, (session['id_jugador'],))

    personajes = cur.fetchall()

    cur.close()
    app.db_pool.putconn(conn)

    return render_template('personajes.html', personajes=personajes)


# ==== ELIMINAR PERSONAJE ====
@app.route('/eliminar_personaje/<int:id_personaje>', methods=['DELETE'])
def eliminar_personaje(id_personaje):
    if 'id_jugador' not in session:
        return jsonify({"error": "No autorizado"}), 403

    conn = get_db_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            DELETE FROM personaje
            WHERE id_personaje = %s AND id_jugador = %s;
        """, (id_personaje, session['id_jugador']))

        conn.commit()
        return jsonify({"success": True})

    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 400

    finally:
        cur.close()
        app.db_pool.putconn(conn)


# ==== SELECCIONAR PERSONAJE COMO ACTIVO ====
@app.route('/seleccionar_personaje/<int:id_personaje>', methods=['POST'])
def seleccionar_personaje(id_personaje):
    if 'id_jugador' not in session:
        return jsonify({"error": "No autorizado"}), 403

    conn = get_db_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            UPDATE jugador
            SET id_personaje_activo = %s
            WHERE id_jugador = %s;
        """, (id_personaje, session['id_jugador']))

        conn.commit()
        return jsonify({"success": True})

    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 400

    finally:
        cur.close()
        app.db_pool.putconn(conn)


# ==========================================
# MARK: MASCOTAS — CRUD COMPLETO
# ==========================================
@app.route('/mascotas', methods=['GET', 'POST'])
def mascotas():
    if 'id_jugador' not in session:
        flash('Debes iniciar sesión primero.', 'warning')
        return redirect(url_for('login'))

    conn = get_db_connection()
    cur = conn.cursor()

    # Crear o modificar mascota
    if request.method == 'POST':
        id_mascota = request.form.get('id_mascota')
        nombre = request.form['nombre']
        tipo = request.form['tipo']
        id_jugador = session['id_jugador']

        try:
            if id_mascota and id_mascota.strip() != "":
                # Modificar mascota existente
                cur.execute("""
                    UPDATE mascota
                    SET nombre_mascota = %s, tipo = %s
                    WHERE id_mascota = %s
                    AND id_personaje IN (
                        SELECT id_personaje FROM personaje WHERE id_jugador = %s
                    );
                """, (nombre, tipo, id_mascota, id_jugador))

                flash('✅ Mascota modificada correctamente.', 'success')

            else:
                # Crear mascota
                cur.execute("""
                    INSERT INTO mascota (id_personaje, nombre_mascota, tipo, nivel)
                    VALUES (
                        (SELECT id_personaje FROM personaje WHERE id_jugador = %s LIMIT 1),
                        %s, %s, 1
                    );
                """, (id_jugador, nombre, tipo))

                flash('🆕 Mascota creada correctamente.', 'success')

            conn.commit()

        except Exception as e:
            conn.rollback()
            flash(f'⚠️ Error al guardar mascota: {e}', 'error')

    # Obtener mascotas del jugador
    cur.execute("""
        SELECT m.id_mascota, m.nombre_mascota, m.tipo, m.nivel
        FROM mascota m
        JOIN personaje p ON m.id_personaje = p.id_personaje
        WHERE p.id_jugador = %s;
    """, (session['id_jugador'],))

    mascotas = cur.fetchall()

    cur.close()
    app.db_pool.putconn(conn)

    return render_template('mascotas.html', mascotas=mascotas)


# ==== ELIMINAR MASCOTA ====
@app.route('/eliminar_mascota/<int:id_mascota>', methods=['DELETE'])
def eliminar_mascota(id_mascota):
    if 'id_jugador' not in session:
        return jsonify({"error": "No autorizado"}), 403

    conn = get_db_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            DELETE FROM mascota
            WHERE id_mascota = %s
            AND id_personaje IN (SELECT id_personaje FROM personaje WHERE id_jugador = %s);
        """, (id_mascota, session['id_jugador']))

        conn.commit()
        return jsonify({"success": True})

    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 400

    finally:
        cur.close()
        app.db_pool.putconn(conn)


# ==== SELECCIONAR MASCOTA ACTIVA ====
@app.route('/seleccionar_mascota/<int:id_mascota>', methods=['POST'])
def seleccionar_mascota(id_mascota):
    if 'id_jugador' not in session:
        return jsonify({"error": "No autorizado"}), 403

    conn = get_db_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            UPDATE jugador
            SET id_mascota_activa = %s
            WHERE id_jugador = %s;
        """, (id_mascota, session['id_jugador']))

        conn.commit()
        return jsonify({"success": True})

    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 400

    finally:
        cur.close()
        app.db_pool.putconn(conn)


# ==========================================
# MARK: API Y UTILIDADES DEL SISTEMA
# ==========================================
@app.route("/ping")
def ping():
    """
    Ruta usada por el cron-job para mantener despierta la base.
    Consulta rápida para evitar que Supabase entre en modo sleep.
    """
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT NOW();")
        cur.fetchone()
        cur.close()
        app.db_pool.putconn(conn)

        print("✅ Ping exitoso: conexión a la base activa.")
        return "OK", 200

    except Exception as e:
        print(f"⚠️ Ping fallido, base posiblemente dormida: {e}")
        return "Database waking up", 200


@app.route('/api/mascota/<int:id_mascota>')
def obtener_mascota(id_mascota):
    """
    API pública (segura) que devuelve datos de una mascota en formato JSON.
    """
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT id_mascota, nombre_mascota, tipo, nivel
        FROM mascota
        WHERE id_mascota = %s;
    """, (id_mascota,))

    mascota = cur.fetchone()
    cur.close()
    app.db_pool.putconn(conn)

    if mascota:
        return jsonify({
            "id_mascota": mascota[0],
            "nombre": mascota[1],
            "tipo": mascota[2],
            "nivel": mascota[3]
        })

    else:
        return jsonify({"error": "Mascota no encontrada"}), 404


@app.route('/api/personaje/<int:id_personaje>')
def obtener_personaje(id_personaje):
    """
    API que devuelve datos de un personaje.
    """
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT id_personaje, nombre, clase, nivel
        FROM personaje
        WHERE id_personaje = %s;
    """, (id_personaje,))

    personaje = cur.fetchone()
    cur.close()
    app.db_pool.putconn(conn)

    if personaje:
        return jsonify({
            "id_personaje": personaje[0],
            "nombre": personaje[1],
            "clase": personaje[2],
            "nivel": personaje[3]
        })
    else:
        return jsonify({"error": "Personaje no encontrado"}), 404


# ==========================================
# MARK: RUTAS EXTRA (HTML simple)
# ==========================================
@app.route('/inventario')
def inventario():
    return render_template('inventario.html')


@app.route('/gremio')
def gremio():
    return render_template('gremio.html')


@app.route('/logros')
def logros():
    return render_template('logros.html')


# ==========================================
# MARK: EJECUCIÓN PRINCIPAL DE FLASK
# ==========================================
if __name__ == '__main__':
    # debug=True permite autorecargar y ver errores detallados (solo en desarrollo)
    app.run(debug=True)
