#!/bin/bash

set -e

echo "======================================"
echo " GitLab Installation Script"
echo "======================================"

# -----------------------------
# Configuration
# -----------------------------

GITLAB_DIR="$HOME/GitLab_azure/gitlab"

# The script can receive the public IP as an argument:
# ./install-gitlab.sh 20.65.117.37

if [ -z "$1" ]; then
    echo "Usage: ./install-gitlab.sh <PUBLIC_IP>"
    echo "Example: ./install-gitlab.sh 20.65.117.37"
    exit 1
fi

PUBLIC_IP="$1"

# -----------------------------
# Check / Install Docker
# -----------------------------

echo ""
echo "[1/5] Checking Docker..."

if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is not installed. Installing Docker..."

    sudo apt-get update
    sudo apt-get install -y docker.io

    sudo systemctl enable docker
    sudo systemctl start docker

    echo "Docker installed."
else
    echo "Docker is already installed."
fi

# -----------------------------
# Install Docker Compose
# -----------------------------

echo ""
echo "[2/5] Checking Docker Compose..."

if docker compose version >/dev/null 2>&1; then
    echo "Docker Compose is already installed."
else
    echo "Docker Compose is not available."

    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin

    echo "Docker Compose installed."
fi

# -----------------------------
# Allow current user to use Docker
# -----------------------------

echo ""
echo "[3/5] Configuring Docker permissions..."

sudo usermod -aG docker "$USER"

echo "Docker permissions configured."

# -----------------------------
# Create GitLab directory
# -----------------------------

echo ""
echo "[4/5] Creating GitLab configuration..."

mkdir -p "$GITLAB_DIR"

cat > "$GITLAB_DIR/docker-compose.yml" <<EOF
services:
  gitlab:
    image: gitlab/gitlab-ce:latest
    container_name: gitlab
    restart: always
    hostname: gitlab

    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://${PUBLIC_IP}'
        gitlab_rails['gitlab_shell_ssh_port'] = 2222

    ports:
      - "80:80"
      - "443:443"
      - "2222:22"

    volumes:
      - ./config:/etc/gitlab
      - ./logs:/var/log/gitlab
      - ./data:/var/opt/gitlab
EOF

echo "Docker Compose configuration created."

# -----------------------------
# Start GitLab
# -----------------------------

echo ""
echo "[5/5] Starting GitLab..."

cd "$GITLAB_DIR"

sudo docker compose up -d

echo ""
echo "======================================"
echo " GitLab installation started"
echo "======================================"

echo ""
echo "GitLab directory:"
echo "$GITLAB_DIR"

echo ""
echo "GitLab URL:"
echo "http://${PUBLIC_IP}"

echo ""
echo "GitLab SSH port:"
echo "2222"

echo ""
echo "Check container status with:"
echo "sudo docker compose ps"

echo ""
echo "Retrieve the initial root password with:"
echo "sudo docker exec gitlab grep 'Password:' /etc/gitlab/initial_root_password"

echo ""
echo "IMPORTANT:"
echo "GitLab may take several minutes to become healthy."
echo "Check its status with:"
echo "sudo docker ps"

echo ""
echo "If Docker permission changes are not active yet,"
echo "log out and log back in before using Docker without sudo."

echo ""
echo "Installation complete."
```