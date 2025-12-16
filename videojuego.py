from flask import Flask, render_template, request, redirect, url_for, jsonify, session, flash
import os
from dotenv import load_dotenv
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text
from werkzeug.security import generate_password_hash, check_password_hash

# ==========================================
# MARK: CONFIGURACIÓN INICIAL
# ==========================================
# Se cargan las variables del archivo .env (credenciales, claves, URL de la DB, etc.)
load_dotenv()

# Se crea la aplicación Flask
app = Flask(__name__)

# Clave para manejar sesiones seguras (cookies firmadas)
app.secret_key = os.getenv("SECRET_KEY", "clave_segura_para_sesiones")

from config import Config
app.config.from_object(Config)

app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    "pool_pre_ping": True,     # 🔥 detecta conexiones muertas
    "pool_recycle": 280,       # 🔁 recicla conexiones viejas
}

db = SQLAlchemy(app)


class Jugador(db.Model):
    __tablename__ = 'jugador'

    id_jugador = db.Column(db.Integer, primary_key=True)

    nombre_usuario = db.Column(db.String(100), nullable=False)
    correo_electronico = db.Column(db.String(100), unique=True, nullable=False)
    contrasena_hash = db.Column(db.String(255), nullable=False)

    # 🔹 PERSONAJE ACTIVO
    id_personaje_activo = db.Column(
        db.Integer,
        db.ForeignKey('personaje.id_personaje'),
        nullable=True
    )

    personaje_activo = db.relationship(
        'Personaje',
        foreign_keys=[id_personaje_activo],
        uselist=False
    )

    # 🔹 MASCOTA ACTIVA (AQUÍ VA)
    id_mascota_activa = db.Column(
        db.Integer,
        db.ForeignKey('mascota.id_mascota'),
        nullable=True
    )

    # 🔹 LISTA DE PERSONAJES
    personajes = db.relationship(
        'Personaje',
        foreign_keys='Personaje.id_jugador',
        back_populates='jugador'
    )

    def __repr__(self):
        return f"<Jugador {self.nombre_usuario}>"

class Personaje(db.Model):
    __tablename__ = 'personaje'

    id_personaje = db.Column(db.Integer, primary_key=True)

    id_jugador = db.Column(
        db.Integer,
        db.ForeignKey('jugador.id_jugador'),
        nullable=False
    )

    nombre = db.Column(db.String(100), nullable=False)
    clase = db.Column(db.String(50), nullable=False)
    nivel = db.Column(db.Integer, default=1)

    jugador = db.relationship(
        'Jugador',
        foreign_keys=[id_jugador],
        back_populates='personajes'
    )

    def __repr__(self):
        return f"<Personaje {self.nombre}>"

class Mascota(db.Model):
    __tablename__ = 'mascota'

    id_mascota = db.Column(db.Integer, primary_key=True)
    id_personaje = db.Column(db.Integer, db.ForeignKey('personaje.id_personaje'), nullable=False)

    nombre_mascota = db.Column(db.String(50), nullable=False)
    tipo = db.Column(db.String(50), nullable=False)
    nivel = db.Column(db.Integer, default=1)

class Objeto(db.Model):
    __tablename__ = 'objeto'

    id_objeto = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(80), nullable=False)
    descripcion = db.Column(db.Text)
    valor = db.Column(db.Integer)
    rareza = db.Column(db.String(30))

    # 🔥 ESTO FALTABA
    pocion = db.relationship("Pocion", back_populates="objeto", uselist=False)
    arma = db.relationship("Arma", back_populates="objeto", uselist=False)
    armadura = db.relationship("Armadura", back_populates="objeto", uselist=False)

    inventarios = db.relationship("Inventario", back_populates="objeto")

class Pocion(db.Model):
    __tablename__ = 'pocion'

    id_objeto = db.Column(
        db.Integer,
        db.ForeignKey('objeto.id_objeto'),
        primary_key=True
    )
    efecto = db.Column(db.Text)

    objeto = db.relationship("Objeto", back_populates="pocion")

