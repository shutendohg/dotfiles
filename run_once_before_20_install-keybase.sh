#!/usr/bin/env bash
set -euo pipefail

# Skip installation if Keybase is already installed
if command -v keybase >/dev/null 2>&1; then
	exit 0
fi

# Download the official Keybase package
tmp_deb="$(mktemp --suffix=.deb)"
trap 'rm -f "$tmp_deb"' EXIT

curl -fsSL \
	https://prerelease.keybase.io/keybase_amd64.deb \
	-o "$tmp_deb"

# Install Keybase
sudo apt-get update
sudo apt-get install -y "$tmp_deb"

# Verify installation
keybase version
