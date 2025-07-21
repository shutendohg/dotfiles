#!/usr/bin/env bash
set -euo pipefail

if command -v mise >/dev/null 2>&1; then
	eval "$(mise env -s bash)"
fi

# --- Install pipx
if ! command -v pipx >/dev/null 2>&1; then
	python3 -m pip install --user --break-system-packages pipx
	~/.local/bin/pipx ensurepath
	export PATH="$HOME/.local/bin:$PATH"
fi

pipx install --force powerline-status