class Arma(db.Model):
    __tablename__ = 'arma'

    id_objeto = db.Column(
        db.Integer,
        db.ForeignKey('objeto.id_objeto'),
        primary_key=True
    )
    dano_base = db.Column(db.Integer)

    objeto = db.relationship("Objeto", back_populates="arma")

class Armadura(db.Model):
    __tablename__ = 'armadura'

    id_objeto = db.Column(
        db.Integer,
        db.ForeignKey('objeto.id_objeto'),
        primary_key=True
    )
    valor_defensa = db.Column(db.Integer)

    objeto = db.relationship("Objeto", back_populates="armadura")


class Inventario(db.Model):
    __tablename__ = 'inventario'

    id_personaje = db.Column(
        db.Integer,
        db.ForeignKey('personaje.id_personaje'),
        primary_key=True
    )
    id_objeto = db.Column(
        db.Integer,
        db.ForeignKey('objeto.id_objeto'),
        primary_key=True
    )

    cantidad = db.Column(db.Integer, default=1)

    objeto = db.relationship("Objeto", back_populates="inventarios")

class Gremio(db.Model):
    __tablename__ = 'gremio'

    id_gremio = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(80), nullable=False)
    fecha_fundacion = db.Column(db.Date)

class Pertenece(db.Model):
    __tablename__ = 'pertenece'

    id_jugador = db.Column(db.Integer, db.ForeignKey('jugador.id_jugador'), primary_key=True)
    id_gremio = db.Column(db.Integer, db.ForeignKey('gremio.id_gremio'), primary_key=True)

class Logro(db.Model):
    __tablename__ = 'logro'

    id_logro = db.Column(db.Integer, primary_key=True)
    nombre_logro = db.Column(db.String(100), nullable=False)
    descripcion_logro = db.Column(db.Text)

class Obtiene(db.Model):
    __tablename__ = 'obtiene'

    id_jugador = db.Column(db.Integer, db.ForeignKey('jugador.id_jugador'), primary_key=True)
    id_logro = db.Column(db.Integer, db.ForeignKey('logro.id_logro'), primary_key=True)

# ==========================================
# MARK: LOGIN
# ==========================================
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        correo = request.form['correo']
        contrasena = request.form['contrasena']

        jugador = Jugador.query.filter_by(
            correo_electronico=correo
        ).first()

        if not jugador:
            flash("Correo o contraseña incorrectos", "error")
            return render_template('login.html')

        # ✅ CASO 1: Hash nuevo (Werkzeug)
        if jugador.contrasena_hash.startswith("pbkdf2:") or jugador.contrasena_hash.startswith("scrypt:"):
            if check_password_hash(jugador.contrasena_hash, contrasena):
                session['usuario'] = jugador.nombre_usuario
                session['id_jugador'] = jugador.id_jugador
                flash(f"Bienvenido, {jugador.nombre_usuario}", "success")
                return redirect(url_for('lobby'))

        # 🔄 CASO 2: Hash viejo (PostgreSQL crypt)
        else:
            try:
                result = db.session.execute(
                    text("""
                        SELECT id_jugador
                        FROM jugador
                        WHERE id_jugador = :id
                        AND contrasena_hash = crypt(:pass, contrasena_hash)
                    """),
                    {
                        "id": jugador.id_jugador,
                        "pass": contrasena
                    }
                ).fetchone()

                if result:
                    # 🔁 Rehashear con Werkzeug
                    jugador.contrasena_hash = generate_password_hash(contrasena)
                    db.session.commit()

                    session['usuario'] = jugador.nombre_usuario
                    session['id_jugador'] = jugador.id_jugador
                    flash("Contraseña actualizada automáticamente 🔐", "success")
                    return redirect(url_for('lobby'))

            except Exception as e:
                flash(f"Error en migración de contraseña: {e}", "error")

        flash("Correo o contraseña incorrectos", "error")

    return render_template('login.html')

