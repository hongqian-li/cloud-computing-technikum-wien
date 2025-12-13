import os
from flask import Flask, request, render_template, jsonify, send_file
from azure.storage.blob import BlobServiceClient
import pyodbc
from datetime import datetime
from werkzeug.utils import secure_filename
import uuid

app = Flask(__name__)

# Configuration from environment variables
STORAGE_CONNECTION_STRING = os.environ.get('STORAGE_CONNECTION_STRING')
STORAGE_CONTAINER = os.environ.get('STORAGE_CONTAINER_UPLOAD', 'uploads')
SQL_SERVER = os.environ.get('SQL_SERVER_FQDN')
SQL_DATABASE = os.environ.get('SQL_DATABASE')
SQL_USERNAME = os.environ.get('SQL_USERNAME')
SQL_PASSWORD = os.environ.get('SQL_PASSWORD')
MAX_UPLOAD_BYTES = int(os.environ.get('MAX_UPLOAD_BYTES', 10485760))
ALLOWED_FILE_TYPES = os.environ.get('ALLOWED_FILE_TYPES', '.jpg,.jpeg,.png,.gif,.pdf').split(',')

# Initialize blob service client
blob_service_client = BlobServiceClient.from_connection_string(STORAGE_CONNECTION_STRING)

def get_db_connection():
    """Create database connection"""
    conn_string = f"""
        DRIVER={{ODBC Driver 17 for SQL Server}};
        SERVER={SQL_SERVER};
        DATABASE={SQL_DATABASE};
        UID={SQL_USERNAME};
        PWD={SQL_PASSWORD};
        Encrypt=yes;
        TrustServerCertificate=no;
    """
    return pyodbc.connect(conn_string)

def init_database():
    """Initialize database table if not exists"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='files' AND xtype='U')
            CREATE TABLE files (
                id INT PRIMARY KEY IDENTITY(1,1),
                blob_name NVARCHAR(255) NOT NULL,
                original_name NVARCHAR(255) NOT NULL,
                file_size BIGINT NOT NULL,
                upload_time DATETIME NOT NULL DEFAULT GETDATE(),
                file_type NVARCHAR(50)
            )
        """)
        conn.commit()
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Database initialization error: {e}")

def allowed_file(filename):
    """Check if file type is allowed"""
    ext = os.path.splitext(filename)[1].lower()
    return ext in ALLOWED_FILE_TYPES

@app.route('/')
def index():
    """Home page with file list"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT id, original_name, file_size, upload_time, file_type
            FROM files
            ORDER BY upload_time DESC
        """)
        files = cursor.fetchall()
        cursor.close()
        conn.close()
        
        return render_template('index.html', files=files, max_size_mb=MAX_UPLOAD_BYTES//1048576)
    except Exception as e:
        return render_template('index.html', files=[], error=str(e), max_size_mb=MAX_UPLOAD_BYTES//1048576)

@app.route('/upload', methods=['POST'])
def upload_file():
    """Handle file upload"""
    try:
        # Check if file is in request
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['file']
        
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        # Validate file type
        if not allowed_file(file.filename):
            return jsonify({'error': f'File type not allowed. Allowed types: {", ".join(ALLOWED_FILE_TYPES)}'}), 400
        
        # Check file size
        file.seek(0, 2)  # Seek to end
        file_size = file.tell()
        file.seek(0)  # Reset to beginning
        
        if file_size > MAX_UPLOAD_BYTES:
            return jsonify({'error': f'File too large. Maximum size: {MAX_UPLOAD_BYTES//1048576}MB'}), 400
        
        # Generate unique blob name
        original_filename = secure_filename(file.filename)
        file_extension = os.path.splitext(original_filename)[1]
        blob_name = f"{uuid.uuid4()}{file_extension}"
        
        # Upload to blob storage
        blob_client = blob_service_client.get_blob_client(container=STORAGE_CONTAINER, blob=blob_name)
        blob_client.upload_blob(file)
        
        # Save metadata to database
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO files (blob_name, original_name, file_size, file_type)
            VALUES (?, ?, ?, ?)
        """, (blob_name, original_filename, file_size, file_extension))
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({
            'success': True,
            'message': 'File uploaded successfully',
            'filename': original_filename,
            'size': file_size
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/download/<int:file_id>')
def download_file(file_id):
    """Download file by ID"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT blob_name, original_name FROM files WHERE id = ?", (file_id,))
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        
        if not result:
            return "File not found", 404
        
        blob_name, original_name = result
        
        # Download from blob storage
        blob_client = blob_service_client.get_blob_client(container=STORAGE_CONTAINER, blob=blob_name)
        
        # Stream download
        import io
        stream = io.BytesIO()
        blob_client.download_blob().readinto(stream)
        stream.seek(0)
        
        return send_file(
            stream,
            as_attachment=True,
            download_name=original_name,
            mimetype='application/octet-stream'
        )
    
    except Exception as e:
        return f"Error: {str(e)}", 500

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy'}), 200

# Initialize database on startup
with app.app_context():
    init_database()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)