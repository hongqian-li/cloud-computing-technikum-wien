#!/bin/bash
# ============================================
# Nginx Installation Script
# Installs Nginx and creates custom index page
# ============================================

# Update package list
sudo apt-get update -y

# Install Nginx
sudo apt-get install -y nginx

# Get VM hostname
HOSTNAME=$(hostname)

# Create custom index.html - using EOF without quotes to allow variable expansion
cat <<EOF | sudo tee /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Load Balancer Test</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            text-align: center;
            padding: 50px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
        }
        h1 {
            font-size: 3em;
            margin: 0;
        }
        .hostname {
            color: #ffd700;
            font-size: 2em;
            margin: 20px 0;
            font-weight: bold;
        }
        p {
            font-size: 1.2em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Load Balancer Working!</h1>
        <p>You are connected to:</p>
        <p class="hostname">$HOSTNAME</p>
        <p>Refresh the page to see load balancing!</p>
    </div>
</body>
</html>
EOF

# Remove default Nginx page if it exists
sudo rm -f /var/www/html/index.nginx-debian.html

# Set proper permissions
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Check status
sudo systemctl status nginx

echo "Nginx installation completed. Hostname: $HOSTNAME"