# ==========================================
# MARK: REGISTRO
# ==========================================
@app.route('/registro', methods=['GET', 'POST'])
def registro():
    if request.method == 'POST':
        usuario = request.form['usuario']
        correo = request.form['correo']
        contrasena = request.form['contrasena']

        # 🔎 Verificar si el correo ya existe
        existente = Jugador.query.filter_by(
            correo_electronico=correo
        ).first()

        if existente:
            flash("❌ El correo ya está registrado.", "error")
            return redirect(url_for('registro'))

        try:
            # 🔐 Hash moderno (Werkzeug)
            hash_password = generate_password_hash(contrasena)

            nuevo_jugador = Jugador(
                nombre_usuario=usuario,
                correo_electronico=correo,
                contrasena_hash=hash_password
            )

            db.session.add(nuevo_jugador)
            db.session.commit()

            flash("✅ Registro exitoso. Ahora puedes iniciar sesión.", "success")
            return redirect(url_for('login'))

        except Exception as e:
            db.session.rollback()
            flash(f"⚠️ Error al registrar usuario: {e}", "error")

    return render_template('registro.html')

# ==========================================
# MARK: LOGOUT
# ==========================================
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
    if 'id_jugador' not in session:
        flash("Debes iniciar sesión primero.", "warning")
        return redirect(url_for('login'))

    # 🔹 Obtener jugador (ORM moderno)
    jugador = db.session.get(Jugador, session['id_jugador'])

    if not jugador:
        flash("Jugador no encontrado.", "error")
        return redirect(url_for('logout'))

    # 🔹 Datos del jugador
    jugador_data = {
        "id": jugador.id_jugador,
        "nombre": jugador.nombre_usuario
    }

    # 🔹 Personaje activo (relación ORM)
    if jugador.personaje_activo:
        personaje_data = {
            "id": jugador.personaje_activo.id_personaje,
            "nombre": jugador.personaje_activo.nombre,
            "nivel": jugador.personaje_activo.nivel,
            "clase": jugador.personaje_activo.clase,
            "imagen": url_for('static', filename='img/personaje01.png')
        }
    else:
        personaje_data = {
            "id": None,
            "nombre": "Sin personaje activo",
            "nivel": 0,
            "clase": "N/A",
            "imagen": url_for('static', filename='img/personaje01.png')
        }

    return render_template(
        "lobby.html",
        jugador=jugador_data,
        personaje=personaje_data
    )

# ==========================================
# MARK: PERSONAJES
# ==========================================
@app.route('/personajes', methods=['GET', 'POST'])
def personajes():
    if 'id_jugador' not in session:
        flash('Debes iniciar sesión primero.', 'warning')
        return redirect(url_for('login'))

    id_jugador = session['id_jugador']

    # 🔹 Crear o editar personaje
    if request.method == 'POST':
        id_personaje = request.form.get('id_personaje')
        nombre = request.form['nombre']
        clase = request.form['clase']

        try:
            if id_personaje:
                # ✏️ Editar personaje existente
                personaje = db.session.get(Personaje, int(id_personaje))

                if not personaje or personaje.id_jugador != id_jugador:
                    flash("Personaje no válido.", "error")
                    return redirect(url_for('personajes'))

                personaje.nombre = nombre
                personaje.clase = clase
                flash("✅ Personaje actualizado.", "success")

            else:
                # 🆕 Crear nuevo personaje
                nuevo = Personaje(
                    id_jugador=id_jugador,
                    nombre=nombre,
                    clase=clase,
                    nivel=1
                )
                db.session.add(nuevo)
                flash("🆕 Personaje creado.", "success")

            db.session.commit()

        except Exception as e:
            db.session.rollback()
            flash(f"⚠️ Error al guardar personaje: {e}", "error")

        return redirect(url_for('personajes'))

    # 🔹 Listar personajes del jugador
    personajes = Personaje.query.filter_by(
        id_jugador=id_jugador
    ).order_by(Personaje.id_personaje).all()

    return render_template('personajes.html', personajes=personajes)

# ==========================================
# MARK: ELIMINAR PERSONAJE
# ==========================================
@app.route('/eliminar_personaje/<int:id_personaje>', methods=['DELETE'])
def eliminar_personaje(id_personaje):
    if 'id_jugador' not in session:
        return jsonify({"error": "No autorizado"}), 403

    personaje = db.session.get(Personaje, id_personaje)

    if not personaje or personaje.id_jugador != session['id_jugador']:
        return jsonify({"error": "Personaje no encontrado"}), 404

    try:
        db.session.delete(personaje)
        db.session.commit()
        return jsonify({"success": True})

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 400

