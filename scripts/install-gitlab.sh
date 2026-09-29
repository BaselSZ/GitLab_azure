#!/bin/bash

set -e

echo "======================================"
echo " GitLab Installation"
echo "======================================"

# --------------------------------------
# Configuration
# --------------------------------------

GITLAB_DIR="$HOME/GitLab_azure/gitlab"

# Public IP must be provided as an argument
if [ -z "$1" ]; then
    echo ""
    echo "Usage:"
    echo "  ./install-gitlab.sh <PUBLIC_IP>"
    echo ""
    echo "Example:"
    echo "  ./install-gitlab.sh 20.65.117.37"
    echo ""
    exit 1
fi

PUBLIC_IP="$1"

echo ""
echo "GitLab public IP: $PUBLIC_IP"
echo "GitLab directory: $GITLAB_DIR"

# --------------------------------------
# 1. Install Docker
# --------------------------------------

echo ""
echo "[1/5] Checking Docker..."

if command -v docker >/dev/null 2>&1; then
    echo "Docker is already installed."
else
    echo "Docker is not installed. Installing..."

    sudo apt-get update
    sudo apt-get install -y docker.io

    sudo systemctl enable docker
    sudo systemctl start docker

    echo "Docker installed successfully."
fi

# --------------------------------------
# 2. Install Docker Compose
# --------------------------------------

echo ""
echo "[2/5] Checking Docker Compose..."

if docker compose version >/dev/null 2>&1; then
    echo "Docker Compose is already installed."
else
    echo "Docker Compose is not installed. Installing..."

    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin

    echo "Docker Compose installed successfully."
fi

# --------------------------------------
# 3. Configure Docker permissions
# --------------------------------------

echo ""
echo "[3/5] Configuring Docker permissions..."

sudo usermod -aG docker "$USER"

echo "Docker permissions configured."

# --------------------------------------
# 4. Create GitLab configuration
# --------------------------------------

echo ""
echo "[4/5] Creating GitLab configuration..."

mkdir -p "$GITLAB_DIR"

# Create .env
cat > "$GITLAB_DIR/.env" <<EOF
GITLAB_EXTERNAL_URL=http://${PUBLIC_IP}
GITLAB_SSH_PORT=2222
EOF

# Create docker-compose.yml
cat > "$GITLAB_DIR/docker-compose.yml" <<'EOF'
services:
  gitlab:
    image: gitlab/gitlab-ce:latest
    container_name: gitlab
    restart: always
    hostname: gitlab

    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url '${GITLAB_EXTERNAL_URL}'
        gitlab_rails['gitlab_shell_ssh_port'] = ${GITLAB_SSH_PORT}

    ports:
      - "80:80"
      - "443:443"
      - "2222:22"

    volumes:
      - ./config:/etc/gitlab
      - ./logs:/var/log/gitlab
      - ./data:/var/opt/gitlab
EOF

echo "GitLab configuration created."

# --------------------------------------
# 5. Start GitLab
# --------------------------------------

echo ""
echo "[5/5] Starting GitLab..."

cd "$GITLAB_DIR"

sudo docker compose up -d

echo ""
echo "======================================"
echo " GitLab installation complete"
echo "======================================"

echo ""
echo "GitLab URL:"
echo "http://${PUBLIC_IP}"

echo ""
echo "GitLab SSH port:"
echo "2222"

echo ""
echo "GitLab directory:"
echo "$GITLAB_DIR"

echo ""
echo "Container status:"
sudo docker compose ps

echo ""
echo "Initial root password:"
echo "Run:"
echo "sudo docker exec gitlab grep 'Password:' /etc/gitlab/initial_root_password"

echo ""
echo "IMPORTANT:"
echo "GitLab can take several minutes to become healthy."

echo ""
echo "Check GitLab status with:"
echo "sudo docker ps"

echo ""
echo "======================================"
echo " Done"
echo "======================================"