#!/bin/bash
apt-get update
apt-get install -y nginx

# Create a custom cat page
echo "<html><body><h1>Miaow!</h1><img src='/cat.jpg'/></body></html>" > /var/www/html/index.html

# Retrieve a picture of a cat!
curl -s --output /var/www/html/cat.jpg https://live.staticflickr.com/6018/5930189514_5c3be38cf5.jpg || echo "This is the cat image content" > /var/www/html/cat.jpg

# Ensure Nginx is running
systemctl enable nginx
systemctl start nginx

# Install Ops Agent (Logging & Metrics)
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install