# ==========================================
# MARK: SELECCIONAR PERSONAJE COMO ACTIVO
# ==========================================
@app.route('/seleccionar_personaje/<int:id_personaje>', methods=['POST'])
def seleccionar_personaje(id_personaje):
    if 'id_jugador' not in session:
        return {"error": "No autenticado"}, 401

    jugador = db.session.get(Jugador, session['id_jugador'])
    personaje = db.session.get(Personaje, id_personaje)

    if not jugador or not personaje or personaje.id_jugador != jugador.id_jugador:
        return {"error": "Acción no permitida"}, 400

    jugador.id_personaje_activo = personaje.id_personaje
    db.session.commit()

    return {"success": True}, 200

# ==========================================
# MARK: MASCOTAS
# ==========================================
@app.route('/mascotas', methods=['GET', 'POST'])
def mascotas():
    if 'id_jugador' not in session:
        flash('Debes iniciar sesión primero.', 'warning')
        return redirect(url_for('login'))

    jugador = db.session.get(Jugador, session['id_jugador'])

    if not jugador:
        flash("Jugador no encontrado.", "error")
        return redirect(url_for('logout'))

    # 🔹 Usamos el personaje activo
    if not jugador.id_personaje_activo:
        flash("Debes seleccionar un personaje activo.", "warning")
        return redirect(url_for('personajes'))

    id_personaje = jugador.id_personaje_activo

    # ======================
    # CREAR / EDITAR
    # ======================
    if request.method == 'POST':
        id_mascota = request.form.get('id_mascota')
        nombre = request.form['nombre']
        tipo = request.form['tipo']

        try:
            if id_mascota:
                # ✏️ Editar
                mascota = db.session.get(Mascota, int(id_mascota))

                if not mascota or mascota.id_personaje != id_personaje:
                    flash("Mascota no válida.", "error")
                    return redirect(url_for('mascotas'))

                mascota.nombre_mascota = nombre
                mascota.tipo = tipo
                flash("✅ Mascota actualizada.", "success")

            else:
                # 🆕 Crear
                nueva = Mascota(
                    id_personaje=id_personaje,
                    nombre_mascota=nombre,
                    tipo=tipo,
                    nivel=1
                )
                db.session.add(nueva)
                flash("🆕 Mascota creada.", "success")

            db.session.commit()

        except Exception as e:
            db.session.rollback()
            flash(f"⚠️ Error al guardar mascota: {e}", "error")

        return redirect(url_for('mascotas'))

    # ======================
    # LISTAR
    # ======================
    mascotas = Mascota.query.filter_by(
        id_personaje=id_personaje
    ).order_by(Mascota.id_mascota).all()

    return render_template('mascotas.html', mascotas=mascotas)

# ==========================================
# MARK: ELIMINAR MASCOTA
# ==========================================
@app.route('/eliminar_mascota/<int:id_mascota>', methods=['DELETE'])
def eliminar_mascota(id_mascota):
    if 'id_jugador' not in session:
        return jsonify({"error": "No autorizado"}), 403

    mascota = db.session.get(Mascota, id_mascota)

    if not mascota:
        return jsonify({"error": "Mascota no encontrada"}), 404

    # Validar que pertenece al jugador
    jugador = db.session.get(Jugador, session['id_jugador'])
    if mascota.id_personaje != jugador.id_personaje_activo:
        return jsonify({"error": "Acción no permitida"}), 403

    try:
        db.session.delete(mascota)
        db.session.commit()
        return jsonify({"success": True})

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 400

