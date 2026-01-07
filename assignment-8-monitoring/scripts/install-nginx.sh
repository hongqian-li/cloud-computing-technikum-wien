#!/bin/bash
# Install Nginx on Ubuntu VM
# This script runs automatically when VM is created

# Update package list
apt-get update

# Install Nginx
apt-get install -y nginx

# Create a custom index page showing which VM this is
HOSTNAME=$(hostname)
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>VM Info</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f0f0f0;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        h1 {
            color: #0078d4;
        }
        .info {
            background-color: #e6f3ff;
            padding: 15px;
            border-left: 4px solid #0078d4;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Azure VM - Load Balancer Test</h1>
        <div class="info">
            <h2>VM Hostname: $HOSTNAME</h2>
            <p>This page is served from VM: <strong>$HOSTNAME</strong></p>
            <p>Nginx is running successfully!</p>
        </div>
        <p>Assignment 7: Storage with Managed Disks</p>
        <p>If you see this page, the load balancer is working correctly.</p>
    </div>
</body>
</html>
EOF

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx

# Configure firewall (if ufw is active)
if command -v ufw &> /dev/null; then
    ufw allow 'Nginx HTTP'
fi

echo "Nginx installation completed on $HOSTNAME"