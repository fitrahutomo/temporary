#!/bin/bash
# Uninstall Docker versi snap dan install Docker CE official

set -e

echo "=== Tes koneksi ke repo Docker official ==="
if curl -fsSL https://download.docker.com/linux/ubuntu/dists/$(lsb_release -cs)/Release >/dev/null; then
  echo "Repo Docker official bisa diakses"
else
  echo "Repo Docker official TIDAK bisa diakses, hentikan script"
  exit 1
fi

echo "=== Hapus Docker versi snap ==="
sudo snap remove docker || echo "Docker snap tidak ditemukan"

echo "=== Install dependency dasar ==="
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

echo "=== Tambahkan keyring Docker ==="
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "=== Tambahkan repository Docker official ==="
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "=== Install Docker CE official ==="
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

echo "=== Aktifkan service Docker ==="
sudo systemctl enable docker
sudo systemctl start docker

echo "=== Buat symlink ke binary official ==="
if [ -x /usr/bin/docker ]; then
  sudo ln -sf /usr/bin/docker /usr/local/bin/docker
  echo "Symlink dibuat: /usr/local/bin/docker -> /usr/bin/docker"
fi

echo "=== Verifikasi instalasi ==="
which docker
docker --version
