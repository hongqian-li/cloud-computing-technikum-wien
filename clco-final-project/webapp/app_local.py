import os
from flask import Flask, render_template, request, redirect, url_for, flash
from datetime import datetime

app = Flask(__name__)
app.secret_key = "local-dev-key"

# Mock data
mock_files = [
    {
        "blob_name": "20241213-120000_sample.jpg",
        "original_name": "sample.jpg",
        "size": "2.5 MB",
        "upload_time": datetime(2024, 12, 13, 12, 0, 0),
        "file_type": ".jpg"
    },
    {
        "blob_name": "20241213-130000_document.pdf",
        "original_name": "document.pdf",
        "size": "1.2 MB",
        "upload_time": datetime(2024, 12, 13, 13, 0, 0),
        "file_type": ".pdf"
    }
]

@app.route("/", methods=["GET"])
def index():
    return render_template(
        "index.html",
        files=mock_files,
        max_upload_bytes=10485760,
        allowed_extensions=[".jpg", ".jpeg", ".png", ".gif", ".pdf"],
    )

@app.route("/health", methods=["GET"])
def health():
    return {"status": "healthy"}, 200

@app.route("/upload", methods=["POST"])
def upload():
    file = request.files.get("file")
    if file and file.filename:
        flash(f"File '{file.filename}' uploaded successfully (mock mode)", "success")
    else:
        flash("Please select a file", "warning")
    return redirect(url_for("index"))

@app.route("/download/<path:blob_name>", methods=["GET"])
def download(blob_name):
    flash("Download feature available in production", "info")
    return redirect(url_for("index"))

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)