# ==========================================
# MARK: SELECCIONAR MASCOTA ACTIVA 
# ==========================================
@app.route('/seleccionar_mascota/<int:id_mascota>', methods=['POST'])
def seleccionar_mascota(id_mascota):
    if 'id_jugador' not in session:
        return jsonify({"error": "No autorizado"}), 403

    jugador = db.session.get(Jugador, session['id_jugador'])
    if not jugador:
        return jsonify({"error": "Jugador no encontrado"}), 404

    mascota = db.session.get(Mascota, id_mascota)
    if not mascota:
        return jsonify({"error": "Mascota no encontrada"}), 404

    # 🔒 Validar que la mascota pertenezca al jugador
    if mascota.id_personaje != jugador.id_personaje_activo:
        return jsonify({"error": "Mascota no pertenece a tu personaje activo"}), 403

    try:
        jugador.id_mascota_activa = mascota.id_mascota
        db.session.commit()
        return jsonify({"success": True})

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 400

# ==========================================
# MARK: API Y UTILIDADES DEL SISTEMA
# ==========================================

@app.route('/api/mascota/<int:id_mascota>')
def obtener_mascota(id_mascota):
    mascota = db.session.get(Mascota, id_mascota)

    if not mascota:
        return jsonify({"error": "Mascota no encontrada"}), 404

    return jsonify({
        "id_mascota": mascota.id_mascota,
        "nombre": mascota.nombre_mascota,
        "tipo": mascota.tipo,
        "nivel": mascota.nivel
    })

@app.route('/api/personaje/<int:id_personaje>')
def obtener_personaje(id_personaje):
    personaje = db.session.get(Personaje, id_personaje)

    if not personaje:
        return jsonify({"error": "Personaje no encontrado"}), 404

    return jsonify({
        "id_personaje": personaje.id_personaje,
        "nombre": personaje.nombre,
        "clase": personaje.clase,
        "nivel": personaje.nivel
    })

