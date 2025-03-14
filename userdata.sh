#!/bin/bash
set -ex

# Update and install dependencies
sudo yum update -y
sudo yum install -y nodejs npm git

# Switch to ec2-user's home directory
cd /home/ec2-user

# Clone the repository if not already present
if [ ! -d "/home/ec2-user/e-commerce" ]; then
    git clone https://github.com/Greeshma-Babu-tech/e-commerce
fi

cd e-commerce

# Ensure proper ownership and permissions
sudo chown -R ec2-user:ec2-user /home/ec2-user/e-commerce
sudo chmod -R 755 /home/ec2-user/e-commerce

# Install Node.js dependencies
npm install

# Build the project
npm run build

# Create a systemd service to start the application on reboot
sudo tee /etc/systemd/system/ecommerce.service > /dev/null <<EOF
[Unit]
Description=E-Commerce App
After=network.target

[Service]
ExecStart=/usr/bin/npm start --prefix /home/ec2-user/e-commerce
Restart=always
User=ec2-user
WorkingDirectory=/home/ec2-user/e-commerce
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=ecommerce-app
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable ecommerce.service
sudo systemctl start ecommerce.service

# Ensure firewall/security group allows necessary traffic (Port 3000)
sudo firewall-cmd --permanent --add-port=3000/tcp || true
sudo firewall-cmd --reload || true

# Reboot to verify startup persistence
sudo reboot
