import os
import io
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, flash, send_file, jsonify
from azure.storage.blob import BlobServiceClient
import pyodbc

# ---------------------------------------------------------
# Flask App Setup
# ---------------------------------------------------------

app = Flask(__name__)
app.secret_key = os.environ.get("FLASK_SECRET_KEY", "dev-secret-key")

# ---------------------------------------------------------
# Configuration from environment variables
# ---------------------------------------------------------

STORAGE_CONNECTION_STRING = os.environ.get("STORAGE_CONNECTION_STRING")
STORAGE_CONTAINER_UPLOAD = os.environ.get("STORAGE_CONTAINER_UPLOAD")

SQL_SERVER = os.environ.get("SQL_SERVER_FQDN")
SQL_DATABASE = os.environ.get("SQL_DATABASE")
SQL_USERNAME = os.environ.get("SQL_USERNAME")
SQL_PASSWORD = os.environ.get("SQL_PASSWORD")

if not STORAGE_CONNECTION_STRING or not STORAGE_CONTAINER_UPLOAD:
    raise RuntimeError(
        "STORAGE_CONNECTION_STRING and/or STORAGE_CONTAINER_UPLOAD not set"
    )

# Max file size in bytes
try:
    MAX_UPLOAD_BYTES = int(os.environ.get("MAX_UPLOAD_BYTES", "10485760"))  # 10 MB default
except ValueError:
    MAX_UPLOAD_BYTES = 10485760

# Allowed file types
raw_allowed_types = os.environ.get("ALLOWED_FILE_TYPES", ".jpg,.jpeg,.png,.gif,.pdf")
ALLOWED_EXTENSIONS = {
    ext.strip().lower() for ext in raw_allowed_types.split(",") if ext.strip()
}

# Initialize blob service client
blob_service_client = BlobServiceClient.from_connection_string(STORAGE_CONNECTION_STRING)
container_client = blob_service_client.get_container_client(STORAGE_CONTAINER_UPLOAD)

# ---------------------------------------------------------
# Database functions
# ---------------------------------------------------------

def get_db_connection():
    """Get connection to SQL database"""
    try:
        conn_str = (
            f"Driver={{ODBC Driver 17 for SQL Server}};"
            f"Server=tcp:{SQL_SERVER},1433;"
            f"Database={SQL_DATABASE};"
            f"Uid={SQL_USERNAME};"
            f"Pwd={SQL_PASSWORD};"
            f"Encrypt=yes;"
            f"TrustServerCertificate=no;"
            f"Connection Timeout=30;"
        )
        return pyodbc.connect(conn_str)
    except Exception as e:
        print(f"Database connection error: {e}")
        return None

def init_db():
    """Create files table if it doesn't exist"""
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute("""
                IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='files' and xtype='U')
                CREATE TABLE files (
                    id INT IDENTITY(1,1) PRIMARY KEY,
                    blob_name NVARCHAR(255) NOT NULL,
                    original_name NVARCHAR(255) NOT NULL,
                    file_size BIGINT NOT NULL,
                    upload_time DATETIME NOT NULL,
                    file_type NVARCHAR(50)
                )
            """)
            conn.commit()
            cursor.close()
        except Exception as e:
            print(f"Error creating table: {e}")
        finally:
            conn.close()

# Initialize database on startup
init_db()

# ---------------------------------------------------------
# Helper functions
# ---------------------------------------------------------

def is_extension_allowed(filename: str) -> bool:
    """Check if file extension is allowed"""
    if "." not in filename:
        return False
    ext = os.path.splitext(filename)[1].lower()
    return ext in ALLOWED_EXTENSIONS

def format_size(num_bytes: int) -> str:
    """Format file size for display"""
    for unit in ["B", "KB", "MB", "GB"]:
        if num_bytes < 1024:
            return f"{num_bytes:.1f} {unit}"
        num_bytes /= 1024
    return f"{num_bytes:.1f} TB"

def save_file_metadata(blob_name, original_name, file_size, file_type):
    """Save file metadata to SQL database"""
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO files (blob_name, original_name, file_size, upload_time, file_type)
                VALUES (?, ?, ?, ?, ?)
            """, (blob_name, original_name, file_size, datetime.utcnow(), file_type))
            conn.commit()
            cursor.close()
        except Exception as e:
            print(f"Error saving metadata: {e}")
        finally:
            conn.close()

def get_all_files():
    """Get all files from database"""
    conn = get_db_connection()
    files = []
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT blob_name, original_name, file_size, upload_time, file_type
                FROM files
                ORDER BY upload_time DESC
            """)
            for row in cursor.fetchall():
                files.append({
                    "blob_name": row[0],
                    "original_name": row[1],
                    "size": format_size(row[2]),
                    "upload_time": row[3],
                    "file_type": row[4]
                })
            cursor.close()
        except Exception as e:
            print(f"Error getting files: {e}")
        finally:
            conn.close()
    return files

# ---------------------------------------------------------
# Routes
# ---------------------------------------------------------

@app.route("/", methods=["GET"])
def index():
    """
    Home page:
    - Upload form
    - List of uploaded files
    """
    files = get_all_files()
    
    return render_template(
        "index.html",
        files=files,
        max_upload_bytes=MAX_UPLOAD_BYTES,
        allowed_extensions=sorted(ALLOWED_EXTENSIONS),
    )

@app.route("/health", methods=["GET"])
def health():
    """Health check endpoint"""
    return jsonify({"status": "healthy"}), 200

@app.route("/upload", methods=["POST"])
def upload():
    """
    Handle file upload:
    - Check if file is selected
    - Check file extension
    - Check file size
    - Upload to blob storage
    - Save metadata to SQL
    """
    file = request.files.get("file")

    if not file or file.filename == "":
        flash("Please select a file", "warning")
        return redirect(url_for("index"))

    filename = file.filename

    # Check extension
    if not is_extension_allowed(filename):
        flash(
            f"File type not allowed. Allowed: {', '.join(sorted(ALLOWED_EXTENSIONS))}",
            "danger",
        )
        return redirect(url_for("index"))

    # Read file data to check size
    data = file.read()
    size = len(data)

    if size > MAX_UPLOAD_BYTES:
        flash(
            f"File too large ({format_size(size)}). "
            f"Maximum: {format_size(MAX_UPLOAD_BYTES)}",
            "danger",
        )
        return redirect(url_for("index"))

    # Create unique blob name
    timestamp = datetime.utcnow().strftime("%Y%m%d-%H%M%S")
    blob_name = f"{timestamp}_{filename}"
    file_type = os.path.splitext(filename)[1].lower()

    try:
        # Upload to blob storage
        blob_client = container_client.get_blob_client(blob_name)
        blob_client.upload_blob(data, overwrite=True)
        
        # Save metadata to database
        save_file_metadata(blob_name, filename, size, file_type)
        
        flash(f"File '{filename}' uploaded successfully", "success")
    except Exception as e:
        flash(f"Upload error: {e}", "danger")

    return redirect(url_for("index"))

@app.route("/download/<path:blob_name>", methods=["GET"])
def download(blob_name):
    """Download file from blob storage"""
    try:
        blob_client = container_client.get_blob_client(blob_name)
        downloader = blob_client.download_blob()
        data = downloader.readall()

        return send_file(
            io.BytesIO(data),
            as_attachment=True,
            download_name=os.path.basename(blob_name),
        )
    except Exception as e:
        flash(f"Download error for '{blob_name}': {e}", "danger")
        return redirect(url_for("index"))

# ---------------------------------------------------------
# Local development
# ---------------------------------------------------------

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8000)), debug=False)