# ==========================================
# MARK: INVENTARIO
# ==========================================
@app.route('/inventario/<tipo>', methods=['GET', 'POST'])
def inventario(tipo):
    if 'id_jugador' not in session:
        flash("Debes iniciar sesión", "warning")
        return redirect(url_for('login'))

    jugador = db.session.get(Jugador, session['id_jugador'])

    if not jugador or not jugador.id_personaje_activo:
        flash("Debes seleccionar un personaje activo", "warning")
        return redirect(url_for('personajes'))

    id_personaje = jugador.id_personaje_activo

    # ======================================
    # 🔧 POST: ACCIONES / AGREGAR / CREAR
    # ======================================
    if request.method == 'POST':
        modo = request.form.get('modo')

        # ==========================
        # ➕ AGREGAR OBJETO EXISTENTE
        # ==========================
        if modo == 'existente':
            id_objeto = int(request.form['id_objeto'])
            cantidad = int(request.form.get('cantidad', 1))

            inv = Inventario.query.filter_by(
                id_personaje=id_personaje,
                id_objeto=id_objeto
            ).first()

            if inv:
                inv.cantidad += cantidad
            else:
                nuevo = Inventario(
                    id_personaje=id_personaje,
                    id_objeto=id_objeto,
                    cantidad=cantidad
                )
                db.session.add(nuevo)

            db.session.commit()
            flash("Objeto agregado al inventario", "success")
            return redirect(request.url)

        # ==========================
        # 🆕 CREAR NUEVO OBJETO
        # ==========================
        if modo == 'nuevo':
            nombre = request.form['nombre']
            descripcion = request.form['descripcion']
            valor = int(request.form.get('valor', 0))
            rareza = request.form['rareza']
            tipo_obj = request.form['tipo']
            extra = request.form['extra']

            # Crear objeto base
            objeto = Objeto(
                nombre=nombre,
                descripcion=descripcion,
                valor=valor,
                rareza=rareza
            )
            db.session.add(objeto)
            db.session.flush()  # 🔥 obtiene id_objeto

            # Tabla hija según tipo
            if tipo_obj == 'pocion':
                db.session.add(Pocion(
                    id_objeto=objeto.id_objeto,
                    efecto=extra
                ))
            elif tipo_obj == 'arma':
                db.session.add(Arma(
                    id_objeto=objeto.id_objeto,
                    dano_base=int(extra)
                ))
            elif tipo_obj == 'armadura':
                db.session.add(Armadura(
                    id_objeto=objeto.id_objeto,
                    valor_defensa=int(extra)
                ))

            # Agregar al inventario
            inv = Inventario(
                id_personaje=id_personaje,
                id_objeto=objeto.id_objeto,
                cantidad=1
            )
            db.session.add(inv)

            db.session.commit()
            flash("Objeto creado y agregado al inventario", "success")
            return redirect(request.url)

        # ==========================
        # ⚙ ACCIONES (+ − 🗑)
        # ==========================
        accion = request.form.get('accion')
        id_objeto = int(request.form.get('id_objeto'))
        inv = Inventario.query.filter_by(
            id_personaje=id_personaje,
            id_objeto=id_objeto
        ).first()

        if not inv:
            flash("Objeto no encontrado", "error")
            return redirect(request.url)

        if accion == 'sumar':
            inv.cantidad += 1
        elif accion == 'restar':
            inv.cantidad -= 1
            if inv.cantidad <= 0:
                db.session.delete(inv)
        elif accion == 'eliminar':
            db.session.delete(inv)

        db.session.commit()
        return redirect(request.url)

    # ======================================
    # 📦 LISTADO Y OBJETOS DISPONIBLES
    # ======================================
    if tipo == 'pociones':
        lista = (
            db.session.query(Inventario)
            .join(Objeto)
            .join(Pocion)
            .filter(Inventario.id_personaje == id_personaje)
            .all()
        )
        objetos = (
            db.session.query(Objeto)
            .join(Pocion)
            .all()
        )
        titulo = "Pociones"

    elif tipo == 'armas':
        lista = (
            db.session.query(Inventario)
            .join(Objeto)
            .join(Arma)
            .filter(Inventario.id_personaje == id_personaje)
            .all()
        )
        objetos = (
            db.session.query(Objeto)
            .join(Arma)
            .all()
        )
        titulo = "Armas"

    elif tipo == 'armaduras':
        lista = (
            db.session.query(Inventario)
            .join(Objeto)
            .join(Armadura)
            .filter(Inventario.id_personaje == id_personaje)
            .all()
        )
        objetos = (
            db.session.query(Objeto)
            .join(Armadura)
            .all()
        )
        titulo = "Armaduras"

    else:
        flash("Categoría inválida", "error")
        return redirect(url_for('lobby'))

    return render_template(
        'inventario.html',
        lista=lista,
        objetos=objetos,
        tipo=tipo,
        titulo=titulo
    )

# ==========================================
# MARK: LOGROS
# ==========================================
@app.route('/logros')
def logros():
    if 'id_jugador' not in session:
        flash('Debes iniciar sesión primero.', 'warning')
        return redirect(url_for('login'))

    id_jugador = session['id_jugador']

    # 🔹 Obtener todos los logros
    logros_db = Logro.query.order_by(Logro.id_logro).all()

    # 🔹 Logros obtenidos por el jugador
    obtenidos = (
        db.session.query(Obtiene.id_logro)
        .filter(Obtiene.id_jugador == id_jugador)
        .all()
    )

    # Convertimos a set para búsqueda rápida
    logros_obtenidos = {o.id_logro for o in obtenidos}

    # 🔹 Construir respuesta para el template
    logros = []
    for l in logros_db:
        logros.append({
            "id_logro": l.id_logro,
            "nombre_logro": l.nombre_logro,
            "descripcion_logro": l.descripcion_logro,
            "desbloqueado": l.id_logro in logros_obtenidos
        })

    return render_template("logros.html", logros=logros)

# ==========================================
# MARK: GREMIO
# ==========================================

