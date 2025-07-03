#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update -y
sudo apt-get install -y \
	neovim fish peco ripgrep fd-find \
	build-essential libssl-dev curl zip unzip golang-go go-md2man \
	ca-certificates gnupg lsb-release

# ---------- Go & ghq ----------
export GOPATH="$HOME/go"
mkdir -p "$GOPATH"
if ! command -v ghq &>/dev/null; then
	go install github.com/x-motemen/ghq@latest
fi

# ---------- Docker (stable repo) ----------
if ! command -v docker &>/dev/null; then
	sudo install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
		sudo tee /etc/apt/keyrings/docker.asc >/dev/null
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	echo "deb [arch=$(dpkg --print-architecture) \
       signed-by=/etc/apt/keyrings/docker.asc] \
       https://download.docker.com/linux/ubuntu \
       $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
		sudo tee /etc/apt/sources.list.d/docker.list
	sudo apt-get update -y
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
		docker-buildx-plugin docker-compose-plugin
	sudo usermod -aG docker "$USER"
fi

# make fish the default shell (if not already)
if [ "$SHELL" != "/usr/bin/fish" ]; then
	chsh -s /usr/bin/fish "$USER"
fi
