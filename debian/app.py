"""
app.py — Servidor Flask SSA UMSA para demo MITM educativa
Corre en Debian. La víctima (Windows) se conecta aquí normalmente.
El atacante (Kali) intercepta el tráfico con mitmproxy sin que nadie lo sepa.

Instalar en Debian:
    python3 -m venv venv && source venv/bin/activate
    pip install flask werkzeug
Correr:
    python3 app.py
Acceder desde Windows:
    http://192.168.0.11:5000
"""

from flask import (
    Flask, render_template, request,
    redirect, url_for, session, g
)
from werkzeug.security import generate_password_hash, check_password_hash
import sqlite3, os, datetime

app = Flask(__name__)
app.secret_key = "clave-super-secreta-ssa-umsa-2024"

DB_PATH = os.path.join(os.path.dirname(__file__), "ssa.db")

# ─── Base de datos ────────────────────────────────────────────────

def get_db():
    db = getattr(g, "_database", None)
    if db is None:
        db = g._database = sqlite3.connect(DB_PATH)
        db.row_factory = sqlite3.Row
    return db

@app.teardown_appcontext
def close_db(exc):
    db = getattr(g, "_database", None)
    if db:
        db.close()

def init_db():
    """Crea tablas y usuarios de demo si la BD no existe."""
    if os.path.exists(DB_PATH):
        return
    with app.app_context():
        db = get_db()
        db.executescript("""
            CREATE TABLE IF NOT EXISTS usuarios (
                id       INTEGER PRIMARY KEY AUTOINCREMENT,
                nombre   TEXT NOT NULL,
                email    TEXT UNIQUE NOT NULL,
                password TEXT NOT NULL
            );
            CREATE TABLE IF NOT EXISTS inscripciones (
                id         INTEGER PRIMARY KEY AUTOINCREMENT,
                usuario_id INTEGER,
                nombre     TEXT,
                gestion    TEXT,
                periodo    TEXT,
                FOREIGN KEY(usuario_id) REFERENCES usuarios(id)
            );
        """)
        # Usuarios de demo con contraseñas reales hasheadas
        usuarios_demo = [
            ("Alexander Jonathan Villarroel Torrico", "alexander@ssa.umsa.bo", "umsa2024",   0),
            ("Maria Fernanda Quispe Lopez",            "mquispe@ssa.umsa.bo",   "infosecure", 0),
            ("Carlos Eduardo Mamani Flores",           "cmamani@ssa.umsa.bo",   "carrera123", 0),
        ]
        for nombre, email, pw, saldo in usuarios_demo:
            db.execute(
                "INSERT OR IGNORE INTO usuarios (nombre, email, password) VALUES (?,?,?)",
                (nombre, email, generate_password_hash(pw))
            )
        # Inscripciones de demo
        inscripciones = [
            (1, "PRIMERO 2026",   "2026", "PRIMERO"),
            (1, "EX. MESA 2025", "2025", "EX. MESA"),
            (1, "VERANO 2025",   "2025", "VERANO"),
            (1, "SEGUNDO 2025",  "2025", "SEGUNDO"),
            (1, "INVIERNO 2025", "2025", "INVIERNO"),
            (1, "PRIMERO 2025",  "2025", "PRIMERO"),
            (1, "VERANO 2024",   "2024", "VERANO"),
            (1, "SEGUNDO 2024",  "2024", "SEGUNDO"),
            (1, "INVIERNO 2024", "2024", "INVIERNO"),
            (2, "PRIMERO 2026",  "2026", "PRIMERO"),
            (2, "SEGUNDO 2025",  "2025", "SEGUNDO"),
            (3, "PRIMERO 2026",  "2026", "PRIMERO"),
            (3, "VERANO 2025",   "2025", "VERANO"),
        ]
        for uid, nombre, gestion, periodo in inscripciones:
            db.execute(
                "INSERT INTO inscripciones (usuario_id, nombre, gestion, periodo) VALUES (?,?,?,?)",
                (uid, nombre, gestion, periodo)
            )
        db.commit()
    print("[DB] Base de datos SSA creada con usuarios de demo.")

# ─── Rutas ────────────────────────────────────────────────────────

@app.route("/")
def index():
    if "usuario_id" in session:
        return redirect(url_for("dashboard"))
    return redirect(url_for("login"))


@app.route("/login", methods=["GET", "POST"])
def login():
    error = None
    if request.method == "POST":
        email    = request.form.get("email", "").strip()
        password = request.form.get("password", "")

        # Log en consola del servidor (Debian) — visible para el presentador
        print(f"\n{'='*55}")
        print(f"  [SERVIDOR DEBIAN] Intento de login recibido")
        print(f"  Email   : {email}")
        print(f"  Password: {password}   <-- esto llega al servidor")
        print(f"  IP origen: {request.remote_addr}")
        print(f"  Timestamp: {datetime.datetime.now()}")
        print(f"{'='*55}\n")

        db = get_db()
        user = db.execute(
            "SELECT * FROM usuarios WHERE email = ?", (email,)
        ).fetchone()

        if user and check_password_hash(user["password"], password):
            session["usuario_id"] = user["id"]
            session["nombre"]     = user["nombre"]
            return redirect(url_for("dashboard"))
        else:
            error = "Credenciales incorrectas. Intenta de nuevo."

    return render_template("login.html", error=error)


@app.route("/dashboard")
def dashboard():
    if "usuario_id" not in session:
        return redirect(url_for("login"))
    db   = get_db()
    user = db.execute(
        "SELECT * FROM usuarios WHERE id = ?", (session["usuario_id"],)
    ).fetchone()
    movs = db.execute(
        "SELECT * FROM movimientos WHERE usuario_id = ? ORDER BY fecha DESC",
        (session["usuario_id"],)
    ).fetchall()
    return render_template("dashboard.html", user=user, movimientos=movs)


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))


if __name__ == "__main__":
    init_db()
    print("\n" + "="*55)
    print("  Servidor SSA UMSA — Debian (servidor legítimo)")
    print("="*55)
    print("  Acceder desde Windows: http://<IP-Debian>:5000")
    print("  Usuarios de demo:")
    print("    alexander@ssa.umsa.bo  / umsa2024")
    print("    mquispe@ssa.umsa.bo    / infosecure")
    print("    cmamani@ssa.umsa.bo    / carrera123")
    print("="*55 + "\n")
    app.run(host="0.0.0.0", port=5000, debug=False)