@app.route('/gremio')
def gremio():
    if 'id_jugador' not in session:
        flash("Debes iniciar sesión.", "warning")
        return redirect(url_for('login'))

    id_jugador = session['id_jugador']

    # 🔹 Ver si pertenece a un gremio
    pertenece = (
        db.session.query(Pertenece)
        .filter_by(id_jugador=id_jugador)
        .first()
    )

    # =====================================
    # 🔹 CASO 1: TIENE GREMIO
    # =====================================
    if pertenece:
        gremio = db.session.get(Gremio, pertenece.id_gremio)

        # Miembros del gremio
        miembros = (
            db.session.query(Jugador)
            .join(Pertenece, Pertenece.id_jugador == Jugador.id_jugador)
            .filter(Pertenece.id_gremio == gremio.id_gremio)
            .order_by(Jugador.id_jugador)
            .all()
        )

        return render_template(
            "gremio.html",
            gremio={
                "id_gremio": gremio.id_gremio,
                "nombre": gremio.nombre,
                "fecha_fundacion": gremio.fecha_fundacion
            },
            miembros=[
                {
                    "nombre_usuario": m.nombre_usuario,
                    "nivel": 1  # ⚠️ Si luego agregas nivel al jugador aquí va
                }
                for m in miembros
            ]
        )

    # =====================================
    # 🔹 CASO 2: NO TIENE GREMIO
    # =====================================
    gremios = Gremio.query.order_by(Gremio.id_gremio).all()

    disponibles = [
        {
            "id_gremio": g.id_gremio,
            "nombre": g.nombre,
            "fecha_fundacion": g.fecha_fundacion
        }
        for g in gremios
    ]

    return render_template("gremio.html", gremio=None, disponibles=disponibles)
# ==========================================
# MARK: UNIRSE A UN GREMIO
# ==========================================
@app.route('/unirse_gremio/<int:id_gremio>', methods=['POST'])
def unirse_gremio(id_gremio):
    if 'id_jugador' not in session:
        flash("Debes iniciar sesión.", "warning")
        return redirect(url_for('login'))

    try:
        nuevo = Pertenece(
            id_jugador=session['id_jugador'],
            id_gremio=id_gremio
        )
        db.session.add(nuevo)
        db.session.commit()

        flash("Te has unido al gremio correctamente.", "success")

    except Exception:
        db.session.rollback()
        flash("Ya perteneces a un gremio.", "error")

    return redirect(url_for('gremio'))
# ==========================================
# MARK: ABANDONAR GREMIO
# ==========================================
@app.route('/abandonar_gremio', methods=['POST'])
def abandonar_gremio():
    if 'id_jugador' not in session:
        flash("Debes iniciar sesión.", "warning")
        return redirect(url_for('login'))

    pertenece = (
        db.session.query(Pertenece)
        .filter_by(id_jugador=session['id_jugador'])
        .first()
    )

    if pertenece:
        db.session.delete(pertenece)
        db.session.commit()
        flash("Has salido del gremio.", "info")

    return redirect(url_for('gremio'))
# ==========================================
# MARK: CREAR GREMIO
# ==========================================
@app.route('/crear_gremio', methods=['POST'])
def crear_gremio():
    if 'id_jugador' not in session:
        flash("Debes iniciar sesión.", "warning")
        return redirect(url_for('login'))

    nombre = request.form['nombre']

    try:
        gremio = Gremio(
            nombre=nombre,
            fecha_fundacion=db.func.current_date()
        )
        db.session.add(gremio)
        db.session.flush()  # obtiene id_gremio

        pertenece = Pertenece(
            id_jugador=session['id_jugador'],
            id_gremio=gremio.id_gremio
        )
        db.session.add(pertenece)

        db.session.commit()
        flash("Gremio creado y unido correctamente.", "success")

    except Exception as e:
        db.session.rollback()
        flash("Error al crear gremio.", "error")
        print(e)

    return redirect(url_for('gremio'))

#MARK: PRUEBAS
@app.route('/test-db')
def test_db():
    try:
        db.session.execute(text("SELECT 1"))
        return "✅ Conexión ORM OK"
    except Exception as e:
        return f"❌ Error ORM: {e}"
    
@app.route('/test-jugador')
def test_jugador():
    try:
        jugador = Jugador.query.first()
        return f"Jugador encontrado: {jugador.nombre_usuario}"
    except Exception as e:
        return f"❌ Error Jugador ORM: {e}"

# ==========================================
# MARK: EJECUCIÓN PRINCIPAL DE FLASK
# ==========================================
if __name__ == '__main__':
    app.run()
